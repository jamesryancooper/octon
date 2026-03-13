# Lifecycle And State Machine Spec

## Purpose

Define the allowed lifecycle states, transitions, invariants, and failure
handling rules for stateful orchestration surfaces in the mature Octon
orchestration model.

This document is normative for lifecycle behavior. Surface object contracts
remain the source of truth for field shapes; this document defines how those
objects are allowed to move through time.

## Scope

This specification covers:

- `missions`
- `automations`
- `watchers`
- `queue` items and claim leases
- `runs`
- `incidents`

`campaigns` are intentionally excluded from the required scope here because they
remain optional and are covered by their own coordination contract.

## Lifecycle Design Rules

1. Every mutable orchestration surface must expose an explicit lifecycle state.
2. Every state transition must be attributable to:
   - a valid trigger,
   - an actor with authority to perform it,
   - a durable state update or evidence record.
3. Ambiguous transitions fail closed.
4. Terminal states are immutable except for append-only correction notes or
   governance-authorized metadata repair.
5. Retry is an explicit transition, not an implicit side effect.
6. Blocking and escalation are not silent; they must be operator-visible.

## Global Transition Semantics

| Concept | Meaning |
|---|---|
| `active` | Surface is eligible to execute its normal function |
| `paused` | Surface is intentionally stopped and may resume |
| `error` | Surface entered a degraded state due to a failed operation and requires explicit next action |
| `blocked` | Execution cannot proceed because prerequisites or authority are missing; use decision/evidence artifacts rather than inventing ad hoc states where the base contract does not define one |
| `terminal` | No further normal transitions are allowed except archive or append-only correction |

## `missions`

### Canonical States

| State | Meaning | Class |
|---|---|---|
| `created` | Mission exists but work has not started | non-terminal |
| `active` | Work is underway | non-terminal |
| `completed` | Success criteria satisfied | terminal |
| `cancelled` | Mission intentionally abandoned | terminal |
| `archived` | Completed or cancelled mission moved to archive | terminal |

### State Rules

- `missions` do not introduce a dedicated `paused` state in the current model.
- Paused or blocked mission work is represented through mission-local
  `tasks.json`, blockers, and operator notes while the mission remains `active`.

### Valid Transitions

| From | To | Trigger |
|---|---|---|
| `created` | `active` | owner begins bounded work |
| `active` | `completed` | all success criteria met |
| `active` | `cancelled` | scope withdrawn or effort intentionally abandoned |
| `completed` | `archived` | closeout and archive action |
| `cancelled` | `archived` | closeout and archive action |

### Invalid Transitions

- `created -> completed`
- `completed -> active`
- `cancelled -> active`
- `archived -> active`

### Invariants

- A mission may be `active` only if it has an owner and at least one defined
  success criterion.
- An `archived` mission must already be `completed` or `cancelled`.
- A mission may reference workflows and runs, but may not store workflow
  definitions or evidence bundles as mission-local state.

## `automations`

### Canonical States

| State | Meaning | Class |
|---|---|---|
| `active` | Eligible to trigger workflow launches | non-terminal |
| `paused` | Temporarily disabled but resumable | non-terminal |
| `disabled` | Intentionally inactive and not expected to resume automatically | terminal-ish |
| `error` | Failed into an operator-visible degraded state | non-terminal |

### Valid Transitions

| From | To | Trigger |
|---|---|---|
| `active` | `paused` | operator pause, policy pause, repeated failure with `pause_on_error=true` |
| `paused` | `active` | operator resume or policy-backed resume |
| `active` | `error` | launch or state failure requiring explicit attention |
| `error` | `paused` | fail-safe stop after failure |
| `error` | `active` | operator or policy-backed recovery after prerequisites restored |
| `active` | `disabled` | retirement or explicit permanent shutdown |
| `paused` | `disabled` | retirement or explicit permanent shutdown |
| `error` | `disabled` | explicit permanent shutdown after failure |

### Invalid Transitions

- `disabled -> active` without explicit recreate or re-enable process
- `paused -> error` without a material operation attempt

### Pause/Resume Rules

- Resume must re-check trigger validity, workflow target existence, and policy
  prerequisites before becoming `active`.
- Resuming does not replay missed scheduled windows unless the trigger policy
  explicitly says so.

### Retry Rules

- Retry behavior is controlled by `policy.yml`.
- Retry may not bypass idempotency rules or concurrency limits.
- Repeated terminal failure may force `active -> paused` or `active -> error`.

### Overlap Mode Rules

- `serialize` requires `max_concurrency=1` and defers a new eligible launch when
  a run is already active.
- `drop` suppresses duplicate or over-limit launches and records a blocking
  decision without emitting a run.
- `parallel` admits distinct launches up to `max_concurrency` and defers any
  over-limit launch.
- `replace` requires `max_concurrency=1` and
  `execution_controls.cancel_safe=true` on the target workflow.
- `replace` cancels the active run before the newest launch is admitted.
- `replace` on a workflow that is not cancel-safe becomes a recorded blocked
  condition.

### Invariants

- Every automation has exactly one workflow target.
- Every event-triggered automation has exactly one `trigger.yml`.
- Every admitted launch attempt emits a run linked to a `decision_id`.
- Every blocked, dropped, or escalated launch attempt emits a decision record
  even when no run is created.

## `watchers`

### Canonical States

| State | Meaning | Class |
|---|---|---|
| `active` | Monitoring and eligible to emit events | non-terminal |
| `paused` | Monitoring intentionally stopped | non-terminal |
| `disabled` | Permanently inactive | terminal-ish |
| `error` | Monitoring degraded or unable to evaluate correctly | non-terminal |

### Valid Transitions

| From | To | Trigger |
|---|---|---|
| `active` | `paused` | operator pause or policy-backed pause |
| `paused` | `active` | operator resume after checks pass |
| `active` | `error` | source unreadable, rule evaluation failure, or unsafe output condition |
| `error` | `paused` | fail-safe stop |
| `error` | `active` | recovery after prerequisites restored |
| `active` | `disabled` | retirement |
| `paused` | `disabled` | retirement |
| `error` | `disabled` | retirement |

### Invalid Transitions

- `disabled -> active` without explicit recreate or re-enable process

### Pause/Resume Rules

- Resume must validate source connectivity, cursor integrity, and emission
  contract before reactivation.
- A watcher in `error` must not emit events until recovered.

### Invariants

- A watcher may emit only through its canonical event envelope.
- Emission failure does not silently drop into success; it becomes `error`,
  `paused`, or a recorded blocked condition.

## `queue` Items And Claim Leases

### Queue Item States

| State | Meaning | Class |
|---|---|---|
| `pending` | ready or future-ready for claim | non-terminal |
| `claimed` | under active lease | non-terminal |
| `retry` | waiting for next eligible retry window | non-terminal |
| `dead_letter` | terminal failure or explicit quarantine | terminal |

### Claim Lease Substate

Claim lease is represented by:

- `claimed_by`
- `claimed_at`
- `claim_deadline`
- `claim_token`

It is a substate of `claimed`, not a separate top-level status.

### Valid Transitions

| From | To | Trigger |
|---|---|---|
| `pending` | `claimed` | successful claim |
| `claimed` | removed from active lanes | successful acknowledgement with receipt |
| `claimed` | `retry` | lease expiry without ack or explicit retryable failure |
| `retry` | `claimed` | re-claim after `available_at` |
| `pending` | `dead_letter` | explicit quarantine or non-retryable pre-claim failure |
| `claimed` | `dead_letter` | terminal failure or explicit quarantine |
| `retry` | `dead_letter` | `max_attempts` reached or explicit quarantine |

### Invalid Transitions

- `dead_letter -> pending`
- `dead_letter -> claimed`
- `pending -> retry` without failed or deferred claim semantics

### Claim/Ack/Lease-Expiry Rules

- Claim requires:
  - eligible `available_at`
  - valid `target_automation_id`
  - no unexpired active lease
- Claim ordering is deterministic: highest `priority`, then earliest
  `available_at`, then earliest `enqueued_at`, then lexical `queue_item_id`.
- A successful claim atomically moves the item into `claimed` and sets
  `claimed_by`, `claimed_at`, `claim_deadline`, and `claim_token`.
- Ack removes the item from active lanes only when the presented `claim_token`
  matches the active claim and writes a receipt.
- Stale or mismatched `claim_token` values are rejected.
- Lease expiry is deterministic and moves the item to `retry`.
- Retry increments `attempt_count`.
- Lease renewal and heartbeats are intentionally out of scope for v1.

### Invariants

- Queue ingress is automation-only.
- A queue item exists in exactly one active lane at a time.
- Acknowledged items must have a receipt artifact.
- `claim_deadline` must be later than `claimed_at`.
- `claim_token` must exist for claimed items.
- `attempt_count` must be monotonic.

## `runs`

### Canonical States

| State | Meaning | Class |
|---|---|---|
| `running` | execution in progress | non-terminal |
| `succeeded` | execution completed successfully | terminal |
| `failed` | execution completed unsuccessfully | terminal |
| `cancelled` | execution intentionally stopped before success/failure completion | terminal |

### Valid Transitions

| From | To | Trigger |
|---|---|---|
| created record | `running` | execution starts |
| `running` | `succeeded` | successful completion |
| `running` | `failed` | terminal execution failure |
| `running` | `cancelled` | operator or policy-backed cancellation |

### Invalid Transitions

- `succeeded -> running`
- `failed -> running`
- `cancelled -> running`

### Retry Rules

- Retry creates a new run record; it does not mutate a terminal run back to
  `running`.
- Parent/child lineage may be represented through `parent_run_id`.

### Run Liveness Substate

Active runs carry liveness and recovery substate through fields such as:

- `executor_id`
- `executor_acknowledged_at`
- `last_heartbeat_at`
- `lease_expires_at`
- `recovery_status`

Valid `recovery_status` values for active runs are:

- `healthy`
- `suspect`
- `recovery_pending`
- `recovered`
- `abandoned`

### Invariants

- Every material run must reference continuity evidence.
- Every material run must reference `decision_id`.
- Terminal runs require `completed_at`.
- A failed run must retain summary and evidence linkage.
- A `running` run must have exactly one executor owner.
- A `running` run must have a valid liveness lease.

## `incidents`

### Canonical States

| State | Meaning | Class |
|---|---|---|
| `open` | incident created but not yet acknowledged | non-terminal |
| `acknowledged` | ownership accepted | non-terminal |
| `mitigating` | containment or rollback in progress | non-terminal |
| `monitoring` | immediate containment done; observing stability | non-terminal |
| `resolved` | active mitigation complete | non-terminal |
| `closed` | evidence and closure complete | terminal |
| `cancelled` | incident record intentionally abandoned | terminal |

### Valid Transitions

| From | To | Trigger |
|---|---|---|
| `open` | `acknowledged` | owner or responder accepts |
| `acknowledged` | `mitigating` | active response begins |
| `mitigating` | `monitoring` | containment complete, watching system |
| `monitoring` | `resolved` | stability confirmed |
| `resolved` | `closed` | closure evidence complete and approval granted |
| `open` | `cancelled` | invalid/duplicate incident |
| `acknowledged` | `cancelled` | invalid/duplicate incident |

### Invalid Transitions

- `open -> closed`
- `mitigating -> closed`
- `closed -> monitoring`
- `cancelled -> open`

### Escalation-Triggered Transitions

- Severe or repeated run failure may create `open`.
- Severity change does not change lifecycle state by itself, but must be logged.
- Governance or operator escalation may force response from `acknowledged` to
  `mitigating`.

### Closure Rules

- `closed` requires:
  - closure evidence
  - linked remediation evidence or waiver
  - explicit human confirmation or policy-backed closure authority

### Invariants

- Incident lifecycle is operator-visible.
- `closed` requires `closed_at` and `closed_by`.
- `closed` incidents are append-only except correction notes.

## Cross-Surface Escalation Transitions

| Source | Trigger | Target Transition |
|---|---|---|
| `watcher` | unsafe emission or rule failure | `active -> error` |
| `queue` item | max retries or non-retryable failure | `* -> dead_letter` |
| `automation` | repeated terminal failure | `active -> paused` or `active -> error` |
| `run` | material failure with policy threshold met | incident `open` or enrich existing incident |
| `incident` | remediation larger than one bounded run | create mission |

## Implementation Validation Targets

Implementations should validate:

- only listed transitions are allowed
- invalid transitions fail closed
- terminal-state immutability holds
- lease expiry and retry are deterministic
- escalation-triggered transitions emit evidence and status visibility
