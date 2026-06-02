# Executable Implementation Prompt

## Objective

Implement child proposal `token-efficiency-planner-state-program-context-capsule`: Split full audit program plans from compact planner state and parent/child program context capsules.

## Promotion Targets

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`


## Exact Promotion Targets

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`

## Required Validators

- planner-state reconstruction from program-lifecycle-checkpoint.yml and program-events.ndjson
- program-context capsule digest verification
- proposal-program mock run with no-dispatch completion

## Evidence

Retain source digests, compact artifact outputs, raw/full evidence refs, validator manifests, token ledgers, route/model receipts, context-pack refs, rollback refs, `support/implementation-conformance-review.md`, and `support/post-implementation-drift-churn-review.md`.

## Model Route

Default route: deterministic; small model for operator summary only

Token ceiling: 3k for final parent completion; 0 LLM for state generation

Escalate when: checkpoint/event-log drift, child state conflict, missing child receipt digest, terminal verdict mismatch

## Closeout Refusal

Refuse closeout/archive-ready status if validators fail, compact artifacts are stale, raw evidence cannot be verified, generated/read-model surfaces are stale, rollback evidence is missing, authorization/context-pack receipts are missing, `support/implementation-conformance-review.md` is missing, or `support/post-implementation-drift-churn-review.md` is missing.

## Required Post-Implementation Receipts

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
