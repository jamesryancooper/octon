---
name: "audit-change-risk-workflow"
description: "Orchestrate layered bounded audits to quantify change risk across subsystem integrity, migration impact, API contracts, test quality, operational readiness, cross-subsystem coherence, and freshness. Produces deterministic evidence with stable finding IDs, coverage accounting, and explicit done-gate evaluation."
steps:
  - id: "configure"
    file: "01-configure.md"
    description: "configure"
  - id: "subsystem-health-audit"
    file: "02-subsystem-health-audit.md"
    description: "subsystem-health-audit"
  - id: "migration-impact-audit"
    file: "03-migration-impact-audit.md"
    description: "migration-impact-audit"
  - id: "api-contract-audit"
    file: "04-api-contract-audit.md"
    description: "api-contract-audit"
  - id: "test-quality-audit"
    file: "05-test-quality-audit.md"
    description: "test-quality-audit"
  - id: "operational-readiness-audit"
    file: "06-operational-readiness-audit.md"
    description: "operational-readiness-audit"
  - id: "cross-subsystem-audit"
    file: "07-cross-subsystem-audit.md"
    description: "cross-subsystem-audit"
  - id: "freshness-audit"
    file: "08-freshness-audit.md"
    description: "freshness-audit"
  - id: "merge"
    file: "09-merge.md"
    description: "merge"
  - id: "report"
    file: "10-report.md"
    description: "report"
  - id: "verify"
    file: "11-verify.md"
    description: "verify"
---

# Audit Change Risk Workflow

_Generated projection from canonical pipeline `audit-change-risk-workflow`._

## Usage

```text
/audit-change-risk-workflow
```

## Target

This projection wraps the canonical pipeline `audit-change-risk-workflow` for staged human review and slash-facing compatibility.

## Prerequisites

- Required pipeline inputs are available.
- Canonical pipeline assets exist under `.harmony/orchestration/runtime/pipelines/audit/audit-change-risk-workflow`.

## Parameters

- `subsystem` (folder, required=true): Root directory of the changed subsystem to audit
- `manifest` (file, required=false): Migration manifest (inline YAML or file path) used for migration-impact checks
- `docs` (folder, required=false): Companion documentation directory for optional coherence checks
- `severity_threshold` (text, required=false), default=`all`: Minimum severity to report: critical, high, medium, low, all
- `run_migration` (boolean, required=false), default=`true`: Run migration-impact stage when manifest is available
- `run_api_contract` (boolean, required=false), default=`true`: Run API-contract risk stage
- `run_test_quality` (boolean, required=false), default=`true`: Run test-quality containment-risk stage
- `run_operational` (boolean, required=false), default=`true`: Run operational-readiness risk stage
- `run_cross_subsystem` (boolean, required=false), default=`true`: Run cross-subsystem coherence contagion-risk stage
- `run_freshness` (boolean, required=false), default=`true`: Run freshness and supersession stale-context risk stage
- `max_age_days` (text, required=false), default=`30`: Freshness threshold in days when run_freshness is enabled
- `post_remediation` (boolean, required=false): Enable strict done-gate enforcement for remediation verification
- `convergence_k` (text, required=false), default=`3`: Number of controlled reruns used to evaluate convergence stability
- `seed_list` (text, required=false): Comma-separated deterministic seeds used for multi-run consistency checks

## Failure Conditions

- Required inputs are missing or invalid.
- The backing canonical pipeline contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `change_risk_report` -> `../../output/reports/{{date}}-audit-change-risk-workflow.md`: Consolidated change-risk report with risk tier and recommendation
- `subsystem_health_audit_report` -> `../../output/reports/{{date}}-subsystem-health-audit.md`: Subsystem-health stage report (mandatory)
- `migration_audit_report` -> `../../output/reports/{{date}}-migration-audit.md`: Migration-impact stage report (produced if enabled and manifest is provided)
- `api_contract_audit_report` -> `../../output/reports/{{date}}-api-contract-audit-{{run_id}}.md`: API-contract stage report (produced if enabled)
- `test_quality_audit_report` -> `../../output/reports/{{date}}-test-quality-audit-{{run_id}}.md`: Test-quality stage report (produced if enabled)
- `operational_readiness_audit_report` -> `../../output/reports/{{date}}-operational-readiness-audit-{{run_id}}.md`: Operational-readiness stage report (produced if enabled)
- `cross_subsystem_audit_report` -> `../../output/reports/{{date}}-cross-subsystem-coherence-audit.md`: Cross-subsystem stage report (produced if enabled)
- `freshness_audit_report` -> `../../output/reports/{{date}}-freshness-and-supersession-audit.md`: Freshness stage report (produced if enabled)
- `change_risk_audit_bundle` -> `../../output/reports/audits/{{date}}-{{slug}}/`: Authoritative bounded-audit bundle for change-risk recommendation and done-gate evidence

## Steps

1. [configure](./01-configure.md)
2. [subsystem-health-audit](./02-subsystem-health-audit.md)
3. [migration-impact-audit](./03-migration-impact-audit.md)
4. [api-contract-audit](./04-api-contract-audit.md)
5. [test-quality-audit](./05-test-quality-audit.md)
6. [operational-readiness-audit](./06-operational-readiness-audit.md)
7. [cross-subsystem-audit](./07-cross-subsystem-audit.md)
8. [freshness-audit](./08-freshness-audit.md)
9. [merge](./09-merge.md)
10. [report](./10-report.md)
11. [verify](./11-verify.md)

## Verification Gate

- [ ] All enabled stages executed or explicitly skipped
- [ ] Consolidated change-risk report exists
- [ ] Bounded bundle exists at `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`
- [ ] Findings are deduplicated with stable IDs and acceptance criteria
- [ ] Coverage and convergence metadata are present
- [ ] Done-gate expression is evaluated and recorded
- [ ] If `post_remediation=true`, done-gate is true

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical pipeline `audit-change-risk-workflow` |

## References

- Canonical pipeline: `.harmony/orchestration/runtime/pipelines/audit/audit-change-risk-workflow/`
