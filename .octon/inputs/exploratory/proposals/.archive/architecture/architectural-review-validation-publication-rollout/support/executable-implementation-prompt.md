# Executable Implementation Prompt

Implement only the owned scope for `architectural-review-validation-publication-rollout`.

## Promotion Targets

- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/framework/assurance/runtime/_ops/fixtures/`

## Required Work

- Add rollout validators, schema tests, receipt tests, negative controls, workflow registration checks, publication checks, and completion gates.
- Regenerate generated registries and projections with canonical scripts only.
- Confirm generated artifacts remain derived-only and are not authority.

## Validation And Evidence

Run `test-architectural-review-validators.sh`, `generate-proposal-registry.sh --write`, `validate-proposal-artifact-index-spine.sh`, `validate-capability-publication-state.sh`, `validate-proposal-standard.sh`, `validate-architecture-proposal.sh`, and `validate-proposal-implementation-readiness.sh`.
Record evidence in `support/implementation-run.md`, then produce `support/implementation-conformance-review.md` and `support/post-implementation-drift-churn-review.md`.

## Rollback And Closeout

Rollback removes rollout validator additions and regenerates affected generated projections from source.
Forbid closeout or archive if publication is stale, if generated outputs are hand-edited authority, or if conformance and drift/churn receipts are absent.
