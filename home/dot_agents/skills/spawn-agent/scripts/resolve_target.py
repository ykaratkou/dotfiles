#!/usr/bin/env python3
"""Resolve the caller's tmux location without trusting Codex's daemon environment."""

import argparse
import json
import os
import re
import subprocess
import sys


def run(*args):
    return subprocess.run(
        args, check=True, capture_output=True, text=True, timeout=10
    ).stdout.strip()


def resolve(explicit_target=None):
    thread = os.environ.get("CODEX_THREAD_ID") or os.environ.get("CODEX_SESSION_ID")
    if explicit_target:
        target = explicit_target
    elif thread:
        agents = json.loads(run("muxify", "agent", "list", "--json"))["agents"]
        matches = [
            item for item in agents
            if item.get("agent", {}).get("kind") == "codex"
            and item["agent"].get("conversation") == thread
        ]
        if len(matches) != 1:
            raise ValueError(
                f"Expected one tmux pane for Codex thread {thread}; found {len(matches)}. "
                "Supply an explicit tmux target."
            )
        target = matches[0]["pane_id"]
    else:
        target = os.environ.get("TMUX_PANE")
        if not target:
            raise ValueError("No caller pane is available. Supply an explicit tmux target.")

    location = run(
        "tmux", "display-message", "-p", "-t", target,
        "#{session_id} #{window_id} #{pane_id}",
    )
    # tmux can return success with empty fields for a nonexistent target.
    if not re.fullmatch(r"\$\d+ @\d+ %\d+", location):
        raise ValueError(f"tmux target {target!r} did not resolve to a live pane.")
    session, window, pane = location.split()
    return {"session_id": session, "window_id": window, "pane_id": pane}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--target", help="Explicit user-supplied tmux target")
    args = parser.parse_args()
    try:
        print(json.dumps(resolve(args.target)))
    except (OSError, subprocess.SubprocessError, ValueError, KeyError, TypeError) as error:
        print(f"Cannot resolve tmux target: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
