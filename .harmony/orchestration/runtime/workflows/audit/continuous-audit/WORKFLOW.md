---
name: continuous-audit
description: >
  Orchestrate a layered bounded continuous audit across subsystem integrity,
  observability, operational readiness, API contracts, test quality, security,
  data governance, cross-subsystem coherence, and freshness. Produces
  deterministic evidence with stable finding IDs, coverage accounting, and
  explicit done-gate evaluation for recurring risk control.
steps:
  - id: configure
    file: 01-configure.md
    description: Parse continuous-audit parameters, cadence metadata, and deterministic controls.
  - id: subsystem-health-audit
    file: 02-subsystem-health-audit.md
    description: Run audit-subsystem-health as mandatory integrity baseline layer.
  - id: observability-audit
    file: 03-observability-audit.md
    description: Run audit-observability-coverage as mandatory drift-detection layer.
  - id: operational-readiness-audit
    file: 04-operational-readiness-audit.md
    description: Run audit-operational-readiness unless explicitly disabled.
  - id: api-contract-audit
    file: 05-api-contract-audit.md
    description: Run audit-api-contract unless explicitly disabled.
  - id: test-quality-audit
    file: 06-test-quality-audit.md
    description: Run audit-test-quality unless explicitly disabled.
  - id: security-audit
    file: 07-security-audit.md
    description: Run audit-security-compliance unless explicitly disabled.
  - id: data-governance-audit
    file: 08-data-governance-audit.md
    description: Run audit-data-governance unless explicitly disabled.
  - id: cross-subsystem-audit
    file: 09-cross-subsystem-audit.md
    description: Run audit-cross-subsystem-coherence unless explicitly disabled.
  - id: freshness-audit
    file: 10-freshness-audit.md
    description: Run audit-freshness-and-supersession unless explicitly disabled.
  - id: merge
    file: 11-merge.md
    description: Merge stage outputs into stable continuous-risk findings and trend posture.
  - id: report
    file: 12-report.md
    description: Generate consolidated continuous-audit report and bounded-audit evidence bundle.
  - id: verify
    file: 13-verify.md
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

# Continuous Audit: Overview

Run a bounded layered continuous audit that tracks ongoing subsystem risk posture with deterministic evidence and recurring controls.

## Usage

```text
/continuous-audit subsystem=".harmony/capabilities/runtime/services"
```

With strict post-remediation gate:

```text
/continuous-audit subsystem=".harmony/capabilities/runtime/services" cadence="weekly" lookback_days="14" post_remediation="true" convergence_k="3" seed_list="11,23,37"
```

## Target

A subsystem that requires ongoing health and drift monitoring across integrity, telemetry, operations, interface, quality, security, governance, and currency layers.

## Prerequisites

- `audit-subsystem-health` skill is active
- `audit-observability-coverage` skill is active
- `audit-operational-readiness` skill is active when `run_operational=true`
- `audit-api-contract` skill is active when `run_api_contract=true`
- `audit-test-quality` skill is active when `run_test_quality=true`
- `audit-security-compliance` skill is active when `run_security=true`
- `audit-data-governance` skill is active when `run_data_governance=true`
- `audit-cross-subsystem-coherence` skill is active when `run_cross_subsystem=true`
- `audit-freshness-and-supersession` skill is active when `run_freshness=true`

## Failure Conditions

- `subsystem` missing or unreadable -> STOP, report configuration error
- mandatory layers fail with no recoverable prior report -> FAIL workflow
- all enabled supplemental layers fail -> FAIL done-gate
- merged coverage cannot account for in-scope surfaces -> FAIL done-gate

## Steps

1. [Configure](./01-configure.md)
2. [Subsystem Health Audit](./02-subsystem-health-audit.md)
3. [Observability Audit](./03-observability-audit.md)
4. [Operational Readiness Audit](./04-operational-readiness-audit.md)
5. [API Contract Audit](./05-api-contract-audit.md)
6. [Test Quality Audit](./06-test-quality-audit.md)
7. [Security Audit](./07-security-audit.md)
8. [Data Governance Audit](./08-data-governance-audit.md)
9. [Cross-Subsystem Audit](./09-cross-subsystem-audit.md)
10. [Freshness Audit](./10-freshness-audit.md)
11. [Merge](./11-merge.md)
12. [Report](./12-report.md)
13. [Verify](./13-verify.md)

## Verification Gate

Workflow verification must prove:

- [ ] All enabled stages executed or explicitly skipped
- [ ] Consolidated continuous-audit report exists
- [ ] Bounded bundle exists at `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`
- [ ] Findings are deduplicated with stable IDs and acceptance criteria
- [ ] Coverage and convergence metadata are present
- [ ] Done-gate expression is evaluated and recorded
- [ ] If `post_remediation=true`, done-gate is true

## Outputs

- Consolidated workflow report:
  - `.harmony/output/reports/YYYY-MM-DD-continuous-audit.md`
- Authoritative bounded-audit bundle:
  - `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`

## Version History

| Version | Date | Changes |
| ------- | ---- | ------- |
| 1.0.0 | 2026-02-23 | Initial bounded layered continuous-audit workflow |
