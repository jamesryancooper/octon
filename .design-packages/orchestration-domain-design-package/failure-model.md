# Failure Model

## Purpose

Define the canonical failure classes, retry rules, compensation posture, and
recovery behavior for the orchestration domain.

This document is normative for failure semantics.

## Failure Philosophy

The system must prefer:

1. deterministic containment
2. truthful evidence
3. operator-visible degradation
4. explicit compensation over implicit rollback

Failures are not allowed to silently mutate into success.

## Canonical Failure Classes

| Failure Class | Meaning | Retryable By Default | Typical Surface |
|---|---|---|---|
| `validation_failure` | contract or schema validation failed | no | any |
| `reference_resolution_failure` | required reference missing or ambiguous | no | any |
| `policy_denied` | policy explicitly disallows the action | no | any |
| `approval_missing` | required approval or waiver absent | no; escalate instead | incidents, privileged actions |
| `transient_runtime_failure` | execution failed for a temporary condition expected to clear | yes if policy allows | workflows, watchers, queue handling |
| `terminal_runtime_failure` | execution failed in a way that retry is not expected to fix | no | workflows, watchers |
| `concurrency_conflict` | overlap or active-state conflict prevented safe admission | no; block or defer | automations |
| `binding_validation_failure` | event or binding inputs could not be validated safely | no | automations |
| `lock_acquisition_failure` | required target-global coordination could not be obtained | no | automations, incidents, manual launches |
| `lock_lost_during_execution` | active execution lost required coordination ownership | no; recover first | runs |
| `executor_liveness_failure` | active executor failed to acknowledge or renew ownership | no; recover first | runs |
| `stale_claim` | queue ack/release used an invalid or expired `claim_token` | no | queue |
| `evidence_write_failure` | required run or decision evidence could not be persisted | no; escalate or incident | runs, continuity |
| `launch_commit_failure` | admission began but run creation / evidence allocation did not complete | no automatic retry; reconcile first | automation / launcher boundary |
| `manual_quarantine` | operator intentionally dead-lettered or quarantined work | no | queue, incidents |

`retry_policy.retryable_classes` in automation policy must use these canonical
class names.

## Retry Semantics

Retries are explicit transitions, never invisible background side effects.

### Automatic Retry Preconditions

Automatic retry is allowed only when:

- the failure class is listed in `retry_policy.retryable_classes`
- `attempt_count < max_attempts`
- the originating surface is still eligible to run
- the retry would not violate idempotency or overlap mode

### Backoff Values

Supported `retry_policy.backoff` values are:

- `fixed`
- `linear`
- `exponential`

Implementations may configure the interval constants, but not invent new
semantic backoff modes without a contract update.

### Queue-Backed Retries

- retries reuse the same queue item lineage
- `attempt_count` increments monotonically
- on retry ceiling or non-retryable failure, move to `dead_letter`

### Schedule-Backed Retries

- retries reuse the same schedule window id
- retries do not create a new logical scheduled opportunity
- repeated terminal failure may pause the automation or move it into `error`

## Partial Execution Handling

Once workflow step execution begins, the system must assume external side
effects may already exist.

Therefore:

- a terminal failure produces a `failed` run, not a silent retry loop
- partial side effects must be summarized in the evidence bundle or run summary
- downstream closure or completion paths must be able to inspect that evidence

## Compensation And Rollback

The orchestration domain does not assume implicit rollback.

Compensation is always explicit and must run through normal orchestration
admission.

Allowed compensation paths are:

- containment or rollback workflow launched through an incident
- operator-approved follow-up workflow
- remediation mission when the work is larger than one bounded run

What is forbidden:

- treating cancellation as proof that no side effects occurred
- inventing implicit rollback because a workflow failed
- deleting lineage to hide partial execution

## Conflict Resolution

| Conflict | Required Resolution |
|---|---|
| duplicate event for same automation | suppress through idempotency |
| multiple matching automations for one event | deterministic fan-out |
| lock unavailable for side-effectful execution | `block` or defer according to policy |
| stale queue token | reject and record failed handling |
| `replace` without `cancel_safe` | `block` |
| unresolved reference | `block` |
| missing approval | `escalate` |
| orphan allow decision | reconcile before any new launch based on that attempt |

## Recovery Rules

| Recovery Case | Required Behavior |
|---|---|
| orphan allow decision | do not guess whether execution began; raise operator-visible failure and incident/error path as policy requires |
| running run without executor acknowledgement | move to deterministic recovery before any relaunch on the same coordination key |
| running run with expired heartbeat | mark liveness failure, preserve lineage, and require deterministic recovery |
| lost coordination lock during execution | contain or escalate before additional side effects proceed |
| run exists without evidence | block any completion or closure path that depends on that run until linkage is repaired or waived |
| evidence bundle exists without run | quarantine as inconsistency; do not adopt it automatically |
| queue item stuck claimed past deadline | move to `retry` deterministically |
| incident close without evidence | `block` close transition |

## Incident Escalation Rules

Incidents should be opened or enriched when:

- failure class crosses a configured incident threshold
- repeated retries do not stabilize the system
- launch commit or evidence write failures threaten auditability
- operator policy requires explicit containment

## Non-Goals

This document does not require one compensation framework or workflow language.
It requires explicit, evidenced compensation behavior and a shared failure
taxonomy.
