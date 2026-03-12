---
# I/O Contract Documentation
# This file provides extended documentation for human reference.
#
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Parameters: .harmony/capabilities/runtime/skills/registry.yml
#   - Output paths: .harmony/capabilities/runtime/skills/registry.yml
#
# Current allowed-tools: Read Glob Grep WebFetch Write(../../output/reports/*) Write(_ops/state/logs/*)
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# I/O Contract

Formal input/output specification for the `audit-ui` skill.

> **Authoritative Source:** Parameter definitions and output paths live in `.harmony/capabilities/runtime/skills/registry.yml`.

## Parameters

| Parameter | Type | Required | Default | Description |
| --------- | ---- | -------- | ------- | ----------- |
| `target` | folder | No | `.` | Directory containing UI files to audit |
| `ruleset_url` | text | No | (see below) | URL of the external design guidelines ruleset |
| `file_types` | text | No | `tsx,jsx,html,css,vue,svelte` | Comma-separated UI file extensions to scan |
| `severity_threshold` | text | No | `all` | Minimum severity to report: `critical`, `high`, `medium`, `low`, `all` |
| `post_remediation` | boolean | No | `false` | Enables strict done-gate behavior for convergence verification |
| `convergence_k` | text | No | `3` | Number of controlled reruns used for convergence validation |
| `seed_list` | text | No | deterministic defaults | Comma-separated seed list for run-to-run consistency checks |

### Default Ruleset URL

```text
https://raw.githubusercontent.com/anthropics/anthropic-cookbook/refs/heads/main/misc/web_interface_guidelines.md
```

## Inputs

This skill has no persistent input resources. It operates on:

1. Live code in the `target` directory (read via Read/Glob/Grep)
2. External ruleset fetched at runtime (via WebFetch)

## Outputs

- `.harmony/output/reports/analysis/YYYY-MM-DD-ui-audit.md`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/bundle.yml`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/findings.yml`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/coverage.yml`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/convergence.yml`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/evidence.md`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/commands.md`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/validation.md`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/inventory.md`
- `.harmony/capabilities/runtime/skills/_ops/state/logs/audit-ui/{run_id}.md`
- `.harmony/capabilities/runtime/skills/_ops/state/logs/audit-ui/index.yml`

## Determinism Notes

- `audit_report` determinism is variable because the external ruleset may change over time.
- Bundle convergence metadata must always record ruleset URL, fetch timestamp, and seed/fingerprint policy to explain any run variance.
