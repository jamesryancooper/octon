---
name: release-readiness-audit
description: >
  Orchestrate layered bounded audits (release core, operational readiness, API
  contract, test quality, observability, security, and data governance) into a
  deterministic release gate with stable finding identity, coverage accounting,
  and explicit done-gate evaluation.
steps:
  - id: configure
    file: 01-configure.md
    description: Parse parameters and build deterministic stage plan.
  - id: release-core-audit
    file: 02-release-core-audit.md
    description: Run release-readiness-audit skill as the mandatory release-core layer.
  - id: operational-readiness-audit
    file: 03-operational-readiness-audit.md
    description: Run audit-operational-readiness unless explicitly disabled.
  - id: api-contract-audit
    file: 04-api-contract-audit.md
    description: Run audit-api-contract unless explicitly disabled.
  - id: test-quality-audit
    file: 05-test-quality-audit.md
    description: Run audit-test-quality unless explicitly disabled.
  - id: observability-audit
    file: 06-observability-audit.md
    description: Run audit-observability-coverage unless explicitly disabled.
  - id: security-audit
    file: 07-security-audit.md
    description: Run audit-security-compliance unless explicitly disabled.
  - id: data-governance-audit
    file: 08-data-governance-audit.md
    description: Run audit-data-governance unless explicitly disabled.
  - id: merge
    file: 09-merge.md
    description: Merge stage outputs into stable release-readiness finding set.
  - id: report
    file: 10-report.md
    description: Generate consolidated workflow report and bounded-audit evidence bundle.
  - id: verify
    file: 11-verify.md
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

# Release Readiness Audit Workflow: Overview

Run a bounded layered release-readiness gate by composing domain audits into one deterministic recommendation.

## Usage

```text
/release-readiness-workflow scope=".harmony"
```

With strict post-remediation gate:

```text
/release-readiness-workflow scope=".harmony" post_remediation="true" convergence_k="3" seed_list="11,23,37"
```

## Target

A subsystem or repository scope that requires evidence-backed release readiness across operational, interface, quality, observability, security, and governance layers.

## Prerequisites

- `release-readiness-audit` skill is active
- `audit-operational-readiness` skill is active when `run_operational=true`
- `audit-api-contract` skill is active when `run_api_contract=true`
- `audit-test-quality` skill is active when `run_test_quality=true`
- `audit-observability-coverage` skill is active when `run_observability=true`
- `audit-security-compliance` skill is active when `run_security=true`
- `audit-data-governance` skill is active when `run_data_governance=true`

## Failure Conditions

- `scope` missing or unreadable -> STOP, report configuration error
- mandatory release-core stage fails with no prior report -> FAIL workflow
- all enabled supplemental stages fail -> FAIL done-gate
- merged coverage cannot account for scope surfaces -> FAIL done-gate

## Steps

1. [Configure](./01-configure.md)
2. [Release Core Audit](./02-release-core-audit.md)
3. [Operational Readiness Audit](./03-operational-readiness-audit.md)
4. [API Contract Audit](./04-api-contract-audit.md)
5. [Test Quality Audit](./05-test-quality-audit.md)
6. [Observability Audit](./06-observability-audit.md)
7. [Security Audit](./07-security-audit.md)
8. [Data Governance Audit](./08-data-governance-audit.md)
9. [Merge](./09-merge.md)
10. [Report](./10-report.md)
11. [Verify](./11-verify.md)

## Verification Gate

Workflow verification must prove:

- [ ] All enabled stages executed or explicitly skipped
- [ ] Consolidated workflow report exists
- [ ] Bounded bundle exists at `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`
- [ ] Findings are deduplicated with stable IDs and acceptance criteria
- [ ] Coverage and convergence metadata are present
- [ ] Done-gate expression is evaluated and recorded
- [ ] If `post_remediation=true`, done-gate is true

## Outputs

- Consolidated workflow report:
  - `.harmony/output/reports/YYYY-MM-DD-release-readiness-workflow.md`
- Authoritative bounded-audit bundle:
  - `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`

## Version History

| Version | Date | Changes |
| ------- | ---- | ------- |
| 1.0.0 | 2026-02-23 | Initial bounded layered release-readiness orchestration workflow |
