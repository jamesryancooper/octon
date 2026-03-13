---
name: "migrate-harness"
description: "Migrate an older harness layout to current conventions while preserving intent, traceability, and recoverability. Reject unsupported harness schema versions with deterministic migration instructions."
steps:
  - id: "backup-assessment"
    file: "stages/01-backup-assessment.md"
    description: "backup-assessment"
  - id: "structure-migration"
    file: "stages/02-structure-migration.md"
    description: "structure-migration"
  - id: "content-migration"
    file: "stages/03-content-migration.md"
    description: "content-migration"
  - id: "validation"
    file: "stages/04-validation.md"
    description: "validation"
---

# Migrate Harness

_Generated README from canonical workflow `migrate-harness`._

## Usage

```text
/migrate-harness
```

## Purpose

Migrate an older harness layout to current conventions while preserving intent, traceability, and recoverability. Reject unsupported harness schema versions with deterministic migration instructions.

## Target

This README summarizes the canonical workflow unit at `.octon/orchestration/runtime/workflows/meta/migrate-harness`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/orchestration/runtime/workflows/meta/migrate-harness/workflow.yml`.

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Steps

1. [backup-assessment](./stages/01-backup-assessment.md)
2. [structure-migration](./stages/02-structure-migration.md)
3. [content-migration](./stages/03-content-migration.md)
4. [validation](./stages/04-validation.md)

## Verification Gate

- [ ] verification stage passes

## References

- Canonical contract: `.octon/orchestration/runtime/workflows/meta/migrate-harness/workflow.yml`
- Canonical stages: `.octon/orchestration/runtime/workflows/meta/migrate-harness/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.1.0 | Generated from canonical workflow `migrate-harness` |

