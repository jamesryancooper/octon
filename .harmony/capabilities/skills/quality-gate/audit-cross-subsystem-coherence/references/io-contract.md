---
title: I/O Contract
description: Input/output contract for audit-cross-subsystem-coherence.
---

# I/O Contract

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `scope` | folder | No | `.harmony` | Root directory to audit for subsystem coherence |
| `subsystems` | text | No | `agency,capabilities,cognition,orchestration,quality,continuity,runtime` | Comma-separated subsystem list |
| `docs` | folder | No | `.harmony/cognition/_meta/architecture` | Companion architecture docs root for link and policy checks |
| `severity_threshold` | text | No | `all` | Minimum severity to report: `critical`, `high`, `medium`, `low`, `all` |

## Outputs

- `.harmony/output/reports/YYYY-MM-DD-cross-subsystem-coherence-audit.md`
- `.harmony/capabilities/skills/_ops/state/logs/audit-cross-subsystem-coherence/{{run_id}}.md`
- `.harmony/capabilities/skills/_ops/state/logs/audit-cross-subsystem-coherence/index.yml`
- `.harmony/capabilities/skills/_ops/state/logs/index.yml`

## Allowed Tools

Defined in `SKILL.md` frontmatter `allowed-tools` (single source of truth).
