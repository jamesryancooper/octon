# Implementation Plan

## Route Requirement

This is a later implementation plan only. It must not be executed from this
packet creation step.

Before implementation starts:

1. Review and revise this packet.
2. Record a fresh accepted `support/proposal-review.md` with
   `implementation_prompt_authorized: yes`.
3. Pass the implementation-grade completeness gate.
4. Generate an implementation prompt through the governed proposal lifecycle.
5. Run implementation through the approved runner/executor route with retained
   evidence.

## Workstream 1: Contract Model

Update the source-authored proposal lifecycle contract to include explicit
phase-loop declarations by moving the contract to
`schema_version: octon-extension-lifecycle-contract-v2` and adding
`phase_loop.model_version: phase-loop-v1`. The implementation must preserve
existing routes, receipts, gates, terminal outcomes, and proposal manifest
statuses while adding phase transition and observability policy.

Required design points:

- keep `proposal.yml#status` allowed statuses unchanged;
- keep existing `routes`, `receipts`, `gates`, `validators`, `loops`, and
  `terminal_outcomes` as the canonical route and evidence definitions;
- make `phase_loop` reference those existing definitions instead of duplicating
  route predicates;
- include the full phase set from `architecture/target-architecture.md`;
- define phase entry and exit evidence without making phases proposal statuses;
- define re-entry triggers and backward transitions;
- bind implementation, promotion, closeout, and archive phases to fresh receipt
  gates;
- require fail-closed behavior on missing, stale, or contradictory evidence.

## Workstream 2: Schema Updates

Update `extension-lifecycle-contract.schema.json` to support
`octon-extension-lifecycle-contract-v2` and `phase_loop`.

Required `phase_loop` fields:

- `model_version`;
- `phases[]`;
- phase `phase_id`;
- phase `mode`;
- phase `owner_layer`;
- phase `route_refs`;
- phase `receipt_refs`;
- phase `gate_refs`;
- phase `entry_when`;
- phase `exit_when`;
- phase `exit_evidence_refs`;
- phase `re_entry_triggers`;
- phase `backward_transitions`;
- phase `loop_bounds`;
- phase `stop_conditions`;
- phase `authority_boundaries`.

Schema and validator support must enforce:

- unique phase ids;
- all route, receipt, gate, validator, loop, terminal, and phase refs resolve;
- backward transitions target existing phases;
- loop bounds are finite;
- terminal phases do not dispatch routes;
- no phase introduces or implies new manifest statuses.

Update `lifecycle-run-event.schema.json` to support phase-scoped events with
`phase_id`, `transition_id`, and event types for `phase-entered`,
`phase-exited`, `phase-backtracked`, and `phase-blocked`.

## Workstream 3: Runner And Checkpoint Behavior

Update lifecycle runner behavior to:

- plan from the current phase and route, not only from route conditions;
- evaluate current phase from durable manifest, receipt, gate, checkpoint, and
  event evidence;
- enforce allowed transitions and backward transitions;
- maintain phase attempt counts and route dispatch counts;
- write checkpoint fields for `current_phase`, `phase_counts`,
  `last_phase_transition`, `phase_blockers`, selected route, receipt
  freshness, gate results, event-log head, and stop class;
- verify resume from checkpoint against current target digest, receipt state,
  event-log head, and cancellation marker;
- distinguish non-execute handoffs from adapter dispatch attempts in budgets;
- fail closed when checkpoint and event log disagree;
- keep `route-ready` or equivalent handoff outcomes distinct from completed
  route execution.

## Workstream 4: Event Log And Replay

Extend packet event logging to cover:

- `phase-entered`;
- `phase-exited`;
- `phase-backtracked`;
- `phase-blocked`;
- loop iteration start and finish;
- gate reroute;
- stale receipt detection;
- budget exhaustion;
- checkpoint rebaseline;
- cancellation;
- fail-closed blocker classification.

Replay validation should prove the event chain, checkpoint convergence, route
ordering, phase transition legality, loop bound adherence, and
impossible-transition denial.

## Workstream 5: Proposal Extension Semantics

Update the proposal lifecycle extension docs, commands, skills, prompts, and
validation scenarios so operators see phase-loop behavior without confusing it
with proposal statuses.

Required updates:

- lifecycle model and routing guide explain phase-loop behavior;
- run-packet lifecycle skill states that phases are runner state, not proposal
  statuses;
- create, review, revise, implementation, verification, closeout, and archive
  prompts preserve receipt gates and non-authority boundaries;
- validation scenarios cover phase-loop convergence and fail-closed behavior.

## Workstream 6: Validators And Tests

Add or update validators and acceptance tests to cover:

- lifecycle contract phase-loop schema validity;
- references from phases to routes, receipts, gates, validators, and loops;
- references from backward transitions to existing phases;
- references from phase terminal policies to existing terminal outcomes;
- finite `max_phase_iterations` and `max_route_dispatches`;
- terminal phases do not dispatch routes;
- no new proposal statuses;
- stale receipt denial;
- missing phase exit evidence denial;
- loop max iteration denial;
- resume from valid checkpoint;
- denial on checkpoint/event-log mismatch;
- cancellation prevents further dispatch;
- generated projection refresh remains derived-only;
- generated effective projection is required for runtime discovery but is not
  source authority.

## Workstream 7: Publication

After source-authored changes pass validation:

1. Refresh generated effective extension projections.
2. Verify generated projection source digests.
3. Refresh host-projected proposal lifecycle skills from source extension
   inputs.
4. Retain publication and freshness receipts.
5. Re-run lifecycle discovery and acceptance tests against the generated
   runtime handles.
6. Retire v1 packet lifecycle claims or mark v1 as compatibility-only with
   owner, removal review, and retirement trigger.

Generated outputs remain derived-only throughout.
