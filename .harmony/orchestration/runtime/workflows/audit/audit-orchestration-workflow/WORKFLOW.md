---
name: "audit-orchestration-workflow"
description: "Coordinate bounded multi-pass audits across partitioned scope, merge with stable finding IDs and coverage accounting, and emit a deterministic evidence bundle with explicit done-gate and convergence metadata."
steps:
  - id: "configure"
    file: "01-configure.md"
    description: "configure"
  - id: "partition"
    file: "02-partition.md"
    description: "partition"
  - id: "dispatch"
    file: "03-dispatch.md"
    description: "dispatch"
  - id: "merge"
    file: "04-merge.md"
    description: "merge"
  - id: "challenge"
    file: "05-challenge.md"
    description: "challenge"
  - id: "cross-subsystem-audit"
    file: "06-cross-subsystem-audit.md"
    description: "cross-subsystem-audit"
  - id: "freshness-audit"
    file: "07-freshness-audit.md"
    description: "freshness-audit"
  - id: "report"
    file: "08-report.md"
    description: "report"
  - id: "verify"
    file: "09-verify.md"
    description: "verify"
---

# Audit Orchestration Workflow

_Generated projection from canonical pipeline `audit-orchestration-workflow`._

## Usage

```text
/audit-orchestration-workflow
```

## Target

This projection wraps the canonical pipeline `audit-orchestration-workflow` for staged human review and slash-facing compatibility.

## Prerequisites

- Required pipeline inputs are available.
- Canonical pipeline assets exist under `.harmony/orchestration/runtime/pipelines/audit/audit-orchestration-workflow`.

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
- The backing canonical pipeline contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `consolidated_report` -> `../../output/reports/{{date}}-migration-audit-consolidated.md`: Consolidated report with partitioned migration findings and optional global-stage outcomes
- `partition_reports` -> `../../output/reports/{{date}}-migration-audit-{{partition}}.md`: Individual partition audit reports
- `cross_subsystem_audit_report` -> `../../output/reports/{{date}}-cross-subsystem-coherence-audit.md`: Individual cross-subsystem coherence audit report (produced if enabled)
- `freshness_audit_report` -> `../../output/reports/{{date}}-freshness-and-supersession-audit.md`: Individual freshness and supersession audit report (produced if enabled)
- `bounded_audit_bundle` -> `../../output/reports/audits/{{date}}-{{slug}}/`: Authoritative bounded-audit evidence bundle with findings, coverage, and convergence artifacts

## Steps

1. [configure](./01-configure.md)
2. [partition](./02-partition.md)
3. [dispatch](./03-dispatch.md)
4. [merge](./04-merge.md)
5. [challenge](./05-challenge.md)
6. [cross-subsystem-audit](./06-cross-subsystem-audit.md)
7. [freshness-audit](./07-freshness-audit.md)
8. [report](./08-report.md)
9. [verify](./09-verify.md)

## Verification Gate

- [ ] Coverage accounting has zero unaccounted files
- [ ] Findings are deduplicated with stable IDs and acceptance criteria
- [ ] Determinism receipt is present (`commit_sha`, `scope_hash`, `prompt_hash`, seed/fingerprint policy, findings hash)
- [ ] Audit bundle exists at `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`
- [ ] Done-gate expression is evaluated and recorded
- [ ] If `post_remediation=true`, convergence K-run result is stable and empty at/above threshold

## Version History

| Version | Changes |
|---------|---------|
| 2.0.0 | Generated from canonical pipeline `audit-orchestration-workflow` |

## References

- Canonical pipeline: `.harmony/orchestration/runtime/pipelines/audit/audit-orchestration-workflow/`
