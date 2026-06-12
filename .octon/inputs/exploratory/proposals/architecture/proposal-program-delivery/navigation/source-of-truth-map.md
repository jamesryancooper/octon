# Source Of Truth Map

## Durable Authorities After Promotion

- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/`
  owns delivery sequencing and delivery receipt emission.
- `.octon/framework/product/contracts/proposal-program-delivery-profile-v1.schema.json`
  owns the delivery profile contract.
- `.octon/framework/product/contracts/proposal-program-delivery-receipt-v1.schema.json`
  owns the aggregate delivery receipt contract.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh`
  owns profile validation.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh`
  owns delivery receipt validation.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh`
  owns workflow shape validation.
- `.octon/framework/capabilities/runtime/commands/proposal-program-delivery.md`
  owns the thin command projection.
- `.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/SKILL.md`
  owns the thin skill projection.
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/` owns proposal
  lifecycle hook source updates until published through canonical projection
  paths.

## Target-Owned Evidence Sources After Promotion

- Proposal-program lifecycle receipts remain owned by the proposal lifecycle.
- Child packet receipts remain owned by each child packet lifecycle.
- Implementation conformance receipts remain owned by the conformance workflow
  and validator.
- Post-implementation drift/churn receipts remain owned by the drift workflow
  and validator.
- Generated publication receipts remain owned by the relevant publisher.
- Governed mechanism integration receipts remain owned by the governed
  mechanism integration workflow when applicable.
- Change receipts remain owned by closeout-change and the default work-unit
  policy.
- Repo hygiene cleanup receipts remain owned by repo-hygiene-cleanup.
- Branch landing and branch cleanup authorization receipts remain owned by
  their product contracts and validators.
- Terminal current-state proof remains evidence-only and never authorizes a
  lifecycle transition by itself.

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
  proposal review.
- `support/implementation-conformance-review.md` is a scaffolded
  post-implementation gate receipt.
- `support/post-implementation-drift-churn-review.md` is a scaffolded
  post-implementation drift gate receipt.

## Non-Authority Boundaries

Generated proposal registry entries, product feature catalog entries,
proposal-local support files, raw inputs, generated outputs, generated prompts,
host projections, dashboards, chat state, model memory, and tool availability
may inform review but cannot authorize proposal delivery, closeout, archive,
generated publication, cleanup, branch landing, branch deletion, or a cleaned
claim.

## Integration Boundary

Governed Proposal Delivery composes target-owned evidence. It does not replace
proposal-program, proposal-packet, conformance, drift/churn, generated
publication, governed mechanism integration, Change closeout, worktree closeout,
repo hygiene, branch authorization, or terminal-proof ownership.
