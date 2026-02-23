---
name: post-incident-audit
description: >
  Orchestrate a layered bounded post-incident audit across operational
  readiness, observability coverage, security/compliance posture, data
  governance controls, API-contract safety, test-quality containment,
  cross-subsystem coherence, and freshness integrity. Produces deterministic
  evidence with stable finding IDs, coverage accounting, and explicit done-gate
  evaluation for incident remediation closure.
steps:
  - id: configure
    file: 01-configure.md
    description: Parse incident parameters, scope, and deterministic controls.
  - id: operational-readiness-audit
    file: 02-operational-readiness-audit.md
    description: Run audit-operational-readiness as mandatory incident-response layer.
  - id: observability-audit
    file: 03-observability-audit.md
    description: Run audit-observability-coverage as mandatory detection/diagnostics layer.
  - id: security-audit
    file: 04-security-audit.md
    description: Run audit-security-compliance unless explicitly disabled.
  - id: data-governance-audit
    file: 05-data-governance-audit.md
    description: Run audit-data-governance unless explicitly disabled.
  - id: api-contract-audit
    file: 06-api-contract-audit.md
    description: Run audit-api-contract unless explicitly disabled.
  - id: test-quality-audit
    file: 07-test-quality-audit.md
    description: Run audit-test-quality unless explicitly disabled.
  - id: cross-subsystem-audit
    file: 08-cross-subsystem-audit.md
    description: Run audit-cross-subsystem-coherence unless explicitly disabled.
  - id: freshness-audit
    file: 09-freshness-audit.md
    description: Run audit-freshness-and-supersession unless explicitly disabled.
  - id: merge
    file: 10-merge.md
    description: Merge stage outputs into stable post-incident risk and remediation set.
  - id: report
    file: 11-report.md
    description: Generate consolidated post-incident report and bounded-audit evidence bundle.
  - id: verify
    file: 12-verify.md
    description: Validate workflow contract and mode-specific done-gate outcomes.
# --- Harmony extensions ---
access: human
version: "1.0.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".harmony/continuity/checkpoints/"
parallel_steps: []
---

# Post-Incident Audit: Overview

Run a bounded layered post-incident gate that evaluates whether remediation is sufficient to close incident risk and prevent recurrence.

## Usage

```text
/post-incident-audit incident_id="INC-2026-02-23-001" subsystem=".harmony/capabilities/runtime/services"
```

With strict post-remediation gate:

```text
/post-incident-audit incident_id="INC-2026-02-23-001" subsystem=".harmony/capabilities/runtime/services" post_remediation="true" convergence_k="3" seed_list="11,23,37"
```

## Target

An incident-affected subsystem that requires evidence-backed closure validation across response, detection, security, governance, interface, and regression-control lenses.

## Prerequisites

- `audit-operational-readiness` skill is active
- `audit-observability-coverage` skill is active
- `audit-security-compliance` skill is active when `run_security=true`
- `audit-data-governance` skill is active when `run_data_governance=true`
- `audit-api-contract` skill is active when `run_api_contract=true`
- `audit-test-quality` skill is active when `run_test_quality=true`
- `audit-cross-subsystem-coherence` skill is active when `run_cross_subsystem=true`
- `audit-freshness-and-supersession` skill is active when `run_freshness=true`

## Failure Conditions

- `incident_id` missing -> STOP, report configuration error
- `subsystem` missing or unreadable -> STOP, report configuration error
- mandatory layers fail with no recoverable prior report -> FAIL workflow
- merged coverage cannot account for in-scope surfaces -> FAIL done-gate

## Steps

1. [Configure](./01-configure.md)
2. [Operational Readiness Audit](./02-operational-readiness-audit.md)
3. [Observability Audit](./03-observability-audit.md)
4. [Security Audit](./04-security-audit.md)
5. [Data Governance Audit](./05-data-governance-audit.md)
6. [API Contract Audit](./06-api-contract-audit.md)
7. [Test Quality Audit](./07-test-quality-audit.md)
8. [Cross-Subsystem Audit](./08-cross-subsystem-audit.md)
9. [Freshness Audit](./09-freshness-audit.md)
10. [Merge](./10-merge.md)
11. [Report](./11-report.md)
12. [Verify](./12-verify.md)

## Verification Gate

Workflow verification must prove:

- [ ] All enabled stages executed or explicitly skipped
- [ ] Consolidated post-incident report exists
- [ ] Bounded bundle exists at `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`
- [ ] Findings are deduplicated with stable IDs and acceptance criteria
- [ ] Coverage and convergence metadata are present
- [ ] Done-gate expression is evaluated and recorded
- [ ] If `post_remediation=true`, done-gate is true

## Outputs

- Consolidated workflow report:
  - `.harmony/output/reports/YYYY-MM-DD-post-incident-audit.md`
- Authoritative bounded-audit bundle:
  - `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`

## Version History

| Version | Date | Changes |
| ------- | ---- | ------- |
| 1.0.0 | 2026-02-23 | Initial bounded layered post-incident workflow |
