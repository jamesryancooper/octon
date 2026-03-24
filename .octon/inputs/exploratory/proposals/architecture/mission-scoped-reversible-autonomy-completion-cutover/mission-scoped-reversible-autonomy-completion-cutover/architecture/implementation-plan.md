# Implementation Plan

## Release And Cutover Shape

- current baseline: `0.5.6`
- target release: `0.6.0`
- cutover type: `atomic`, `clean break`, `pre-1.0`
- branch policy: one integration branch, no long-lived dual runtime behavior
- migration ID: `mission-scoped-reversible-autonomy-completion-cutover`

Historical evidence remains untouched. Live runtime behavior changes in one
merge.

## Workstream 1 — Root Manifest, Architecture Contracts, And Durable Ratification

### Changes
- bump `version.txt` to `0.6.0`
- update `.octon/octon.yml` to publish:
  - completed MSRAOM cutover release ID
  - mission control root bindings
  - generated effective route root
  - generated summary roots
  - runtime input bindings for mission-autonomy policy and ownership registry
- update umbrella architecture specification to:
  - declare mission control under `state/control/execution/missions/**`
  - declare retained control evidence under `state/evidence/control/**`
  - declare generated effective scenario routing and generated summaries
- update runtime-vs-ops contract
- update contract registry
- promote durable migration plan under
  `instance/cognition/context/shared/migrations/mission-scoped-reversible-autonomy-completion-cutover/plan.md`
- record decision lineage under `instance/cognition/decisions/**`

### Exit condition
All canonical placements are declared before runtime changes merge.

## Workstream 2 — Mission Authority And Scaffolding Completion

### Changes
- keep `octon-mission-v2` canonical
- update mission scaffold to create:
  - `mission.yml`
  - `mission.md`
  - `tasks.json`
  - `log.md`
  - mission control stubs for:
    - `lease.yml`
    - `mode-state.yml`
    - `intent-register.yml`
    - `directives.yml`
    - `schedule.yml`
    - `autonomy-budget.yml`
    - `circuit-breakers.yml`
    - `subscriptions.yml`
- update mission registry and mission readers
- fix all readers to consume `owner_ref`
- migrate any active missions in-tree to the final v2 charter and control-file family

### Exit condition
No active autonomous mission can exist without the complete control-file family.

## Workstream 3 — Add Missing Contracts

### Add under `.octon/framework/engine/runtime/spec/`
- `mission-control-lease-v1.schema.json`
- `mode-state-v1.schema.json`
- `action-slice-v1.schema.json`
- `intent-register-v1.schema.json`
- `control-directive-v1.schema.json`
- `schedule-control-v1.schema.json`
- `autonomy-budget-v1.schema.json`
- `circuit-breaker-v1.schema.json`
- `subscriptions-v1.schema.json`
- `control-receipt-v1.schema.json`
- `scenario-resolution-v1.schema.json`

### Update existing contracts
- `execution-request-v2.schema.json`
- `execution-receipt-v2.schema.json`
- `policy-receipt-v2.schema.json`
- `policy-digest-v2.md`

### Required semantics
- autonomous material execution requires mission, slice, and intent references
- mode/posture/reversibility must be explicit
- control receipts must exist for directive, schedule, breaker, lease, safing,
  and break-glass changes
- scenario-resolution freshness must be defined

### Exit condition
Every runtime-required control primitive has a schema and contract-registry entry.

## Workstream 4 — Runtime, Policy, And Scheduler Integration

### Kernel and policy engine
- require valid mission control files for active autonomous missions
- consume mission-autonomy policy, not just its existence
- derive effective route from mission class + ACP/action class + live control state
- remove hidden fallback recovery semantics
- emit mission-aware receipts and policy digests
- deny or stage-only when autonomy context or effective recovery is missing

### Orchestration runtime
- consume directives
- enforce safe-boundary pause
- distinguish future-run suspension vs active-run pause
- enforce overlap policy
- enforce backfill policy
- enforce pause-on-failure
- fork observe missions into operate sub-missions where policy allows
- block finalize when directives or recovery state demand it

### Exit condition
Scheduler and runtime behavior are demonstrably driven by canonical mission
control state and effective scenario resolution.

## Workstream 5 — Trust Tightening, Safing, And Break-Glass

### Changes
- derive autonomy burn counters from:
  - run receipts
  - control receipts
  - retries
  - rollback/compensation events
  - operator vetoes
  - incident evidence
- write `autonomy-budget.yml`
- trip and reset `circuit-breakers.yml`
- apply automatic mode tightening and scheduler actions
- implement safing subset enforcement
- implement break-glass authorize-update flow with receipts and TTL

### Exit condition
Autonomy burn and circuit breakers change behavior automatically based on
evidence, and those changes are operator-visible.

## Workstream 6 — Control Evidence, Continuity, And Generated Views

### Changes
- emit control receipts under `state/evidence/control/execution/**`
- keep continuity under `state/continuity/repo/missions/**`
- generate mission summaries:
  - `now.md`
  - `next.md`
  - `recent.md`
  - `recover.md`
- generate operator digests under
  `generated/cognition/summaries/operators/**`
- generate effective scenario resolution under
  `generated/effective/orchestration/missions/<mission-id>/scenario-resolution.yml`

### Exit condition
The repo no longer relies on placeholder-only summary or control-evidence roots.

## Workstream 7 — Assurance, Conformance, And Merge Gates

### Changes
- schema validation for all new contracts
- freshness validation for generated effective route and summaries
- conformance suite covering all required scenarios
- negative suite for missing control files, stale route data, missing recovery,
  ownership conflicts, and unauthorized break-glass
- merge gate that forbids docs overclaiming missing surfaces

### Exit condition
The cutover cannot merge unless the scenario and negative suites are green.

## Workstream 8 — Cleanup And Deprecation

### Changes
- remove or update stale references to placeholder-only generated views
- remove any runtime expectations for legacy mission fields after the cutover
- deprecate fallback logic that is no longer allowed
- archive this proposal after promotion

### Exit condition
No contradictory or stale live documentation remains.

## Sequencing

1. Workstream 1
2. Workstream 2 and 3 together
3. Workstream 4
4. Workstream 5
5. Workstream 6
6. Workstream 7
7. Workstream 8
8. release `0.6.0`

The cutover is **one merge**, but implementation work within the branch may
sequence in this order.

## Rollback Strategy

Because this is pre-1.0 and atomic, rollback is branch-level, not model-level:

- if the conformance suite fails, do not merge
- if merged and production-hosted workflows misbehave, revert the cutover
  branch and restore the previous release
- historical receipts remain intact either way

There is no supported long-lived split where some missions use the old partial
implementation and others use the completed one.
