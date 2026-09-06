# op-gate

The fish aliases in [`fish/overrides.d/op.fish`](../../../fish/overrides.d/op.fish) wrap
secret-hungry tools in `op run`. Claude's Bash tool starts a fresh non-interactive shell
for every call, so those aliases never apply and the commands run without their
1Password-injected env.

This plugin closes that gap with a single `PreToolUse` hook on `Bash`:

1. It finds protected commands anywhere in the pipeline.
2. It rewrites each one to run under `op run --`.
3. It returns `permissionDecision: "ask"`, so Claude pauses and the rewritten command is
   shown for approval before anything executes.

Approve and the wrapped command runs. Reject and nothing does. In a context with no
interactive prompt (headless, `-p`), `ask` resolves to a denial — nothing runs unattended.

## Protected commands

Hard-coded at the top of [`hooks-handlers/op-gate.sh`](hooks-handlers/op-gate.sh):

- `PROTECTED` — gates the command outright: `yarn`, `pnpm`, `bundle`, `terraform`, `gh`,
  `aws`.
- `PROTECTED_SUB` — gates one subcommand of an otherwise unremarkable tool:
  `git commit`. `git status` and `git push` stay ungated. Global flags are walked past,
  so `git -C /repo commit` and `git --no-pager commit` are both caught.

`op.fish` covers only the `PROTECTED` names, and wraps them with `--no-masking`; this
plugin uses a plain `op run --`. Adding a seventh entry means editing both files.

## What it catches

| Claude asks for | Approval prompt shows |
| --- | --- |
| `yarn install` | `op run -- yarn install` |
| `cd apps/web && yarn build` | `cd apps/web && op run -- yarn build` |
| `NODE_ENV=production yarn build` | `NODE_ENV=production op run -- yarn build` |
| `yarn a && pnpm b` | both segments wrapped independently |
| `echo $(gh api user)` | `echo $(op run -- gh api user)` |
| `git add -A && git commit -m x` | `git add -A && op run -- git commit -m x` |

Wrapping is per-segment, so `cd` still affects the persistent Bash session.

Left alone: quoted mentions (`echo 'run yarn install'`, `git commit -m 'use yarn'`),
commands already under `op`, and anything where the protected name is an argument rather
than the command word (`npx yarn install`, `find … -exec terraform fmt`). A miss means the
command runs without `op` and fails loudly on a missing variable — never silently.

## Install

The dotfiles repo root is a Claude Code marketplace, and this plugin is an entry in it:

```bash
claude plugin marketplace add ~/.dotfiles
claude plugin install op-gate@dotfiles
```

Installing **copies** the plugin into
`~/.claude/plugins/cache/dotfiles/op-gate/<version>/`, so editing a file here does not
change what runs. After any edit:

```bash
# bump "version" in .claude-plugin/plugin.json first — update is a
# no-op while the version string is unchanged
claude plugin update op-gate
```

Then restart Claude Code, or `/reload-plugins` in a running session. Check what is actually
loaded with `claude plugin details op-gate`.

## Implementation

`op-gate.sh` is plain bash, targeting the 3.2 that macOS ships at `/bin/bash`, plus `jq`
(`/usr/bin/jq`) for reading and writing the hook's JSON. If `jq` is missing the hook fails
open and says so on stderr.

It works in four passes: mark every quoted or escaped character; split on unquoted `&&`,
`||`, `;`, `|`, `&`, newline and parentheses; find each segment's command word (skipping
leading env assignments) and check it against the two lists; then insert the wrapper at
each hit, rightmost first so the earlier offsets stay valid.

## Test the rewriter

```bash
echo '{"tool_name":"Bash","tool_input":{"command":"cd web && yarn build"}}' \
  | OP_GATE_DRY_RUN=1 ./hooks-handlers/op-gate.sh
```

`OP_GATE_DRY_RUN` prints the rewritten command instead of the hook JSON.
