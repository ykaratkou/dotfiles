# Agent skills

Skills live in `skills/` and deploy to `~/.agents/skills/`. Claude Code reads
`~/.claude/skills/`, so every skill, whether local or copied from upstream, also needs a
link there: `home/dot_claude/skills/symlink_<name>`, containing
`../../.agents/skills/<name>`.

Most skills are copied from [mattpocock/skills](https://github.com/mattpocock/skills) and
[cursor/plugins](https://github.com/cursor/plugins). Before adding, updating, porting or
editing a skill, read [`skills/UPSTREAM.md`](skills/UPSTREAM.md). It lists each skill's
source, pinned commit and local overrides, and explains how to change them.

The `lavish` skill hands HTML authoring to a `lavish-author` subagent, defined per tool in
`home/dot_claude/agents/` and `home/dot_config/opencode/agents/`. `agent-browser` needs
its CLI: `brew install agent-browser && agent-browser install`.

Matt Pocock's domain docs now use `GLOSSARY.md` / `GLOSSARY-MAP.md`, not
`CONTEXT.md` / `CONTEXT-MAP.md`. Existing projects need those files renamed and their
pointers updated. The local auto-grill/auto-spec skills use the new names; old eval
snapshots remain readable.

This file, `CLAUDE.md` and `skills/UPSTREAM.md` are not deployed.
