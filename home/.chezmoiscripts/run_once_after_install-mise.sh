#!/bin/sh
# fish activates mise from conf.d/mise.fish; bash and zsh need it in their rc files.
set -eu

if [ ! -x "$HOME/.local/bin/mise" ]; then
  curl https://mise.run | sh
fi

grep -qs 'mise activate bash' "$HOME/.bashrc" || echo 'eval "$(~/.local/bin/mise activate bash)"' >> "$HOME/.bashrc"
grep -qs 'mise activate zsh' "$HOME/.zshrc" || echo 'eval "$(~/.local/bin/mise activate zsh)"' >> "$HOME/.zshrc"
