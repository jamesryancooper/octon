---
name: orchestrate-audit
description: >
  Coordinate bounded multi-pass audits across partitioned scope, merge with stable
  finding IDs and coverage accounting, and emit a deterministic evidence bundle
  with explicit done-gate and convergence metadata.
steps:
  - id: configure
    file: 01-configure.md
    description: Parse parameters, validate bounded-audit contract, and build execution plan.
  - id: partition
    file: 02-partition.md
    description: Divide scope into disjoint slices with full coverage accounting.
  - id: dispatch
    file: 03-dispatch.md
    description: Launch partition x pass audit matrix with deterministic receipts.
  - id: merge
    file: 04-merge.md
    description: Normalize, deduplicate, and assign stable finding IDs.
  - id: challenge
    file: 05-challenge.md
    description: Run global self-consistency and cross-partition challenge checks.
  - id: cross-subsystem-audit
    file: 06-cross-subsystem-audit.md
    description: Run audit-cross-subsystem-coherence unless explicitly disabled.
  - id: freshness-audit
    file: 07-freshness-audit.md
    description: Run audit-freshness-and-supersession unless explicitly disabled.
  - id: report
    file: 08-report.md
    description: Generate consolidated report plus bounded-audit evidence bundle.
  - id: verify
    file: 09-verify.md
    description: Validate workflow and done-gate outcomes.
# --- Harmony extensions ---
access: human
version: "2.0.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".harmony/continuity/checkpoints/"
parallel_steps:
  - group: "partition-audits"
    steps: ["03-dispatch"]
    join_at: "04-merge"
---

# Orchestrate Audit: Overview

Coordinate bounded multi-pass `audit-migration` runs and merge results into a deterministic, machine-checkable audit bundle.

## Usage

```text
/orchestrate-audit manifest="..." strategy="by-directory"
```

Post-remediation convergence check:

```text
/orchestrate-audit manifest="..." post_remediation="true" convergence_k="3" seed_list="11,23,37"
```

## Target

A migration scope that must be audited with deterministic coverage accounting, stable finding IDs, and explicit done-gate evaluation.

## Prerequisites

- `audit-migration` skill is active
- Migration manifest is available (inline YAML or file path)
- Task tool is available for parallel dispatch (sequential fallback allowed)
- `audit-cross-subsystem-coherence` skill is active when `run_cross_subsystem=true`
- `audit-freshness-and-supersession` skill is active when `run_freshness=true`

## Failure Conditions

- Invalid migration manifest -> STOP, report validation error
- Zero files in scope after exclusions -> STOP, nothing to audit
- Partition strategy produces zero partitions -> STOP, check strategy and scope
- All partition/pass jobs fail -> STOP, report aggregated failures
- Coverage accounting cannot prove full scope -> FAIL done-gate

## Steps

1. [Configure](./01-configure.md)
2. [Partition](./02-partition.md)
3. [Dispatch](./03-dispatch.md)
4. [Merge](./04-merge.md)
5. [Challenge](./05-challenge.md)
6. [Cross-Subsystem Audit](./06-cross-subsystem-audit.md)
7. [Freshness Audit](./07-freshness-audit.md)
8. [Report](./08-report.md)
9. [Verify](./09-verify.md)

## Verification Gate

Workflow verification must prove:

- [ ] Coverage accounting has zero unaccounted files
- [ ] Findings are deduplicated with stable IDs and acceptance criteria
- [ ] Determinism receipt is present (`commit_sha`, `scope_hash`, `prompt_hash`, seed/fingerprint policy, findings hash)
- [ ] Audit bundle exists at `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`
- [ ] Done-gate expression is evaluated and recorded
- [ ] If `post_remediation=true`, convergence K-run result is stable and empty at/above threshold

## Outputs

- Legacy report (backward-compatible):
  - `.harmony/output/reports/YYYY-MM-DD-migration-audit-consolidated.md`
- Authoritative bounded-audit bundle:
  - `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`

## Version History

| Version | Date | Changes |
| ------- | ---- | ------- |
| 2.0.0 | 2026-02-22 | Added bounded-audit bundle contract, stable finding IDs, coverage ledger, and convergence metadata |
| 1.1.0 | 2026-02-15 | Added optional cross-subsystem and freshness stages |
| 1.0.0 | 2026-02-08 | Initial version |

## References

- `.harmony/cognition/practices/methodology/audits/README.md`
- `.harmony/cognition/practices/methodology/audits/findings-contract.md`
- `.harmony/capabilities/runtime/skills/audit/audit-migration/SKILL.md`
- `.harmony/capabilities/runtime/skills/audit/audit-cross-subsystem-coherence/SKILL.md`
- `.harmony/capabilities/runtime/skills/audit/audit-freshness-and-supersession/SKILL.md`
