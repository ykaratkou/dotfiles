#!/usr/bin/env python3
"""Launch an agent in tmux using an argv array, without a shell parsing its prompt."""

import argparse
import json
from pathlib import Path
import subprocess
import sys

from resolve_target import resolve


def launch(spec, target=None):
    argv = spec["argv"]
    if (not isinstance(argv, list) or not argv
            or not all(isinstance(arg, str) and "\0" not in arg for arg in argv)
            or not argv[0] or argv[0].startswith("-")):
        raise ValueError("argv must be a nonempty array of strings beginning with a command")
    directory = Path(spec["directory"])
    if not directory.is_absolute() or not directory.is_dir():
        raise ValueError("directory must be an existing absolute directory")
    layout = spec.get("layout", "window")
    if layout not in ("window", "pane"):
        raise ValueError("layout must be window or pane")
    location = resolve(target)
    if layout == "window":
        create = ["new-window", "-t", location["session_id"] + ":"]
    else:
        create = ["split-window", "-h", "-t", location["pane_id"]]
    # Multiple command arguments make tmux exec directly. env guarantees this
    # even for an argv containing only the executable name.
    command = ["tmux", *create, "-d", "-P", "-F", "#{window_id} #{pane_id}",
               "-c", str(directory), "--", "/usr/bin/env", *argv]
    result = subprocess.run(command, check=True, capture_output=True, text=True, timeout=10)
    window, pane = result.stdout.strip().split()
    return {"session_id": location["session_id"], "window_id": window,
            "pane_id": pane, "directory": str(directory), "layout": layout}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("spec", type=Path, help="JSON file with argv, directory, and optional layout")
    parser.add_argument("--target", help="Explicit user-supplied tmux target")
    args = parser.parse_args()
    try:
        spec = json.loads(args.spec.read_text())
        print(json.dumps(launch(spec, args.target)))
    except (OSError, subprocess.SubprocessError, ValueError, KeyError, TypeError) as error:
        print(f"Agent launch unconfirmed: {error}. Inspect tmux before retrying.", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
