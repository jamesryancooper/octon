# Acceptance Criteria

## Runner Route Selection

- The runner emits a route-decision receipt that names the selected route,
  route owner, source refs, digests, blocked alternatives, and authority
  boundary before dispatch.
- When exactly one child-owned or parent-owned route is legal, the runner can
  select it without an operator prompt.
- When more than one route is legal, no route is legal, or ownership is
  ambiguous, the runner stops with a typed blocker instead of guessing.
- Non-execute mode still stops at planned `program-route-handoff` evidence and
  does not run selected routes.

## Child Authority Preservation

- Parent summaries, readiness projections, generated registries, generated
  effective outputs, chat, host state, and model memory are rejected as child
  receipt substitutes.
- Child promotion, closeout, archive, verification, and implementation
  transitions require child-owned receipts and digests.
- Parent aggregate receipts may cite child evidence only by path and digest.

## Retry And Resume

- Bounded retries stop on unchanged blocker fingerprints after the declared
  budget is exhausted.
- Retry is allowed only when the lifecycle contract declares the recovery
  route or action, idempotency class, authority zone, and post-attempt
  validation.
- Resume succeeds only when checkpoint event heads, child registry digest,
  source refs, model-visible context digest, and selected child evidence still
  verify.
- Unsafe resume fails closed and records a typed blocker.

## Delivery Handoff

- Delivery handoff occurs only after parent review, child-readiness, receipt
  freshness, generated freshness, worktree posture, route legality, and
  delivery-readiness preflight gates pass.
- `target_outcome=cleaned` is recorded as a Proposal Program Delivery input,
  not as completion proof.
- The runner stops before hosted mutation, landing, push, branch cleanup,
  deletion, Change closeout, terminal proof, or a `cleaned` claim unless the
  owning route has explicit authority and fresh retained evidence.

## Validation And Evidence

- `cargo test -p kernel lifecycle_program` covers route selection, retry
  budget exhaustion, resume safety, delivery handoff, and negative controls.
- Proposal-program structure and child-readiness validators pass on fixture
  programs covering clean delivery progression and blocked states.
- Extension publication/freshness validators pass after additive command,
  skill, and lifecycle contract changes are generated into effective outputs.
- Retained evidence exists for route decisions, retry fingerprints, resume
  source refs, handoff inputs, and blocker outcomes.
