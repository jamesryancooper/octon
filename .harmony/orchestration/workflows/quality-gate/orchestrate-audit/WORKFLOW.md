---
name: orchestrate-audit
description: >
  Coordinate parallel partition-scoped audit-migration runs across codebase
  partitions, merge findings with deduplication, and perform global
  cross-partition validation. Use after a migration when the scope exceeds
  what a single audit-migration run can cover in one context window.
steps:
  - id: configure
    file: 01-configure.md
    description: Parse manifest and enumerate full scope.
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
  - id: report
    file: 06-report.md
    description: Generate consolidated report.
  - id: verify
    file: 07-verify.md
    description: Validate workflow executed successfully.
# --- Harmony extensions ---
access: human
version: "1.0.0"
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

Coordinate parallel partition-scoped `audit-migration` runs and merge results into a consolidated report.

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
```

## Target

A codebase scope to audit after a migration, partitioned for parallel execution across multiple agents.

## Prerequisites

- `audit-migration` skill is active in the skill registry
- Migration manifest is available (inline YAML or file path)
- Task tool is available for parallel agent dispatch

## Failure Conditions

- Invalid migration manifest -> STOP, report validation error
- Zero files in scope after exclusions -> STOP, nothing to audit
- Partition strategy produces zero partitions -> STOP, check strategy and scope
- Task tool unavailable -> FALLBACK, run partitions sequentially

## Steps

1. [Configure](./01-configure.md) - Parse manifest and enumerate full scope
2. [Partition](./02-partition.md) - Divide scope into disjoint slices
3. [Dispatch](./03-dispatch.md) - Launch parallel audit-migration runs
4. [Merge](./04-merge.md) - Collect partition reports and deduplicate
5. [Challenge](./05-challenge.md) - Global self-challenge across partitions
6. [Report](./06-report.md) - Generate consolidated report
7. [Verify](./07-verify.md) - Validate workflow executed successfully

## Verification Gate

Orchestrate Audit is NOT complete until:

- [ ] All partition reports exist at expected paths
- [ ] Consolidated report exists at `.harmony/output/reports/YYYY-MM-DD-migration-audit-consolidated.md`
- [ ] Global self-challenge completed with all 5 checks documented
- [ ] Deduplication applied (no duplicate file:line entries)
- [ ] Coverage proof accounts for all files in full scope
- [ ] Verification step passes

## Version History

| Version | Date | Changes |
| ------- | ---- | ------- |
| 1.0.0 | 2026-02-08 | Initial version |

## References

- **Skill:** `.harmony/capabilities/skills/quality-gate/audit-migration/SKILL.md`
- **Registry:** `.harmony/capabilities/skills/registry.yml`
- **Workflow template:** `.harmony/orchestration/workflows/_template/`
