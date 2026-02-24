---
title: Migrate Harness
description: Upgrade an older harness to current conventions.
access: human
version: "1.2.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".harmony/continuity/checkpoints/"
parallel_steps: []
---

# Migrate Harness: Overview

Upgrade an older harness to current conventions, preserving existing content. This is a **structural migration** for harnesses using deprecated patterns.

For incremental alignment of harnesses that are already structurally correct, use `/update-harness` instead.

## Target

Existing `.harmony/` directory using older conventions.

## Prerequisites

- Exactly one `.harmony` directory reference provided
- Target `.harmony` directory MUST exist

## Version Gate (Mandatory)

Before any structural/content migration work:

1. Read target `.harmony/harmony.yml`.
2. Resolve `schema_version`.
3. Compare against `versioning.harness.supported_schema_versions`.

If the target version is unsupported, STOP and fail closed. Do not run partial migration.

Use deterministic upgrade path:

1. Run `/migrate-harness` against the target `.harmony` root.
2. Execute steps in declared order:
   - `backup-assessment`
   - `structure-migration`
   - `content-migration`
   - `validation`
3. Re-run:
   - `.harmony/assurance/runtime/_ops/scripts/validate-harness-version-contract.sh`
   - `.harmony/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness,workflows`

## Failure Conditions

- Target `.harmony/` does not exist → STOP, suggest `/create-harness` instead
- Target path is not a `.harmony/` directory → STOP, report error
- Harness already uses current conventions → STOP, suggest `/update-harness` instead
- Target `schema_version` is unsupported → STOP, emit deterministic migration instructions above

## Steps

1. [Backup assessment](./01-backup-assessment.md)
2. [Structure migration](./02-structure-migration.md)
3. [Content migration](./03-content-migration.md)
4. [Validation](./04-validation.md)

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.2.0 | 2026-02-24 | Added mandatory version gate and deterministic unsupported-version migration path |
| 1.1.0 | 2025-01-14 | Added gap remediation fields |
| 1.0.0 | 2025-01-05 | Initial version |

## References

- **Canonical:** `.harmony/cognition/_meta/architecture/README.md`
- **Templates:** `.harmony/scaffolding/runtime/templates/harmony/` (for new structure)
