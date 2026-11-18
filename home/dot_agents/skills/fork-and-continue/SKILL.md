---
name: fork-and-continue
description: Open a fork of the current Codex or Claude Code conversation in a new tmux window, waiting for user input unless an explicit task is supplied.
---

# Fork and continue

1. Default to an interactive fork waiting for the user's next message. Supply
   an initial prompt only when the user explicitly gives a task for the fork.
   An unfinished objective or the word "continue" in the skill name is not a
   request to start work automatically. Keep the current directory and harness.
   Read **spawn-agent** for tmux targeting and launch mechanics. Use a new window
   by default, or a split pane only when explicitly requested. Check
   `codex fork --help` or `claude --help` for the selected harness.
2. Identify the exact source conversation for the chosen harness:

   - **Codex:** read `CODEX_THREAD_ID` from the current tool environment, falling
     back to `CODEX_SESSION_ID`. Resolve the tmux target through **spawn-agent**'s
     helper, which matches the thread ID through Muxify. Codex's shared daemon
     can carry a stale `TMUX_PANE`; use the helper's returned pane ID.
   - **Claude Code:** the invoking session ID is `${CLAUDE_SESSION_ID}` (skill
     substitution, not a shell variable). If unavailable or unexpanded, read
     the caller's pane metadata:
     `tmux show-options -p -v -t "$TMUX_PANE" @muxify_agent_conversation`,
     checking that `@muxify_agent` is `claude`.

   Use an explicit user-supplied source ID when forking a conversation from
   another harness. If the harness or source ID is unknown, ask. Use the exact
   ID rather than the most recent session.
3. Stop this session's writes, including workers and background commands that
   change shared files. Forking copies conversation history; both sessions
   share the same files and branch. Keep this session's writes stopped after
   launch and leave the original window open.
4. Use **spawn-agent**'s JSON launch specification and `scripts/launch.py`, with
   the matching argv in place of its fresh-session command. Replace SOURCE_ID
   with the exact source ID:

   **Codex:**

   ```json
   ["codex", "fork", "SOURCE_ID"]
   ```

   **Claude Code:**

   ```json
   ["env", "-u", "CLAUDECODE", "claude", "--resume", "SOURCE_ID", "--fork-session"]
   ```

   For the default idle fork, use these arrays as written: omit the initial
   prompt entirely. Verify startup from the terminal and runtime metadata;
   create no acknowledgement task and send no synthetic user message.
   If the user explicitly supplied a task, append one prompt argument containing
   that task and a short note that this is the fork recipient, so it should do
   the task rather than repeat the fork operation.

   Write the argv using a JSON encoder or file-writing tool, then pass the
   specification to the launcher. Keep any task text out of shell command
   strings and `tmux send-keys`. For Claude Code, the environment change applies
   only to the child and removes its nested-session marker. Preserve explicitly
   requested model and permission settings; otherwise use CLI defaults. Keep
   focus unchanged unless requested.
5. Inspect the new pane for up to two minutes, waiting at most ten seconds per
   check. For an idle fork, require the interactive input prompt with the
   inherited conversation loaded. For an explicit task, require a response to
   that task. Use Muxify's conversation mapping or the new pane's runtime
   metadata to verify a session ID different from the source when available.
   If the new ID is not yet exposed, report startup as observed with identity
   unconfirmed; leave the fork waiting for input instead of sending a message
   just to obtain an ID. Report the harness, window and pane IDs, directory,
   observed session ID, and whether the fork is waiting or running a supplied
   task. End this turn.
6. If startup fails, report the transfer as unconfirmed with its IDs and saved
   paths. Inspect that instance before resuming writes or launching a replacement.
