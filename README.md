# Install:

## Dependencies:

### MacOS:
```bash
brew bundle --file=~/.dotfiles/Brewfile
```

Configure Alacritty:
1. Preferences -> Keyboard -> Keyboard shortcuts -> App shortcuts
2. Add shortcut override for Alacritty "Hide alacritty" to `Cmd + Shift + H`

### AWS + 1password
To make aws profiles works
```bash
# .aws/credentials
[default]
region = us-east-1
credential_process = <path-to op-aws-helper> <vault> <secret>

[other]
region = us-east-1
credential_process = <path-to op-aws-helper> <vault> <secret>
```

# Remote Machine

### SSH configuration
```bash
ln -s $HOME/.dotfiles/.ssh/rc $HOME/.ssh
```

Use the rules in `.ssh/config.sample` after any includes or host-specific SSH
settings. SSH sessions use the forwarded agent via `~/.ssh/ssh_auth_sock`;
local sessions keep using 1Password. Git's `git/ssh-sign` wrapper makes the
same choice for commit signing, so remote commits remain signed.
