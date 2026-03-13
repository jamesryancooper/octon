
# Task: Agent-Led Happy Path

## Context

Use this as the canonical onboarding path for agent-led work in this repository.
Legacy onboarding variants are hard-deprecated for new runs.

## Failure Conditions

- Canonical ingress files are missing -> STOP, run the bootstrap path before continuing
- No unblocked task can be identified -> STOP, resolve continuity state before execution
- Required alignment or surface-specific validators fail -> STOP, address the failing checks before handoff

## Flow

1. Bootstrap
   - Read `AGENTS.md`, `/.octon/OBJECTIVE.md`, `.octon/START.md`, `.octon/scope.md`, and `.octon/conventions.md`.
   - Confirm canonical cross-subsystem rules in `.octon/cognition/_meta/architecture/specification.md`.
2. Execute
   - Read `.octon/continuity/log.md` and `.octon/continuity/tasks.json`.
   - Pick the highest-priority unblocked task and execute a bounded plan.
3. Assure
   - Run `bash .octon/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness`.
   - Run scope-specific validators required by the changed surfaces.
4. Continuity
   - Append session results in `.octon/continuity/log.md`.
   - Update `.octon/continuity/tasks.json` status.
   - Complete `.octon/assurance/practices/session-exit.md` before handoff.

## Required Outcome

- One execution pass from bootstrap -> execute -> assure -> continuity with
  fail-closed validation and durable continuity updates.
