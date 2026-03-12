---
title: I/O Contract
description: Parameters, inputs, and outputs for audit-documentation-standards.
---

# I/O Contract

## Parameters

Defined in `.harmony/capabilities/runtime/skills/registry.yml`.

| Parameter | Type | Required | Default | Description |
| --------- | ---- | -------- | ------- | ----------- |
| `docs_root` | folder | Yes | -- | Root documentation directory to audit |
| `template_root` | folder | No | `.harmony/scaffolding/runtime/templates/docs/documentation-standards` | Canonical documentation template root |
| `policy_doc` | file | No | `.harmony/cognition/governance/principles/documentation-is-code.md` | Canonical docs-as-code policy document |
| `severity_threshold` | text | No | `all` | Minimum severity to report: `critical`, `high`, `medium`, `low`, `all` |
| `post_remediation` | boolean | No | `false` | Enables strict done-gate behavior for convergence verification |
| `convergence_k` | text | No | `3` | Number of controlled reruns used for convergence validation |
| `seed_list` | text | No | deterministic defaults | Comma-separated seed list for run-to-run consistency checks |

## Inputs

- Documentation tree under `docs_root`
- Canonical policy document
- Canonical documentation standards guidance
- Canonical template bundle

## Outputs

- `.harmony/output/reports/analysis/YYYY-MM-DD-documentation-standards-audit.md`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/bundle.yml`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/findings.yml`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/coverage.yml`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/convergence.yml`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/evidence.md`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/commands.md`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/validation.md`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/inventory.md`
- `_ops/state/logs/audit-documentation-standards/{{run_id}}.md`
- `_ops/state/logs/audit-documentation-standards/index.yml`
- `_ops/state/logs/index.yml`
