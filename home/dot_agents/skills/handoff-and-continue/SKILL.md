---
name: handoff-and-continue
description: Hand off the current task and start a fresh agent in a new tmux window by default, or a split pane when explicitly requested, without manually reopening it.
argument-hint: "[window|pane] [target harness] [next task]"
---

# Hand off and continue

1. Use the requested next task or the unfinished objective. Ask only if neither
   exists. Default to the current harness and directory. Create a new tmux
   window by default; use a split pane only when the user explicitly requests
   a pane. Check **spawn-agent**'s launch prerequisites before proceeding.
2. Stop this session's writes, including workers and background commands that
   change shared files. Inspect the resulting working tree. Invoke **handoff**
   for the next task, saving its document in a unique OS temporary directory.
   Include the absolute working directory, branch, uncommitted work, active
   processes, next action, and completion checks. Reference existing artifacts
   instead of copying them.
3. Choose an absent acknowledgement-file path beside the handoff. From now on,
   only monitor the transfer. Invoke **spawn-agent** with the chosen layout
   (window by default, pane only if explicitly requested) and this prompt,
   using absolute paths:

   > Read <handoff-file> and the repository instructions. Check the working
   > directory and working tree. Then write <acknowledgement-file> with the
   > handoff path, working directory, and concrete next action. Continue the
   > recorded task within its existing authorization. The previous agent has
   > stopped editing. You are the recipient; do not repeat the handoff.

4. Within two minutes, read the acknowledgement and check that it matches the
   handoff and next task. Check the recipient for startup errors in the pane.
   On success, report the layout, tmux window and pane IDs, handoff path, and
   next action, then end this turn. Retain the old window or pane and the
   files. Change focus only if requested.
5. If startup or acknowledgement fails, report the transfer as unconfirmed with
   its window and pane IDs and saved paths. Keep edits stopped while the recipient may run.
   Inspect or stop it before resuming writes or launching a replacement.
