# Source Of Truth Map

## Proposal-Local Authority

The proposal-local decision source is limited to:

- `proposal.yml`
- `architecture-proposal.yml`
- `architecture/target-architecture.md`
- `architecture/implementation-plan.md`
- `architecture/acceptance-criteria.md`
- `architecture/validation-plan.md`
- `navigation/source-of-truth-map.md`

These files are temporary proposal authority only. They do not override
framework, instance, runtime, validator, Git, or hosted-provider authority.

## Authored Repository Authority Consulted

- `.octon/framework/product/features/governed-lifecycle-orchestration.md`
- `.octon/framework/product/contracts/default-work-unit.yml`
- `.octon/framework/product/contracts/change-closeout-state-machine.yml`
- `.octon/framework/product/contracts/change-closeout-state-machine.md`
- `.octon/framework/product/contracts/change-receipt-v1.schema.json`
- `.octon/framework/product/contracts/branch-landing-authorization-v1.schema.json`
- `.octon/framework/product/contracts/branch-cleanup-authorization-v1.schema.json`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle-model.md`
- `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/extension-lifecycle-contract.schema.json`
- `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/lifecycle-run-event.schema.json`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/request.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/authorization.rs`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-contracts.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-runner.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-executor-adapter.sh`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/remediation/repo-hygiene-cleanup/SKILL.md`

## Generated And Runtime Handles

Generated effective projections may be refreshed only as derived publication:

- `.octon/generated/effective/extensions/published/octon-proposal-lifecycle/bundled-first-party/context/lifecycle.contract.yml`
- `.octon/generated/effective/extensions/published/octon-proposal-lifecycle/bundled-first-party/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md`

They are runtime discovery handles, not source authority.
