# Implementation Plan

## Durable Promotion Targets

- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/prompt_bundle.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/generated.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/request.rs`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/prompts/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/`

## Workstream

1. Modify prompt_bundle.rs to support prompt-pack handle mode and retained full prompt packet refs.
2. Compile stable prompt/reference/shared-reference assets into capsules with source digests and visible short rules.
3. Expand full prompt text only under explicit prompt-expansion-policy-v1 triggers.
4. Retain full prompt packet for replay and audit.

## Implementation Steps

1. Add or update schema/spec definitions for the proposed artifacts.
2. Add deterministic producer or wrapper code under the declared runtime/assurance surfaces.
3. Add reader preference so lifecycle planner, recovery, closeout, or executor uses compact artifacts by default.
4. Retain raw/full evidence unchanged and link compact artifacts by digest.
5. Add fail-closed stale/missing/digest-mismatch behavior.
6. Add validation fixtures and negative controls.
7. Update documentation or lifecycle contracts only where durable and non-proposal.
8. Run proposal and runtime validation.
9. Emit implementation conformance and drift/churn receipts before closeout.

## Validators

- prompt-pack capsule generation test
- stale capsule fail-closed test
- mutation-sensitive expansion test
- prompt model-visible hash replay test

## Evidence To Retain

- source refs and digests;
- compact artifact output;
- raw/full evidence refs;
- validator result manifest;
- token-budget ledger delta;
- route/model decision receipt when LLM is used;
- context-pack receipt and model-visible hash when consequential;
- rollback evidence.

## Closeout Refusal Criteria

Refuse successful closeout if compact artifacts cannot be verified against raw evidence, if generated/read-model state is stale, if authorization evidence is missing, if rollback evidence is missing, if raw/proposal/generated surfaces are treated as authority, or if child-owned receipts are incomplete.
