#!/usr/bin/env bash

set -euo pipefail

SCRIPT_NAME="$(basename $0)"

if pgrep -qf "$SCRIPT_NAME"; then
	echo "$SCRIPT_NAME is already running, nothing to do here."
	exit 0
fi

while :; do
	dark-notify -c "tmux source-file ~/.tmux.conf"
done
