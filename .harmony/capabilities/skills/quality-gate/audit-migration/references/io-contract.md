---
# I/O Contract Documentation
# This file provides extended documentation for human reference.
#
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Parameters: .harmony/capabilities/skills/registry.yml
#   - Output paths: .harmony/capabilities/skills/registry.yml
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# I/O Contract Reference

Extended input/output documentation for the audit-migration skill.

> **Authoritative Sources:**
>
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Parameters: `.harmony/capabilities/skills/registry.yml`
> - Output paths: `.harmony/capabilities/skills/registry.yml`

## Parameters

| Parameter | Type | Required | Default | Description |
| --------- | ---- | -------- | ------- | ----------- |
| `manifest` | text | Yes | — | Migration manifest (inline YAML or file path) |
| `scope` | text | No | `.` | Directory to audit |
| `severity_threshold` | text | No | `all` | Minimum severity to report: `critical`, `high`, `medium`, `low`, `all` |
| `structure_spec` | file | No | — | Path to documented directory structure for structure diff layer |
| `template_dir` | folder | No | — | Path to template directory for template smoke test layer |
| `partition` | text | No | — | Partition label for parallel orchestration (e.g., "docs-architecture") |
| `file_filter` | text | No | — | Glob pattern to narrow scope within `scope` directory (e.g., "docs/architecture/**") |

## Migration Manifest Schema

The manifest describes what changed and what to exclude. Provide inline or as a file path.

```yaml
migration:
  name: "human-readable migration description"

  mappings:
    - old: ".workspace/"
      new: ".harmony/"
      # Optional: restrict search to specific file types
      file_types: "md,yml,yaml,json"

    - old: "context/"
      new: "cognition/context/"

    - old: "commands/"
      new: "capabilities/commands/"

  exclusions:
    # Exact files
    - "continuity/log.md"
    # Directories (recursive)
    - "cognition/decisions/"
    - ".history/"
    # Glob patterns
    - "*.archive/*"

  key_files:
    # Override default key file list for cross-reference audit
    # Omit to use defaults (START.md, catalog.md, README.md, etc.)
    - "START.md"
    - "catalog.md"
    - "conventions.md"

  scope: "."
    # Directory to audit (default: current directory)
```

### Manifest Validation Rules

| Rule | Error |
| ---- | ----- |
| `mappings` must be a non-empty list | `MANIFEST_EMPTY: No mappings defined` |
| Each mapping must have `old` and `new` | `MAPPING_INCOMPLETE: Missing old or new field` |
| `old` must be non-empty | `MAPPING_INVALID: Empty old pattern` |
| No duplicate `old` patterns | `MAPPING_DUPLICATE: Pattern 'X' appears twice` |
| `old` and `new` must differ | `MAPPING_NOOP: old and new are identical` |

## Output Structure

### Primary Output: Audit Report

Written to `.harmony/output/reports/YYYY-MM-DD-migration-audit.md`.

```markdown
# Post-Migration Audit Report

**Date:** 2026-02-08
**Migration:** capability-organized restructure
**Scope:** . (N files scanned across M directories)
**Layers:** Grep Sweep, Cross-Reference Audit, Semantic Read-Through

## Executive Summary

**Total findings: 53 across 25 files**

| Layer | Findings |
|-------|----------|
| Grep Sweep | 29 |
| Cross-Reference Audit | 12 |
| Semantic Read-Through | 12 |

| Severity | Count |
|----------|-------|
| CRITICAL | 1 |
| HIGH | 25 |
| MEDIUM | 15 |
| LOW | 12 |

## Findings by Layer
[Detailed findings grouped by layer]

## Recommended Fix Batches
[Grouped by priority and logical cohesion]

## Files Confirmed Clean
[Summary of clean categories]

## Exclusion Zones
[What was excluded and why]
```

### Partition-Mode Output

When `partition` is set, the report filename includes the partition name:

Written to `.harmony/output/reports/YYYY-MM-DD-migration-audit-{partition}.md`.

The report header includes additional metadata:

```markdown
**Partition:** docs-architecture
**File Filter:** docs/architecture/**
**Partition Mode:** Yes
**Partition Coverage:** 45 files (of 280 total in scope)
```

The execution log filename similarly includes the partition:

Written to `.harmony/capabilities/skills/logs/audit-migration/{{run_id}}-{partition}.md`.

### Execution Log

Written to `.harmony/capabilities/skills/logs/audit-migration/{{run_id}}.md`.

```markdown
# Audit Migration Run Log

**Run ID:** 2026-02-08-capability-restructure
**Started:** 2026-02-08T14:30:00Z
**Completed:** 2026-02-08T14:45:00Z
**Migration:** capability-organized restructure

## Configuration
- Mappings: 12
- Exclusions: 5
- Key files: 15
- Scope: .

## Layer Results

| Layer | Files Scanned | Findings | Duration |
|-------|--------------|----------|----------|
| Grep Sweep | 257 | 29 | — |
| Cross-Reference Audit | 15 | 12 | — |
| Semantic Read-Through | 8 | 12 | — |

## Output
- Report: .harmony/output/reports/2026-02-08-migration-audit.md
```

### Log Index

Written to `.harmony/capabilities/skills/logs/audit-migration/index.yml`:

```yaml
skill: audit-migration
updated: "2026-02-08T14:45:00Z"

runs:
  - id: "2026-02-08-capability-restructure"
    migration: "capability-organized restructure"
    status: completed
    timestamp: "2026-02-08T14:30:00Z"
    metrics:
      mappings: 12
      files_scanned: 280
      total_findings: 53
      critical: 1
      high: 25
    report: ../../output/reports/2026-02-08-migration-audit.md
    log: 2026-02-08-capability-restructure.md
```

## Dependencies

Tool requirements are defined in SKILL.md `allowed-tools` frontmatter (single source of truth).

This skill requires:
- **Read** — Read files for cross-reference and semantic analysis
- **Glob** — Find key operational files and verify path existence
- **Grep** — Pattern-based search for stale references
- **Write(../../output/reports/*)** — Write audit report
- **Write(logs/*)** — Write execution logs

No external dependencies required.

## Command-Line Usage

### Basic Invocation

```text
/audit-migration manifest=".harmony/migrations/restructure.yml"
```

### With Inline Manifest

```text
/audit-migration manifest="migration: {name: 'rename', mappings: [{old: '.scratch/', new: '.scratchpad/'}]}"
```

### With Options

```text
# Only report CRITICAL and HIGH
/audit-migration manifest="..." severity_threshold="high"

# Narrow scope to specific directory
/audit-migration manifest="..." scope="docs/"

# Enable structure diff layer
/audit-migration manifest="..." structure_spec="docs/architecture/harness/README.md"

# Enable template smoke test layer
/audit-migration manifest="..." template_dir=".harmony/scaffolding/templates/"
```

### With Partition (for parallel orchestration)

```text
# Audit only docs/architecture/ files
/audit-migration manifest="..." partition="docs-architecture" file_filter="docs/architecture/**"

# Audit only agency files
/audit-migration manifest="..." partition="agency-files" file_filter=".harmony/agency/**"

# Audit only YAML/JSON config files
/audit-migration manifest="..." partition="config-files" file_filter="**/*.{yml,yaml,json}"
```

**Note:** Partition mode is designed for use by the `orchestrate-audit` workflow. Direct use is supported but the partition label and filter must be manually coordinated.
