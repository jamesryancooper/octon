---
name: change-risk-audit
description: >
  Orchestrate layered bounded audits to quantify change risk across subsystem
  integrity, migration impact, API contracts, test quality, operational
  readiness, cross-subsystem coherence, and freshness. Produces deterministic
  evidence with stable finding IDs, coverage accounting, and explicit done-gate
  evaluation.
steps:
  - id: configure
    file: 01-configure.md
    description: Parse parameters and build deterministic stage plan.
  - id: subsystem-health-audit
    file: 02-subsystem-health-audit.md
    description: Run audit-subsystem-health as the mandatory integrity layer.
  - id: migration-impact-audit
    file: 03-migration-impact-audit.md
    description: Run audit-migration when a migration manifest is available and enabled.
  - id: api-contract-audit
    file: 04-api-contract-audit.md
    description: Run audit-api-contract unless explicitly disabled.
  - id: test-quality-audit
    file: 05-test-quality-audit.md
    description: Run audit-test-quality unless explicitly disabled.
  - id: operational-readiness-audit
    file: 06-operational-readiness-audit.md
    description: Run audit-operational-readiness unless explicitly disabled.
  - id: cross-subsystem-audit
    file: 07-cross-subsystem-audit.md
    description: Run audit-cross-subsystem-coherence unless explicitly disabled.
  - id: freshness-audit
    file: 08-freshness-audit.md
    description: Run audit-freshness-and-supersession unless explicitly disabled.
  - id: merge
    file: 09-merge.md
    description: Merge stage outputs into stable change-risk findings and risk tier.
  - id: report
    file: 10-report.md
    description: Generate consolidated change-risk report and bounded evidence bundle.
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

# Change Risk Audit: Overview

Run a bounded layered change-risk gate that composes multiple audit lenses into one deterministic risk recommendation.

## Usage

```text
/change-risk-audit subsystem=".harmony/capabilities/runtime/services"
```

With migration manifest and strict post-remediation gate:

```text
/change-risk-audit subsystem=".harmony/capabilities/runtime/services" manifest=".harmony/output/plans/migration.yml" post_remediation="true" convergence_k="3" seed_list="11,23,37"
```

## Target

A subsystem change scope that requires risk quantification before rollout, refactor, or release.

## Prerequisites

- `audit-subsystem-health` skill is active
- `audit-migration` skill is active when migration stage is enabled
- `audit-api-contract` skill is active when `run_api_contract=true`
- `audit-test-quality` skill is active when `run_test_quality=true`
- `audit-operational-readiness` skill is active when `run_operational=true`
- `audit-cross-subsystem-coherence` skill is active when `run_cross_subsystem=true`
- `audit-freshness-and-supersession` skill is active when `run_freshness=true`

## Failure Conditions

- `subsystem` missing or unreadable -> STOP, report configuration error
- subsystem-health stage fails with no recoverable prior report -> FAIL workflow
- all enabled supplemental stages fail -> FAIL done-gate
- merged coverage cannot account for in-scope surfaces -> FAIL done-gate

## Steps

1. [Configure](./01-configure.md)
2. [Subsystem Health Audit](./02-subsystem-health-audit.md)
3. [Migration Impact Audit](./03-migration-impact-audit.md)
4. [API Contract Audit](./04-api-contract-audit.md)
5. [Test Quality Audit](./05-test-quality-audit.md)
6. [Operational Readiness Audit](./06-operational-readiness-audit.md)
7. [Cross-Subsystem Audit](./07-cross-subsystem-audit.md)
8. [Freshness Audit](./08-freshness-audit.md)
9. [Merge](./09-merge.md)
10. [Report](./10-report.md)
11. [Verify](./11-verify.md)

## Verification Gate

Workflow verification must prove:

- [ ] All enabled stages executed or explicitly skipped
- [ ] Consolidated change-risk report exists
- [ ] Bounded bundle exists at `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`
- [ ] Findings are deduplicated with stable IDs and acceptance criteria
- [ ] Coverage and convergence metadata are present
- [ ] Done-gate expression is evaluated and recorded
- [ ] If `post_remediation=true`, done-gate is true

## Outputs

- Consolidated workflow report:
  - `.harmony/output/reports/YYYY-MM-DD-change-risk-audit.md`
- Authoritative bounded-audit bundle:
  - `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`

## Version History

| Version | Date | Changes |
| ------- | ---- | ------- |
| 1.0.0 | 2026-02-23 | Initial bounded layered change-risk workflow |
