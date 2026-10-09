# dotfiles

macOS dotfiles, managed with [chezmoi](https://www.chezmoi.io/). `chezmoi apply` copies
real files into `~`; the repo is the source of truth.

| Path | What it is |
| --- | --- |
| `home/` | chezmoi source state (set by `.chezmoiroot`). `home/dot_config/fish` deploys to `~/.config/fish`, and so on. |
| `Brewfile` | Homebrew packages and apps. |
| `.claude-plugin/`, `claude/plugins/` | Claude Code plugin marketplace. |
| `opencode/plugins/` | opencode plugins, loaded from the repo by path in `~/.config/opencode/opencode.json`. |
| `assets/` | App icons. |
| `.obsidian.vimrc` | Vim keymap for Obsidian. Copy it into a vault's root. |

## Install

```bash
git clone https://github.com/ykaratkou/dotfiles.git ~/.dotfiles
brew bundle --file ~/.dotfiles/Brewfile
chezmoi init --source ~/.dotfiles --apply
```

Before the last step, sign in to 1Password and turn on **Settings → Developer → Integrate
with 1Password CLI**: the first apply reads the commit-signing key `~/.ssh/personal.pub`
from 1Password. It also installs [mise](https://mise.jdx.dev) into `~/.local/bin` if it is
missing.

`init` writes `~/.config/chezmoi/chezmoi.toml` pointing at `~/.dotfiles`, so later
commands need no `--source`.

## Day to day

| Task | Command |
| --- | --- |
| Edit a config | `chezmoi edit --apply ~/.config/fish/config.fish`, or edit under `home/` and run `chezmoi apply` |
| Preview changes | `chezmoi diff` |
| Pull back changes an app made | `chezmoi re-add` |
| Track a new file | `chezmoi add ~/.config/foo/config.toml` |
| Open a shell in the repo | `chezmoi cd` |

These apps write to their own config, so they drift and need `chezmoi re-add`:
`~/.config/nvim/lazy-lock.json`, `~/.pi/agent/settings.json`, `~/.config/zed/settings.json`.

File names under `home/` use chezmoi's
[source state attributes](https://www.chezmoi.io/reference/source-state-attributes/):
`dot_` becomes `.`, `executable_` sets `+x`, `private_` drops group and world access,
`symlink_` holds a link target, and `create_` writes the file only if it is missing.

## Agent skills

Skills live in `home/dot_agents/skills/` and deploy to `~/.agents/skills/`. Claude Code
reads `~/.claude/skills/`, so every skill also needs a link there:
`home/dot_claude/skills/symlink_<name>`, containing `../../.agents/skills/<name>`.

The `lavish` skill hands HTML authoring to a `lavish-author` subagent, defined per tool in
`home/dot_claude/agents/` and `home/dot_config/opencode/agents/`. `agent-browser` needs
its CLI: `brew install agent-browser && agent-browser install`.

`agent-browser`, `lavish` and `lavish-code-review` are local. The rest are a curated subset
of [mattpocock/skills](https://github.com/mattpocock/skills), copied verbatim at `3cca18b`
(2026-09-04). To refresh them (this brings in every upstream skill, so prune afterwards):

```bash
git clone --depth 1 https://github.com/mattpocock/skills.git /tmp/mp-skills
cd ~/.dotfiles/home
for d in /tmp/mp-skills/skills/*/*/; do
  n=$(basename "$d")
  rm -rf "dot_agents/skills/$n"
  cp -R "$d" "dot_agents/skills/$n"
  echo "../../.agents/skills/$n" > "dot_claude/skills/symlink_$n"
done
```

## Claude Code plugins

The repo root is a Claude Code marketplace
([`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json)):

```bash
claude plugin marketplace add ~/.dotfiles
claude plugin install op-gate@dotfiles
```

| Plugin | What it does |
| --- | --- |
| [`op-gate`](claude/plugins/op-gate) | Gates `yarn`/`pnpm`/`bundle`/`terraform`/`gh`/`aws`/`git commit` behind `op run` plus a human approval, since Claude's Bash tool never sees the fish aliases. |

Installing copies the plugin into `~/.claude/plugins/cache/dotfiles/<plugin>/<version>/`,
so edits here don't run until you bump `version` in its `plugin.json` and run
`claude plugin update <plugin>` (a no-op while the version is unchanged). Then restart
Claude Code or run `/reload-plugins`. `claude plugin details <plugin>` shows what is
loaded.

## Manual setup

**Alacritty.** In System Settings → Keyboard → Keyboard Shortcuts → App Shortcuts, remap
Alacritty's "Hide Alacritty" to `Cmd+Shift+H`. For the icon, open Alacritty's Get Info
window and drag `assets/Alacritty.icns` onto the small icon at its top left.

**AWS through 1Password.** One section per profile in `~/.aws/credentials`:

```ini
[default]
region = us-east-1
credential_process = /Users/evgeny/.bin/op-aws-helper <vault> <secret>
```

**SSH agent forwarding.** `~/.ssh/rc` links `~/.ssh/ssh_auth_sock` to the forwarded agent
on each SSH login. Add these rules to `~/.ssh/config`, after any includes and host-specific
settings, so remote sessions use that agent and local ones keep using 1Password:

```sshconfig
Match exec "test -n \"$SSH_CONNECTION\""
  IdentityAgent ~/.ssh/ssh_auth_sock

Match all
  IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```

`~/.config/git/ssh-sign` makes the same choice when signing commits, so commits made over
SSH are still signed.
