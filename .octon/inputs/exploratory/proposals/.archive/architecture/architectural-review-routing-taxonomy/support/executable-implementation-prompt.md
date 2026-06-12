# Executable Implementation Prompt

Implement only the owned scope for `architectural-review-routing-taxonomy`.

## Promotion Targets

- `.octon/framework/cognition/practices/methodology/architectural-review/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/framework/assurance/runtime/_ops/fixtures/`

## Required Work

- Add deterministic review-mode routing for pre-integration, Architecture Revision Packet, post-integration, current-state mechanism, readiness, domain, surface, lifecycle postmortem, and constitutional challenge routes.
- Validate that post-integration and lifecycle postmortem modes remain evidence-only under current policy.

## Validation And Evidence

Run `validate-architectural-review-routing.sh`, `validate-proposal-standard.sh`, `validate-architecture-proposal.sh`, and `validate-proposal-implementation-readiness.sh`.
Record evidence in `support/implementation-run.md`, then produce `support/implementation-conformance-review.md` and `support/post-implementation-drift-churn-review.md`.

## Rollback And Closeout

Rollback removes the routing file and routing validator fixtures added by this child.
Forbid closeout or archive if route coverage is incomplete, if validator evidence is missing, or if conformance and drift/churn receipts are absent.
