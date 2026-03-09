---
name: "audit-release-readiness-workflow"
description: "Orchestrate layered bounded audits (release core, operational readiness, API contract, test quality, observability, security, and data governance) into a deterministic release gate with stable finding identity, coverage accounting, and explicit done-gate evaluation."
steps:
  - id: "configure"
    file: "01-configure.md"
    description: "configure"
  - id: "release-core-audit"
    file: "02-release-core-audit.md"
    description: "release-core-audit"
  - id: "operational-readiness-audit"
    file: "03-operational-readiness-audit.md"
    description: "operational-readiness-audit"
  - id: "api-contract-audit"
    file: "04-api-contract-audit.md"
    description: "api-contract-audit"
  - id: "test-quality-audit"
    file: "05-test-quality-audit.md"
    description: "test-quality-audit"
  - id: "observability-audit"
    file: "06-observability-audit.md"
    description: "observability-audit"
  - id: "security-audit"
    file: "07-security-audit.md"
    description: "security-audit"
  - id: "data-governance-audit"
    file: "08-data-governance-audit.md"
    description: "data-governance-audit"
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

# Audit Release Readiness Workflow

_Generated projection from canonical pipeline `audit-release-readiness-workflow`._

## Usage

```text
/audit-release-readiness-workflow
```

## Target

This projection wraps the canonical pipeline `audit-release-readiness-workflow` for staged human review and slash-facing compatibility.

## Prerequisites

- Required pipeline inputs are available.
- Canonical pipeline assets exist under `.harmony/orchestration/runtime/pipelines/audit/audit-release-readiness-workflow`.

## Parameters

- `scope` (folder, required=true): Root directory containing release-relevant artifacts to audit
- `severity_threshold` (text, required=false), default=`all`: Minimum severity to report: critical, high, medium, low, all
- `run_operational` (boolean, required=false), default=`true`: Run audit-operational-readiness stage
- `run_api_contract` (boolean, required=false), default=`true`: Run audit-api-contract stage
- `run_test_quality` (boolean, required=false), default=`true`: Run audit-test-quality stage
- `run_observability` (boolean, required=false), default=`true`: Run audit-observability-coverage stage
- `run_security` (boolean, required=false), default=`true`: Run audit-security-compliance stage
- `run_data_governance` (boolean, required=false), default=`true`: Run audit-data-governance stage
- `post_remediation` (boolean, required=false): Enable strict done-gate enforcement for remediation verification
- `convergence_k` (text, required=false), default=`3`: Number of controlled reruns used to evaluate convergence stability
- `seed_list` (text, required=false): Comma-separated deterministic seeds used for multi-run consistency checks

## Failure Conditions

- Required inputs are missing or invalid.
- The backing canonical pipeline contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `release_readiness_workflow_report` -> `../../output/reports/{{date}}-audit-release-readiness-workflow.md`: Consolidated layered release-readiness workflow report with recommendation
- `release_core_audit_report` -> `../../output/reports/{{date}}-audit-release-readiness-{{run_id}}.md`: Release-core stage report produced by audit-release-readiness
- `operational_readiness_audit_report` -> `../../output/reports/{{date}}-operational-readiness-audit-{{run_id}}.md`: Operational-readiness stage report (produced if enabled)
- `api_contract_audit_report` -> `../../output/reports/{{date}}-api-contract-audit-{{run_id}}.md`: API-contract stage report (produced if enabled)
- `test_quality_audit_report` -> `../../output/reports/{{date}}-test-quality-audit-{{run_id}}.md`: Test-quality stage report (produced if enabled)
- `observability_coverage_audit_report` -> `../../output/reports/{{date}}-observability-coverage-audit-{{run_id}}.md`: Observability-coverage stage report (produced if enabled)
- `security_compliance_audit_report` -> `../../output/reports/{{date}}-security-compliance-audit-{{run_id}}.md`: Security-compliance stage report (produced if enabled)
- `data_governance_audit_report` -> `../../output/reports/{{date}}-data-governance-audit-{{run_id}}.md`: Data-governance stage report (produced if enabled)
- `release_readiness_audit_bundle` -> `../../output/reports/audits/{{date}}-{{slug}}/`: Authoritative bounded-audit bundle for layered release-readiness recommendation and done-gate evidence

## Steps

1. [configure](./01-configure.md)
2. [release-core-audit](./02-release-core-audit.md)
3. [operational-readiness-audit](./03-operational-readiness-audit.md)
4. [api-contract-audit](./04-api-contract-audit.md)
5. [test-quality-audit](./05-test-quality-audit.md)
6. [observability-audit](./06-observability-audit.md)
7. [security-audit](./07-security-audit.md)
8. [data-governance-audit](./08-data-governance-audit.md)
9. [merge](./09-merge.md)
10. [report](./10-report.md)
11. [verify](./11-verify.md)

## Verification Gate

- [ ] All enabled stages executed or explicitly skipped
- [ ] Consolidated workflow report exists
- [ ] Bounded bundle exists at `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`
- [ ] Findings are deduplicated with stable IDs and acceptance criteria
- [ ] Coverage and convergence metadata are present
- [ ] Done-gate expression is evaluated and recorded
- [ ] If `post_remediation=true`, done-gate is true

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical pipeline `audit-release-readiness-workflow` |

## References

- Canonical pipeline: `.harmony/orchestration/runtime/pipelines/audit/audit-release-readiness-workflow/`
