---
# I/O Contract Documentation
# This file provides extended documentation for human reference.
#
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Parameters: .octon/capabilities/runtime/skills/registry.yml
#   - Output paths: .octon/capabilities/runtime/skills/registry.yml
#
# Current allowed-tools: Read Glob Grep Write(../../output/reports/*) Write(_ops/state/logs/*)
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# I/O Contract Reference

Extended input/output documentation for the `audit-subsystem-health` skill.

> **Authoritative Sources:**
>
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Parameters: `.octon/capabilities/runtime/skills/registry.yml`
> - Output paths: `.octon/capabilities/runtime/skills/registry.yml`

## Parameters

| Parameter | Type | Required | Default | Description |
| --------- | ---- | -------- | ------- | ----------- |
| `subsystem` | folder | Yes | -- | Root directory of the subsystem to audit |
| `schema_ref` | file | No | Auto-detect | Path to schema file (for example `capabilities.yml`) |
| `docs` | folder | No | -- | Companion documentation directory for doc-to-source alignment checks |
| `severity_threshold` | text | No | `all` | Minimum severity to report: `critical`, `high`, `medium`, `low`, `all` |
| `file_types` | text | No | `md,yml,yaml,json` | Comma-separated file extensions to include in scope |
| `post_remediation` | boolean | No | `false` | Enables strict done-gate behavior for convergence verification |
| `convergence_k` | text | No | `3` | Number of controlled reruns used for convergence validation |
| `seed_list` | text | No | deterministic defaults | Comma-separated seed list for run-to-run consistency checks |

## Output Structure

### Primary Report

Written to `.octon/output/reports/analysis/YYYY-MM-DD-subsystem-health-audit.md`.

The report includes:

- Executive summary with layer and severity counts
- Findings grouped by layer with evidence references
- Stable finding IDs and acceptance criteria (orchestrated mode)
- Coverage proof and exclusions ledger
- Determinism/convergence summary and done-gate result

### Execution Log

Written to `.octon/capabilities/runtime/skills/_ops/state/logs/audit-subsystem-health/{{run_id}}.md`.

### Log Index

Written to `.octon/capabilities/runtime/skills/_ops/state/logs/audit-subsystem-health/index.yml`.

### Authoritative Bundle (Orchestrated Mode)

When called through `audit-orchestration`, output is also materialized into:

- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/bundle.yml`
- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/findings.yml`
- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/coverage.yml`
- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/convergence.yml`
- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/evidence.md`
- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/commands.md`
- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/validation.md`
- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/inventory.md`

## Dependencies

Tool requirements are defined in `SKILL.md` `allowed-tools` frontmatter (single source of truth).

This skill requires:

- **Read** -- Read config files, definitions, and docs
- **Glob** -- Discover definition files and path targets
- **Grep** -- Pattern-based cross-reference/semantic checks
- **Write(../../output/reports/*)** -- Write report and bounded bundle artifacts
- **Write(_ops/state/logs/*)** -- Write run logs and indexes
