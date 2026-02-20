---
# I/O Contract Documentation
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Parameters: .harmony/capabilities/runtime/skills/registry.yml
#   - Output paths: .harmony/capabilities/runtime/skills/registry.yml
#
# Current allowed-tools: Read Glob Grep Write(../../output/reports/*) Write(_ops/state/logs/*)
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# I/O Contract Reference

Extended input/output documentation for the audit-subsystem-health skill.

> **Authoritative Sources:**
>
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Parameters: `.harmony/capabilities/runtime/skills/registry.yml`
> - Output paths: `.harmony/capabilities/runtime/skills/registry.yml`

## Parameters

| Parameter | Type | Required | Default | Description |
| --------- | ---- | -------- | ------- | ----------- |
| `subsystem` | folder | Yes | — | Root directory of the subsystem to audit |
| `schema_ref` | file | No | Auto-detect | Path to schema file (e.g., capabilities.yml) |
| `docs` | folder | No | — | Companion documentation directory for doc-to-source alignment |
| `severity_threshold` | text | No | `all` | Minimum severity to report: `critical`, `high`, `medium`, `low`, `all` |
| `file_types` | text | No | `md,yml,yaml,json` | Comma-separated file extensions to include in scope |

## Output Structure

### Primary Output: Health Audit Report

Written to `.harmony/output/reports/YYYY-MM-DD-subsystem-health-audit.md`.

```markdown
# Subsystem Health Audit Report

**Date:** YYYY-MM-DD
**Subsystem:** {{subsystem}}
**Schema Reference:** {{schema_ref}}
**Scope:** N entries across M files
**Bounded audit:** 7 principles enforced

## Executive Summary

**Total findings: N across M files**

| Layer                 | Findings |
| --------------------- | -------- |
| Config Consistency    | N        |
| Schema Conformance    | N        |
| Semantic Quality      | N        |
| Self-Challenge (new)  | N        |

| Severity | Count |
| -------- | ----- |
| CRITICAL | N     |
| HIGH     | N     |
| MEDIUM   | N     |
| LOW      | N     |

## Findings by Layer
[Detailed findings grouped by layer]

## Self-Challenge Results
[Verification outcomes, disproved findings, blind spots]

## Recommended Fix Batches
[Batched by priority and logical grouping]

## Coverage Proof
[What was checked and found clean]

## Idempotency Metadata
[Scope hash, entry count, sorted file order hash]
```

### Execution Log

Written to `.harmony/capabilities/runtime/skills/_ops/state/logs/audit-subsystem-health/{{run_id}}.md`.

```markdown
# Audit Subsystem Health Run Log

**Run ID:** {{run_id}}
**Started:** {{timestamp}}
**Subsystem:** {{subsystem}}
**Entries:** N entries
**Scope:** N files
**Principles enforced:** 7/7

## Layer Execution

| Phase                 | Isolation | Findings | Coverage         |
| --------------------- | --------- | -------- | ---------------- |
| Configure             | —         | —        | N files in scope |
| Config Consistency    | Yes       | N        | N/N entries      |
| Schema Conformance    | Yes       | N        | N/N entries      |
| Semantic Quality      | Yes       | N        | N/N checks       |
| Self-Challenge        | —         | +N / -N  | N/N checks       |
| Report                | —         | —        | —                |

## Idempotency

- Scope hash: {{hash}}
- Entry count: N
- Sorted file list hash: {{hash}}

## Report Location
- .harmony/output/reports/YYYY-MM-DD-subsystem-health-audit.md
```

### Log Index

Written to `.harmony/capabilities/runtime/skills/_ops/state/logs/audit-subsystem-health/index.yml`:

```yaml
skill: audit-subsystem-health
updated: "YYYY-MM-DDTHH:MM:SSZ"

runs:
  - id: "{{run_id}}"
    subsystem: "{{subsystem}}"
    status: completed
    timestamp: "YYYY-MM-DDTHH:MM:SSZ"
    metrics:
      entries: N
      files_scanned: N
      total_findings: N
      critical: N
      high: N
    report: ../../output/reports/YYYY-MM-DD-subsystem-health-audit.md
    log: {{run_id}}.md
```

## Dependencies

Tool requirements are defined in SKILL.md `allowed-tools` frontmatter (single source of truth).

This skill requires:
- **Read** — Read config files, definition files, and docs for all layers
- **Glob** — Find definition files and verify path existence
- **Grep** — Pattern-based search for cross-references and trigger analysis
- **Write(../../output/reports/*)** — Write audit report
- **Write(_ops/state/logs/*)** — Write execution logs

No external dependencies required.

## Command-Line Usage

### Basic Invocation

```text
/audit-subsystem-health subsystem=".harmony/capabilities/runtime/skills"
```

### With Schema Reference

```text
/audit-subsystem-health subsystem=".harmony/capabilities/runtime/skills" schema_ref=".harmony/capabilities/runtime/skills/capabilities.yml"
```

### With Companion Docs

```text
/audit-subsystem-health subsystem=".harmony/capabilities/runtime/skills" docs=".harmony/cognition/_meta/architecture/skills"
```

### With Options

```text
# Only report CRITICAL and HIGH
/audit-subsystem-health subsystem="..." severity_threshold="high"

# Restrict file types
/audit-subsystem-health subsystem="..." file_types="yml,yaml,md"
```
