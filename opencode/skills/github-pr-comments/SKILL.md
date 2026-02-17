---
name: github-pr-comments
description: Use when asked to review, triage, or work on pull request comments - fetches PR review comments and lets the user choose which to address
---

# GitHub PR Comments Triage

## Overview

Fetch PR review comments, let the user pick which to address, then implement the selected ones.

## The Process

### 1. Fetch Comments

Always use `op run --` to authenticate via 1Password:

```bash
# Inline review comments
op run -- gh api repos/{owner}/{repo}/pulls/{n}/comments --paginate

# Top-level review summaries
op run -- gh api repos/{owner}/{repo}/pulls/{n}/reviews --paginate
```

NEVER use bare `gh` commands. Always `op run -- gh ...`.

### 2. Present Grouped by File

Group comments by file path. Show reviewer, line number, and comment body. Collapse threads - show root comment with reply count.

### 3. Ask the User

Present the list and ask which comments to skip and which to work on. Do NOT start implementing until the user responds.

### 4. Implement Selected

For each selected comment:
1. Read the full thread for context
2. Find the code and make the change
3. Reply in the thread only if the user asks

```bash
# Reply to a comment thread
op run -- gh api repos/{owner}/{repo}/pulls/{n}/comments/{id}/replies -f body="Done"

# Resolve a thread
op run -- gh api graphql -f query='mutation { resolveReviewThread(input: {threadId: "ID"}) { thread { isResolved } } }'
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Bare `gh` without `op run --` | Always: `op run -- gh ...` |
| Implementing before asking | Present list, wait for selection |
| Missing review summaries | Fetch both `/comments` and `/reviews` |
