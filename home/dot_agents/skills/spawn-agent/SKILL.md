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
   otherwise wait for the input prompt and paste through a tmux buffer.
3. Use tmux directly. Create a new **window** by default; split a **pane** only
   when the user explicitly requests a pane. Write a JSON launch specification
   in a unique OS temporary directory, using a file-writing tool or JSON encoder:

   ```json
   {"directory": "/absolute/project", "layout": "window", "argv": ["codex", "Read /absolute/task.md"]}
   ```

   `argv` holds the executable and each argument separately, including the
   entire prompt as one string. For a fork, use the caller's fork argv instead
   of a fresh-session command. Run
   `python3 <this-skill-directory>/scripts/launch.py <absolute-spec-file>`, adding
   `--target <target>` only for an explicit user-supplied tmux target. This helper
   launches the argv directly through tmux without shell interpretation or
   typing a command into fish. Keep prompt text in the JSON file, including
   apostrophes and shell metacharacters, rather than building a shell command
   string from the prompt.
   The helper uses `resolve_target.py`: Codex targets are matched by thread ID
   through Muxify because its daemon can carry a stale `TMUX_PANE`; other
   harnesses use their live pane. Read the returned JSON for session, window,
   and pane IDs. Focus stays unchanged. On failure, inspect tmux and report the
   error before retrying or asking for an explicit target. Use the returned
   pane ID for later operations; titles can change.
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
