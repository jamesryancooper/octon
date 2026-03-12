---
name: "audit-orchestration"
description: "Coordinate bounded multi-pass audits across partitioned scope, merge with stable finding IDs and coverage accounting, and emit a deterministic evidence bundle with explicit done-gate and convergence metadata."
steps:
  - id: "configure"
    file: "stages/01-configure.md"
    description: "configure"
  - id: "partition"
    file: "stages/02-partition.md"
    description: "partition"
  - id: "dispatch"
    file: "stages/03-dispatch.md"
    description: "dispatch"
  - id: "merge"
    file: "stages/04-merge.md"
    description: "merge"
  - id: "challenge"
    file: "stages/05-challenge.md"
    description: "challenge"
  - id: "cross-subsystem-audit"
    file: "stages/06-cross-subsystem-audit.md"
    description: "cross-subsystem-audit"
  - id: "freshness-audit"
    file: "stages/07-freshness-audit.md"
    description: "freshness-audit"
  - id: "report"
    file: "stages/08-report.md"
    description: "report"
  - id: "verify"
    file: "stages/09-verify.md"
    description: "verify"
---

# Audit Orchestration

_Generated README from canonical workflow `audit-orchestration`._

## Usage

```text
/audit-orchestration
```

## Purpose

Coordinate bounded multi-pass audits across partitioned scope, merge with stable finding IDs and coverage accounting, and emit a deterministic evidence bundle with explicit done-gate and convergence metadata.

## Target

This README summarizes the canonical workflow unit at `.harmony/orchestration/runtime/workflows/audit/audit-orchestration`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.harmony/orchestration/runtime/workflows/audit/audit-orchestration/workflow.yml`.

## Parameters

- `manifest` (file, required=true): Migration manifest (inline YAML or file path)
- `scope` (folder, required=false), default=`.`: Root directory to partition and audit
- `docs` (folder, required=false): Companion documentation directory for optional global coherence checks
- `severity_threshold` (text, required=false), default=`all`: Minimum severity to report: critical, high, medium, low, all
- `strategy` (text, required=false), default=`by-directory`: Partition strategy: by-directory, by-type, by-concern, auto
- `concern_map` (text, required=false): Manual concern-to-glob mapping (required for by-concern strategy)
- `partition_count` (text, required=false): Number of partitions (for auto strategy)
- `run_cross_subsystem` (boolean, required=false), default=`true`: Run cross-subsystem coherence audit stage
- `run_freshness` (boolean, required=false), default=`true`: Run freshness and supersession audit stage
- `max_age_days` (text, required=false), default=`30`: Freshness threshold in days for stale artifact detection
- `post_remediation` (boolean, required=false): Enable strict done-gate verification after remediation
- `convergence_k` (text, required=false), default=`3`: Number of controlled reruns used to evaluate convergence stability
- `seed_list` (text, required=false): Comma-separated deterministic seeds used for multi-pass consistency checks

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `consolidated_report` -> `../../output/reports/analysis/{{date}}-migration-audit-consolidated.md`: Consolidated report with partitioned migration findings and optional global-stage outcomes
- `partition_reports` -> `../../output/reports/analysis/{{date}}-migration-audit-{{partition}}.md`: Individual partition audit reports
- `cross_subsystem_audit_report` -> `../../output/reports/analysis/{{date}}-cross-subsystem-coherence-audit.md`: Individual cross-subsystem coherence audit report (produced if enabled)
- `freshness_audit_report` -> `../../output/reports/analysis/{{date}}-freshness-and-supersession-audit.md`: Individual freshness and supersession audit report (produced if enabled)
- `bounded_audit_bundle` -> `../../output/reports/audits/{{date}}-{{slug}}/`: Authoritative bounded-audit evidence bundle with findings, coverage, and convergence artifacts

## Steps

1. [configure](./stages/01-configure.md)
2. [partition](./stages/02-partition.md)
3. [dispatch](./stages/03-dispatch.md)
4. [merge](./stages/04-merge.md)
5. [challenge](./stages/05-challenge.md)
6. [cross-subsystem-audit](./stages/06-cross-subsystem-audit.md)
7. [freshness-audit](./stages/07-freshness-audit.md)
8. [report](./stages/08-report.md)
9. [verify](./stages/09-verify.md)

## Verification Gate

- [ ] Coverage accounting has zero unaccounted files
- [ ] Findings are deduplicated with stable IDs and acceptance criteria
- [ ] Determinism receipt is present (`commit_sha`, `scope_hash`, `prompt_hash`, seed/fingerprint policy, findings hash)
- [ ] Audit bundle exists at `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`
- [ ] Done-gate expression is evaluated and recorded
- [ ] If `post_remediation=true`, convergence K-run result is stable and empty at/above threshold

## References

- Canonical contract: `.harmony/orchestration/runtime/workflows/audit/audit-orchestration/workflow.yml`
- Canonical stages: `.harmony/orchestration/runtime/workflows/audit/audit-orchestration/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 2.0.0 | Generated from canonical workflow `audit-orchestration` |

