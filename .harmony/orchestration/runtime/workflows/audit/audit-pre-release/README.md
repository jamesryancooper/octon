---
name: "audit-pre-release"
description: "Chain bounded migration, subsystem-health, cross-subsystem, and freshness audits into a pre-release gate with deterministic evidence, stable finding identity, and explicit done-gate evaluation."
steps:
  - id: "configure"
    file: "stages/01-configure.md"
    description: "configure"
  - id: "migration-audit"
    file: "stages/02-migration-audit.md"
    description: "migration-audit"
  - id: "health-audit"
    file: "stages/03-health-audit.md"
    description: "health-audit"
  - id: "cross-subsystem-audit"
    file: "stages/04-cross-subsystem-audit.md"
    description: "cross-subsystem-audit"
  - id: "freshness-audit"
    file: "stages/05-freshness-audit.md"
    description: "freshness-audit"
  - id: "merge"
    file: "stages/06-merge.md"
    description: "merge"
  - id: "report"
    file: "stages/07-report.md"
    description: "report"
  - id: "verify"
    file: "stages/08-verify.md"
    description: "verify"
---

# Audit Pre Release

_Generated README from canonical workflow `audit-pre-release`._

## Usage

```text
/audit-pre-release
```

## Purpose

Chain bounded migration, subsystem-health, cross-subsystem, and freshness audits into a pre-release gate with deterministic evidence, stable finding identity, and explicit done-gate evaluation.

## Target

This README summarizes the canonical workflow unit at `.harmony/orchestration/runtime/workflows/audit/audit-pre-release`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.harmony/orchestration/runtime/workflows/audit/audit-pre-release/workflow.yml`.

## Parameters

- `subsystem` (folder, required=true): Root directory of the subsystem to audit
- `manifest` (file, required=false): Migration manifest (inline YAML or file path); omit for health-only audit
- `docs` (folder, required=false): Companion documentation directory for doc-to-source alignment
- `severity_threshold` (text, required=false), default=`all`: Minimum severity to report: critical, high, medium, low, all
- `run_cross_subsystem` (boolean, required=false), default=`true`: Run cross-subsystem coherence audit stage
- `run_freshness` (boolean, required=false), default=`true`: Run freshness and supersession audit stage
- `max_age_days` (text, required=false), default=`30`: Freshness threshold in days for stale artifact detection
- `post_remediation` (boolean, required=false): Enable strict done-gate enforcement for remediation verification
- `convergence_k` (text, required=false), default=`3`: Number of controlled reruns used to evaluate convergence stability
- `seed_list` (text, required=false): Comma-separated deterministic seeds used for multi-run consistency checks

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `pre_release_report` -> `../../output/reports/analysis/{{date}}-audit-pre-release.md`: Consolidated pre-release audit report with go/no-go recommendation
- `health_audit_report` -> `../../output/reports/analysis/{{date}}-subsystem-health-audit.md`: Individual health audit report (produced by audit-subsystem-health)
- `migration_audit_report` -> `../../output/reports/analysis/{{date}}-migration-audit-consolidated.md`: Consolidated migration audit report (produced by audit-orchestration in migration-only mode, if manifest provided)
- `cross_subsystem_audit_report` -> `../../output/reports/analysis/{{date}}-cross-subsystem-coherence-audit.md`: Individual cross-subsystem coherence audit report (produced by audit-cross-subsystem-coherence, if enabled)
- `freshness_audit_report` -> `../../output/reports/analysis/{{date}}-freshness-and-supersession-audit.md`: Individual freshness and supersession audit report (produced by audit-freshness-and-supersession, if enabled)
- `pre_release_audit_bundle` -> `../../output/reports/audits/{{date}}-{{slug}}/`: Authoritative bounded-audit bundle for release recommendation, context-governance evidence, and done-gate verification

## Steps

1. [configure](./stages/01-configure.md)
2. [migration-audit](./stages/02-migration-audit.md)
3. [health-audit](./stages/03-health-audit.md)
4. [cross-subsystem-audit](./stages/04-cross-subsystem-audit.md)
5. [freshness-audit](./stages/05-freshness-audit.md)
6. [merge](./stages/06-merge.md)
7. [report](./stages/07-report.md)
8. [verify](./stages/08-verify.md)

## Verification Gate

- [ ] All planned stages executed or explicitly skipped
- [ ] Consolidated report exists at `.harmony/output/reports/analysis/YYYY-MM-DD-audit-pre-release.md`
- [ ] Pre-release bundle exists at `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`
- [ ] Findings are deduplicated with stable IDs and acceptance criteria
- [ ] Coverage and convergence metadata are recorded
- [ ] Instruction-layer manifest evidence exists for material policy runs
- [ ] Context-acquisition telemetry fields are present in receipts/digests
- [ ] Context governance validators pass (`validate-developer-context-policy.sh`, `validate-context-overhead-budget.sh`)
- [ ] Recommendation and done-gate rationale are explicit

## References

- Canonical contract: `.harmony/orchestration/runtime/workflows/audit/audit-pre-release/workflow.yml`
- Canonical stages: `.harmony/orchestration/runtime/workflows/audit/audit-pre-release/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 2.2.0 | Generated from canonical workflow `audit-pre-release` |

