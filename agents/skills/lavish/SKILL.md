---
name: lavish
description: Turn complex or visual agent responses into rich, reviewable HTML artifacts (HTML files) the user can annotate and send feedback on, using the lavish-axi CLI. Use when about to give a plan, comparison, diagram, table, code diff, report, or anything easier to grasp visually than as prose.
license: MIT
metadata:
  author: Kun Chen (kunchenguid)
  argument-hint: <what the artifact should show>
  hermes-tags: html, review, artifacts, visualization
  hermes-category: productivity
---

# Lavish Editor

Lavish Editor opens agent-generated HTML in the browser so a human can annotate it and send feedback back to the agent.
Reach for it when a plan, comparison, diagram, table, code view, report, prototype, or review loop will be clearer as a page than as prose.

## Current guidance lives in the CLI

Get current upstream workflow, design, and playbook guidance from the CLI - installed copies go stale. The local browser preferences below override the CLI's default URL and browser-opening behavior:

- `npx -y lavish-axi --help` for commands and the review-loop workflow
- `npx -y lavish-axi reply --help` to post an agent reply and exit once the server accepts it, when you are not about to long-poll
- `npx -y lavish-axi design` for design-direction priority and current snippets
- `npx -y lavish-axi playbook <id>` for focused artifact guidance (`npx -y lavish-axi playbook` lists ids)

You do not need lavish-axi installed globally - invoke it with `npx -y lavish-axi <html-file> --no-open`, then open the session through Muxify as described below.
If lavish-axi output shows a follow-up command starting with `lavish-axi`, run it as `npx -y lavish-axi ...` instead.

## Local browser preferences

Always open Lavish review sessions using a Tailscale MagicDNS domain through Muxify. This keeps review links usable across the tailnet and opens them in the user's workspace rather than the system browser.

1. Start or resume the session with `npx -y lavish-axi <html-file> --no-open` to suppress the default browser opener. Include `--no-open` on authorized `--reopen` calls too; do not bypass the CLI's user-ended session protections.
2. Read `session.url` from the CLI output. Use its Tailscale domain when already present. Otherwise, get the current machine's domain from `tailscale status --json` (`Self.DNSName`, without the trailing dot) and replace only the URL's hostname. Preserve the scheme, port, path, query, and fragment; do not hardcode a hostname, port, or session ID. Verify that the session is reachable at the Tailscale URL before opening it.
3. Open that URL with:

   ```bash
   muxify browser open "<tailscale-url>"
   ```

   Use the same Tailscale URL in links given to the user. Do not use `localhost`, loopback addresses, raw IP addresses, `open`, `xdg-open`, or browser-opening tools as alternatives.
4. If Tailscale is unavailable, the domain URL is unreachable, or Muxify cannot open it, report the blocker instead of falling back to a different hostname or browser. Once opening succeeds, continue the CLI's normal feedback/poll workflow.

## Request

$ARGUMENTS

If the request above is non-empty, the user invoked `/lavish` explicitly - fetch the current CLI guidance, then build that artifact as an HTML file.
If it is empty, infer what to visualize from the conversation.
