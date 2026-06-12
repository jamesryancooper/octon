# Executable Implementation Prompt

Implement only the owned scope for `architectural-review-extension-split-cleanup`.

## Promotion Targets

- `.octon/inputs/additive/extensions/octon-concept-integration/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`

## Required Work

- Update `octon-concept-integration` so architecture review method references native doctrine.
- Keep Architecture Revision Packet as an extension-owned packetization helper.
- Remove duplicate method ownership once native doctrine exists and update extension-local tests.

## Validation And Evidence

Run `validate-architectural-review-extension-split.sh`, `validate-extension-local-tests.sh`, `validate-extension-publication-state.sh`, `validate-proposal-standard.sh`, `validate-architecture-proposal.sh`, and `validate-proposal-implementation-readiness.sh`.
Record evidence in `support/implementation-run.md`, then produce `support/implementation-conformance-review.md` and `support/post-implementation-drift-churn-review.md`.

## Rollback And Closeout

Rollback restores the prior extension prompt text and removes the split validator for this child.
Block closeout or archive if extension packetization can replace native lifecycle gates, if duplicate method ownership returns, or if conformance and drift/churn receipts are absent.
