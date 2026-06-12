# Executable Implementation Prompt

Implement only the owned scope for `architectural-review-governed-mechanism-integration`.

## Promotion Targets

- `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/`
- `.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-governed-cross-surface-mechanisms.sh`

## Required Work

- Add Architectural Review Mechanism to the governed cross-surface mechanism index and detail docs.
- Include authority refs, product refs when present, workflow refs, mutable control refs, retained evidence refs, generated refs, raw input refs, validators, ownership boundaries, and non-authority boundaries.

## Validation And Evidence

Run `validate-governed-cross-surface-mechanisms.sh`, `validate-architectural-review-routing.sh`, `validate-proposal-standard.sh`, `validate-architecture-proposal.sh`, and `validate-proposal-implementation-readiness.sh`.
Record evidence in `support/implementation-run.md`, then produce `support/implementation-conformance-review.md` and `support/post-implementation-drift-churn-review.md`.

## Rollback And Closeout

Rollback removes the mechanism index entry and detail page added by this child.
Refuse closeout or archive if generated projections are treated as authority, if mechanism boundaries are incomplete, or if conformance and drift/churn receipts are absent.
