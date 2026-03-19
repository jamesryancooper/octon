---
# I/O Contract Documentation
# This file provides extended documentation for human reference.
#
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Parameters: .octon/framework/capabilities/runtime/skills/registry.yml
#   - Output paths: .octon/framework/capabilities/runtime/skills/registry.yml
#
# Current allowed-tools: Read Glob Grep Edit Bash(gh) Write(/.octon/state/evidence/validation/analysis/*) Write(/.octon/state/evidence/runs/skills/*)
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# I/O Contract Reference

Extended input/output documentation for the resolve-pr-comments skill.

> **Authoritative Sources:**
>
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Parameters: `.octon/framework/capabilities/runtime/skills/registry.yml`
> - Output paths: `.octon/framework/capabilities/runtime/skills/registry.yml`

## Parameters

| Parameter | Type | Required | Default | Description |
| --------- | ---- | -------- | ------- | ----------- |
| `pr` | text | Yes | — | PR number or full GitHub URL |
| `reviewer` | text | No | — | Filter to specific reviewer's comments only |
| `types` | text | No | `all` | Comma-separated comment types to resolve: `bug,design,style,nit,question` |

## Output Structure

### Primary Output: Resolution Report

Written to `.octon/state/evidence/validation/analysis/YYYY-MM-DD-pr-comments-resolved.md`.

### Execution Log

Written to `.octon/state/evidence/runs/skills/resolve-pr-comments/{{run_id}}.md`.

### Log Index

Written to `.octon/state/evidence/runs/skills/resolve-pr-comments/index.yml`.

## Dependencies

Tool requirements are defined in SKILL.md `allowed-tools` frontmatter (single source of truth).

This skill requires:

- **Read** — Read source files for context during resolution
- **Glob** — Find files referenced in comments
- **Grep** — Search for related code patterns
- **Edit** — Apply fixes to source files
- **Bash(gh)** — GitHub CLI for fetching PR data and comments
- **Write(/.octon/state/evidence/validation/analysis/*)** — Write resolution report
- **Write(/.octon/state/evidence/runs/skills/*)** — Write execution logs

## External Dependencies

- `gh` CLI must be installed and authenticated
- Repository must be a GitHub repository with push access
