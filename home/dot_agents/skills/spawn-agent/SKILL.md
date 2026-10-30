---
name: spawn-agent
description: Launch a coding agent in a new tmux window by default, or a split pane when explicitly requested, with an optional task or handoff file. Also used by handoff-and-continue.
argument-hint: "[window|pane] [harness] [directory] [task or handoff path]"
---

# Spawn an agent

1. Use the requested CLI and directory; default to the current harness and
   directory. If the harness is unknown, ask. Read the installed CLI's help to
   establish its fresh-session command and initial-prompt options. Report
   unsupported settings instead of guessing flags. Preserve requested model and
   permission settings; otherwise use CLI defaults. Launching alone does not
   authorize a permissions bypass.
2. Put a long task in a unique OS temporary file, or use the supplied handoff
   file. Pass a short prompt with its absolute path. Prefer CLI prompt options;
   otherwise wait for the input prompt and paste through a tmux buffer. Quote
   shell arguments; keep task text out of shell code.
3. Use tmux directly. Create a new **window** by default; split a **pane** only
   when the user explicitly requests a pane. Target the caller's `$TMUX_PANE`,
   or an explicit tmux target supplied by the user. If neither exists, ask for
   a target rather than choosing an unrelated session. Keep focus unchanged:
   - **Window (default):** resolve the target session with
     `tmux display-message -p -t "$target" '#{session_id}'`, then run
     `tmux new-window -d -P -F '#{window_id} #{pane_id}' -t "$target_session:" -c "$directory"`.
     Capture the returned window and pane IDs.
   - **Pane (explicit request):** resolve a target pane if necessary, then run
     `tmux split-window -h -d -P -F '#{window_id} #{pane_id}' -t "$target_pane" -c "$directory"`.
     Capture the returned window and pane IDs.
   If creation fails, report the error rather than switching layout or session.
   Wait for the new pane's shell to be ready, then send the quoted launch
   command with one leading space, so shell history skips it:
   `tmux send-keys -l -t "$pane_id" " $launch_command"`. Submit with
   `tmux send-keys -t "$pane_id" Enter`. Use the pane ID for all
   later operations; titles can change.
4. Check startup for up to two minutes, with waits of at most ten seconds.
   Require a task-specific response or the caller's acknowledgement file. For
   an empty session, require a ready input prompt. An echoed command is not
   evidence of startup. Report unresolved authentication or approval prompts.
5. Return the harness, layout (window or pane), window and pane IDs, directory,
   settings, and observed result. On failure or timeout, retain the created
   window or pane and prompt file. Inspect that pane before retrying; do not
   launch a duplicate.

If remote control was requested, discover its support from the installed CLI,
enable it, and return the link. Report when it is unsupported.
