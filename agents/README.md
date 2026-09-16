# Install

## Install the agent

```bash
brew install agent-browser
agent-browser install
```

## Install the skills

```bash
mkdir -p ~/.agents/skills
ln -s ~/.dotfiles/agents/skills/* ~/.agents/skills/
```

## Add a skill to Claude Code

Claude Code loads skills from `~/.claude/skills`. Symlink the ones you want individually:

```bash
mkdir -p ~/.claude/skills
ln -s ~/.dotfiles/agents/skills/* ~/.claude/skills/
```

## Provenance

Most skills here are copies of [mattpocock/skills](https://github.com/mattpocock/skills),
taken verbatim at `3cca18b` (2026-09-04) — all of `engineering/`, `productivity/`,
`misc/`, and `in-progress/`, flattened into `agents/skills/`. To refresh:

```bash
git clone --depth 1 https://github.com/mattpocock/skills.git /tmp/mp-skills
for d in /tmp/mp-skills/skills/*/*/; do
  n=$(basename "$d")
  rm -rf ~/.dotfiles/agents/skills/"$n"
  cp -R "$d" ~/.dotfiles/agents/skills/"$n"
done
```

`agent-browser`, `find-skills`, and `tds-jira-ticket` are local, not upstream.
