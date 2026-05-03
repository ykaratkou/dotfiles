#!/usr/bin/env bash

if defaults read -g AppleInterfaceStyle &>/dev/null; then
  tmux source-file ~/.dotfiles/tmux/dracula-theme.conf

  fish -c "set -U macos_theme dark"
else
  tmux source-file ~/.dotfiles/tmux/rose-pine-light-theme.conf

  fish -c "set -U macos_theme light"
fi
