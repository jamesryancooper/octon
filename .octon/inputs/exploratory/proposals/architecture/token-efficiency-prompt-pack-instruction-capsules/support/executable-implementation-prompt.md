# Executable Implementation Prompt

## Objective

Implement child proposal `token-efficiency-prompt-pack-instruction-capsules`: Replace full prompt asset expansion by default with digest-bound prompt-pack handles, route capsules, compiled governance capsules, and controlled expansion rules.

## Promotion Targets

- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/prompt_bundle.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/generated.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/request.rs`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/prompts/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/`


## Exact Promotion Targets

- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/prompt_bundle.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/generated.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/request.rs`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/prompts/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/`

## Required Validators

- prompt-pack capsule generation test
- stale capsule fail-closed test
- mutation-sensitive expansion test
- prompt model-visible hash replay test

## Evidence

Retain source digests, compact artifact outputs, raw/full evidence refs, validator manifests, token ledgers, route/model receipts, context-pack refs, rollback refs, `support/implementation-conformance-review.md`, and `support/post-implementation-drift-churn-review.md`.

## Model Route

Default route: high-reasoning only for architecture review; runtime capsule generation deterministic

Token ceiling: route prompt header plus capsules ≤4k before stage context

Escalate when: digest drift, mutation-sensitive work, gate dispute, authority conflict, audit request

## Closeout Refusal

Refuse closeout/archive-ready status if validators fail, compact artifacts are stale, raw evidence cannot be verified, generated/read-model surfaces are stale, rollback evidence is missing, authorization/context-pack receipts are missing, `support/implementation-conformance-review.md` is missing, or `support/post-implementation-drift-churn-review.md` is missing.

## Required Post-Implementation Receipts

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
