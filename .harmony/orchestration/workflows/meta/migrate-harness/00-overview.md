---
title: Migrate Harness
description: Upgrade an older harness to current conventions.
access: human
version: "1.1.0"
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

## Failure Conditions

- Target `.harmony/` does not exist → STOP, suggest `/create-harness` instead
- Target path is not a `.harmony/` directory → STOP, report error
- Harness already uses current conventions → STOP, suggest `/update-harness` instead

## Steps

1. [Backup assessment](./01-backup-assessment.md)
2. [Structure migration](./02-structure-migration.md)
3. [Content migration](./03-content-migration.md)
4. [Validation](./04-validation.md)

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.1.0 | 2025-01-14 | Added gap remediation fields |
| 1.0.0 | 2025-01-05 | Initial version |

## References

- **Canonical:** `docs/architecture/harness/README.md`
- **Templates:** `.harmony/scaffolding/templates/harmony/` (for new structure)

