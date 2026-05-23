# Validation Plan

## Proposal Creation Validation

Run these checks for this packet:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model --skip-registry-check`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model`

The registry check is intentionally skipped during proposal creation because
refreshing generated proposal projections is outside the requested scope.

## Later Implementation Validation

Run the following after a reviewed and accepted implementation modifies durable
targets:

- lifecycle contract v2 schema validation;
- phase-loop reference validation;
- phase-loop negative fixture validation;
- extension publication validation;
- generated effective projection freshness validation;
- proposal lifecycle acceptance tests;
- lifecycle runner tests;
- lifecycle executor adapter tests;
- proposal lifecycle extension route-resolution tests;
- proposal implementation readiness, review gate, conformance, and
  post-implementation drift validators;
- Change closeout lifecycle alignment validation if the implementation updates
  shared phase-loop vocabulary in the product closeout contract.

## Acceptance Scenarios

| Scenario | Expected Result |
| --- | --- |
| Draft packet with no review receipt | Runner selects review phase or handoff, not implementation. |
| In-review packet with revision-required receipt | Runner enters revision loop and increments loop count. |
| Review loop exceeds max iterations | Runner stops with blocked max iterations and preserves checkpoint. |
| Accepted packet with stale review digest | Implementation prompt generation is denied and rerouted to review. |
| Accepted packet with fresh review but missing implementation-grade receipt | Implementation routes are denied. |
| Implementation route requested without explicit execution authority | Runner stops at route-ready handoff. |
| Durable route requested without required human approval evidence | Executor blocks before dispatch. |
| Route completes but required receipt is absent | Route completion is not accepted. |
| Checkpoint event head mismatches event log | Resume fails closed. |
| Cancellation marker exists | Resume and execute-routes return cancelled without dispatch. |
| Generated projection differs from source after source edit | Publication validation blocks until refreshed with receipt. |
| Generated projection is opened as authority | Validator or runtime access denies the path. |
| Proposal-local receipt is used as runtime authority | Authority-boundary check denies the claim. |
| Proposal archive requested before closeout receipt | Archive route is denied. |
| Clean-break cutover leaves old compatibility semantics active | Acceptance fails until old semantics are removed or explicitly retained with owner and retirement trigger. |
| Valid proposal-packet v2 phase-loop contract | Contract validator passes and all phase refs resolve. |
| Dangling route, receipt, gate, validator, loop, terminal, or phase ref | Contract validator fails. |
| Backward transition points at missing phase | Contract validator fails. |
| Loop bound is missing or unbounded | Contract validator fails. |
| Terminal phase declares dispatchable route | Contract validator fails. |
| Phase id appears in proposal manifest status set | Contract validator fails. |
| Stale review receipt exists | Runner routes to review phase and does not authorize implementation. |
| Revision loop exhausts `max_phase_iterations` | Runner stops as `blocked-max-iterations` and preserves checkpoint. |
| Implementation requested without strict fresh review | Runner denies implementation route. |
| Archive requested without closeout receipt | Runner denies archive route. |
| Generated effective projection is absent or stale | Runtime discovery fails closed until publication refresh. |
| Source-authored contract and generated projection disagree | Publication/freshness validation fails. |
| Cancellation then resume | Resume preserves phase state and returns cancelled without dispatch. |
| Checkpoint phase and event-log head disagree | Resume fails closed with phase blocker evidence. |

## Fixture Requirements

Later implementation must add named positive and negative fixtures for:

- valid `phase_loop` over the proposal-packet lifecycle;
- duplicate phase id;
- dangling `route_refs`;
- dangling `receipt_refs`;
- dangling `gate_refs`;
- dangling `validator_refs`;
- dangling `loop_refs`;
- dangling terminal outcome refs;
- dangling backward-transition phase id;
- missing loop bounds;
- non-finite loop bounds;
- terminal phase with route dispatch;
- phase-defined proposal status expansion;
- generated-effective-as-source-authority denial;
- stale generated projection denial;
- cancellation/resume phase preservation.

## Evidence Quality

Evidence must prove behavior and boundaries, not only mirror implementation
text. Required evidence classes include behavior proof, boundary proof,
architecture proof, runtime authorization proof, generated-output freshness
proof, and retained evidence proof.
