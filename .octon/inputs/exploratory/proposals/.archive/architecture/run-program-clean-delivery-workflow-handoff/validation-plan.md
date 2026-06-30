# Validation Plan

Packet revision validators:

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff`
- `validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff --mode pre-integration-architecture-review --require-pass`
- `validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff --print-digest`

Future implementation validators and evidence:

- `validate-proposal-program-delivery-workflow.sh`
- `validate-proposal-program-delivery-profile.sh --profile <profile>`
- `validate-proposal-program-delivery-receipt.sh --receipt <receipt>`
- `generate-proposal-program-delivery-evidence-index.sh --receipt <receipt> --run-id <run-id> --write`
- `validate-proposal-program-delivery-evidence-index.sh --index <index>`
- `validate-change-closeout-state-machine.sh`
- `validate-closeout-worktree-wrapper.sh`
- `validate-branch-no-pr-delivery-authorization-envelope.sh`
- `validate-feature-catalog-drift-closeout.sh --receipt <receipt>`
- `validate-proposal-implementation-conformance.sh --package <packet>`
- `validate-proposal-post-implementation-drift.sh --package <packet>`
- `validate-generated-effective-freshness.sh`
- `validate-generated-non-authority.sh`
- `validate-input-non-authority.sh`

Negative controls:

- parent summary or delivery aggregate substituted for a child receipt must
  fail the delivery receipt validator;
- readiness preflight evidence used as Git, archive, cleanup, branch, or
  terminal proof authority must fail boundary review;
- branch-no-pr landing without governed landing authorization must fail;
- branch cleanup without governed cleanup authorization must fail;
- `cleaned` claimed without terminal current-state proof after the final
  mutation must fail;
- generated effective outputs edited directly instead of regenerated through
  the owning publisher must fail freshness or non-authority validation.

Retained evidence expectations:

- delivery readiness preflight receipt;
- child-owned receipt refs and digests;
- feature catalog drift receipt;
- generated publication and freshness receipts;
- closeout-worktree report or repo-hygiene cleanup receipt when source posture
  requires them;
- closeout-change receipt, hosted landing proof, cleanup authorization, final
  sync proof, rollback handle, and terminal current-state proof when landed,
  synced, or cleaned is claimed;
- aggregate Proposal Program Delivery receipt and compact delivery evidence
  index with non-authority classification.
