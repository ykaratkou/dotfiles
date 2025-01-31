#!/usr/bin/env bash

if defaults read -g AppleInterfaceStyle &>/dev/null; then
  tmux set -g @rose_pine_variant 'moon'
  fish -c "set -U macos_theme dark"
else
  tmux set -g @rose_pine_variant 'dawn'
  fish -c "set -U macos_theme light"
fi
