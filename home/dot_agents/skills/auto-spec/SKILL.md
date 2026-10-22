---
name: auto-spec
description: Turn a feature request into a published spec and tickets without user interaction, using auto-grill to resolve design questions.
argument-hint: <feature request>
disable-model-invocation: true
---

Request: $ARGUMENTS

If `$ARGUMENTS` is empty or unexpanded, use the invoking message's request, then the previous user message.

Run the grilling and domain-modeling workflow, then to-spec and to-tickets, with auto-grill answering for the user. Do not ask the user questions or wait for confirmation; this overrides dependent skills' interview and confirmation steps. Planning only: write only domain context files, ADRs, the feature folder and tracker issues.

Resolve dependent skills through the runtime's skill loader or installed skill directories (siblings of this skill). Use runtime tools and default models, not provider-specific commands or identifiers. Follow auto-grill's delegation and model-selection rules.

## 0. Set up

- Work from the git root of the current directory.
- Pick an unused kebab-case `<feature-slug>` under `.scratch/`. The feature folder is `.scratch/<feature-slug>/`; reuse the slug in skills and tracker docs.
- Find the tracker in `docs/agents/issue-tracker.md` or the `## Agent skills` block of the repository's agent instructions (e.g. `AGENTS.md`, `CLAUDE.md`). If absent, follow `setup-matt-pocock-skills/issue-tracker-local.md`; do not run setup. Read triage labels from `docs/agents/triage-labels.md` (default `ready-for-agent`) and the domain layout from `docs/agents/domain.md` (default root `GLOSSARY.md` and `docs/adr/`).

## 1. Grill (at most 5 rounds)

Read grilling, domain-modeling and auto-grill. Use auto-grill steps 1–3 for each round; this section replaces steps 4–5.

Each round:

1. Compute the frontier as grilling describes: numbered questions with recommended answers. Include only questions that would change the spec or tickets.
2. Run auto-grill steps 1–3: build the handoff without user hints, delegate to the answerer, and log the run.
3. Save the same handoff, report and context snapshot to `grill/round-<NN>/` in the feature folder as an auto-grill eval case:
   - `handoff.md`: the handoff, exactly (the text after `=== HANDOFF ===`);
   - `answers.md`: the answerer's report, verbatim;
   - `context/`: snapshot before applying answers, preserving paths (`context/GLOSSARY.md`, `context/docs/adr/…`); omit if empty;
   - `expected.md`: one line per question, `Q<n>: <Status from answers.md>  # answerer's label; flip it if it was wrong`;
   - `feedback.md`: the single line `TODO: what went wrong, in your words.`
4. Apply every answer:
   - ANSWERED: treat as a user reply.
   - JUDGEMENT: adopt the recommendation as an assumption. Record the decision, criterion (a–d), and fact that would change it.

   Update context and ADRs per domain-modeling. Write an ADR when its three criteria hold, except for assumptions.
5. Append the round to `grill/summary.md` in auto-grill's summary format, under a `## Round <NN>` heading: one line per question, `✓` for answered, `?` for assumed. When you create the file, start it with: "Each `round-<NN>/` folder is an auto-grill eval case: copy it to `auto-grill/evals/cases/<NNN>-<slug>/`, fix `expected.md`, and write `feedback.md`."

Stop when the frontier is empty or after round 5. Put remaining questions in the spec's Further Notes.

## 2. Spec

Read to-spec and follow it, except:

- Choose the test seams yourself and say why in Testing Decisions.
- Add `## Assumptions to review` after Out of Scope: one bullet per assumption, ending with what would change it.
- In Further Notes, list any questions still open and point to the feature folder's `grill/`.

## 3. Tickets

Read to-tickets and apply it to the published spec. Replace step 4's user quiz with one self-review for granularity, blocking edges, merges and splits; fix the draft and publish.

## 4. Report

End with:

- where the spec and tickets were published;
- the tickets, one line each: number, title, blocked by;
- the assumptions, one line each;
- any questions still open;
- the path to the feature folder's `grill/`.
