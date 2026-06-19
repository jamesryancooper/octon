# Source Of Truth Map

## Durable Authorities After Promotion

- `.octon/framework/product/contracts/change-receipt-v1.schema.json` owns
  branch-no-PR Change receipt state semantics.
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
  owns closeout-change route behavior, hosted landing posture, cleanup
  posture, and final reporting.

## Proposal-Local Lifecycle Sources

- `proposal.yml`
- `architecture-proposal.yml`
- `architecture/target-architecture.md`
- `architecture/implementation-plan.md`
- `architecture/acceptance-criteria.md`

## Retained Evidence

- `support/implementation-grade-completeness-review.md`
- `support/pre-integration-architecture-review.yml`
- `support/proposal-review.md`
- `support/validation.md`
- Future implementation evidence under `.octon/state/evidence/**`

## Dependencies

- `packet-delivery-wrapper-orchestration-autonomy` owns the wrapper route that
  delegates branch-no-PR Git mutation and closeout to `closeout-change`.
- `blocked-delivery-receipt-semantics` owns blocked aggregate receipt
  semantics used by delivery wrapper outcomes.

## Non-Authority Boundaries

The parent accepted review, sibling child reviews, raw source evidence,
proposal-local files, generated outputs, host projections, dashboards, chat,
and model memory cannot authorize this child implementation or replace this
child's receipts.
