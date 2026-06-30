# Implementation Plan

## Workstream 1: Contract And Boundary Declaration

Update the proposal-program lifecycle contract so clean-delivery continuation
is a declared runner posture under the existing orchestrated replan loop.

- Add contract fields for continuation mode, selected outcome, route-decision
  evidence, retry fingerprint inputs, resume source refs, and delivery handoff
  evidence.
- Bind generated projection refresh to publisher-owned routes and retained
  publication/freshness receipts.
- Preserve existing authority boundaries: child receipts remain child-owned,
  parent summaries remain aggregate-only, and generated outputs remain
  derived-only.

Validation:

- lifecycle contract validation;
- generated effective extension publication validation after implementation;
- negative control proving raw additive input and generated output paths do not
  authorize route selection directly.

## Workstream 2: Runner Route Selection

Update `lifecycle_program.rs` so the planner can select the next route without
operator prompts when only one route-owned continuation is legal.

- Reconstruct parent and child state from current manifests, child registry,
  support receipts, checkpoints, event logs, and source-ref digests.
- Select child routes before parent delivery when child gates remain open.
- Select parent routes only after parent review and child-readiness gates are
  satisfied.
- Emit route-decision, model-routing, and action-slice evidence before
  dispatch.
- Keep non-execute mode as handoff-only evidence.

Validation:

- cargo tests for deterministic route selection across review, revision,
  implementation, verification, promotion, closeout, archive, and blocked
  states;
- fixture tests for sibling child dependency ordering and write-scope
  serialization;
- review-gate digest tests proving stale child receipts select the owning
  refresh route.

## Workstream 3: Bounded Retry And Resume

Add progress fingerprinting and resume checks to prevent loops and unsafe
continuation.

- Record blocker fingerprint fields: blocker class, child id, route id, target
  digest, receipt digest, write-scope digest, stable digest boundary, and
  recovery owner.
- Apply contract-declared retry budgets and idempotency classes before
  dispatch.
- Replan after every route attempt, recovery action, generated refresh, or
  residue-classification handoff.
- Fail closed when checkpoint event heads, child registry digests, source refs,
  or model-visible context digests do not verify.

Validation:

- tests for unchanged blocker fingerprints exhausting retry budget;
- tests for changed digest boundaries allowing one owning-route refresh;
- tests for unsafe resume and parent-summary substitution failures.

## Workstream 4: Delivery Handoff Evidence

Emit Proposal Program Delivery handoff evidence only after child and parent
lifecycle gates pass.

- Bind `target_outcome=cleaned` as a requested delivery outcome, not as a
  completion claim.
- Include child receipt refs and digests, parent receipt refs and digests,
  child registry digest, generated freshness status, delivery-readiness
  preflight status, and route-decision receipt refs.
- Stop before delivery mutation when delivery readiness, Change closeout,
  branch cleanup, cleanup authorization, generated freshness, or terminal proof
  is missing or stale.

Validation:

- delivery profile and receipt validators from the delivery workflow packet;
- negative controls proving the runner does not own landing, cleanup, branch
  cleanup, terminal proof, or final `cleaned` disclosure.

## Workstream 5: Command And Skill Alignment

Update the proposal lifecycle command and skill surfaces that describe
proposal-program runner execution.

- Document clean-delivery continuation, `--execute-routes`, `--max-steps`,
  `--max-child-concurrency`, deterministic resume, and stop conditions.
- Keep the wrapper marked as no prompt bundle and not a dispatcher route.
- Keep command and skill text aligned with contract and runtime behavior.

Validation:

- extension command and skill registry validation;
- generated effective extension publication validation;
- text search proving no command or skill claims delivery, cleanup, branch
  cleanup, terminal proof, or `cleaned` authority for the runner.

## Rollback

Revert the runner, lifecycle contract, command, and skill changes as one
atomic change. Regenerate effective extension projections through owning
publisher routes after rollback and retain publication/freshness evidence.
