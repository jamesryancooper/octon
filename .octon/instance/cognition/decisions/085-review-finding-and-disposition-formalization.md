# ADR 085: Review Finding And Disposition Formalization

- Date: 2026-04-11
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/instance/cognition/context/shared/migrations/2026-04-11-octon-selected-harness-concepts-integration/plan.md`
  - `/.octon/state/evidence/migration/2026-04-11-octon-selected-harness-concepts-integration/`

## Context

Octon already retained evaluator reviews, but it did not carry a canonical
finding/disposition pair that could block progression without relying on
free-form comments.

## Decision

Promote retained `review-finding-v1` records and run-local
`review-disposition-v1` control records.

Rules:

1. Findings remain retained evidence.
2. Dispositions are the only canonical review-gating control surface.
3. Deferred or backlog entries require a durable follow-up ref.
4. Free-form comments may mirror status but never mint authority.

## Consequences

- Review traceability becomes explicit and validator-coverable.
- Progression gates can fail closed on unresolved blocking dispositions.
