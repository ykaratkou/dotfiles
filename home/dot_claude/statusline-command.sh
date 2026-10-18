#!/bin/sh
input=$(cat)

display_name=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
session_id=$(echo "$input" | jq -r '.session_id // empty')

# Color a percent value: green <50, yellow <80, red otherwise
color_pct() {
  pct=$1
  label=$2
  if [ "$pct" -lt 50 ]; then
    color="32" # green
  elif [ "$pct" -lt 80 ]; then
    color="33" # yellow
  else
    color="31" # red
  fi
  printf '\033[%sm%s\033[0m' "$color" "$label"
}

# Derive context window label from display_name (fall back to 200K)
case "$display_name" in
  *1M*|*1m*) ctx_label="1M" ;;
  *) ctx_label="200K" ;;
esac

# Derive short model family name from display_name
case "$display_name" in
  *Opus*)   family="Opus" ;;
  *Haiku*)  family="Haiku" ;;
  *Sonnet*) family="Sonnet" ;;
  *)        family="$display_name" ;;
esac

# Build context progress bar
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used_pct" ]; then
  pct_int=$(printf "%.0f" "$used_pct")
  filled=$(( pct_int / 10 ))
  # clamp to [0,10]
  [ "$filled" -lt 0 ] && filled=0
  [ "$filled" -gt 10 ] && filled=10
  empty=$(( 10 - filled ))
  bar=""
  i=0
  while [ "$i" -lt "$filled" ]; do
    bar="${bar}█"
    i=$(( i + 1 ))
  done
  i=0
  while [ "$i" -lt "$empty" ]; do
    bar="${bar}░"
    i=$(( i + 1 ))
  done
  pct_colored=$(color_pct "$pct_int" "${pct_int}%")
  ctx="[${bar}] ${pct_colored} (${ctx_label}, ${family})"
else
  ctx="[░░░░░░░░░░] --% (${ctx_label}, ${family})"
fi

# Rate limits
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

limits=""
if [ -n "$five" ]; then
  five_int=$(printf "%.0f" "$five")
  limits="5h:$(color_pct "$five_int" "${five_int}%")"
fi
if [ -n "$week" ]; then
  week_int=$(printf "%.0f" "$week")
  if [ -n "$limits" ]; then
    limits="$limits "
  fi
  limits="${limits}7d:$(color_pct "$week_int" "${week_int}%")"
fi

parts="$ctx"
if [ -n "$limits" ]; then
  parts="$parts | $limits"
fi
if [ -n "$session_id" ]; then
  parts="$parts | $session_id"
fi

printf "%s" "$parts"
