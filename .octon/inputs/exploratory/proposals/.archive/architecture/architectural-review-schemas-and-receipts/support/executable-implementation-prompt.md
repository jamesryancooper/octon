# Executable Implementation Prompt

Implement only the owned scope for `architectural-review-schemas-and-receipts`.

## Promotion Targets

- `.octon/framework/constitution/contracts/assurance/`
- `.octon/framework/scaffolding/governance/patterns/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/framework/assurance/runtime/_ops/fixtures/`

## Required Work

- Add strict native architectural review report, routing decision, and support receipt schemas.
- Reuse `review-finding-v1` and `review-disposition-v1`.
- Add validator fixtures that reject placeholder, stale, missing-validator, missing-evidence, and non-passing receipts.

## Validation And Evidence

Run `validate-architectural-review-receipts.sh`, `test-architectural-review-validators.sh`, `validate-proposal-standard.sh`, `validate-architecture-proposal.sh`, and `validate-proposal-implementation-readiness.sh`.
Record evidence in `support/implementation-run.md`, then produce `support/implementation-conformance-review.md` and `support/post-implementation-drift-churn-review.md`.

## Rollback And Closeout

Rollback removes the architectural-review schema files, fixtures, and validator additions for this child.
Block closeout or archive if receipt strictness can be bypassed, if receipts lack evidence refs, or if conformance and drift/churn receipts are absent.
