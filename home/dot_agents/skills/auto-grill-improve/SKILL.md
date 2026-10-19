---
name: auto-grill-improve
description: Turn a bad /auto-grill run plus the user's feedback into an eval case, then improve the answerer until every case passes.
argument-hint: [run folder, or paste the questions + answers + your feedback]
disable-model-invocation: true
---

The skill under improvement is `~/.dotfiles/home/dot_agents/skills/auto-grill/` (the chezmoi source; run `chezmoi apply` after editing it). The prompt being tuned is its `ANSWERER.md`. Evals live in its `evals/` (read the docstring at the top of `evals/run.py` for the case format).

Input: $ARGUMENTS

## 1. Capture the case

- Find the run. If the input names a folder, use it. If the user pasted questions and answers, match them to a folder in `~/.local/state/auto-grill/runs/` (newest first, compare question titles). If nothing matches, build the case from the paste alone: write the handoff from the pasted questions, and ask for the repo path so you can snapshot `CONTEXT.md` and `docs/adr/`.
- Create `evals/cases/<NNN>-<slug>/` (next free number, slug from the topic). Copy in `handoff.md`, `answers.md` and `context/` from the run.
- Write `feedback.md`: the user's words verbatim, plus one line on what went wrong.
- Write `expected.md`: one line per question, `Q<n>: ANSWERED | JUDGEMENT | any  # why`. Take the labels from the feedback. Questions the feedback doesn't mention are `any`, unless the answer was plainly fine as given (then keep its label). Ask the user only when the feedback leaves a label truly unclear, and ask all unclear ones in one message.
- If the handoff itself was the problem (missing context, a question not copied verbatim), the fix belongs in `auto-grill/SKILL.md`, not `ANSWERER.md`. Say so, fix it there, and still keep the case.

## 2. Baseline

Configure `AUTO_GRILL_COMMAND` or `--command` with a read-only CLI/adapter for the active runtime and provider; follow `evals/run.py`'s command contract. Run `evals/run.py -n 3` (all cases, 3 runs each, since labels can flip). Use tracked background execution if available and wait for completion. Record the table.

## 3. Improve

- Read the failing outputs in `evals/results/<timestamp>/`. Work out *why* the answerer chose wrong: which rule it leaned on, or which rule was missing.
- Edit `ANSWERER.md` with a **general** rule: one that would also catch the next case like this. Never name a specific case, product or question in it. Prefer sharpening or replacing a rule to adding one; keep the prompt short.
- Re-run all cases with `-n 3`. Done when every graded label passes in every run. If a change fixes the new case but breaks an old one, the rule is too broad: rework it rather than trading one case for another.
- Stop after 3 attempts and report what's still failing, with your best guess why.

## 4. Report

Show:
- a before/after table (case, question, expected, got in each run);
- the `ANSWERER.md` diff;
- any `SKILL.md` change.

Don't commit. The user reviews and commits the dotfiles.
