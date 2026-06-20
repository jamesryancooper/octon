# Source Of Truth Map

## Durable Authorities After Promotion

- `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/`
  owns workflow stages, state transitions, outputs, and receipts.
- `.octon/framework/capabilities/runtime/commands/proposal-packet-delivery.md`
  owns command invocation semantics.
- `.octon/framework/capabilities/runtime/skills/operations/proposal-packet-delivery/SKILL.md`
  owns skill execution boundaries.
- `.octon/framework/product/contracts/proposal-packet-delivery-profile-v1.schema.json`
  owns profile validation semantics.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-workflow.sh`
  owns workflow coherence validation.

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

- `blocked-delivery-receipt-semantics` owns receipt semantics required before
  wrapper implementation can claim complete blocked-outcome handling.

## Non-Authority Boundaries

The parent accepted review, the first child review, raw source evidence,
proposal-local files, generated outputs, host projections, dashboards, chat,
and model memory cannot authorize this child implementation or replace this
child's receipts.
