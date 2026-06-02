# Executable Implementation Prompt

## Objective

Implement child proposal `token-efficiency-lifecycle-context-pack-integration`: Apply Context Pack Builder inclusion modes to lifecycle, skill, bootstrap, generated, evidence, raw-log, and proposal context.

## Promotion Targets

- `.octon/framework/engine/runtime/spec/context-pack-builder-v1.md`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/instance/governance/policies/context-packing.yml`


## Exact Promotion Targets

- `.octon/framework/engine/runtime/spec/context-pack-builder-v1.md`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/instance/governance/policies/context-packing.yml`

## Required Validators

- test-context-pack-builder.sh
- context omission manifest test
- raw/generated authority negative control
- invalid context-pack blocks authorization test

## Evidence

Retain source digests, compact artifact outputs, raw/full evidence refs, validator manifests, token ledgers, route/model receipts, context-pack refs, rollback refs, `support/implementation-conformance-review.md`, and `support/post-implementation-drift-churn-review.md`.

## Model Route

Default route: deterministic policy enforcement; high-reasoning only on context authority conflict

Token ceiling: stage-specific; default proposal-program child dispatch ≤12k before target file excerpts

Escalate when: required source omitted, context hash mismatch, raw/generated source marked authority, budget conflict over required evidence

## Closeout Refusal

Refuse closeout/archive-ready status if validators fail, compact artifacts are stale, raw evidence cannot be verified, generated/read-model surfaces are stale, rollback evidence is missing, authorization/context-pack receipts are missing, `support/implementation-conformance-review.md` is missing, or `support/post-implementation-drift-churn-review.md` is missing.

## Required Post-Implementation Receipts

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
