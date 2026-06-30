# Executable Implementation Prompt

prompt_id: run-program-clean-delivery-operator-surface-implementation-20260629T145230Z
proposal_path: .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-operator-surface
authorized_review_digest: sha256:4ca1fc9a808a4e72e3688e8b5ba69ed59a2ec061790d8ad052269f1d33cc51dc
implementation_authorized: yes

## Goal

Implement the operator-surface packet by preserving exactly these promotion
targets:

- `.octon/framework/capabilities/runtime/commands/proposal-program-delivery.md`
- `.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/SKILL.md`
- `.octon/framework/product/features/catalog.yml`
- `.octon/framework/product/features/README.md`
- `.octon/framework/product/features/governed-proposal-delivery.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/octon-proposal-run-program-lifecycle.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/manifest.fragment.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/octon-proposal-lifecycle-run-program-lifecycle/SKILL.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/registry.fragment.yml`

## Instructions

- Keep `/proposal-program-delivery` as the canonical clean-delivery operator
  command.
- Keep the operations skill as a route wrapper that delegates to
  `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/workflow.yml`.
- Keep product feature documentation explicit that aggregate delivery receipts
  summarize target-owned evidence and do not replace child packet, archive,
  cleanup, Change closeout, generated publication, branch cleanup, or terminal
  proof receipts.
- Keep lifecycle-runner command and skill wording explicit that
  `target_outcome=cleaned` is only a Proposal Program Delivery handoff request.
- Do not introduce a duplicate `/run-program-to-clean-delivery` command.
- Do not authorize archive, cleanup, branch cleanup, generated publication, Git
  mutation, terminal proof synthesis, or a `cleaned` claim.

## Validation Commands

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-operator-surface --skip-registry-check`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-operator-surface`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-operator-surface --require-implementation-authorization`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-operator-surface/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-operator-surface --mode pre-integration-architecture-review --require-pass`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-operator-surface`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-operator-surface`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-operator-surface`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh`

## Retained Evidence

Record implementation evidence in `support/implementation-run.md`, validation
evidence in `support/validation.md`, implementation conformance in
`support/implementation-conformance-review.md`, and post-implementation drift
or churn review in `support/post-implementation-drift-churn-review.md`.

## Rollback

Rollback removes the command surface, operations skill, feature catalog entry,
feature note, feature index reference, and lifecycle handoff wording together.
Do not leave only part of the operator surface promoted.

## Closeout Refusal Criteria

Refuse closeout or archive when validation fails, promotion evidence is missing,
receipt digests are stale, implementation conformance does not pass,
post-implementation drift/churn does not pass, or the packet attempts to use
aggregate, parent, generated, host, proposal-local, chat, model-memory, or
local/private evidence as a substitute for target-owned delivery, archive,
cleanup, Change closeout, generated publication, branch cleanup, or terminal
proof receipts.
