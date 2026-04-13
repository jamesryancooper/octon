
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
   - Read `AGENTS.md`, `/.octon/instance/charter/workspace.md`, `.octon/instance/bootstrap/START.md`, `.octon/instance/bootstrap/scope.md`, and `.octon/instance/bootstrap/conventions.md`.
   - Confirm canonical cross-subsystem rules in `.octon/framework/cognition/_meta/architecture/specification.md`.
   - Run `/bootstrap-doctor` and keep its readiness result with the onboarding run; if doctor reports a blocker, stop before task selection.
2. Execute
   - Read `.octon/state/continuity/repo/log.md` and `.octon/state/continuity/repo/tasks.json`.
   - Read `.octon/state/continuity/scopes/<scope-id>/{log.md,tasks.json,next.md}` when a declared scope is the primary continuity home.
   - Pick the highest-priority unblocked task and execute a bounded plan.
3. Assure
   - Run `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness`.
   - Run scope-specific validators required by the changed surfaces.
4. Continuity
   - Append session results in `.octon/state/continuity/repo/log.md`.
   - Update `.octon/state/continuity/repo/tasks.json` status.
   - Update `.octon/state/continuity/scopes/<scope-id>/**` when the work is primarily scope-bound.
   - Complete `.octon/framework/assurance/practices/session-exit.md` before handoff.

## Required Outcome

- One execution pass from bootstrap -> execute -> assure -> continuity with
  fail-closed validation and durable continuity updates.
