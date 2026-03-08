# Evidence Observability And Retention Spec

## Purpose

Define how orchestration surfaces produce, link, retain, and expose evidence
without collapsing runtime state into continuity or duplicating evidence
payloads.

## Evidence Design Rules

1. Every material action produces durable evidence.
2. Runtime state and continuity evidence remain separate.
3. `runs/` is a projection and linkage layer, not the durable evidence store.
4. Evidence must support forward and reverse lookup across lineage.
5. Retention rules must distinguish mutable runtime state from append-oriented
   evidence.

## Required Evidence For Every Material Run

| Evidence Element | Required | Notes |
|---|---|---|
| `run_id` | yes | canonical identity |
| `decision_id` | yes | authoritative routing and authority basis |
| `workflow_ref` | yes for workflow-backed runs | route and ownership anchor |
| `started_at` / `completed_at` | yes | timestamps |
| `status` | yes | terminal or active outcome |
| `summary` | yes | short operator-readable result |
| `continuity_run_path` | yes | pointer to durable evidence bundle |
| execution context refs | yes when applicable | `mission_id`, `automation_id`, `incident_id`, `event_id`, `queue_item_id` |
| evidence bundle contents | yes | receipts, digests, validation/evidence files as applicable |

## Required Evidence For Blocked And Escalated Actions

Blocked or escalated material attempts must record:

- attempted surface and action
- actor or initiating surface
- reason code
- `decision_id`
- prerequisite failure or escalation condition
- timestamp
- related references (`mission_id`, `workflow_ref`, `automation_id`, etc.)
- operator-visible disposition

These are canonically stored under:

```text
continuity/decisions/<decision-id>/
```

The required artifact is `decision.json`. Supporting digests or approval
artifacts may accompany it.

## Decision Evidence Layer

Decision evidence is continuity-owned, append-oriented evidence for material
action outcomes.

It answers:

- why work was allowed
- why work was blocked
- why escalation was required

`runs/` may point to decision evidence through `decision_id`, but it does not
replace the decision record as source of truth.

## Runtime Projection vs Continuity Evidence

### Runtime Projection Layer

The orchestration runtime may hold:

- current status
- lightweight indexes
- reverse-lookup projections
- operator-facing summaries

### Continuity Evidence Layer

Continuity holds:

- append-oriented receipts
- digests
- policy traces
- decision records
- durable validation and evidence artifacts

### Separation Rule

Runtime projection may point to continuity evidence, but must not duplicate the
durable payload as its own source of truth.

## Expectations For `runs/`

`runs/` must provide:

- global discovery index
- per-run orchestration status
- by-surface reverse lookup
- pointers to continuity evidence

`runs/` must not become:

- a second evidence bundle store
- a replacement for mission state
- a replacement for incident timelines

## Evidence Bundle Linkage Conventions

Every material run must support lookup chains in both directions:

### Forward

`watcher event -> queue item -> automation -> workflow -> run -> continuity evidence -> incident or mission`

### Reverse

`incident or mission -> run -> queue item/event/automation/workflow -> continuity evidence`

### Decision Lookup

`decision_id -> run_id? -> continuity evidence -> related mission/incident/queue/event context`

## Traceability Expectations By Surface

| Surface | Must Link To |
|---|---|
| `watchers` | emitted events, health state |
| `queue` | source event, target automation, receipts |
| `automations` | trigger policy, workflow target, produced runs, blocked/drop decision records |
| `workflows` | produced runs, mission context where applicable |
| `missions` | related runs, related workflows, continuity state |
| `runs` | continuity evidence, `decision_id`, upstream context, downstream incident/mission linkage |
| `incidents` | triggering runs, containment runs, remediation missions, decision records when applicable |

## Operator And Audit Lookup Expectations

Operators and auditors must be able to answer:

- what happened?
- why did it happen?
- what triggered it?
- what did it change?
- what evidence proves the outcome?
- what is the current status?

Minimum supported lookups:

- by `run_id`
- by `decision_id`
- by `mission_id`
- by `incident_id`
- by `automation_id`
- by `queue_item_id`
- by `event_id`

## Retention Guidance

### Runtime State

- mutable
- compactable
- retained only as long as needed for active orchestration and operator support

### Continuity Evidence

- append-oriented
- retained according to continuity policy
- authoritative for material execution evidence

### Suggested Retention Classes

| Class | Use |
|---|---|
| `governance_evidence` | material runs, decision records, incident closure evidence, policy traces |
| `operational_debug` | queue receipts, watcher health snapshots, automation counters |
| `ephemeral_runtime` | transient runtime-local snapshots that do not replace continuity evidence |

## Observability Expectations

Each surface should expose at least:

| Surface | Minimum Observability |
|---|---|
| `watchers` | health, last successful evaluation, last emitted event, suppressed count |
| `queue` | pending count, claimed count, retry count, dead-letter count, expired-lease count |
| `automations` | active status, last run, suppression count, failure count, pause/error reason |
| `missions` | status, owner, linked active runs, blocker visibility through continuity/task state |
| `runs` | counts by status, per-surface lookup, evidence link health, decision link health |
| `incidents` | open counts by severity, current owner, last timeline update |

## Failure Modes

| Failure Mode | Required Handling |
|---|---|
| missing evidence link | fail validation; do not declare run complete |
| duplicated durable payload in runtime state | fail design/validation checks |
| orphaned queue receipt | flag operational inconsistency |
| run record without `decision_id` | fail material-run acceptance |
| decision record missing continuity bundle | fail routing/evidence acceptance |
| run record without continuity evidence | fail material-run acceptance |
| incident closure without linked evidence | block closure |
