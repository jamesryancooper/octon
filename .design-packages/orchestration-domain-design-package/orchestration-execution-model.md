# Orchestration Execution Model

## Purpose

Define how orchestration begins, how launch opportunities are evaluated, and
how admitted work progresses through execution.

This document is normative for entry modes, scheduling semantics, concurrency,
and idempotency.

## Entry Modes

There are four canonical ways orchestration begins:

| Entry Mode | Initiator | First Material Action |
|---|---|---|
| manual mission-driven | operator or delegated actor in mission context | workflow launch decision |
| scheduled automation | automation controller | scheduled launch decision |
| event-driven automation | watcher event routed through queue | queue claim and workflow launch decision |
| incident-driven response | incident manager with required authority | containment/remediation launch decision |

## Canonical Execution Phases

Every execution path moves through these phases:

1. definition resolved
2. dependencies checked
3. policy evaluated
4. decision recorded
5. execution admitted or denied
6. run/evidence created when admitted
7. terminal outcome or escalation recorded

Detailed per-surface state tables remain in
`lifecycle-and-state-machine-spec.md`.

## Manual Mission-Driven Execution

Manual orchestration begins when a mission owner or delegated actor requests a
workflow in mission context.

Required steps:

1. resolve `mission_id`
2. resolve `workflow_ref`
3. validate mission/workflow eligibility
4. evaluate objective scope and policy
5. create decision record
6. if `allow`, create run and execute workflow

Manual launch bypasses the queue unless an implementation inserts an internal
mechanism with no externally visible behavior change.

## Scheduled Automation Execution

Scheduled automation is owned by the automation controller.

### Schedule Fields

`trigger.yml` schedule fields are interpreted as:

| Field | Meaning |
|---|---|
| `cadence` | recurrence rule using the grammar below |
| `at` | local wall-clock time in `HH:MM` 24-hour form |
| `timezone` | IANA timezone name |
| `missed_run_policy` | backfill behavior after downtime, pause, or delayed evaluation |

### Supported `cadence` Grammar

To keep evaluation deterministic, v1 schedule cadence is limited to:

- `hourly:<N>` where `N` is an integer from `1` to `24`
- `daily`
- `weekly:<DAY[,DAY...]>` where `DAY` is one of `MO,TU,WE,TH,FR,SA,SU`

Examples:

- `hourly:6`
- `daily`
- `weekly:MO,WE,FR`

### Schedule Window Resolution

The controller must resolve each schedule into a canonical schedule window.

The schedule-window identity is derived from:

- `automation_id`
- the resolved cadence
- the scheduled local instant after timezone resolution

The same schedule window must always yield the same idempotency key.

### Hourly Cadence Anchor Rule

`hourly:<N>` cadence is anchored from local midnight in the declared timezone.
The controller evaluates the minute selected by `at` inside each eligible hour
bucket.

### Timezone And DST Rules

- schedule evaluation uses the declared IANA `timezone`
- if the local wall-clock time does not exist because of DST spring-forward,
  evaluate the next valid local minute on the same local date
- if the local wall-clock time occurs twice because of DST fall-back, only the
  first occurrence creates a new schedule window; the second occurrence is
  treated as the same window and must not launch again

### `missed_run_policy`

| Value | Meaning |
|---|---|
| `skip` | missed windows are dropped permanently |
| `run_immediately` | when evaluation resumes, backfill exactly the most recent missed window immediately |
| `next_window` | do not backfill; wait for the next naturally due window |

## Event-Driven Automation Execution

Event-driven execution begins with a watcher event.

Required steps:

1. validate the watcher event envelope
2. resolve matching active automations using `dependency-resolution.md`
3. create queue items targeted to those automations
4. claim queue items in deterministic order
5. validate bindings and derive input parameters
6. evaluate automation policy before launch
7. acquire target-global coordination when required
8. create decision record
9. if `allow`, create run and execute workflow

One watcher event may fan out to multiple queue items, but each queue item must
target exactly one automation.

## Incident-Driven Execution

Incident-driven execution is a controlled exception path.

It may:

- open or enrich incident state after a failed run
- launch rollback or containment workflows
- create remediation missions when work exceeds one bounded run

Incident-driven launches are still subject to the same decision protocol as
other material actions.

## Concurrency Model

Concurrency behavior is owned by the target automation policy.

| Mode | Behavior |
|---|---|
| `serialize` | admit one active run at a time; defer later eligible launches |
| `drop` | suppress duplicate or over-limit launches; emit decision, not run |
| `parallel` | admit distinct launches up to `max_concurrency`; defer overflow |
| `replace` | latest eligible launch wins, but only after prior run is confirmed `cancelled` and only when `execution_controls.cancel_safe=true` |

Concurrency decisions are made before workflow launch, not during workflow step
execution.

Automation-local concurrency does not replace target-global coordination rules
from `concurrency-control-model.md`.

## Idempotency Model

Idempotency is mandatory for all automation-owned launches.

### Event-Driven

Canonical key inputs:

- `automation_id`
- `event_id`
- `workflow_ref.workflow_id`

The same event must not admit multiple materially equivalent launches for the
same automation unless an explicit replay / redrive action changes the
idempotency context.

### Scheduled

Canonical key inputs:

- `automation_id`
- resolved schedule window id

Retries of the same scheduled attempt reuse the same schedule window id; they do
not create a new logical window.

## Execution Completion

When a workflow-backed execution ends:

1. terminal run status is written
2. continuity evidence is finalized
3. queue acknowledgement or retry transition occurs when applicable
4. automation counters and last-run state are updated
5. incident escalation is evaluated if failure severity or policy requires

## Admission Rules

No workflow execution may begin until:

- references resolve
- dependencies validate
- policy permits launch
- idempotency context is known
- required bindings validate
- required approvals or overrides validate
- required coordination lock is acquired
- exactly one decision record exists for the attempt
- the run record exists for workflow-backed admitted work

## Execution Handshake

After run creation, the executor must acknowledge ownership before side-effectful
steps may begin. Missing acknowledgement becomes a recovery condition handled by
`run-liveness-and-recovery-spec.md`.

Workflow metadata and launch request semantics are defined in
`contracts/workflow-execution-contract.md`.

## Out Of Scope

This document does not define workflow step syntax or capability internals. It
defines only orchestration-domain execution behavior around those steps.
