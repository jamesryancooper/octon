# Run Liveness And Recovery Spec

## Purpose

Define how active runs prove executor ownership, how stale runs are detected,
and how recovery occurs without guessing.

This document is normative for run liveness and recovery.

## Core Concepts

| Concept | Meaning |
|---|---|
| `executor_id` | Stable identifier for the active executor currently owning the run |
| executor acknowledgement | First durable signal that an executor accepted ownership of the run |
| heartbeat | Periodic ownership renewal for an active run |
| run lease | Time-bounded liveness window for an active run |
| `recovery_status` | Liveness/recovery substate for `running` runs |

## Required Active-Run Fields

Active runs MUST carry:

- `executor_id`
- `executor_acknowledged_at`
- `last_heartbeat_at`
- `lease_expires_at`
- `recovery_status`

## Recovery Status Values

| Value | Meaning |
|---|---|
| `healthy` | executor acknowledged and heartbeats are current |
| `suspect` | one or more expected heartbeat or ownership signals are late |
| `recovery_pending` | run requires reconciler action before new execution may start on the same coordination key |
| `recovered` | reconciler completed deterministic recovery |
| `abandoned` | run could not be safely resumed and was explicitly abandoned under policy |

## Acknowledgement Rule

After a run record is created, the executor must acknowledge ownership before
`executor_ack_timeout`.

If no acknowledgement arrives in time:

- set `recovery_status=recovery_pending`
- treat the launch as `launch_commit_failure`
- do not assume the workflow actually began

## Heartbeat Rule

While `status=running`, the executor must renew heartbeat before
`lease_expires_at`.

Missing heartbeat transitions:

1. `healthy -> suspect`
2. `suspect -> recovery_pending` when lease expires

## Recovery Rule

When `recovery_status=recovery_pending`, the reconciler must choose exactly one:

- resume with the same executor if liveness is restored
- transfer ownership to a recovery executor when policy and lock rules allow
- mark the run `abandoned` and require containment or operator review

No new side-effectful execution may start on the same `coordination_key` until
recovery is resolved or an explicit override permits it.

## Terminalization Rule

Terminal state updates for `running` runs are accepted only when:

- the same `executor_id` finalizes the run, or
- a recovery executor finalizes the run under explicit recovery authority

## Observability

Operators must be able to answer:

- who owns this active run?
- when was the last heartbeat?
- is this run healthy, suspect, pending recovery, recovered, or abandoned?

## Validation Expectations

Implementations must prove:

- executor acknowledgement timeout handling
- stale-run detection
- deterministic recovery path selection
- no duplicate side effects during recovery
