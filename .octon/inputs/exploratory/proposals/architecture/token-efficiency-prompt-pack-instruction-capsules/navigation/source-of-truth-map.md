# Source Of Truth Map

## Proposal-local lifecycle sources

1. `proposal.yml`
2. `architecture-proposal.yml`

## Durable authority targets

- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/prompt_bundle.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/generated.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/request.rs`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/prompts/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/`

## Derived / non-authoritative artifacts

- `prompt-pack-capsule.yml`
- `route-instruction-capsule.yml`
- `compiled-governance-capsule.yml`
- `prompt-expansion-policy.yml`

These artifacts are compact evidence, generated/read-model projections, or templates. They do not replace durable authorities or raw evidence.

## Parent Program

Parent proposal: `token-efficient-proposal-program-controller`

The parent may coordinate and summarize. It cannot satisfy this child's receipts.

## Boundary Rules

- This child cannot use parent summaries as child-owned evidence.
- Raw proposal inputs are non-authoritative.
- Generated/read-model outputs are advisory only.
- Material execution requires engine-owned authorization.
