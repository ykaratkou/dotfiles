#!/usr/bin/env bash
# PreToolUse gate: wrap protected commands in `op run` and ask the human first.
#
# Claude's Bash tool starts a fresh non-interactive shell per call, so the fish
# aliases in fish/overrides.d/op.fish never apply. This hook does the same job:
# it finds protected commands anywhere in the pipeline, rewrites each one to run
# under `op run --`, and returns permissionDecision "ask" so the rewritten
# command is shown to the human for approval before anything executes.
#
# PROTECTED gates a command outright. PROTECTED_SUB gates one subcommand of an
# otherwise unremarkable tool, so `git commit` is wrapped while `git status`
# is left alone.
#
# Written for bash 3.2 (the /bin/bash macOS ships), so no associative arrays,
# `mapfile`, or `${var,,}`.

set -uo pipefail

PROTECTED=" yarn pnpm bundle terraform gh aws "
PROTECTED_SUB="|git commit|"
WRAPPER='op run -- '

pass_through() { printf '{}'; exit 0; }

# --- read the event -------------------------------------------------------

if ! command -v jq >/dev/null 2>&1; then
  echo "op-gate: jq not found, letting the command through ungated" >&2
  pass_through
fi

payload=$(cat)
[ -n "$payload" ] || pass_through

[ "$(printf '%s' "$payload" | jq -r '.tool_name // ""')" = "Bash" ] || pass_through

cmd=$(printf '%s' "$payload" | jq -r '.tool_input.command // ""')
case $cmd in
  *[!$' \t\n\r']*) ;;   # has at least one non-whitespace character
  *) pass_through ;;
esac

# --- pass 1: mark every quoted or escaped character -----------------------
#
# quoted[i]=1 when character i sits inside '...', "..." or `...`, or is the
# character a backslash escaped. Everything the later passes treat as shell
# syntax has to be unquoted, so this one table drives both of them.

len=${#cmd}
quoted=()
i=0
quote=""
while [ "$i" -lt "$len" ]; do
  c=${cmd:$i:1}
  if [ -n "$quote" ]; then
    quoted[$i]=1
    if [ "$quote" = "'" ]; then
      [ "$c" = "'" ] && quote=""
    elif [ "$c" = "\\" ] && [ $((i + 1)) -lt "$len" ]; then
      quoted[$((i + 1))]=1
      i=$((i + 2))
      continue
    elif [ "$c" = "$quote" ]; then
      quote=""
    fi
    i=$((i + 1))
    continue
  fi
  if [ "$c" = "\\" ] && [ $((i + 1)) -lt "$len" ]; then
    quoted[$i]=0
    quoted[$((i + 1))]=1
    i=$((i + 2))
    continue
  fi
  case $c in
    "'" | '"' | '`') quote=$c; quoted[$i]=1; i=$((i + 1)); continue ;;
  esac
  quoted[$i]=0
  i=$((i + 1))
done

# --- pass 2: find the separators between top-level commands ---------------
#
# "(" and ")" separate too, so a command substitution's body is inspected as
# its own segment: echo $(gh api user) gets wrapped inside the substitution.

break_starts=()
break_ends=()
i=0
while [ "$i" -lt "$len" ]; do
  if [ "${quoted[$i]}" = "0" ]; then
    two=${cmd:$i:2}
    if [ "$two" = "&&" ] || [ "$two" = "||" ]; then
      break_starts+=("$i")
      break_ends+=("$((i + 2))")
      i=$((i + 2))
      continue
    fi
    case ${cmd:$i:1} in
      ';' | '|' | '&' | '(' | ')' | $'\n')
        break_starts+=("$i")
        break_ends+=("$((i + 1))")
        i=$((i + 1))
        continue
        ;;
    esac
  fi
  i=$((i + 1))
done

# --- pass 3: decide what each segment actually runs ------------------------

hit_offsets=()
hit_names=()
seg_offs=()
seg_words=()
_bare=""

# Strip shell quoting from a word, so "yarn" and 'yarn' compare equal.
unquote() {
  local s=$1 n=${#1} out="" q="" k=0 ch
  while [ "$k" -lt "$n" ]; do
    ch=${s:$k:1}
    if [ -n "$q" ]; then
      if [ "$ch" = "$q" ]; then
        q=""
      elif [ "$ch" = "\\" ] && [ "$q" = '"' ] && [ $((k + 1)) -lt "$n" ]; then
        out=$out${s:$((k + 1)):1}
        k=$((k + 2))
        continue
      else
        out=$out$ch
      fi
    else
      case $ch in
        "'" | '"') q=$ch ;;
        "\\")
          if [ $((k + 1)) -lt "$n" ]; then
            out=$out${s:$((k + 1)):1}
            k=$((k + 2))
            continue
          fi
          out=$out$ch
          ;;
        *) out=$out$ch ;;
      esac
    fi
    k=$((k + 1))
  done
  _bare=$out
}

# Split one segment into unquoted words, keeping each word's offset in $cmd.
collect_words() {
  local seg_start=$1 seg_end=$2 word_start=-1 j c qz w
  seg_offs=()
  seg_words=()
  j=$seg_start
  while [ "$j" -le "$seg_end" ]; do
    if [ "$j" -eq "$seg_end" ]; then
      c=" "        # sentinel, so a word ending at the segment edge is flushed
      qz=0
    else
      c=${cmd:$j:1}
      qz=${quoted[$j]}
    fi
    if [ "$qz" = "0" ] && { [ "$c" = " " ] || [ "$c" = $'\t' ] || [ "$c" = $'\n' ] || [ "$c" = $'\r' ]; }; then
      if [ "$word_start" -ge 0 ]; then
        unquote "${cmd:$word_start:$((j - word_start))}"
        w=$_bare
        while [ -n "$w" ]; do
          case $w in
            '('* | '{'* | '!'*) w=${w:1} ;;
            *) break ;;
          esac
        done
        seg_offs+=("$word_start")
        seg_words+=("$w")
        word_start=-1
      fi
    elif [ "$word_start" -lt 0 ]; then
      word_start=$j
    fi
    j=$((j + 1))
  done
}

record_hit() {
  hit_offsets+=("$1")
  hit_names+=("$2")
}

# Find the segment's command word, then decide whether it needs the wrapper.
decide_segment() {
  local n=${#seg_words[@]} k=0 j w name base sub
  while [ "$k" -lt "$n" ]; do
    w=${seg_words[$k]}
    case $w in
      '' | '{' | '}' | '!') k=$((k + 1)); continue ;;
    esac
    case $w in
      *=*)
        name=${w%%=*}
        case $name in
          '' | *[!A-Za-z0-9_]*) ;;         # not a name: a real command
          *) k=$((k + 1)); continue ;;     # leading env assignment: skip past
        esac
        ;;
    esac
    break
  done
  [ "$k" -lt "$n" ] || return 0

  base=${seg_words[$k]}
  base=${base##*/}
  [ "$base" = "op" ] && return 0    # already wrapped, leave it alone

  case $PROTECTED in
    *" $base "*) record_hit "${seg_offs[$k]}" "$base"; return 0 ;;
  esac

  case $PROTECTED_SUB in
    *"|$base "*) ;;
    *) return 0 ;;
  esac

  # Only some subcommands are gated: walk past the global flags to find it.
  j=$((k + 1))
  while [ "$j" -lt "$n" ]; do
    case ${seg_words[$j]} in
      -C | -c) j=$((j + 2)); continue ;;   # git's two value-taking globals
      -*) j=$((j + 1)); continue ;;
    esac
    break
  done
  [ "$j" -lt "$n" ] || return 0

  sub=${seg_words[$j]}
  case $PROTECTED_SUB in
    *"|$base $sub|"*) record_hit "${seg_offs[$k]}" "$base $sub" ;;
  esac
}

seg_start=0
idx=0
breaks=${#break_starts[@]}
while : ; do
  if [ "$idx" -lt "$breaks" ]; then
    collect_words "$seg_start" "${break_starts[$idx]}"
    decide_segment
    seg_start=${break_ends[$idx]}
    idx=$((idx + 1))
  else
    collect_words "$seg_start" "$len"
    decide_segment
    break
  fi
done

hits=${#hit_offsets[@]}
[ "$hits" -gt 0 ] || pass_through

# --- pass 4: insert the wrapper, rightmost first --------------------------

updated=$cmd
k=$((hits - 1))
while [ "$k" -ge 0 ]; do
  off=${hit_offsets[$k]}
  updated=${updated:0:$off}$WRAPPER${updated:$off}
  k=$((k - 1))
done

if [ -n "${OP_GATE_DRY_RUN:-}" ]; then
  printf '%s' "$updated"
  exit 0
fi

# --- ask the human --------------------------------------------------------

names=$(printf '%s\n' "${hit_names[@]}" | sort -u | awk '{ out = out sep $0; sep = ", " } END { print out }')
reason="op-gate: $names needs 1Password secrets, so the command was rewrapped to run under \`op run\`. Approve to run:

    $updated"

printf '%s' "$payload" | jq -c \
  --arg cmd "$updated" \
  --arg reason "$reason" \
  '{
     hookSpecificOutput: {
       hookEventName: "PreToolUse",
       permissionDecision: "ask",
       permissionDecisionReason: $reason,
       updatedInput: ((.tool_input // {}) + { command: $cmd })
     }
   }'
