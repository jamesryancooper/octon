# Executable Implementation Prompt

prompt_id: run-program-clean-delivery-validators-implementation-20260629T143231Z
proposal_path: .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-validators
authorized_review_digest: sha256:21cf98cb01008fdad1b6919362c5fd3286b9278a6b170c12e1be4d08db177305
implementation_authorized: yes

## Goal

Implement the validators packet by preserving exactly these promotion targets:

- `.octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-run-program-clean-delivery-validator.sh`

## Instructions

- Keep the aggregate validator read-only.
- In static mode, require the clean-delivery validator chain to exist and pass
  the static validators that support no-argument validation.
- In `--receipt <proposal-program-delivery-receipt>` mode, run
  `validate-proposal-program-delivery-receipt.sh --receipt <receipt>` before
  aggregate clean terminal checks.
- Fail closed unless the receipt records `actual_outcome: cleaned`, passing
  fresh terminal proof, clean worktree hygiene, final sync equality, no open
  blockers, and target-owned receipt preservation.
- Do not authorize archive, cleanup, branch cleanup, generated publication, Git
  mutation, terminal proof synthesis, or a `cleaned` claim.

## Validation Commands

- `bash -n .octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh`
- `bash -n .octon/framework/assurance/runtime/_ops/tests/test-run-program-clean-delivery-validator.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-run-program-clean-delivery-validator.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-validators --require-implementation-authorization`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-validators`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-validators/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-validators --mode pre-integration-architecture-review --require-pass`

## Retained Evidence

Record implementation evidence in `support/implementation-run.md`, validation
evidence in `support/validation.md`, implementation conformance in
`support/implementation-conformance-review.md`, and post-implementation drift
or churn review in `support/post-implementation-drift-churn-review.md`.

## Rollback

Rollback removes the aggregate validator and regression test together. Do not
leave one target promoted without the other.

## Closeout Refusal Criteria

Refuse closeout or archive when validation fails, promotion evidence is missing,
receipt digests are stale, implementation conformance does not pass,
post-implementation drift/churn does not pass, or the packet attempts to use
aggregate, parent, generated, host, proposal-local, chat, model-memory, or
local/private evidence as a substitute for target-owned delivery, archive,
cleanup, Change closeout, generated publication, branch cleanup, or terminal
proof receipts.
