---
name: auto-grill
description: Let a subagent answer the open domain-modeling questions instead of you
argument-hint: [optional hints, e.g. "treat edge-snap as one idea"]
disable-model-invocation: true
---

Take the questions you asked in your previous message in this domain-modeling session.

1. Build the handoff. The subagent starts with no memory of this conversation, so include:
   - the repo path;
   - the user's original request for this session, verbatim;
   - every decision already settled this session (one line each), including ones not yet in CONTEXT.md;
   - each open question verbatim, with the suggestion you made and the code facts you cited, as a numbered list;
   - these user hints, if any: $ARGUMENTS
2. Read [ANSWERER.md](ANSWERER.md) fresh (never from memory: it changes between runs). Launch a `general-purpose` subagent with `model: sonnet` whose prompt is the full ANSWERER.md text, then a line `=== HANDOFF ===`, then the handoff. Tell it to look up anything external (products, services, APIs) on the web rather than leaving it to me.
3. When it returns, log the run before anything else, so it can become an eval case later:
   - Create `~/.local/state/auto-grill/runs/<YYYYMMDD-HHMMSS>-<repo dir name>/`.
   - Write `handoff.md` (exactly the text after `=== HANDOFF ===`) and `answers.md` (the subagent's report, verbatim).
   - Copy `CONTEXT.md` (or `CONTEXT-MAP.md` and the contexts it lists) and `docs/adr/` into `context/` there, if they exist.
   - Do this silently: one Bash call, no narration.
4. Then:
   - Apply every ANSWERED answer exactly as if I had typed it: update CONTEXT.md and continue your normal domain-modeling process.
   - Do NOT apply JUDGEMENT answers. Wait for "ok", "ok except 2", or corrections on those.
   - If nothing is JUDGEMENT, don't wait: carry straight on.
   - End your message with a summary: one line per question, in question order, with the answer as a fact of at most 5 words. Mark applied answers `✓` and JUDGEMENT ones `?`, followed by what would change it, also in at most 5 words. No URLs, sources or notes (they're in the run log):
     ```
     Q1 ✓ TypeSafe: decision-model API
     Q3 ✓ Token in Keychain
     Q5 ? Leave Voice out · unless same release
     ```
5. After I confirm, carry on with the next batch of terms as usual.

If an answer looks wrong to me, I'll run `/auto-grill-improve` in a new session with the run folder and my feedback.
