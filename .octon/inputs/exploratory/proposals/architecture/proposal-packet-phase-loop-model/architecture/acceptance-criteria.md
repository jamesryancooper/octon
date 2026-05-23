# Acceptance Criteria

## Architecture Acceptance

This proposal is implementation-grade when all criteria below are met:

- current proposal lifecycle and Lifecycle Autopilot behavior is summarized
  from source-authored files and runtime implementation surfaces;
- target Proposal Packet Phase-Loop Model is explicit;
- placement decision is layered/both with a clear substrate and extension
  responsibility split;
- runner and executor responsibility boundary is preserved;
- contract, schema, receipt, gate, checkpoint, event-log, validator, and test
  impacts are named;
- file-by-file impact distinguishes source-authored surfaces from generated
  projections;
- clean-break cutover sequence is concrete and does not introduce intermediate
  live authority states;
- explicit non-changes preserve proposal non-authority, existing proposal
  statuses, and self-operating versus self-authorizing separation;
- risk and fail-closed behavior is complete enough for review;
- later implementation sequencing can start without inventing hidden scope;
- generated effective projection refresh is treated only as a derived
  publication step.

## Later Implementation Acceptance

A later implementation is acceptable only when:

- proposal packet lifecycle source contract uses
  `schema_version: octon-extension-lifecycle-contract-v2`;
- proposal packet lifecycle source contract declares
  `phase_loop.model_version: phase-loop-v1`;
- no new proposal manifest statuses are introduced unless the accepted
  implementation proves a contract-level need and updates validators;
- lifecycle contract phase declarations validate against schema;
- every phase references existing route, receipt, gate, validator, and loop ids;
- every backward transition targets an existing phase;
- every phase loop has finite `max_phase_iterations` and
  `max_route_dispatches`;
- terminal phases cannot dispatch routes;
- runner checkpoints record current phase, selected route, loop counters,
  `phase_counts`, `last_phase_transition`, `phase_blockers`, event head,
  receipt freshness, gate results, stop class, and resume command;
- packet event logs record `phase-entered`, `phase-exited`,
  `phase-backtracked`, `phase-blocked`, loop iteration, gate reroute, budget
  exhaustion, cancellation, and fail-closed blocker events;
- lifecycle event schema supports `phase_id` and `transition_id`;
- replay verifies hash chain and checkpoint convergence;
- stale, missing, incomplete, or contradictory receipts deny implementation,
  promotion, closeout, and archive routes;
- executor adapter cannot dispatch durable routes without valid delegation
  proof and approval evidence;
- generated effective projection is required for runtime discovery but never
  becomes source authority;
- generated projections are refreshed from source and publication receipts are
  retained;
- host-projected proposal lifecycle skills are refreshed from source extension
  inputs when source skill inputs change;
- proposal lifecycle skills and docs explain phases without treating them as
  manifest statuses;
- acceptance tests cover positive, negative, stale, blocked, incomplete,
  unsafe, ambiguous, successful, cancelled, resumed, archived, loop-bound, and
  generated-authority-denial cases.

## Closeout Acceptance

Closeout of the later implementation requires:

- implementation conformance receipt with `verdict: pass`;
- post-implementation drift/churn receipt with `verdict: pass`;
- evidence that durable targets do not depend on this proposal path as
  authority;
- generated projection freshness receipts where generated outputs changed;
- rollback notes identifying how to restore previous contract, schema, runner,
  validator, skill, and projection behavior;
- final disclosure that this proposal packet is temporary and may be archived
  only after durable targets stand alone.
