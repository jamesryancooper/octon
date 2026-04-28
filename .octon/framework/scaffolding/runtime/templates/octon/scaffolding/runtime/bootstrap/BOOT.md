# BOOT.md

## Purpose

Recurring startup routine for execution sessions in this repository.

## Session Start Checklist

1. Confirm working directory is repository root and `.octon/` exists.
2. Read `.octon/AGENTS.md`, then load default execution-role contracts from `.octon/framework/execution-roles/manifest.yml`.
3. Scan `.octon/state/continuity/repo/log.md` and `.octon/state/continuity/repo/tasks.json` for active work and blockers.
4. Review `.octon/instance/bootstrap/START.md` for the active boot sequence.
5. Begin the highest-priority unblocked task.

## Guardrails

- Keep this file short and deterministic.
- Keep steps idempotent and primarily read-only.
- Put one-time onboarding in `BOOTSTRAP.md`, not here.
