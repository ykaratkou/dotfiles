# Upstream skills

Some skills here are copied from other repos. This file records where each one came from,
the upstream commit it matches, and any local changes made on top. Each skill has its
own pin, so a single skill can be added or updated without touching the rest.

## Sources

| Source | Repo |
| --- | --- |
| `mattpocock` | https://github.com/mattpocock/skills |
| `cursor` | https://github.com/cursor/plugins |
| `glebglazov` | https://github.com/glebglazov/dotfiles |

## Skills

| Skill | Source | Upstream path | Pinned | Synced |
| --- | --- | --- | --- | --- |
| `codebase-design` | `mattpocock` | `skills/engineering/codebase-design` | `59db609` | 2026-10-27 |
| `domain-modeling` | `mattpocock` | `skills/engineering/domain-modeling` | `59db609` | 2026-10-27 |
| `grill-me` | `mattpocock` | `skills/productivity/grill-me` | `59db609` | 2026-10-27 |
| `grill-with-docs` | `mattpocock` | `skills/engineering/grill-with-docs` | `59db609` | 2026-10-27 |
| `grilling` | `mattpocock` | `skills/productivity/grilling` | `59db609` | 2026-10-27 |
| `handoff` | `mattpocock` | `skills/productivity/handoff` | `59db609` | 2026-10-27 |
| `improve-codebase-architecture` | `mattpocock` | `skills/engineering/improve-codebase-architecture` | `59db609` | 2026-10-27 |
| `pr` | `mattpocock` | `skills/engineering/pr` | `59db609` | 2026-10-27 |
| `prototype` | `mattpocock` | `skills/engineering/prototype` | `59db609` | 2026-10-27 |
| `setup-matt-pocock-skills` | `mattpocock` | `skills/engineering/setup-matt-pocock-skills` | `59db609` | 2026-10-27 |
| `to-spec` | `mattpocock` | `skills/engineering/to-spec` | `59db609` | 2026-10-27 |
| `to-tickets` | `mattpocock` | `skills/engineering/to-tickets` | `59db609` | 2026-10-27 |
| `wayfinder` | `mattpocock` | `skills/engineering/wayfinder` | `59db609` | 2026-10-27 |
| `unslop` | `cursor` | `pstack/skills/unslop` | `eb4db2b` | 2026-10-22 |
| `handoff-and-continue` | `glebglazov` | `home/dot_agents/skills/handoff-and-continue` | `f319dad` | 2026-10-29 |
| `spawn-agent` | `glebglazov` | `home/dot_agents/skills/spawn-agent` | `f319dad` | 2026-10-29 |

`Pinned` is the upstream commit the local copy is based on. `Synced` is the date it was
last ported.

Not synced from anywhere, so no pin: `agent-browser`, `auto-grill`, `auto-grill-improve`,
`auto-spec`, `lavish`, `lavish-code-review`.

## Local overrides

Local changes to upstream skills. A port keeps these changes, and the reason given here
is what you go by when an upstream change conflicts with one.

### handoff-and-continue

- `SKILL.md`: Keep only the tmux route; remove T3 Code launching and monitoring as requested.
- `SKILL.md`: Default to a new tmux window, pass through an explicit pane request, and report both window and pane IDs.

### spawn-agent

- `SKILL.md`: Create a new window in the target session by default; split a pane only when explicitly requested. Keep focus unchanged and report both IDs.

Record each override as:

```markdown
### <skill>

- `<file>`: what changed, and why.
```

## How to

Work in a temporary directory outside the repo (`tmp=$(mktemp -d)`). Do not commit or
run `chezmoi apply` unless asked. Finish by showing `chezmoi diff` and reporting what
changed.

### Port upstream changes

Do this for one source, several, or all of them, whichever the user asks for.

1. Clone the source: `git clone -q <repo> "$tmp/<source>"`. Then, for each skill in the
   table from that source:
2. List the changes: `git -C "$tmp/<source>" diff --stat -M <pinned> HEAD -- <path>`. If
   the path is missing at `HEAD`, upstream moved or renamed the skill. Find where it
   went, update `Upstream path`, and diff the old path against the new one.
3. For every file upstream modified, three-way merge it into the local copy:

   ```sh
   git -C "$tmp/<source>" show <pinned>:<path>/<file> > "$tmp/base"
   git -C "$tmp/<source>" show HEAD:<path>/<file> > "$tmp/new"
   git merge-file <local file> "$tmp/base" "$tmp/new"
   ```

   If the file has no local override, the merge leaves it identical to upstream. If it has
   one, the override is kept and the upstream change is applied around it. A non-zero
   exit code is the number of conflicts. Resolve them using the reason recorded under
   Local overrides, and ask the user if that reason doesn't settle it.
4. Files upstream added: copy them in. Files upstream deleted: delete them, and add their
   deployed path (for example `.agents/skills/<skill>/<file>`) to `home/.chezmoiremove`
   so `chezmoi apply` removes the copy in `~`. Treat a rename as a delete plus an add,
   and carry any override over to the new name.
5. Update `Pinned` and `Synced` for every skill you checked, including ones upstream
   left unchanged, so that all skills from a source end up on the same commit.
6. Report each skill's changes, any conflicts and how you resolved them, and any new
   upstream skills not installed here. Don't add those new skills unless asked.

### Add a skill from upstream

1. Clone the source (add it under Sources if it is new) and find the skill at `HEAD`.
2. Copy its directory to `home/dot_agents/skills/<skill>/` exactly as it is upstream,
   apart from the chezmoi file names described below.
3. Create `home/dot_claude/skills/symlink_<skill>` containing
   `../../.agents/skills/<skill>` so that Claude Code can find it.
4. Check whether the skill refers to other skills. Install those too, or tell the user
   which ones are missing.
5. Add a row to the Skills table, pinned to the commit you copied from.

### Change an upstream skill locally

Edit the file in place, then add a line under Local overrides giving the file, what you
changed, and why. Without that line, the next port can't tell your change from upstream
drift.

### Remove a skill

Delete its directory and its `symlink_<skill>` file, add `.agents/skills/<skill>` and
`.claude/skills/<skill>` to `home/.chezmoiremove`, and remove its row and any overrides
from this file.

### chezmoi file names

Local file names carry chezmoi prefixes that upstream names don't: an executable `run.sh`
becomes `executable_run.sh`, and `.foo` becomes `dot_foo`. Translate between the two
names when copying files in, merging them, or diffing local against upstream.
