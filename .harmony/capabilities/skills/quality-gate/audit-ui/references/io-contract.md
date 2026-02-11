---
# I/O Contract Documentation
# This file provides extended documentation for human reference.
#
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Parameters: .harmony/capabilities/skills/registry.yml
#   - Output paths: .harmony/capabilities/skills/registry.yml
#
# Current allowed-tools: Read Glob Grep WebFetch Write(../../output/reports/*) Write(_state/logs/*)
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# I/O Contract

Formal input/output specification for the audit-ui skill.

> **Authoritative Source:** Parameter definitions and output paths live in
> `.harmony/capabilities/skills/registry.yml`. This document provides
> supplementary context for the interface.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `target` | folder | No | `.` | Directory containing UI files to audit |
| `ruleset_url` | text | No | (see below) | URL of the external design guidelines ruleset |
| `file_types` | text | No | `tsx,jsx,html,css,vue,svelte` | Comma-separated UI file extensions to scan |

### Default Ruleset URL

```
https://raw.githubusercontent.com/anthropics/anthropic-cookbook/refs/heads/main/misc/web_interface_guidelines.md
```

## Inputs

This skill has no persistent input resources. It operates on:

1. **Live code** in the `target` directory (read via Read/Glob/Grep)
2. **External ruleset** fetched at runtime (via WebFetch)

## Outputs

### Audit Report

- **Path:** `.harmony/output/reports/YYYY-MM-DD-ui-audit.md`
- **Format:** Markdown
- **Determinism:** Variable (depends on codebase state and ruleset version)

#### Report Schema

```markdown
# UI Audit Report — YYYY-MM-DD

## Executive Summary
- Files scanned: {count}
- Violations found: {count} (CRITICAL: {n}, HIGH: {n}, MEDIUM: {n}, LOW: {n})
- Rules applied: {count} from {category_count} categories
- Ruleset source: {url}
- Fetch timestamp: {timestamp}

## Findings

### CRITICAL
- `src/components/Button.tsx:42` — **[a11y-focus-visible]** Missing visible focus indicator on interactive element. Add `focus-visible` outline or ring style.

### HIGH
...

### MEDIUM
...

### LOW
...

## Clean Files
Files scanned with no violations:
- src/components/Header.tsx
- src/components/Footer.tsx
- ...

## Ruleset Metadata
- Source: {url}
- Fetched: {timestamp}
- Rules parsed: {count}
- Categories: {list}
```

### Execution Log

- **Path:** `.harmony/capabilities/skills/_state/logs/audit-ui/{run_id}.md`
- **Format:** Markdown
- **Determinism:** Unique

### Log Index

- **Path:** `.harmony/capabilities/skills/_state/logs/audit-ui/index.yml`
- **Format:** YAML
- **Determinism:** Variable (appended each run)
