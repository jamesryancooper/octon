# Executable Implementation Prompt

Implement only the owned scope for `architectural-review-post-integration-boundaries`.

## Promotion Targets

- `.octon/framework/orchestration/runtime/workflows/meta/verify-implementation-conformance/`
- `.octon/framework/orchestration/runtime/workflows/meta/audit-post-implementation-drift/`
- `.octon/framework/orchestration/runtime/workflows/meta/lifecycle-postmortem/`
- `.octon/framework/assurance/evaluators/lifecycle-postmortem/`
- `.octon/framework/assurance/runtime/_ops/scripts/`

## Required Work

- Preserve implementation conformance and post-implementation drift/churn as hard closeout gates.
- Keep Post-Integration Architecture Review evidence-only under current policy.
- Confirm lifecycle postmortem cannot authorize closeout, promotion, redesign, support widening, generated publication, or constitutional amendment.

## Validation And Evidence

Run `validate-architectural-review-routing.sh`, `validate-proposal-implementation-conformance.sh`, `validate-proposal-post-implementation-drift.sh`, `validate-proposal-standard.sh`, `validate-architecture-proposal.sh`, and `validate-proposal-implementation-readiness.sh`.
Record evidence in `support/implementation-run.md`, then produce `support/implementation-conformance-review.md` and `support/post-implementation-drift-churn-review.md`.

## Rollback And Closeout

Rollback restores only the child-owned boundary wording or validator checks.
Block closeout or archive if post-integration review is treated as a hard closeout gate, if postmortem authority expands, or if conformance and drift/churn receipts are absent.
