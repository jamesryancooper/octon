# Migrate Harness Overview

This compatibility overview exists because the harness version contract points
to `migrate-harness/00-overview.md` as the deterministic migration overview for
older harness layouts.

For the canonical workflow contract and generated operator guide, use:

- `workflow.yml`
- `README.md`

## Purpose

Migrate an older harness layout to current conventions while preserving intent,
traceability, and recoverability.

## Entry Command

```text
/migrate-harness
```

## Stage Order

1. `stages/01-backup-assessment.md`
2. `stages/02-structure-migration.md`
3. `stages/03-content-migration.md`
4. `stages/04-validation.md`
