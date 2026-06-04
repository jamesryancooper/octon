# Executable Implementation Prompt

## Role

Act as an Octon runtime engineer operating under Octon's governed lifecycle. Implement only after this proposal and relevant child packet are accepted and an engine-owned authorization boundary grants the route.

## Objective

Implement the Token-Efficient Proposal Program Controller in phases while preserving governance, evidence, replay, rollback, authorization, and support proof.

## Required Read Set

1. Parent `proposal.yml`
2. Parent `architecture-proposal.yml`
3. `resources/child-packet-index.yml`
4. The selected child packet manifests
5. `architecture/child-packet-contract.md`
6. `architecture/context-pack-policy.md`
7. `architecture/model-routing-policy.md`
8. `architecture/token-budget-policy.md`
9. `architecture/evidence-and-replay-model.md`
10. Existing repository specs/validators relevant to the selected child

## Promotion Targets

Use only the promotion targets declared in the selected parent/child manifests. Do not write runtime authority into proposal paths.


## Exact Promotion Targets

- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- `.octon/framework/cognition/_meta/architecture/`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/generated.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/prompt_bundle.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/request.rs`
- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/engine/runtime/spec/context-pack-builder-v1.md`
- `.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `.octon/framework/engine/runtime/spec/operator-read-models-v1.md`
- `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/prompts/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/octon-proposal-lifecycle-cleanup-lifecycle-residue/SKILL.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/`
- `.octon/instance/governance/policies/context-packing.yml`
- `.octon/instance/governance/policies/model-routing.yml`
- `.octon/instance/governance/policies/token-budgets.yml`

Generated proposal registry outputs under `.octon/generated/proposals/` are affected read-model artifacts only, not promotion targets or authority.

## Required Validators

- proposal standard validator;
- architecture proposal validator;
- lifecycle runner tests;
- lifecycle interaction receipt tests;
- context pack builder tests;
- publication freshness gate tests;
- run-health read-model tests;
- closeout worktree wrapper tests;
- closeout-change lifecycle alignment validation;
- schema validation for new artifacts;
- replay and rollback validation;
- negative controls listed in `architecture/acceptance-criteria.md`.

## Evidence Requirements

Retain context pack receipt, model-visible context hash, prompt capsule/full packet refs where applicable, evidence index, token budget ledger, validator result manifests, route-decision receipts, model-routing receipts, rollback refs, `support/implementation-conformance-review.md`, and `support/post-implementation-drift-churn-review.md` after implementation.

## Rollback

Each child must provide a reversible implementation plan. Do not close out without rollback evidence.

## Closeout Refusal Criteria

Refuse successful closeout if stale prompt capsule, stale generated freshness handle, missing child receipt, missing rollback evidence, missing context-pack hash, missing authorization receipt, raw proposal input treated as authority, generated artifact treated as source of truth, model route bypass detected, raw-log summary mismatch, blocker fingerprint drift, generated/read-model projection stale, `support/implementation-conformance-review.md` missing, or `support/post-implementation-drift-churn-review.md` missing.

## Output

Produce structured receipts first. Human narrative must be concise and reference retained evidence.

## Required Post-Implementation Receipts

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
