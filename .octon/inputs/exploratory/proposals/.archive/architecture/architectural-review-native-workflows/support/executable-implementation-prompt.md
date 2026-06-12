# Executable Implementation Prompt

Implement only the owned scope for `architectural-review-native-workflows`.

## Promotion Targets

- `.octon/framework/orchestration/runtime/workflows/audit/pre-integration-architecture-review/`
- `.octon/framework/orchestration/runtime/workflows/audit/post-integration-architecture-review/`
- `.octon/framework/orchestration/runtime/workflows/audit/current-state-mechanism-architecture-review/`
- `.octon/framework/orchestration/runtime/workflows/audit/architecture-readiness-audit/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`

## Required Work

- Add canonical workflow contracts and stages for the three architectural review modes.
- Normalize `architecture-readiness-audit` as the canonical workflow route.
- Register workflows in manifests and registries.

## Validation And Evidence

Run `validate-architectural-review-workflows.sh`, `validate-architectural-review-naming.sh`, `validate-proposal-standard.sh`, `validate-architecture-proposal.sh`, and `validate-proposal-implementation-readiness.sh`.
Record evidence in `support/implementation-run.md`, then produce `support/implementation-conformance-review.md` and `support/post-implementation-drift-churn-review.md`.

## Rollback And Closeout

Rollback removes the new workflow directories and restores the prior readiness workflow path only for this child.
Refuse closeout or archive if workflow contracts are unregistered, if legacy routes remain active, or if conformance and drift/churn receipts are absent.
