---
name: "audit-continuous-workflow"
description: "Orchestrate a layered bounded continuous audit across subsystem integrity, observability, operational readiness, API contracts, test quality, security, data governance, cross-subsystem coherence, and freshness. Produces deterministic evidence with stable finding IDs, coverage accounting, and explicit done-gate evaluation for recurring risk control."
steps:
  - id: "configure"
    file: "01-configure.md"
    description: "configure"
  - id: "subsystem-health-audit"
    file: "02-subsystem-health-audit.md"
    description: "subsystem-health-audit"
  - id: "observability-audit"
    file: "03-observability-audit.md"
    description: "observability-audit"
  - id: "operational-readiness-audit"
    file: "04-operational-readiness-audit.md"
    description: "operational-readiness-audit"
  - id: "api-contract-audit"
    file: "05-api-contract-audit.md"
    description: "api-contract-audit"
  - id: "test-quality-audit"
    file: "06-test-quality-audit.md"
    description: "test-quality-audit"
  - id: "security-audit"
    file: "07-security-audit.md"
    description: "security-audit"
  - id: "data-governance-audit"
    file: "08-data-governance-audit.md"
    description: "data-governance-audit"
  - id: "cross-subsystem-audit"
    file: "09-cross-subsystem-audit.md"
    description: "cross-subsystem-audit"
  - id: "freshness-audit"
    file: "10-freshness-audit.md"
    description: "freshness-audit"
  - id: "merge"
    file: "11-merge.md"
    description: "merge"
  - id: "report"
    file: "12-report.md"
    description: "report"
  - id: "verify"
    file: "13-verify.md"
    description: "verify"
---

# Audit Continuous Workflow

_Generated projection from canonical pipeline `audit-continuous-workflow`._

## Usage

```text
/audit-continuous-workflow
```

## Target

This projection wraps the canonical pipeline `audit-continuous-workflow` for staged human review and slash-facing compatibility.

## Prerequisites

- Required pipeline inputs are available.
- Canonical pipeline assets exist under `.harmony/orchestration/runtime/pipelines/audit/audit-continuous-workflow`.

## Parameters

- `subsystem` (folder, required=true): Root directory of the subsystem to continuously audit
- `docs` (folder, required=false): Companion documentation directory for optional coherence checks
- `severity_threshold` (text, required=false), default=`all`: Minimum severity to report: critical, high, medium, low, all
- `cadence` (text, required=false), default=`weekly`: Continuous execution cadence metadata: daily or weekly
- `lookback_days` (text, required=false), default=`7`: Historical lookback window in days used for trend context
- `run_operational` (boolean, required=false), default=`true`: Run operational-readiness layer
- `run_api_contract` (boolean, required=false), default=`true`: Run API-contract layer
- `run_test_quality` (boolean, required=false), default=`true`: Run test-quality layer
- `run_security` (boolean, required=false), default=`true`: Run security/compliance layer
- `run_data_governance` (boolean, required=false), default=`true`: Run data-governance layer
- `run_cross_subsystem` (boolean, required=false), default=`true`: Run cross-subsystem coherence layer
- `run_freshness` (boolean, required=false), default=`true`: Run freshness and supersession layer
- `max_age_days` (text, required=false), default=`30`: Freshness threshold in days when run_freshness is enabled
- `post_remediation` (boolean, required=false): Enable strict done-gate enforcement for remediation verification
- `convergence_k` (text, required=false), default=`3`: Number of controlled reruns used to evaluate convergence stability
- `seed_list` (text, required=false): Comma-separated deterministic seeds used for multi-run consistency checks

## Failure Conditions

- Required inputs are missing or invalid.
- The backing canonical pipeline contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `continuous_audit_report` -> `../../output/reports/{{date}}-audit-continuous-workflow.md`: Consolidated audit-continuous-workflow report with ongoing risk recommendation
- `subsystem_health_audit_report` -> `../../output/reports/{{date}}-subsystem-health-audit.md`: Subsystem-health stage report (mandatory)
- `observability_coverage_audit_report` -> `../../output/reports/{{date}}-observability-coverage-audit-{{run_id}}.md`: Observability-coverage stage report (mandatory)
- `operational_readiness_audit_report` -> `../../output/reports/{{date}}-operational-readiness-audit-{{run_id}}.md`: Operational-readiness stage report (produced if enabled)
- `api_contract_audit_report` -> `../../output/reports/{{date}}-api-contract-audit-{{run_id}}.md`: API-contract stage report (produced if enabled)
- `test_quality_audit_report` -> `../../output/reports/{{date}}-test-quality-audit-{{run_id}}.md`: Test-quality stage report (produced if enabled)
- `security_compliance_audit_report` -> `../../output/reports/{{date}}-security-compliance-audit-{{run_id}}.md`: Security-compliance stage report (produced if enabled)
- `data_governance_audit_report` -> `../../output/reports/{{date}}-data-governance-audit-{{run_id}}.md`: Data-governance stage report (produced if enabled)
- `cross_subsystem_audit_report` -> `../../output/reports/{{date}}-cross-subsystem-coherence-audit.md`: Cross-subsystem stage report (produced if enabled)
- `freshness_audit_report` -> `../../output/reports/{{date}}-freshness-and-supersession-audit.md`: Freshness stage report (produced if enabled)
- `continuous_audit_bundle` -> `../../output/reports/audits/{{date}}-{{slug}}/`: Authoritative bounded-audit bundle for continuous risk recommendation and done-gate evidence

## Steps

1. [configure](./01-configure.md)
2. [subsystem-health-audit](./02-subsystem-health-audit.md)
3. [observability-audit](./03-observability-audit.md)
4. [operational-readiness-audit](./04-operational-readiness-audit.md)
5. [api-contract-audit](./05-api-contract-audit.md)
6. [test-quality-audit](./06-test-quality-audit.md)
7. [security-audit](./07-security-audit.md)
8. [data-governance-audit](./08-data-governance-audit.md)
9. [cross-subsystem-audit](./09-cross-subsystem-audit.md)
10. [freshness-audit](./10-freshness-audit.md)
11. [merge](./11-merge.md)
12. [report](./12-report.md)
13. [verify](./13-verify.md)

## Verification Gate

- [ ] All enabled stages executed or explicitly skipped
- [ ] Consolidated audit-continuous-workflow report exists
- [ ] Bounded bundle exists at `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`
- [ ] Findings are deduplicated with stable IDs and acceptance criteria
- [ ] Coverage and convergence metadata are present
- [ ] Done-gate expression is evaluated and recorded
- [ ] If `post_remediation=true`, done-gate is true

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical pipeline `audit-continuous-workflow` |

## References

- Canonical pipeline: `.harmony/orchestration/runtime/pipelines/audit/audit-continuous-workflow/`
