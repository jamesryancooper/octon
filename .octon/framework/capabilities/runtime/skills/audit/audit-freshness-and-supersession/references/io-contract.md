---
title: I/O Contract
description: Input/output contract for audit-freshness-and-supersession.
---

# I/O Contract

## Parameters

| Parameter | Type | Required | Default | Description |
| --------- | ---- | -------- | ------- | ----------- |
| `scope` | folder | No | `.octon` | Root directory to audit |
| `artifact_globs` | text | No | `cognition/runtime/context/**/*.md,cognition/runtime/decisions/**/*.md,/.octon/inputs/exploratory/plans/**/*.md,/.octon/state/evidence/validation/analysis/**/*.md` | Comma-separated globs of artifact families |
| `max_age_days` | text | No | `30` | Maximum artifact age before stale classification |
| `severity_threshold` | text | No | `all` | Minimum severity to report: `critical`, `high`, `medium`, `low`, `all` |
| `post_remediation` | boolean | No | `false` | Enables strict done-gate behavior for convergence verification |
| `convergence_k` | text | No | `3` | Number of controlled reruns used for convergence validation |
| `seed_list` | text | No | deterministic defaults | Comma-separated seed list for run-to-run consistency checks |

## Outputs

- `.octon/state/evidence/validation/analysis/YYYY-MM-DD-freshness-and-supersession-audit.md`
- `.octon/state/evidence/validation/audits/YYYY-MM-DD-<slug>/bundle.yml`
- `.octon/state/evidence/validation/audits/YYYY-MM-DD-<slug>/findings.yml`
- `.octon/state/evidence/validation/audits/YYYY-MM-DD-<slug>/coverage.yml`
- `.octon/state/evidence/validation/audits/YYYY-MM-DD-<slug>/convergence.yml`
- `.octon/state/evidence/validation/audits/YYYY-MM-DD-<slug>/evidence.md`
- `.octon/state/evidence/validation/audits/YYYY-MM-DD-<slug>/commands.md`
- `.octon/state/evidence/validation/audits/YYYY-MM-DD-<slug>/validation.md`
- `.octon/state/evidence/validation/audits/YYYY-MM-DD-<slug>/inventory.md`
- `.octon/state/evidence/runs/skills/audit-freshness-and-supersession/{{run_id}}.md`
- `.octon/state/evidence/runs/skills/audit-freshness-and-supersession/index.yml`
- `.octon/state/evidence/runs/skills/index.yml`

## Allowed Tools

Defined in `SKILL.md` frontmatter `allowed-tools` (single source of truth).
