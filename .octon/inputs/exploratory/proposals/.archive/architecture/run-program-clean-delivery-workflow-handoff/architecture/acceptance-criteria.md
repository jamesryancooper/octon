# Acceptance Criteria

The proposal is acceptance-ready when a later review-packet pass can verify all
of these conditions from packet text and retained receipts:

- `architecture-proposal.yml#architecture_scope` uses an allowed architecture
  subtype value, and the packet explains why the change is cross-domain.
- `support/implementation-grade-completeness-review.md` records a passing
  implementation-grade completeness verdict with zero unresolved questions and
  no clarification requirement.
- `support/pre-integration-architecture-review.yml` validates in strict
  pre-integration mode against the current packet digest.
- Promotion targets are exhaustive for the declared handoff scope and remain
  under `.octon/` for `octon-internal` scope.
- Proposal Program Delivery can consume runner handoff evidence through a
  retained readiness preflight without treating that evidence as child packet,
  archive, Change, cleanup, generated-publication, branch, or terminal proof
  authority.
- Child-owned implementation conformance, post-implementation drift/churn,
  governed mechanism integration, generated publication, and feature catalog
  drift receipts remain directly validated by their owning validators.
- Parent summaries, aggregate delivery receipts, readiness projections, compact
  delivery evidence indexes, generated outputs, host state, chat, and model
  memory are explicitly classified as non-authorizing for child or Change
  transitions.
- Dirty or stale source posture routes to closeout-worktree or an equivalent
  clean-worktree route before reconstruction, broad stage-all, staging,
  branch-local commit, hosted landing, branch cleanup, final sync, or terminal
  proof.
- Closeout-worktree handoff reports cannot stage, delete, reset, archive,
  publish, branch-clean, close child packets, satisfy Change receipts, or claim
  `cleaned`.
- Branch-no-pr delivery is used only when the default work unit policy and
  closeout-change route evidence allow it, no PR-required predicate exists, and
  governed landing and cleanup authorization validate before hosted or branch
  mutation.
- Delivery receipt claims are downgraded to the highest evidence-backed outcome
  when any owning receipt, generated freshness proof, branch authorization,
  final sync proof, terminal current-state proof, or worktree hygiene proof is
  missing or stale.
- Stop-condition output maps each blocker to a stable stop ID, owning route or
  validator, required evidence, blocked outcome, and next route.
- Rollback requires reverting workflow, command, skill, closeout policy, and
  generated publication changes through the implementing Change; generated
  outputs are regenerated rather than hand edited.
- Later implemented closeout cannot claim implemented, archive-ready,
  delivered, landed, synced, or cleaned until implementation conformance,
  drift/churn, proposal review, delivery receipt, closeout-change, cleanup,
  generated freshness, and terminal proof validators pass at the relevant
  lifecycle boundary.
