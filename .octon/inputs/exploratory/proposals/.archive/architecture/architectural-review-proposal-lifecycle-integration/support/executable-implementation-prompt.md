# Executable Implementation Prompt

Implement only the owned scope for `architectural-review-proposal-lifecycle-integration`.

## Promotion Targets

- `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`
- `.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md`
- `.octon/framework/orchestration/runtime/workflows/meta/create-architecture-proposal/`
- `.octon/framework/orchestration/runtime/workflows/audit/audit-architecture-proposal/`
- `.octon/framework/orchestration/runtime/workflows/meta/validate-proposal/`
- `.octon/framework/orchestration/runtime/workflows/meta/promote-proposal/`
- `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`

## Required Work

- Wire mandatory Pre-Integration Architecture Review into proposal review and implementation authorization gates.
- Ensure missing, stale, invalid, placeholder, non-passing, and omitted-validator receipts fail closed.
- Update lifecycle workflow documentation and done gates to reflect strict receipt enforcement.

## Validation And Evidence

Run `validate-architectural-review-lifecycle-gates.sh`, `validate-architectural-review-receipts.sh`, `validate-proposal-standard.sh`, `validate-architecture-proposal.sh`, and `validate-proposal-implementation-readiness.sh`.
Record evidence in `support/implementation-run.md`, then produce `support/implementation-conformance-review.md` and `support/post-implementation-drift-churn-review.md`.

## Rollback And Closeout

Rollback restores prior lifecycle gate behavior and removes the strict architecture receipt hook.
Forbid closeout or archive if architecture proposals can bypass pre-integration review, if receipt freshness is not checked, or if conformance and drift/churn receipts are absent.
