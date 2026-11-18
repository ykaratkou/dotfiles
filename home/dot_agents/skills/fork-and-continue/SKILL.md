---
name: fork-and-continue
description: Fork the current Claude Code conversation and continue its task in a new tmux window, or a split pane when explicitly requested.
---

# Fork and continue

1. Use the requested next task or the unfinished objective. Ask only if neither
   exists. Keep the current working directory. Read **spawn-agent** for tmux
   targeting, shell readiness, quoting, and startup checks. Use a new window by
   default, or a split pane only when explicitly requested. Confirm that the
   installed `claude --help` supports `--resume` and `--fork-session`.
2. Identify the exact source conversation. In Claude Code, the invoking session
   ID is `${CLAUDE_SESSION_ID}` (skill substitution, not a shell variable).
   If unavailable or unexpanded, read the caller's pane metadata:
   `tmux show-options -p -v -t "$TMUX_PANE" @muxify_agent_conversation`,
   checking that `@muxify_agent` is `claude`. Use an explicit user-supplied
   Claude session ID when forking from another harness. If no reliable ID is
   available, ask for it. Use the exact ID rather than the most recent session.
3. Stop this session's writes, including workers and background commands that
   change shared files. Inspect the working tree and note active processes for
   the recipient. Forking copies conversation history; both sessions share the
   same files and branch. Keep this session's writes stopped after launch.
4. Create a unique OS temporary directory and choose an absent acknowledgement
   file inside it. Prepare a short continuation prompt with absolute paths,
   the source session ID, the next task, and any active-process notes:

   > You are the recipient of a completed fork-and-continue launch. The source
   > agent has stopped editing. Check the repository instructions, working
   > directory, and working tree. Obtain your current session ID from your own
   > runtime metadata or your pane's @muxify_agent_conversation option, rather
   > than the source ID in the inherited conversation. Before changing project
   > files, write <acknowledgement-file> with your session ID, source session ID
   > <source-id>, absolute working directory, and concrete next action. Then
   > continue <next-task> within the existing authorization. This transfer is
   > complete; continue the task directly without invoking fork-and-continue
   > again.

5. Follow **spawn-agent**'s window or pane creation and launch mechanics, using
   this interactive command in place of its fresh-session command:

   ```sh
   env -u CLAUDECODE claude --resume "$source_session" --fork-session "$prompt"
   ```

   Quote each argument for the new pane's shell. The environment change applies
   only to the child command and removes Claude Code's nested-session marker.
   Preserve explicitly requested model and permission settings; otherwise use
   CLI defaults. This single command creates the fork and opens it interactively
   in the new window; no separate background session or attach step is needed.
   Keep focus unchanged unless requested, and retain the original window.
6. Within two minutes, inspect the acknowledgement and the new pane for startup
   errors, waiting at most ten seconds per check. Require a session ID different
   from the source, the expected directory, and a matching next action. Report
   the new session ID, tmux window and pane IDs, acknowledgement path, and next
   action, then end this turn.
7. If startup or acknowledgement fails, report the transfer as unconfirmed with
   its IDs and saved paths. Retain the new window or pane. Inspect or stop that
   instance before resuming writes or launching a replacement.
