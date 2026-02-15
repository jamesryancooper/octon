---
name: migrate-harness
description: >
  Migrate an older harness layout to current conventions while preserving
  intent, traceability, and recoverability.
steps:
  - id: backup-assessment
    file: 01-backup-assessment.md
    description: Assess backup/recovery readiness before changes.
  - id: structure-migration
    file: 02-structure-migration.md
    description: Migrate directory and file structure.
  - id: content-migration
    file: 03-content-migration.md
    description: Reconcile and migrate content contracts.
  - id: validation
    file: 04-validation.md
    description: Validate migration results and report drift.
---

# Migrate Harness Workflow

Use [00-overview.md](./00-overview.md) for migration context, then execute
steps in the declared order.
