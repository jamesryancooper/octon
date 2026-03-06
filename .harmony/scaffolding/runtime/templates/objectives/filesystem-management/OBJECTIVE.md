# Objective: {{OBJECTIVE_LABEL}}

## Workspace Goal

Use Harmony in `{{REPO_NAME}}` to organize, audit, migrate, and maintain a filesystem or directory tree safely, with strong visibility into structure and side effects.

## What Harmony Should Optimize For

- clear structure, naming, and ownership across the managed directory
- safe cleanup, migration, and archival work with bounded blast radius
- durable evidence for reorganizations and destructive-adjacent changes

## In Scope

- file inventories, structure audits, naming normalization, and archival plans
- safe moves, renames, folder creation, and report generation inside the managed tree
- cleanup and migration tasks that improve discoverability and maintainability

## Out of Scope

- edits outside the approved filesystem boundary
- irreversible deletion without explicit approval or recovery posture
- speculative reorganization without a clear outcome or validation path

## Success Signals

- the directory structure is easier to navigate and reason about
- risky file operations are staged with clear evidence and rollback thinking
- cleanup, migration, and archival decisions remain attributable after the fact

## Initial Focus

- inventory the current structure and identify high-friction areas
- define safe boundaries for moves, renames, archives, and deletions
- prioritize the smallest cleanup or migration step that improves clarity
