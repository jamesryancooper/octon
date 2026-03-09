---
name: "audit-pre-release-workflow"
description: "Chain bounded migration, subsystem-health, cross-subsystem, and freshness audits into a pre-release gate with deterministic evidence, stable finding identity, and explicit done-gate evaluation."
steps:
  - id: "configure"
    file: "01-configure.md"
    description: "configure"
  - id: "migration-audit"
    file: "02-migration-audit.md"
    description: "migration-audit"
  - id: "health-audit"
    file: "03-health-audit.md"
    description: "health-audit"
  - id: "cross-subsystem-audit"
    file: "04-cross-subsystem-audit.md"
    description: "cross-subsystem-audit"
  - id: "freshness-audit"
    file: "05-freshness-audit.md"
    description: "freshness-audit"
  - id: "merge"
    file: "06-merge.md"
    description: "merge"
  - id: "report"
    file: "07-report.md"
    description: "report"
  - id: "verify"
    file: "08-verify.md"
    description: "verify"
---

# Audit Pre Release Workflow

_Generated projection from canonical pipeline `audit-pre-release-workflow`._

## Usage

```text
/audit-pre-release-workflow
```

## Target

This projection wraps the canonical pipeline `audit-pre-release-workflow` for staged human review and slash-facing compatibility.

## Prerequisites

- Required pipeline inputs are available.
- Canonical pipeline assets exist under `.harmony/orchestration/runtime/pipelines/audit/audit-pre-release-workflow`.

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
- The backing canonical pipeline contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `pre_release_report` -> `../../output/reports/{{date}}-audit-pre-release-workflow.md`: Consolidated pre-release audit report with go/no-go recommendation
- `health_audit_report` -> `../../output/reports/{{date}}-subsystem-health-audit.md`: Individual health audit report (produced by audit-subsystem-health)
- `migration_audit_report` -> `../../output/reports/{{date}}-migration-audit-consolidated.md`: Consolidated migration audit report (produced by audit-orchestration-workflow in migration-only mode, if manifest provided)
- `cross_subsystem_audit_report` -> `../../output/reports/{{date}}-cross-subsystem-coherence-audit.md`: Individual cross-subsystem coherence audit report (produced by audit-cross-subsystem-coherence, if enabled)
- `freshness_audit_report` -> `../../output/reports/{{date}}-freshness-and-supersession-audit.md`: Individual freshness and supersession audit report (produced by audit-freshness-and-supersession, if enabled)
- `pre_release_audit_bundle` -> `../../output/reports/audits/{{date}}-{{slug}}/`: Authoritative bounded-audit bundle for release recommendation, context-governance evidence, and done-gate verification

## Steps

1. [configure](./01-configure.md)
2. [migration-audit](./02-migration-audit.md)
3. [health-audit](./03-health-audit.md)
4. [cross-subsystem-audit](./04-cross-subsystem-audit.md)
5. [freshness-audit](./05-freshness-audit.md)
6. [merge](./06-merge.md)
7. [report](./07-report.md)
8. [verify](./08-verify.md)

## Verification Gate

- [ ] All planned stages executed or explicitly skipped
- [ ] Consolidated report exists at `.harmony/output/reports/YYYY-MM-DD-audit-pre-release-workflow.md`
- [ ] Pre-release bundle exists at `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`
- [ ] Findings are deduplicated with stable IDs and acceptance criteria
- [ ] Coverage and convergence metadata are recorded
- [ ] Instruction-layer manifest evidence exists for material policy runs
- [ ] Context-acquisition telemetry fields are present in receipts/digests
- [ ] Context governance validators pass (`validate-developer-context-policy.sh`, `validate-context-overhead-budget.sh`)
- [ ] Recommendation and done-gate rationale are explicit

## Version History

| Version | Changes |
|---------|---------|
| 2.2.0 | Generated from canonical pipeline `audit-pre-release-workflow` |

## References

- Canonical pipeline: `.harmony/orchestration/runtime/pipelines/audit/audit-pre-release-workflow/`
