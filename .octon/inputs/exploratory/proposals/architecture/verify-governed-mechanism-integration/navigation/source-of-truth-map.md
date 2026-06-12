# Source Of Truth Map

## Durable Authorities After Promotion

- `.octon/framework/orchestration/runtime/workflows/meta/verify-governed-mechanism-integration/`
  owns the workflow-backed verification sequence and support receipt emission.
- `.octon/framework/product/contracts/governed-mechanism-integration-profile-v1.schema.json`
  owns the mechanism integration profile contract.
- `.octon/framework/product/contracts/governed-mechanism-integration-receipt-v1.schema.json`
  owns the support receipt contract.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-governed-mechanism-integration-profile.sh`
  owns profile validation.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-governed-mechanism-integration-receipt.sh`
  owns receipt validation.
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/` owns the
  proposal lifecycle hook updates until published through canonical projection
  paths.

## Evidence Sources After Promotion

- `support/governed-mechanism-integration-evaluation.yml` records the
  proposal-local support receipt.
- `.octon/state/evidence/runs/workflows/<run-id>/governed-mechanism-integration/<mechanism-id>/`
  retains workflow evidence.
- Existing conformance, drift/churn, publication, architecture review, and
  terminal freshness receipts remain owned by their current validators and
  workflows.

## Proposal-Local Lifecycle Sources

- `proposal.yml`
- `architecture-proposal.yml`
- `architecture/target-architecture.md`
- `architecture/implementation-plan.md`
- `architecture/acceptance-criteria.md`

## Supporting Lineage

- `resources/source-prompt.md` records the source recommendation as lineage.
- `resources/repository-reconnaissance.md` records search-before-create
  evidence.
- `support/proposal-creation.md` records creation receipts.
- `support/implementation-grade-completeness-review.md` records readiness for
  proposal review and future implementation prompt generation.
- `support/implementation-conformance-review.md` is a scaffolded
  post-implementation gate receipt.
- `support/post-implementation-drift-churn-review.md` is a scaffolded
  post-implementation drift gate receipt.

## Non-Authority Boundaries

Generated proposal registry entries, product feature catalog entries, governed
mechanism index entries, proposal-local support files, raw inputs, generated
outputs, host projections, dashboards, chat state, model memory, and tool
availability may inform review but cannot authorize mechanism integration,
closeout, archive readiness, support widening, generated publication, or
runtime behavior.

## Integration Boundaries

Implementation conformance, post-implementation drift/churn, generated
publication, current-state mechanism architecture review, lifecycle postmortem,
terminal freshness, and proposal closeout remain separate owners. The proposed
workflow links their evidence into one strict integration receipt for governed
mechanism proposals.
