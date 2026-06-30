# Implementation Plan

## Workstream 1: Delivery Profile And Runner Handoff

- Current assumption: Proposal Program Delivery accepts a profile and target
  outcome, while the program runner can emit handoff evidence after child
  lifecycle work.
- Required change: add or align profile and workflow fields for runner handoff
  state, requested delivery outcome, release state, order policy, PR policy,
  stash policy, include-path classification state, and retained preflight refs.
- Owner: Proposal Program Delivery workflow and operator surfaces.
- Priority: high.
- Rationale: delivery must consume a stable handoff contract instead of
  rediscovering runner state or treating parent summaries as child evidence.
- Evidence: profile validator output, workflow validator output, and retained
  readiness preflight receipt.

## Workstream 2: Readiness Preflight

- Current assumption: the workflow has a `delivery-readiness-preflight` stage
  and a retained preflight done gate.
- Required change: make the preflight the single required gate before child
  continuation, parent delivery, Git mutation, publication checks, archive
  routing, cleanup, branch deletion, final sync, or terminal proof. It must
  record Git write probes, worktree cleanliness, source staleness, include-path
  classification, review freshness, child receipt compatibility, generated
  freshness, route legality, and tooling availability.
- Owner: Proposal Program Delivery workflow.
- Priority: high.
- Rationale: downstream routes need one retained blocker record, not repeated
  ad hoc rediscovery.
- Evidence: readiness receipt path and digest cited by the aggregate delivery
  receipt.

## Workstream 3: Child Receipt And Generated Publication Boundaries

- Current assumption: child packet receipts and generated publication evidence
  remain owned outside the parent delivery aggregate.
- Required change: require direct source receipt refs and digests for child
  implementation conformance, post-implementation drift/churn, governed
  mechanism integration when applicable, generated publication freshness, and
  feature catalog drift. Reject parent summary, delivery receipt, readiness
  projection, or evidence index substitution for those source receipts.
- Owner: child packet routes, generated publishers, and delivery receipt
  validation.
- Priority: high.
- Rationale: aggregate evidence can coordinate but cannot satisfy target-owned
  gates.
- Evidence: child validator outputs, generated publication receipts, feature
  catalog drift receipt, and negative-control validator results.

## Workstream 4: Closeout And Archive Handoff

- Current assumption: packet closeout and archive routing are distinct from
  Change closeout.
- Required change: route implemented packet closeout through packet lifecycle
  closeout, then route archive relocation through archive lifecycle. Delivery
  must block Change closeout after fresh archive mutation until terminal
  freshness, implementation conformance, and drift/churn validation are current.
- Owner: proposal packet closeout and archive lifecycle routes.
- Priority: high.
- Rationale: delivery cannot directly close or archive packets while preserving
  child-owned evidence.
- Evidence: packet closeout receipt, archive authorization, archive route
  receipt, terminal freshness validation, and updated proposal registry or
  artifact projection publication evidence when applicable.

## Workstream 5: Dirty Or Stale Source Handoff

- Current assumption: dirty worktrees, stale source posture, and local residue
  are outside the delivery aggregate's mutation authority.
- Required change: route dirty or stale source posture to closeout-worktree with
  classifier output ref and digest, foreign fingerprint when relevant, exact
  include/exclude path sets, required return evidence, and no-substitution
  boundaries for child and Change receipts. Route eligible local Octon residue
  to repo-hygiene-cleanup through its governed helper path.
- Owner: closeout-worktree and repo-hygiene-cleanup.
- Priority: high.
- Rationale: source cleanliness must be an explicit route-owned handoff before
  staging, broad stage-all, commit, hosted landing, or cleaned claims.
- Evidence: worktree classifier receipt, closeout-worktree report,
  repo-hygiene classification or cleanup receipt, and delivery receipt source
  refs.

## Workstream 6: Change Closeout And Branch-No-PR Delivery

- Current assumption: closeout-change owns singular Change route selection,
  branch-no-pr hosted preflight, landing authorization, branch cleanup
  authorization, rollback, final sync, terminal proof refs, and actual
  lifecycle outcome.
- Required change: ensure Proposal Program Delivery passes explicit
  include/exclude paths, route hints, target lifecycle outcome, validation
  floor, rollback posture, profile constraints, and source receipt refs into
  closeout-change. Delivery must downgrade to the actual closeout outcome when
  closeout-change lacks landing, cleanup, sync, or terminal proof evidence.
- Owner: closeout-change.
- Priority: high.
- Rationale: delivery may request `cleaned`, but only closeout-change can prove
  landed or cleaned for the coherent Change.
- Evidence: Change receipt, branch landing authorization, branch cleanup
  authorization, hosted landing proof, final sync proof, rollback handle, and
  terminal current-state proof ref.

## Workstream 7: Aggregate Receipt And Evidence Index

- Current assumption: Proposal Program Delivery emits an aggregate receipt and a
  compact delivery evidence index.
- Required change: the aggregate receipt must record source receipt refs,
  digests, disclosure tiers, non-authority classifications, stop condition IDs,
  owning next routes, highest evidence-backed outcome, and excluded evidence
  classes. The evidence index must remain compact, retained, and
  non-authorizing.
- Owner: Proposal Program Delivery receipt and evidence-index validators.
- Priority: high.
- Rationale: final delivery reports must be inspectable without becoming a
  second authority source.
- Evidence: `validate-proposal-program-delivery-receipt.sh`,
  `generate-proposal-program-delivery-evidence-index.sh`, and
  `validate-proposal-program-delivery-evidence-index.sh`.

## Rollback Path

- Before implementation, reject or supersede this packet.
- During implementation, keep changes atomic across workflow, command, skill,
  default-work-unit, closeout state machine, closeout-change, and
  closeout-worktree surfaces.
- After implementation, revert the durable target changes and regenerate any
  derived projections through owning publishers. Do not hand edit generated
  effective outputs as rollback.

## Closeout Expectations

- Implementation conformance must prove every declared promotion target is
  covered or explicitly blocked.
- Post-implementation drift/churn must prove promoted targets do not depend on
  active proposal paths and that generated projections are fresh.
- Delivery closeout must not claim `cleaned` unless closeout-change and terminal
  proof evidence prove landing, cleanup authorization, cleanup disposition,
  final sync, clean worktree posture, and required correction-branch aggregate
  evidence when applicable.
