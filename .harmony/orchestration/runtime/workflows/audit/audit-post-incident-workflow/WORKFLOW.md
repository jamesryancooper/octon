---
name: "audit-post-incident-workflow"
description: "Orchestrate a layered bounded post-incident audit across operational readiness, observability coverage, security/compliance posture, data governance controls, API-contract safety, test-quality containment, cross-subsystem coherence, and freshness integrity. Produces deterministic evidence with stable finding IDs, coverage accounting, and explicit done-gate evaluation for incident remediation closure."
steps:
  - id: "configure"
    file: "01-configure.md"
    description: "configure"
  - id: "operational-readiness-audit"
    file: "02-operational-readiness-audit.md"
    description: "operational-readiness-audit"
  - id: "observability-audit"
    file: "03-observability-audit.md"
    description: "observability-audit"
  - id: "security-audit"
    file: "04-security-audit.md"
    description: "security-audit"
  - id: "data-governance-audit"
    file: "05-data-governance-audit.md"
    description: "data-governance-audit"
  - id: "api-contract-audit"
    file: "06-api-contract-audit.md"
    description: "api-contract-audit"
  - id: "test-quality-audit"
    file: "07-test-quality-audit.md"
    description: "test-quality-audit"
  - id: "cross-subsystem-audit"
    file: "08-cross-subsystem-audit.md"
    description: "cross-subsystem-audit"
  - id: "freshness-audit"
    file: "09-freshness-audit.md"
    description: "freshness-audit"
  - id: "merge"
    file: "10-merge.md"
    description: "merge"
  - id: "report"
    file: "11-report.md"
    description: "report"
  - id: "verify"
    file: "12-verify.md"
    description: "verify"
---

# Audit Post Incident Workflow

_Generated projection from canonical pipeline `audit-post-incident-workflow`._

## Usage

```text
/audit-post-incident-workflow
```

## Target

This projection wraps the canonical pipeline `audit-post-incident-workflow` for staged human review and slash-facing compatibility.

## Prerequisites

- Required pipeline inputs are available.
- Canonical pipeline assets exist under `.harmony/orchestration/runtime/pipelines/audit/audit-post-incident-workflow`.

## Parameters

- `incident_id` (text, required=true): Unique incident identifier used for traceability (for example INC-2026-02-23-001)
- `subsystem` (folder, required=true): Root directory of the incident-affected subsystem to audit
- `incident_report` (file, required=false): Incident report or RCA reference used for contextual grounding
- `docs` (folder, required=false): Companion documentation directory for optional coherence checks
- `severity_threshold` (text, required=false), default=`all`: Minimum severity to report: critical, high, medium, low, all
- `run_security` (boolean, required=false), default=`true`: Run security/compliance post-incident stage
- `run_data_governance` (boolean, required=false), default=`true`: Run data-governance post-incident stage
- `run_api_contract` (boolean, required=false), default=`true`: Run API-contract post-incident stage
- `run_test_quality` (boolean, required=false), default=`true`: Run test-quality post-incident stage
- `run_cross_subsystem` (boolean, required=false), default=`true`: Run cross-subsystem coherence post-incident stage
- `run_freshness` (boolean, required=false), default=`true`: Run freshness/supersession post-incident stage
- `max_age_days` (text, required=false), default=`30`: Freshness threshold in days when run_freshness is enabled
- `post_remediation` (boolean, required=false): Enable strict done-gate enforcement for remediation verification
- `convergence_k` (text, required=false), default=`3`: Number of controlled reruns used to evaluate convergence stability
- `seed_list` (text, required=false): Comma-separated deterministic seeds used for multi-run consistency checks

## Failure Conditions

- Required inputs are missing or invalid.
- The backing canonical pipeline contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `post_incident_report` -> `../../output/reports/{{date}}-audit-post-incident-workflow.md`: Consolidated post-incident closure report with residual risk recommendation
- `operational_readiness_audit_report` -> `../../output/reports/{{date}}-operational-readiness-audit-{{run_id}}.md`: Operational-readiness stage report (mandatory)
- `observability_coverage_audit_report` -> `../../output/reports/{{date}}-observability-coverage-audit-{{run_id}}.md`: Observability-coverage stage report (mandatory)
- `security_compliance_audit_report` -> `../../output/reports/{{date}}-security-compliance-audit-{{run_id}}.md`: Security-compliance stage report (produced if enabled)
- `data_governance_audit_report` -> `../../output/reports/{{date}}-data-governance-audit-{{run_id}}.md`: Data-governance stage report (produced if enabled)
- `api_contract_audit_report` -> `../../output/reports/{{date}}-api-contract-audit-{{run_id}}.md`: API-contract stage report (produced if enabled)
- `test_quality_audit_report` -> `../../output/reports/{{date}}-test-quality-audit-{{run_id}}.md`: Test-quality stage report (produced if enabled)
- `cross_subsystem_audit_report` -> `../../output/reports/{{date}}-cross-subsystem-coherence-audit.md`: Cross-subsystem stage report (produced if enabled)
- `freshness_audit_report` -> `../../output/reports/{{date}}-freshness-and-supersession-audit.md`: Freshness stage report (produced if enabled)
- `post_incident_audit_bundle` -> `../../output/reports/audits/{{date}}-{{slug}}/`: Authoritative bounded-audit bundle for post-incident closure recommendation and done-gate evidence

## Steps

1. [configure](./01-configure.md)
2. [operational-readiness-audit](./02-operational-readiness-audit.md)
3. [observability-audit](./03-observability-audit.md)
4. [security-audit](./04-security-audit.md)
5. [data-governance-audit](./05-data-governance-audit.md)
6. [api-contract-audit](./06-api-contract-audit.md)
7. [test-quality-audit](./07-test-quality-audit.md)
8. [cross-subsystem-audit](./08-cross-subsystem-audit.md)
9. [freshness-audit](./09-freshness-audit.md)
10. [merge](./10-merge.md)
11. [report](./11-report.md)
12. [verify](./12-verify.md)

## Verification Gate

- [ ] All enabled stages executed or explicitly skipped
- [ ] Consolidated post-incident report exists
- [ ] Bounded bundle exists at `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`
- [ ] Findings are deduplicated with stable IDs and acceptance criteria
- [ ] Coverage and convergence metadata are present
- [ ] Done-gate expression is evaluated and recorded
- [ ] If `post_remediation=true`, done-gate is true

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical pipeline `audit-post-incident-workflow` |

## References

- Canonical pipeline: `.harmony/orchestration/runtime/pipelines/audit/audit-post-incident-workflow/`
