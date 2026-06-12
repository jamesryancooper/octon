# Repository Reconnaissance

## Searches Run

- `rg` for `proposal-program`, delivery profile and receipt terms, lifecycle
  terminal proof, implementation conformance, drift/churn, closeout, repo
  hygiene, generated publication, and governed mechanism integration.
- `find` over `.octon/framework/orchestration/runtime/workflows/meta`.
- `find` over proposal packets under `.octon/inputs/exploratory/proposals`.
- `find` over runtime command and skill registries.
- Direct reads of:
  - `.octon/framework/product/features/governed-lifecycle-orchestration.md`
  - `.octon/framework/product/contracts/default-work-unit.yml`
  - `.octon/framework/product/contracts/change-closeout-state-machine.yml`
  - `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`
  - `.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md`
  - adjacent architecture packets for Change closeout, repo hygiene, and
    governed mechanism integration.

## Existing Surfaces Found

- Governed Lifecycle Orchestration already owns proposal-packet and
  proposal-program lifecycle coordination.
- Proposal-program lifecycle keeps child packets as owners of manifests,
  receipts, promotion targets, validation verdicts, and archive metadata.
- Lifecycle interaction receipts already forbid source lifecycles from
  authorizing target-owned lifecycles.
- Default work-unit policy owns Change route selection and branch-no-pr
  evidence requirements.
- Change closeout state machine owns branch landing, branch cleanup, final
  verification, and cleaned outcome proof.
- Closeout-worktree decomposes dirty worktrees into singular Change candidates.
- Repo-hygiene-cleanup owns receipt-backed local residue cleanup.
- Terminal current-state proof and correction-branch aggregate receipts already
  exist as evidence-only closeout support.
- Governed mechanism integration verification is already proposed as a
  mechanism-specific closeout gate.

## Reused Surfaces

- Proposal lifecycle and proposal-program lifecycle for parent/child execution.
- Implementation conformance and post-implementation drift/churn validators.
- Generated publication freshness validators and publisher-owned projection
  refreshes.
- Governed mechanism integration verification when a child changes a governed
  mechanism.
- Default work-unit, Change closeout state machine, closeout-change,
  closeout-worktree, and repo-hygiene-cleanup for Git and cleanup ownership.
- Lifecycle terminal current-state proof for final cleaned evidence.

## Rejected Placements

- Rejected adding this responsibility to `proposal-program` because that would
  move Git, branch cleanup, repo hygiene, and Change closeout authority into
  the proposal lifecycle.
- Rejected adding child dependency sequencing to `closeout-change` because
  closeout owns singular Change routing and should not understand proposal
  child acceptance order.
- Rejected lifecycle postmortem as the delivery surface because postmortems are
  evidence-only and cannot authorize closeout.
- Rejected generated implementation prompts as authority because generated
  artifacts remain derived and non-authoritative.

## New Surface Rationale

A new `proposal-program-delivery` workflow is the smallest robust surface that
can coordinate multiple target-owned lifecycles, validate their receipts, and
emit one delivery receipt without changing ownership of the target lifecycles.
