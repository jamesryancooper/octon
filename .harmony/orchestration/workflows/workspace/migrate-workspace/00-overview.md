---
title: Migrate Workspace
description: Upgrade an older workspace to current conventions.
access: human
version: "1.1.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".workspace/progress/checkpoints/"
parallel_steps: []
---

# Migrate Workspace: Overview

Upgrade an older `.workspace` to current conventions, preserving existing content. This is a **structural migration** for workspaces using deprecated patterns.

For incremental alignment of workspaces that are already structurally correct, use `/update-workspace` instead.

## Target

Existing `.workspace/` directory using older conventions.

## Prerequisites

- Exactly one `.workspace` directory reference provided
- Target `.workspace` directory MUST exist

## Failure Conditions

- Target `.workspace/` does not exist → STOP, suggest `/create-workspace` instead
- Target path is not a `.workspace/` directory → STOP, report error
- Workspace already uses current conventions → STOP, suggest `/update-workspace` instead

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

- **Canonical:** `docs/architecture/workspaces/README.md`
- **Templates:** `.workspace/templates/workspace/` (for new structure)

