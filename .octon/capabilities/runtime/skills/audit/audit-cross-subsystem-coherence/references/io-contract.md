---
title: I/O Contract
description: Input/output contract for audit-cross-subsystem-coherence.
---

# I/O Contract

## Parameters

| Parameter | Type | Required | Default | Description |
| --------- | ---- | -------- | ------- | ----------- |
| `scope` | folder | No | `.octon` | Root directory to audit for subsystem coherence |
| `subsystems` | text | No | `agency,capabilities,cognition,orchestration,quality,continuity,runtime` | Comma-separated subsystem list |
| `docs` | folder | No | `.octon/cognition/_meta/architecture` | Companion architecture docs root for cross-reference checks |
| `severity_threshold` | text | No | `all` | Minimum severity to report: `critical`, `high`, `medium`, `low`, `all` |
| `post_remediation` | boolean | No | `false` | Enables strict done-gate behavior for convergence verification |
| `convergence_k` | text | No | `3` | Number of controlled reruns used for convergence validation |
| `seed_list` | text | No | deterministic defaults | Comma-separated seed list for run-to-run consistency checks |

## Outputs

- `.octon/output/reports/analysis/YYYY-MM-DD-cross-subsystem-coherence-audit.md`
- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/bundle.yml`
- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/findings.yml`
- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/coverage.yml`
- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/convergence.yml`
- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/evidence.md`
- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/commands.md`
- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/validation.md`
- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/inventory.md`
- `.octon/capabilities/runtime/skills/_ops/state/logs/audit-cross-subsystem-coherence/{{run_id}}.md`
- `.octon/capabilities/runtime/skills/_ops/state/logs/audit-cross-subsystem-coherence/index.yml`
- `.octon/capabilities/runtime/skills/_ops/state/logs/index.yml`

## Allowed Tools

Defined in `SKILL.md` frontmatter `allowed-tools` (single source of truth).
