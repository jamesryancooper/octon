---
# I/O Contract Documentation
# This file provides extended documentation for human reference.
#
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Parameters: .harmony/capabilities/runtime/skills/registry.yml
#   - Output paths: .harmony/capabilities/runtime/skills/registry.yml
#
# Current allowed-tools: Read Glob Grep Edit Bash(gh) Write(../../output/reports/*) Write(_ops/state/logs/*)
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# I/O Contract Reference

Extended input/output documentation for the resolve-pr-comments skill.

> **Authoritative Sources:**
>
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Parameters: `.harmony/capabilities/runtime/skills/registry.yml`
> - Output paths: `.harmony/capabilities/runtime/skills/registry.yml`

## Parameters

| Parameter | Type | Required | Default | Description |
| --------- | ---- | -------- | ------- | ----------- |
| `pr` | text | Yes | — | PR number or full GitHub URL |
| `reviewer` | text | No | — | Filter to specific reviewer's comments only |
| `types` | text | No | `all` | Comma-separated comment types to resolve: `bug,design,style,nit,question` |

## Output Structure

### Primary Output: Resolution Report

Written to `.harmony/output/reports/analysis/YYYY-MM-DD-pr-comments-resolved.md`.

### Execution Log

Written to `.harmony/capabilities/runtime/skills/_ops/state/logs/resolve-pr-comments/{{run_id}}.md`.

### Log Index

Written to `.harmony/capabilities/runtime/skills/_ops/state/logs/resolve-pr-comments/index.yml`.

## Dependencies

Tool requirements are defined in SKILL.md `allowed-tools` frontmatter (single source of truth).

This skill requires:

- **Read** — Read source files for context during resolution
- **Glob** — Find files referenced in comments
- **Grep** — Search for related code patterns
- **Edit** — Apply fixes to source files
- **Bash(gh)** — GitHub CLI for fetching PR data and comments
- **Write(../../output/reports/*)** — Write resolution report
- **Write(_ops/state/logs/*)** — Write execution logs

## External Dependencies

- `gh` CLI must be installed and authenticated
- Repository must be a GitHub repository with push access
