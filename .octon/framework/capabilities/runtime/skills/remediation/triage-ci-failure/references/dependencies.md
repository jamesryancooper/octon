---
title: Dependencies Reference
description: External dependencies for the triage-ci-failure skill.
---

# Dependencies Reference

## Required External Tools

| Tool | Purpose | Verification |
|------|---------|-------------|
| `gh` (GitHub CLI) | Fetch CI logs and run metadata | `gh --version` |

## Optional External Tools

| Tool | Purpose | When Needed |
|------|---------|-------------|
| `npm` / `npx` | Local verification of fixes | Node.js projects |
| `python` / `pytest` | Local verification of fixes | Python projects |
| `cargo` | Local verification of fixes | Rust projects |

## Authentication

The `gh` CLI must be authenticated with a token that has:

- `repo` scope (read CI logs, read file contents)
- `actions:read` scope (view workflow runs)

Verify with: `gh auth status`

## Fallback Behavior

If `gh` is not available:

- Skill cannot execute — report error and stop
- Suggest: `brew install gh && gh auth login`

If local verification tools are not available:

- Skip Phase 4 (Verify) with a note in the report
- Mark fix confidence as LOWER due to missing local verification
