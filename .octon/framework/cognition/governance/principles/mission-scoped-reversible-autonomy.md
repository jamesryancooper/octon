---
title: Mission-Scoped Reversible Autonomy
description: Canonical operating model for mission-scoped continuous autonomy with explicit mode, reversible slices, supervisory steering, and retained recovery evidence.
pillar: Direction, Trust, Continuity
status: Active
---

# Mission-Scoped Reversible Autonomy

> Long-running autonomy is continuous by default inside governed mission
> boundaries. Authority is explicit, reversible, receipted, and recoverable.

## What This Means

Mission-Scoped Reversible Autonomy is Octon's canonical operating model for
long-running and always-running autonomous agents.

- durable mission authority defines what the agent may keep trying to achieve
- mission remains the continuity container while per-run objective binding
  lands under the run-contract root
- mutable mission control truth publishes the live lease, mode, schedule,
  directives, burn state, breaker state, and awareness routing
- one freshness-bounded effective route compiles mission, policy, and live
  control inputs for shared runtime, scheduler, and operator consumption
- every material step is an action slice with forward intent, reversibility
  class, and a safe interrupt boundary
- the generated effective route records scenario-family, boundary, and recovery
  provenance plus any tightening overlays from directives, breakers, safing,
  or break-glass
- human control is supervisory: `Inspect`, `Signal`, and `Authorize-Update`
  are distinct
- durable side effects still pass the engine-owned execution boundary and ACP
  promote/finalize gates
- `STAGE_ONLY` is the humane fail-closed fallback when staging is safe but
  promote/finalize prerequisites are missing

## Canonical Surfaces

- mission authority:
  `/.octon/instance/orchestration/missions/<mission-id>/{mission.yml,mission.md}`
- mission autonomy defaults:
  `/.octon/instance/governance/policies/mission-autonomy.yml`
- ownership authority:
  `/.octon/instance/governance/ownership/registry.yml`
- run contract control roots:
  `/.octon/state/control/execution/runs/<run-id>/**`
- mission control truth:
  `/.octon/state/control/execution/missions/<mission-id>/**`
- retained control evidence:
  `/.octon/state/evidence/control/execution/**`
- retained run evidence:
  `/.octon/state/evidence/runs/**`
- mission continuity:
  `/.octon/state/continuity/repo/missions/<mission-id>/**`
- effective mission scenario resolution:
  `/.octon/generated/effective/orchestration/missions/<mission-id>/scenario-resolution.yml`
- derived mission/operator read models:
  `/.octon/generated/cognition/summaries/{missions,operators}/**`
- machine-readable mission views:
  `/.octon/generated/cognition/projections/materialized/missions/<mission-id>/mission-view.yml`

Mission creation stays authority-only.
Before a mission may become active or paused for autonomous runtime, the
seed-before-active path must materialize the mission control family, mission
continuity, effective route, generated summaries, and mission view.
Consequential runs should additionally bind a run contract under
`state/control/execution/runs/<run-id>/run-contract.yml`; mission-only
execution remains transitional until later lifecycle normalization lands.

## Control Dimensions

Keep these concerns distinct:

- **awareness**: what humans can see without blocking the mission
- **intervention**: asynchronous steering that changes control truth
- **approval**: explicit authority mutation
- **reversibility**: what can still be rolled back or compensated after
  promotion

Notifications are not approval.
Silence is not consent.
Reversibility is not permission.

## Mandatory Mode Model

- oversight mode: `silent`, `notify`, `feedback_window`,
  `proceed_on_silence`, `approval_required`
- execution posture: `one_shot`, `continuous`, `interruptible_scheduled`
- safety state: `active`, `paused`, `degraded`, `safe`, `break_glass`
- phase: `planning`, `staging`, `promoting`, `running`, `recovering`,
  `finalizing`, `closed`

Mode must never be implicit. Canonical live mode publishes under
`mode-state.yml`.

## Mandatory Interaction Grammar

- **Inspect**: read-only visibility over canonical authority, control,
  evidence, and continuity
- **Signal**: binding asynchronous steering that does not widen authority
- **Authorize-Update**: synchronous authority mutation such as approval, lease
  change, owner attestation, breaker reset, or break-glass

Chat messages, UI state, and external comments are advisory only until they
materialize into canonical control truth and emit receipts when required.

## Reversibility And Recovery

- `reversible`: rollback is guaranteed inside the declared recovery window
- `compensable`: bounded compensation exists but exact rollback is weaker
- `irreversible`: no credible rollback or bounded compensation exists

Routine ACP-1 through ACP-3 work must not collapse `stage`, `promote`, and
`finalize` into a single point of no return.

Late feedback remains meaningful:

- before stage: edit or replace the slice
- after stage but before promote: discard the stage or replan
- after promote inside recovery window: rollback or compensate and optionally
  block finalize
- after recovery expiry: open a compensating mission or escalate
- after finalize or irreversible boundary: no rollback promise remains

## Escalation

Mission autonomy burn and circuit breakers tighten behavior when trust is being
burned.

- burn states: `healthy`, `warning`, `exhausted`
- breaker actions may downgrade mode, force `STAGE_ONLY`, suspend future runs,
  pause at safe boundaries, or enter safing
- safing contracts authority down to a predeclared safe subset
- break-glass is exceptional, time-boxed, strongly reason-coded, and followed
  by postmortem continuity

## Related Principles

- [Autonomous Control Points](./autonomous-control-points.md)
- [Reversibility](./reversibility.md)
- [Ownership and Boundaries](./ownership-and-boundaries.md)
- [Deny by Default](./deny-by-default.md)
