# Orchestration Lifecycle

## Purpose

Define the cross-surface lifecycle model for the orchestration domain and show
how authored definitions become active execution, evidence, and retained
history.

This document is normative for the lifecycle phase model. Detailed per-surface
state tables remain in `normative/execution/lifecycle-and-state-machine-spec.md`.

## Lifecycle Phase Model

The orchestration domain uses seven canonical phases:

| Phase | Meaning |
|---|---|
| defined | object definition exists but is not yet active |
| discovered | discovery metadata and references resolve |
| eligible | dependencies and lifecycle state make the object or action eligible to proceed |
| admitted | a material action has been allowed and recorded |
| executing | active work is in progress |
| terminal | the active work or mutable object reached a terminal outcome |
| retained | historical evidence remains available under retention rules |

## Surface Mapping

| Surface | Defined | Eligible | Executing | Terminal | Retained |
|---|---|---|---|---|---|
| workflow | authored and registered | reference resolves for launch | run in progress | definition retired or deprecated separately; runs terminate normally | workflow definition plus historical runs |
| mission | `created` | `active` with owner and success criteria | mission-owned work in progress | `completed` / `cancelled` / `archived` | archived mission and linked evidence |
| automation | authored and registered | `active` | launch evaluation ongoing | `disabled` | policy and state history |
| watcher | authored and registered | `active` | evaluation / emission ongoing | `disabled` | watcher state history plus linked event lineage per retention |
| queue item | enqueued | `pending` or eligible `retry` | `claimed` | `dead_letter` or acknowledged removal | receipts and evidence |
| run | created and linked | `running` after admission | `running` | `succeeded` / `failed` / `cancelled` | run record plus continuity evidence |
| incident | `open` | `acknowledged` / `mitigating` / `monitoring` / `resolved` | containment/remediation coordination in progress | `closed` / `cancelled` | incident record and closure evidence |
| campaign | `proposed` | `active` | coordination ongoing | `completed` / `cancelled` / `archived` | archived campaign and rollup history |

## Lifecycle Narrative By Path

### Authoring Path

1. definition files are authored
2. discovery artifacts are registered
3. validation passes
4. the object becomes eligible for activation or reference

### Event Path

1. watcher emits a valid event
2. event router resolves matching automations
3. queue item is enqueued
4. queue item is claimed
5. automation validates bindings and target-global coordination
6. automation admits or rejects launch
7. admitted launch creates a run
8. executor acknowledges ownership
9. queue item is acknowledged, retried, or dead-lettered

### Manual / Mission Path

1. mission exists in `created` or `active`
2. workflow reference resolves
3. launch decision is recorded
4. run executes
5. mission remains active or moves terminal based on mission outcomes, not just
   one run outcome

### Incident Path

1. run or policy threshold opens incident
2. incident becomes acknowledged
3. containment or rollback runs execute
4. remediation mission may be created
5. closure occurs only after evidence and authority checks pass

## Transition Evidence Rule

Every transition that changes material state must be attributable to:

- an actor or component with authority
- a trigger or prerequisite basis
- a durable state update or evidence record

## Terminal-State Rules

- terminal states are immutable except append-only correction notes or
  governance-authorized metadata repair
- terminal runs never return to `running`; retries create new runs
- terminal queue items do not re-enter active lanes
- closed incidents never silently reopen

## Retention Rule

Retention is not a lifecycle shortcut. Runtime state may compact, but material
decision and run evidence must remain queryable according to continuity policy.

## Relationship To State Tables

Use this document for:

- phase-level reasoning
- explaining cross-surface lifecycle interactions
- determining where evidence is required

Use `normative/execution/lifecycle-and-state-machine-spec.md` for:

- exact states
- valid transitions
- invalid transitions
- per-surface invariants
