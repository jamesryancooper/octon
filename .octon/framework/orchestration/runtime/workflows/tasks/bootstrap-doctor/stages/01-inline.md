# Task: Bootstrap Doctor

## Context

Use this as the canonical onboarding preflight before agent-led execution.
It is read-only and must fail closed on missing ingress, bootstrap, workflow,
or support-envelope prerequisites.

## Failure Conditions

- Canonical ingress or workspace-charter files are missing.
- Workflow discovery files or required task workflows are missing.
- Repo-owned support-target or governance exclusion declarations are missing.
- Required evidence or continuity roots needed for onboarding are unavailable.

## Flow

1. Ingress and charter readiness
   - Confirm `AGENTS.md`, `/.octon/instance/ingress/AGENTS.md`,
     `/.octon/instance/charter/workspace.md`, and
     `/.octon/instance/charter/workspace.yml` exist and remain canonical.
2. Workflow and policy readiness
   - Confirm workflow discovery resolves `agent-led-happy-path`,
     `bootstrap-doctor`, and the consequential task workflows through
     `manifest.yml` and `registry.yml`.
   - Confirm `support-targets.yml`, `action-classes.yml`, and the repo-shell
     adapter contract exist and remain readable.
3. Evidence and continuity readiness
   - Confirm `state/continuity/repo/{log.md,tasks.json,next.md}` exists.
   - Confirm `state/evidence/validation/publication/**` and
     `state/control/execution/runs/**` are available for retained onboarding
     receipts and checkpoints.
4. Record readiness
   - Emit a retained readiness result that can back
     `checkpoints/bootstrap-doctor.yml` and a short operator summary.
   - If any prerequisite fails, cite `bootstrap-readiness` and
     `degraded-operator-summary` in the retained output and stop.

## Required Outcome

- One canonical onboarding preflight result that names any blocker before
  agent-led execution continues.
