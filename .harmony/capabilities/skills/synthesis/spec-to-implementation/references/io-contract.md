---
# I/O Contract Documentation
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Parameters: .harmony/capabilities/skills/registry.yml
#   - Output paths: .harmony/capabilities/skills/registry.yml
---

# I/O Contract Reference

Extended input/output documentation for the spec-to-implementation skill.

> **Authoritative Sources:**
>
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Parameters: `.harmony/capabilities/skills/registry.yml`
> - Output paths: `.harmony/capabilities/skills/registry.yml`

## Parameters

| Parameter | Type | Required | Default | Description |
| --------- | ---- | -------- | ------- | ----------- |
| `spec` | text | Yes | — | Path to spec document or inline specification text |
| `scope` | text | No | `.` | Directory to scan for existing code (limits codebase mapping) |
| `format` | text | No | `markdown` | Output format: `markdown` or `yaml` |

## Output Structure

### Primary Output: Implementation Plan

Written to `.harmony/output/plans/YYYY-MM-DD-{{feature}}-implementation-plan.md`.

### Execution Log

Written to `.harmony/capabilities/skills/logs/spec-to-implementation/{{run_id}}.md`.

### Log Index

Written to `.harmony/capabilities/skills/logs/spec-to-implementation/index.yml`.

## Dependencies

This skill requires:

- **Read** — Read spec documents and existing codebase
- **Glob** — Find relevant modules and files
- **Grep** — Search for existing patterns and integrations
- **Write(../../output/plans/*)** — Write implementation plan
- **Write(logs/*)** — Write execution logs

No external dependencies required. This is a read-only analysis skill.
