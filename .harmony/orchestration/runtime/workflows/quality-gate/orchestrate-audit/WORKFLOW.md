---
name: orchestrate-audit
description: >
  Coordinate parallel partition-scoped audit-migration runs across codebase
  partitions, merge findings with deduplication, perform global cross-partition
  validation, and optionally run cross-subsystem and freshness audits before
  issuing a consolidated recommendation.
steps:
  - id: configure
    file: 01-configure.md
    description: Parse parameters, validate manifest, and build execution plan.
  - id: partition
    file: 02-partition.md
    description: Divide scope into disjoint slices.
  - id: dispatch
    file: 03-dispatch.md
    description: Launch parallel audit-migration runs.
  - id: merge
    file: 04-merge.md
    description: Collect partition reports and deduplicate.
  - id: challenge
    file: 05-challenge.md
    description: Global self-challenge across partitions.
  - id: cross-subsystem-audit
    file: 06-cross-subsystem-audit.md
    description: Run audit-cross-subsystem-coherence unless explicitly disabled.
  - id: freshness-audit
    file: 07-freshness-audit.md
    description: Run audit-freshness-and-supersession unless explicitly disabled.
  - id: report
    file: 08-report.md
    description: Generate consolidated report.
  - id: verify
    file: 09-verify.md
    description: Validate workflow executed successfully.
# --- Harmony extensions ---
access: human
version: "1.1.0"
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

Coordinate parallel partition-scoped `audit-migration` runs and merge results into a consolidated report, with optional whole-harness `audit-cross-subsystem-coherence` and `audit-freshness-and-supersession` stages.

## Usage

```text
orchestrate-audit manifest="..." strategy="by-directory"
```

**Examples:**

```text
# Partition by top-level directories (default)
orchestrate-audit manifest=".harmony/migrations/restructure.yml" strategy="by-directory"

# Partition by file type
orchestrate-audit manifest="..." strategy="by-type"

# Partition by manual concern groupings
orchestrate-audit manifest="..." strategy="by-concern" concern_map="..."

# Auto-partition into N equal slices
orchestrate-audit manifest="..." strategy="auto" partition_count="6"

# Include optional global stages explicitly
orchestrate-audit manifest="..." run_cross_subsystem="true" run_freshness="true" max_age_days="30"
```

## Target

A migration scope that must be audited across many files, partitioned for parallel execution, with optional whole-harness coherence/freshness validation before a consolidated recommendation.

## Prerequisites

- `audit-migration` skill is active in the skill registry
- Migration manifest is available (inline YAML or file path)
- Task tool is available for parallel agent dispatch
- `audit-cross-subsystem-coherence` skill is active when `run_cross_subsystem=true`
- `audit-freshness-and-supersession` skill is active when `run_freshness=true`

## Failure Conditions

- Invalid migration manifest -> STOP, report validation error
- Zero files in scope after exclusions -> STOP, nothing to audit
- Partition strategy produces zero partitions -> STOP, check strategy and scope
- Task tool unavailable -> FALLBACK, run partitions sequentially
- All partition audits fail -> STOP, report aggregated partition failures

## Steps

1. [Configure](./01-configure.md) - Parse parameters and enumerate full scope
2. [Partition](./02-partition.md) - Divide scope into disjoint slices
3. [Dispatch](./03-dispatch.md) - Launch parallel audit-migration runs
4. [Merge](./04-merge.md) - Collect partition reports and deduplicate
5. [Challenge](./05-challenge.md) - Global self-challenge across partitions
6. [Cross-Subsystem Audit](./06-cross-subsystem-audit.md) - Run audit-cross-subsystem-coherence unless disabled
7. [Freshness Audit](./07-freshness-audit.md) - Run audit-freshness-and-supersession unless disabled
8. [Report](./08-report.md) - Generate consolidated report
9. [Verify](./09-verify.md) - Validate workflow executed successfully

## Verification Gate

Orchestrate Audit is NOT complete until:

- [ ] All partition reports exist at expected paths (or failures are documented)
- [ ] Consolidated report exists at `.harmony/output/reports/YYYY-MM-DD-migration-audit-consolidated.md`
- [ ] Global self-challenge completed with all 5 checks documented
- [ ] Deduplication applied (no duplicate `file:line` entries)
- [ ] Coverage proof accounts for all files in full scope (including failed-partition impact)
- [ ] If `run_cross_subsystem=true`, cross-subsystem report exists or failure is documented
- [ ] If `run_freshness=true`, freshness report exists or failure is documented
- [ ] Verification step passes

## Version History

| Version | Date | Changes |
| ------- | ---- | ------- |
| 1.1.0 | 2026-02-15 | Added optional cross-subsystem and freshness stages with stage controls |
| 1.0.0 | 2026-02-08 | Initial version |

## References

- **Migration Skill:** `.harmony/capabilities/runtime/skills/quality-gate/audit-migration/SKILL.md`
- **Cross-Subsystem Skill:** `.harmony/capabilities/runtime/skills/quality-gate/audit-cross-subsystem-coherence/SKILL.md`
- **Freshness Skill:** `.harmony/capabilities/runtime/skills/quality-gate/audit-freshness-and-supersession/SKILL.md`
- **Registry:** `.harmony/capabilities/runtime/skills/registry.yml`
- **Workflow template:** `.harmony/orchestration/runtime/workflows/_scaffold/template/`
