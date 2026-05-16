# Workflow History Replay v1

This contract defines bounded workflow history reconstruction, replay
classification, idempotency, retry, compensation, and failure receipt
semantics for supported Octon workflows.

It extends Run Journal v1, Run Lifecycle v1, Workflow Statechart v1, and the
Task-Specific Execution Harness v1 without creating a second control plane.

## Canonical Source Order

Workflow history replay reconstructs from the canonical Run Journal first:

1. `/.octon/state/control/execution/runs/<run-id>/events.ndjson`
2. `/.octon/state/control/execution/runs/<run-id>/events.manifest.yml`
3. `/.octon/state/control/execution/runs/<run-id>/runtime-state.yml` as a
   derived mutable view only
4. bounded side artifacts named by canonical events
5. retained evidence mirrors under `/.octon/state/evidence/runs/<run-id>/**`

The journal wins on conflict. Retained evidence proves and discloses the
history, but it does not become live control truth. Generated projections,
proposal packets, raw `inputs/**`, MCP or tool availability, Durable Object
state, external workflow engines, host UI state, and chat history are never
workflow history authority.

## Reconstruction Outcomes

Replay reconstruction reports must classify one of these outcomes:

| Outcome | Meaning |
| --- | --- |
| `valid` | The journal, manifest, runtime-state materialization, side artifacts, replay pointers, trace pointers, retained evidence, and disclosure refs agree. |
| `drifted` | The journal hash chain, sequence, manifest, runtime-state view, or retained mirror disagrees. |
| `incomplete` | Required side artifacts, replay pointers, trace pointers, evidence snapshots, disclosure refs, or placement receipts are missing. |
| `unsupported` | The history depends on excluded authority such as generated projections, raw input lineage, Durable Object persistence, an external workflow engine, or live side-effect replay without a fresh grant. |
| `blocked` | Reconstruction cannot proceed because an authority, evidence, or boundary prerequisite is unresolved. |

`drifted`, `incomplete`, `unsupported`, and `blocked` outcomes require a
failure receipt or blocked outcome record that is retained under
`/.octon/state/evidence/**` and disclosed to the operator.

## Event Reference Roles

Workflow history reports must classify event refs by role:

- state rebuild refs: events applied to compute current workflow state;
- transition refs: events that created, denied, blocked, or completed state
  movement;
- replay refs: events and pointer records needed for dry-run or sandbox
  reconstruction;
- disclosure refs: evidence snapshot, RunCard, or disclosure publication
  events;
- evidence snapshot refs: retained mirrors used to prove closeout or replay
  completeness; and
- drift refs: events that record mismatch, repair, or withheld
  materialization.

The same canonical event may appear in multiple roles. Generated or proposal
refs may not appear as source events for state rebuild.

## Replay Boundary

Default replay mode is `dry-run` or `sandbox`. Live side-effect replay is
blocked unless the replay request cites a fresh execution authorization grant
created for the replay attempt. A historical grant, generated read model, or
external workflow dashboard is not enough.

Live side-effect replay is blocked unless a fresh replay-specific
authorization grant is present.

Missing side-artifact refs are replay gaps. They must be reported as
`incomplete` or `blocked`; they must not silently fall back to operator memory,
proposal lineage, generated projections, or external workflow state.

## Idempotency

Each mutating workflow event or replayable command must carry a stable
idempotency key. A duplicate key must be deterministically rejected or
classified with the prior event, retry posture, and failure receipt. Silent
duplicate acceptance is invalid.

Silent duplicate idempotency acceptance is invalid.

Silent duplicate acceptance is invalid.

Idempotency records are control-adjacent runtime records. They may link to
retained evidence, but they do not authorize execution or close a run.

## Retry

Retry records use the existing `run-retry-record-v1` class set:

- `retryable_transient`
- `retryable_validation`
- `retryable_environment`
- `rollback_then_retry`
- `manual_review_required`
- `non_retryable_contract_violation`
- `contamination_reset_required`

Retry attempts must not exceed their declared limit. Non-retryable contract
violations, contamination resets, and manual-review cases must not be silently
retried. A retry that would replay a live side effect requires fresh
authorization for that attempt.

## Compensation

Compensation is bounded remedial action. A compensation record may describe a
local compensating action, an unsupported rollback, or the absence of safe
compensation. It must never imply:

- universal replay of arbitrary external systems;
- full rollback of all effects;
- global transactionality; or
- external workflow-engine authority.

Unsupported rollback and no-compensation outcomes require a retained failure
receipt and operator disclosure.

## Failure Receipts

Failure receipts record why replay, retry, idempotency, or compensation cannot
be proven. A valid receipt names the run, triggering artifact, failure class,
outcome, retained evidence ref, disclosure ref, authority boundary, and
timestamp.

Failure receipts are evidence and disclosure inputs. They do not mutate control
truth and do not authorize a retry, rollback, compensation, or closeout.

## Evidence Placement

Replay reconstruction evidence must be retained under
`/.octon/state/evidence/**`. Generated outputs are derived-only and must not
store claim-bearing replay, retry, compensation, or failure evidence.

Required retained evidence includes:

- workflow history reconstruction report;
- replay fixture or scenario results for valid, drifted, incomplete, and
  unsupported histories;
- idempotency duplicate-key evidence;
- retry policy positive and negative evidence;
- compensation boundary and unsupported rollback evidence; and
- evidence placement receipts.

## Related Contracts

- `/.octon/framework/engine/runtime/spec/run-journal-v1.md`
- `/.octon/framework/engine/runtime/spec/run-lifecycle-v1.md`
- `/.octon/framework/engine/runtime/spec/run-lifecycle-reconstruction-v1.schema.json`
- `/.octon/framework/engine/runtime/spec/workflow-statechart-v1.md`
- `/.octon/framework/engine/runtime/spec/task-specific-execution-harness-v1.md`
- `/.octon/framework/constitution/contracts/runtime/workflow-history-replay-v1.schema.json`
- `/.octon/framework/constitution/contracts/runtime/idempotency-record-v1.schema.json`
- `/.octon/framework/constitution/contracts/runtime/retry-record-v1.schema.json`
- `/.octon/framework/constitution/contracts/runtime/compensation-record-v1.schema.json`
- `/.octon/framework/constitution/contracts/runtime/failure-receipt-v1.schema.json`
