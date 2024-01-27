# Install:

## Dependencies:

### MacOS:
```bash
brew install ~/.dotfiles
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
