# Current-State Gap Map

## Current Lifecycle Autopilot Behavior

Lifecycle Autopilot is implemented as a generic lifecycle runner plus shared
lifecycle executor adapter. It discovers extension lifecycle contracts from
generated effective extension projections, evaluates gates and receipts, writes
run evidence and checkpoints, delegates selected routes when requested, and
supports resume and cancellation.

The `proposal-packet` lifecycle contract declares `execution_strategy:
route-progression`. It uses proposal manifest status, receipt completeness,
receipt verdicts, freshness checks, validators, route entry conditions, and a
bounded review/revision loop to decide the next route.

The `proposal-program` lifecycle declares `execution_strategy:
orchestrated-replan-loop`. It coordinates parent program and child packet
targets while preserving child-owned packet truth.

The packet runner writes hash-chained `lifecycle-events.ndjson` traces. The
event schema supports planning, handoff, dispatch, status, budget, and control
categories, but does not yet name phase entry, phase exit, loop iteration, or
phase gate events as first-class event categories.

## Current Proposal Lifecycle Behavior

The proposal lifecycle already preserves critical constraints:

- no extra proposal statuses for review loops;
- review and revision are receipt-driven;
- implementation prompt generation and implementation require strict accepted
  review authorization;
- generated effective projections are discovery handles only;
- proposal-local receipts remain evidence only;
- runner orchestration is separate from executor route invocation.

## Current Change Closeout Behavior

The Change Closeout State Machine already uses a phase-loop model for closeout:
each phase has mode, exit evidence, stop or escalation behavior, cleanup safety,
receipt evidence, rollback posture, and final verification. It is a product
contract, not a generic lifecycle substrate. Its phase vocabulary is valuable
but not yet reusable by extension lifecycle contracts.

## Gap Summary

| Gap | Current State | Target State | Impact |
| --- | --- | --- | --- |
| `GAP-001` | Proposal lifecycle prose describes packet state machine and receipt loops, while the contract encodes routes, gates, receipts, and loops separately. | Contract has explicit phase-loop structure that groups routes, gates, receipts, loops, checkpoint obligations, and event obligations. | Improves determinism and operator diagnostics. |
| `GAP-002` | Generic schema supports `states`, `routes`, `gates`, `receipts`, and `loops`, but not phase-level entry or exit semantics. | Schema supports phase declarations without replacing existing statuses. | Enables reusable phase-loop validation. |
| `GAP-003` | Packet event schema lacks first-class phase and loop event categories. | Event schema can record phase entry, phase exit, loop iteration, gate reroute, budget exhaustion, and fail-closed stops. | Improves replay and debugging. |
| `GAP-004` | Checkpoint behavior records run progress but phase-loop convergence is inferred from route and verdict state. | Checkpoint records current phase, route, event head, loop counters, receipt freshness, and stop class. | Makes resume safer and more explainable. |
| `GAP-005` | Runner step budget and loop iterations exist, but their relationship to phase loops is implicit. | Phase-loop budgets distinguish non-execute handoffs, adapter dispatch attempts, and receipt-loop iterations. | Prevents accidental infinite or skipped loops. |
| `GAP-006` | Change closeout has mature phase-loop semantics, but they are not factored into lifecycle substrate language. | Generic substrate borrows reusable mechanics while leaving Change route selection and proposal route semantics separate. | Reduces conceptual drift without creating a rival closeout workflow. |
| `GAP-007` | Generated effective projection refresh is known as derived-only, but phase-loop cutover would need explicit publication sequencing. | Source-authored changes land first; generated projection refresh follows with publication and freshness receipts. | Prevents generated authority drift. |

## Non-Gap Confirmations

- Existing proposal manifest statuses are sufficient for the target model.
- Proposal-local receipts are sufficient as packet evidence but not as durable
  runtime authority.
- The runner/executor boundary is already directionally correct and should be
  clarified, not collapsed.
- Program lifecycle child authority separation must remain unchanged.
- Generated effective projections should remain runtime discovery handles only.
