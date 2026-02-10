---
title: Dependencies Reference
description: External dependencies for the resolve-pr-comments skill.
---

# Dependencies Reference

## Required External Tools

| Tool | Purpose | Verification |
|------|---------|-------------|
| `gh` (GitHub CLI) | Fetch PR comments and metadata | `gh --version` |

## Authentication

The `gh` CLI must be authenticated with a token that has:

- `repo` scope (read PR comments, read file contents)
- Access to the target repository

Verify with: `gh auth status`

## Fallback Behavior

If `gh` is not available:

- Skill cannot execute — report error and stop
- Do not attempt to use raw `curl` or API calls as a fallback
- Suggest: `brew install gh && gh auth login`
