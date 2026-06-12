# Source Of Truth Map

## Durable Authorities After Promotion

- `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-terminal-closeout/`
  owns terminal sequencing and terminal receipt emission.
- `.octon/framework/product/contracts/proposal-packet-terminal-closeout-profile-v1.schema.json`
  owns the terminal closeout profile contract.
- `.octon/framework/product/contracts/proposal-packet-terminal-closeout-receipt-v1.schema.json`
  owns the aggregate terminal receipt contract.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-profile.sh`
  owns profile validation.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-receipt.sh`
  owns terminal receipt validation.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-workflow.sh`
  owns workflow shape validation.
- `.octon/framework/capabilities/runtime/commands/proposal-packet-terminal-closeout.md`
  owns the thin command projection.
- `.octon/framework/capabilities/runtime/skills/operations/proposal-packet-terminal-closeout/SKILL.md`
  owns the thin skill projection.
- `.octon/framework/assurance/evaluators/proposal-packet-terminal-closeout/README.md`
  owns packet terminal evaluator guidance.
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/` owns proposal
  lifecycle extension source updates until published through canonical
  projection paths.

## Existing Target-Owned Evidence Sources

- Packet proposal lifecycle receipts remain owned by proposal lifecycle routes.
- Implementation conformance receipts remain owned by the conformance workflow
  and validator.
- Post-implementation drift/churn receipts remain owned by the drift workflow
  and validator.
- Generated publication receipts remain owned by the relevant publisher.
- Generated/input non-authority checks remain owned by their validators.
- Run-health projections remain generated read models and are refreshed through
  their generator.
- Change receipts remain owned by closeout-change and the default work-unit
  policy.
- Worktree decomposition remains owned by closeout-worktree.
- Repo hygiene cleanup remains owned by repo-hygiene-cleanup.
- Branch landing and branch cleanup authorization receipts remain owned by
  their product contracts and validators.
- Post-integration architecture review remains evidence-only.
- Lifecycle-postmortem remains optional/read-only/evidence-only unless a later
  governed lifecycle policy requires it for specific blocked terminal runs.
- Archive relocation remains owned by archive-proposal.

## Proposal-Local Lifecycle Sources

- `proposal.yml`
- `architecture-proposal.yml`
- `architecture/target-architecture.md`
- `architecture/implementation-plan.md`
- `architecture/acceptance-criteria.md`

## Supporting Lineage

- `resources/source-findings.md` records source findings from the operator
  request and local context.
- `resources/repository-reconnaissance.md` records repository reconnaissance.
- `support/proposal-creation.md` records creation receipts and impact map.
- `support/implementation-grade-completeness-review.md` records readiness for
  proposal review.
- `support/proposal-review.md` records the pre-implementation architecture
  review verdict and implementation prompt authorization.
- `support/pre-integration-architecture-review.yml` records the strict
  pre-integration architecture review gate receipt for architecture proposal
  acceptance and implementation authorization.
- `support/implementation-conformance-review.md` is a scaffolded
  post-implementation gate receipt.
- `support/post-implementation-drift-churn-review.md` is a scaffolded
  post-implementation drift gate receipt.

## Non-Authority Boundaries

Proposal-local files, raw inputs, generated outputs, generated prompts, host
projections, dashboards, chat state, model memory, tool availability, generated
registry entries, and generated product feature catalog entries may inform
review but cannot authorize terminal closeout, archive readiness, archive
relocation, publication, cleanup, branch landing, branch deletion, promotion,
or a cleaned claim.

## Integration Boundary

Packet terminal closeout composes target-owned evidence into one packet-local
terminal receipt. It does not replace proposal lifecycle, implementation
conformance, drift/churn, generated publication, generated/input
non-authority, run-health, capability publication, extension publication,
Change closeout, worktree closeout, repo hygiene, Git/GitHub, architecture
review, lifecycle-postmortem, or archive-proposal ownership.
