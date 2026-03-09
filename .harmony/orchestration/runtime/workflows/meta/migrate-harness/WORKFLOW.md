---
name: "migrate-harness"
description: "Migrate an older harness layout to current conventions while preserving intent, traceability, and recoverability. Reject unsupported harness schema versions with deterministic migration instructions."
steps:
  - id: "backup-assessment"
    file: "01-backup-assessment.md"
    description: "backup-assessment"
  - id: "structure-migration"
    file: "02-structure-migration.md"
    description: "structure-migration"
  - id: "content-migration"
    file: "03-content-migration.md"
    description: "content-migration"
  - id: "validation"
    file: "04-validation.md"
    description: "validation"
---

# Migrate Harness

_Generated projection from canonical pipeline `migrate-harness`._

## Usage

```text
/migrate-harness
```

## Target

This projection wraps the canonical pipeline `migrate-harness` for staged human review and slash-facing compatibility.

## Prerequisites

- Required pipeline inputs are available.
- Canonical pipeline assets exist under `.harmony/orchestration/runtime/pipelines/meta/migrate-harness`.

## Failure Conditions

- Required inputs are missing or invalid.
- The backing canonical pipeline contract or stage assets are missing.
- Verification criteria are not satisfied.

## Steps

1. [backup-assessment](./01-backup-assessment.md)
2. [structure-migration](./02-structure-migration.md)
3. [content-migration](./03-content-migration.md)
4. [validation](./04-validation.md)

## Verification Gate

- [ ] verification stage passes

## Version History

| Version | Changes |
|---------|---------|
| 1.1.0 | Generated from canonical pipeline `migrate-harness` |

## References

- Canonical pipeline: `.harmony/orchestration/runtime/pipelines/meta/migrate-harness/`
