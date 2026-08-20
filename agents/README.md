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
