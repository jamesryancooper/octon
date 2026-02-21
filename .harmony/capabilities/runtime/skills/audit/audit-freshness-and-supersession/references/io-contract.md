---
title: I/O Contract
description: Input/output contract for audit-freshness-and-supersession.
---

# I/O Contract

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `scope` | folder | No | `.harmony` | Root directory to audit |
| `artifact_globs` | text | No | `cognition/runtime/context/**/*.md,cognition/runtime/decisions/**/*.md,output/plans/**/*.md,output/reports/**/*.md` | Comma-separated globs of artifact families |
| `max_age_days` | text | No | `30` | Maximum artifact age before stale classification |
| `severity_threshold` | text | No | `all` | Minimum severity to report: `critical`, `high`, `medium`, `low`, `all` |

## Outputs

- `.harmony/output/reports/YYYY-MM-DD-freshness-and-supersession-audit.md`
- `.harmony/capabilities/runtime/skills/_ops/state/logs/audit-freshness-and-supersession/{{run_id}}.md`
- `.harmony/capabilities/runtime/skills/_ops/state/logs/audit-freshness-and-supersession/index.yml`
- `.harmony/capabilities/runtime/skills/_ops/state/logs/index.yml`

## Allowed Tools

Defined in `SKILL.md` frontmatter `allowed-tools` (single source of truth).
