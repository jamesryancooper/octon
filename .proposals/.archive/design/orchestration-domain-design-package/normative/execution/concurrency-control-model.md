# Concurrency Control Model

## Purpose

Define how the orchestration domain prevents conflicting executions across all
entry modes, not only within automation-local overlap policy.

This document is normative for target-global coordination, lock ownership, and
contention handling.

## Core Concepts

| Concept | Meaning |
|---|---|
| `coordination_key` | Canonical identifier for the external target or shared mutable resource an execution may affect |
| coordination lock | Exclusive or shared admission guard derived from `coordination_key` |
| lock owner | The active admitted execution or action that currently holds the lock |
| lock lease | Time-bounded ownership window that must be renewed while work remains active |
| contention | A new material action attempts to acquire a lock already held by another active owner |

## Lock Requirement Rule

Any material action that may produce external side effects or mutate shared
state outside append-only evidence MUST declare and acquire a `coordination_key`
before side effects begin.

Actions that are evidence-only or read-only MAY omit `coordination_key`.

## Coordination-Key Derivation

`coordination_key` must be derived deterministically from the strongest known
execution context.

Preferred inputs, in order:

1. workflow-declared target identity
2. incident-declared containment or remediation target
3. mission-declared mutable target scope
4. operator-supplied override scope, when policy permits

If a side-effectful action cannot derive a `coordination_key`, admission MUST
`block`.

## Coordination Classes

| Class | Behavior |
|---|---|
| `exclusive` | Only one active owner may proceed at a time |
| `shared-read` | Multiple read-only or observation actions may coexist |
| `shared-compatible` | Multiple active owners may proceed only when the workflow contract explicitly declares compatibility |

The default is `exclusive`.

## Lock Acquisition Protocol

Before a side-effectful `allow` decision is finalized:

1. derive `coordination_key`
2. determine lock class
3. attempt lock acquisition atomically
4. if acquisition succeeds, write the decision record with `lock_status=acquired`
5. create the run record
6. start execution

If acquisition fails:

- `serialize` and `parallel` may defer only when policy explicitly allows queue
  or schedule deferral
- otherwise admission MUST `block` with reason code
  `coordination-lock-unavailable`

## Cross-Entry Enforcement

Locking applies equally to:

- manual mission-driven launches
- scheduled automation launches
- event-driven automation launches
- incident-driven containment or remediation launches

Automation-local overlap policy does not bypass target-global lock rules.

## Lock Lease

The lock owner must maintain a valid lock lease while execution remains active.

Required fields on the owning run:

- `coordination_key`
- `lock_acquired_at`
- `lock_lease_expires_at`

Lease renewal is performed through the run-liveness heartbeat path.

## Contention Outcomes

| Entry Mode | Default Contention Outcome |
|---|---|
| manual mission-driven | `block` unless operator explicitly requests queued retry |
| scheduled automation | defer or suppress based on overlap policy |
| event-driven automation | leave queue item unacknowledged or return it to `retry` based on retry policy |
| incident-driven | `escalate` if containment urgency requires operator decision |

## Lock Loss During Execution

If an active execution loses lock ownership before terminalization:

- mark the run `recovery_status=recovery_pending`
- stop new side effects
- escalate to the reconciler and incident policy path
- do not silently continue execution as if ownership were still valid

## Workflow Contract Requirement

Workflows that perform side effects MUST declare one of:

- deterministic `coordination_key` derivation guidance, or
- `side_effect_class=none`

Omitted side-effect classification is treated conservatively as side-effectful.

## Observability

Operators must be able to answer:

- which run owns this coordination key?
- when does its lock lease expire?
- which blocked or deferred actions were denied because of contention?

## Invariants

- No external side effect without `allow` decision, run record, and acquired
  coordination lock.
- At most one active exclusive lock owner per `coordination_key`.
- Lost or expired locks require explicit recovery behavior; they are never
  ignored.

## Validation Expectations

Implementations must prove:

- deterministic `coordination_key` derivation
- lock contention handling across all four entry modes
- no side-effectful admitted execution without lock acquisition evidence
