# Claude Code

Config for [Claude Code](https://claude.com/claude-code) specifically. Skills shared with
other agents live in [`agents/`](../agents) instead.

## Plugins

The dotfiles repo root is itself a Claude Code marketplace
([`.claude-plugin/marketplace.json`](../.claude-plugin/marketplace.json)), and
[`plugins/`](plugins) holds its entries. Register the marketplace once, then install from
it:

```bash
claude plugin marketplace add ~/.dotfiles
claude plugin install op-gate@dotfiles
```

| Plugin | What it does |
| --- | --- |
| [`op-gate`](plugins/op-gate) | Gates `yarn`/`pnpm`/`bundle`/`terraform`/`gh`/`aws`/`git commit` behind `op run` plus a human approval, since Claude's Bash tool never sees the fish aliases. |

Installing **copies** the plugin into
`~/.claude/plugins/cache/dotfiles/<plugin>/<version>/`, so an edit here does not change
what runs. Bump `version` in the plugin's `plugin.json`, then:

```bash
claude plugin update <plugin>
```

`claude plugin update` is a no-op while the version string is unchanged. Restart Claude
Code or `/reload-plugins` to apply, and check what is actually loaded with
`claude plugin details <plugin>`.
