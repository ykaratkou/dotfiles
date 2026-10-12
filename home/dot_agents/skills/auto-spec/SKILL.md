---
name: auto-spec
description: Take a feature request to a published spec and tickets without the user. Grills the design with the auto-grill answerer standing in for the user, then runs to-spec and to-tickets.
argument-hint: <what to build, in as much detail as you like>
disable-model-invocation: true
---

Request: $ARGUMENTS

If that line is empty or still shows a placeholder, the request is the rest of the message that invoked this skill (in opencode, the message containing `@auto-spec`), or else the user's previous message.

Run grill-with-docs, to-spec and to-tickets back to back, with the auto-grill answerer giving the user's answers. The user is not here: never ask them anything and never wait for a confirmation. Wherever a skill below says to check with, quiz or wait for the user, follow the override in this file instead. This is planning only: write nothing except `CONTEXT.md`, ADRs, the feature folder and tracker issues.

## 0. Set up

- Work from the git root of the current directory.
- Pick a `<feature-slug>`: short, kebab-case, not already used under `.scratch/`. The **feature folder** is `.scratch/<feature-slug>/`. Use this slug wherever a skill or tracker doc asks for one.
- Find the issue tracker in `docs/agents/issue-tracker.md` or the `## Agent skills` block of `CLAUDE.md` / `AGENTS.md`. If there is none, use local markdown: read `~/.agents/skills/setup-matt-pocock-skills/issue-tracker-local.md` and follow it. Never run setup. Likewise take triage labels from `docs/agents/triage-labels.md` (default `ready-for-agent`) and the domain doc layout from `docs/agents/domain.md` (default: one `CONTEXT.md` and `docs/adr/` at the root).

## 1. Grill (at most 5 rounds)

Read `~/.agents/skills/grilling/SKILL.md` and `~/.agents/skills/domain-modeling/SKILL.md`, and interview on the request as they describe. Also read `~/.agents/skills/auto-grill/SKILL.md`: its steps 1–3 are how each round gets answered. Skip its steps 4–5; this section replaces them.

Each round:

1. Compute the frontier and write the round as grilling describes: numbered questions, each with your recommended answer. Ask only questions whose answer would change the spec or the tickets.
2. Instead of waiting for the user, run auto-grill steps 1–3 on the round: build the handoff (there are no user hints), launch the answerer, and write its run log. In opencode, launch the answerer with the task tool and the `general` subagent.
3. In the same Bash call as the run log, save the round to the feature folder's `grill/round-<NN>/` as a ready-made auto-grill eval case, so the user can copy the folder into `auto-grill/evals/cases/` as is:
   - `handoff.md`: the handoff, exactly (the text after `=== HANDOFF ===`);
   - `answers.md`: the answerer's report, verbatim;
   - `context/`: the same snapshot as the run log's, taken before this round's answers are applied, with paths kept (`context/CONTEXT.md`, `context/docs/adr/…`); leave it out when there's nothing to copy;
   - `expected.md`: one line per question, `Q<n>: <Status from answers.md>  # answerer's label; flip it if it was wrong`;
   - `feedback.md`: the single line `TODO: what went wrong, in your words.`
4. Apply every answer:
   - ANSWERED: exactly as if the user had typed it.
   - JUDGEMENT: adopt the answerer's recommendation as an **assumption**. Keep a running list of each one: the decision, its criterion (a–d), and the fact that would change it.

   Update `CONTEXT.md` and ADRs as domain-modeling says. Where it says to offer an ADR, write the ADR yourself if all three criteria hold. Never write an ADR for an assumption.
5. Append the round to `grill/summary.md` in auto-grill's summary format, under a `## Round <NN>` heading: one line per question, `✓` for answered, `?` for assumed. When you create the file, start it with: "Each `round-<NN>/` folder is an auto-grill eval case: copy it to `auto-grill/evals/cases/<NNN>-<slug>/`, fix `expected.md`, and write `feedback.md`."

Stop when the frontier is empty or after round 5, whichever comes first. Don't wait for anyone to confirm a shared understanding. Questions still open after round 5 go into the spec's Further Notes.

## 2. Spec

Read `~/.agents/skills/to-spec/SKILL.md` and follow it, except:

- Choose the test seams yourself and say why in Testing Decisions.
- Add `## Assumptions to review` after Out of Scope: one bullet per assumption, ending with what would change it.
- In Further Notes, list any questions still open and point to the feature folder's `grill/`.

## 3. Tickets

Read `~/.agents/skills/to-tickets/SKILL.md` and follow it on the spec you just published, except step 4. Instead of quizzing the user, review the draft once against step 4's questions (granularity, blocking edges, merges and splits), fix what you find, and publish.

## 4. Report

End with:

- where the spec and tickets were published;
- the tickets, one line each: number, title, blocked by;
- the assumptions, one line each;
- any questions still open;
- the path to the feature folder's `grill/`.
