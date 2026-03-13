---
name: "audit-release-readiness"
description: "Orchestrate layered bounded audits (release core, operational readiness, API contract, test quality, observability, security, and data governance) into a deterministic release gate with stable finding identity, coverage accounting, and explicit done-gate evaluation."
steps:
  - id: "configure"
    file: "stages/01-configure.md"
    description: "configure"
  - id: "release-core-audit"
    file: "stages/02-release-core-audit.md"
    description: "release-core-audit"
  - id: "operational-readiness-audit"
    file: "stages/03-operational-readiness-audit.md"
    description: "operational-readiness-audit"
  - id: "api-contract-audit"
    file: "stages/04-api-contract-audit.md"
    description: "api-contract-audit"
  - id: "test-quality-audit"
    file: "stages/05-test-quality-audit.md"
    description: "test-quality-audit"
  - id: "observability-audit"
    file: "stages/06-observability-audit.md"
    description: "observability-audit"
  - id: "security-audit"
    file: "stages/07-security-audit.md"
    description: "security-audit"
  - id: "data-governance-audit"
    file: "stages/08-data-governance-audit.md"
    description: "data-governance-audit"
  - id: "merge"
    file: "stages/09-merge.md"
    description: "merge"
  - id: "report"
    file: "stages/10-report.md"
    description: "report"
  - id: "verify"
    file: "stages/11-verify.md"
    description: "verify"
---

# Audit Release Readiness

_Generated README from canonical workflow `audit-release-readiness`._

## Usage

```text
/audit-release-readiness
```

## Purpose

Orchestrate layered bounded audits (release core, operational readiness, API contract, test quality, observability, security, and data governance) into a deterministic release gate with stable finding identity, coverage accounting, and explicit done-gate evaluation.

## Target

This README summarizes the canonical workflow unit at `.octon/orchestration/runtime/workflows/audit/audit-release-readiness`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/orchestration/runtime/workflows/audit/audit-release-readiness/workflow.yml`.

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
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `release_readiness_workflow_report` -> `../../output/reports/analysis/{{date}}-audit-release-readiness.md`: Consolidated layered release-readiness workflow report with recommendation
- `release_core_audit_report` -> `../../output/reports/analysis/{{date}}-audit-release-readiness-{{run_id}}.md`: Release-core stage report produced by audit-release-readiness
- `operational_readiness_audit_report` -> `../../output/reports/analysis/{{date}}-operational-readiness-audit-{{run_id}}.md`: Operational-readiness stage report (produced if enabled)
- `api_contract_audit_report` -> `../../output/reports/analysis/{{date}}-api-contract-audit-{{run_id}}.md`: API-contract stage report (produced if enabled)
- `test_quality_audit_report` -> `../../output/reports/analysis/{{date}}-test-quality-audit-{{run_id}}.md`: Test-quality stage report (produced if enabled)
- `observability_coverage_audit_report` -> `../../output/reports/analysis/{{date}}-observability-coverage-audit-{{run_id}}.md`: Observability-coverage stage report (produced if enabled)
- `security_compliance_audit_report` -> `../../output/reports/analysis/{{date}}-security-compliance-audit-{{run_id}}.md`: Security-compliance stage report (produced if enabled)
- `data_governance_audit_report` -> `../../output/reports/analysis/{{date}}-data-governance-audit-{{run_id}}.md`: Data-governance stage report (produced if enabled)
- `release_readiness_audit_bundle` -> `../../output/reports/audits/{{date}}-{{slug}}/`: Authoritative bounded-audit bundle for layered release-readiness recommendation and done-gate evidence

## Steps

1. [configure](./stages/01-configure.md)
2. [release-core-audit](./stages/02-release-core-audit.md)
3. [operational-readiness-audit](./stages/03-operational-readiness-audit.md)
4. [api-contract-audit](./stages/04-api-contract-audit.md)
5. [test-quality-audit](./stages/05-test-quality-audit.md)
6. [observability-audit](./stages/06-observability-audit.md)
7. [security-audit](./stages/07-security-audit.md)
8. [data-governance-audit](./stages/08-data-governance-audit.md)
9. [merge](./stages/09-merge.md)
10. [report](./stages/10-report.md)
11. [verify](./stages/11-verify.md)

## Verification Gate

- [ ] All enabled stages executed or explicitly skipped
- [ ] Consolidated workflow report exists
- [ ] Bounded bundle exists at `.octon/output/reports/audits/YYYY-MM-DD-<slug>/`
- [ ] Findings are deduplicated with stable IDs and acceptance criteria
- [ ] Coverage and convergence metadata are present
- [ ] Done-gate expression is evaluated and recorded
- [ ] If `post_remediation=true`, done-gate is true

## References

- Canonical contract: `.octon/orchestration/runtime/workflows/audit/audit-release-readiness/workflow.yml`
- Canonical stages: `.octon/orchestration/runtime/workflows/audit/audit-release-readiness/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `audit-release-readiness` |

