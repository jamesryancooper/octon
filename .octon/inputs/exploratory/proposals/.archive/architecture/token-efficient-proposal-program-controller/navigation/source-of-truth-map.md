# Source Of Truth Map

## Proposal-local lifecycle sources

The only proposal-local lifecycle sources for this parent packet are:

1. `proposal.yml`
2. `architecture-proposal.yml`

The child packets each follow the same rule with their own `proposal.yml` and `architecture-proposal.yml`.

## Durable authorities named by this proposal

Durable implementation targets are outside the proposal workspace and include:

- `/.octon/framework/engine/runtime/spec/**`
- `/.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `/.octon/framework/engine/runtime/crates/lifecycle_executor/src/**`
- `/.octon/framework/assurance/runtime/_ops/scripts/**`
- `/.octon/framework/assurance/runtime/_ops/tests/**`
- `/.octon/framework/capabilities/runtime/skills/remediation/closeout-change/**`
- `/.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/**`
- `/.octon/instance/governance/policies/context-packing.yml`
- `/.octon/instance/governance/policies/model-routing.yml`
- `/.octon/instance/governance/policies/token-budgets.yml`
- `/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/**`
- `/.octon/inputs/additive/extensions/octon-proposal-lifecycle/prompts/**`
- `/.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/**`

## Derived/read-model surfaces

The following are derived and non-authoritative even when proposed as generated outputs:

- proposal/program spines;
- proposal artifact indexes;
- repo authority graphs;
- promotion-target/write-scope indexes;
- generated freshness handles;
- run-health compact manifests;
- semantic cache entries;
- publication summaries.

## Retained evidence surfaces

The proposed runtime must retain raw evidence under `/.octon/state/evidence/**`, including full logs, full prompt packets where required, context-pack receipts, model-visible context hashes, token ledgers, validation stdout/stderr refs, closeout receipts, route-decision receipts, model-routing receipts, and rollback refs.

## Boundary rules

- Parent summaries cannot satisfy child-owned receipts.
- Child handoff capsules cannot widen child authority.
- Generated indexes cannot replace manifests.
- Raw proposal input cannot become runtime authority.
- Context compaction is valid only when source manifest, omission manifest, invalidation state, model-visible serialization, and hash are retained.
- Authorization must fail closed if required evidence, context, grant, rollback, or freshness facts are missing.
