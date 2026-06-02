# Executable Implementation Prompt

## Objective

Implement child proposal `token-efficiency-semantic-cache-context-reuse`: Add source-hash invalidated semantic cache, context-pack layer reuse, generated graph/index reuse, parent-to-child handoff reuse, and lifecycle-level budgets at scale.

## Promotion Targets

- `.octon/framework/engine/runtime/spec/context-pack-builder-v1.md`
- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`


## Exact Promotion Targets

- `.octon/framework/engine/runtime/spec/context-pack-builder-v1.md`
- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`

## Required Validators

- semantic cache invalidation test
- context-pack layer reuse replay test
- source digest drift negative control
- CI token regression threshold test

## Evidence

Retain source digests, compact artifact outputs, raw/full evidence refs, validator manifests, token ledgers, route/model receipts, context-pack refs, rollback refs, `support/implementation-conformance-review.md`, and `support/post-implementation-drift-churn-review.md`.

## Model Route

Default route: deterministic cache lookup; medium only for summary regeneration; high only on authority conflict

Token ceiling: cache hit context overhead ≤2k; regenerated summaries stage-specific

Escalate when: source digest drift, policy digest drift, summary/source contradiction, missing retained model-visible hash

## Closeout Refusal

Refuse closeout/archive-ready status if validators fail, compact artifacts are stale, raw evidence cannot be verified, generated/read-model surfaces are stale, rollback evidence is missing, authorization/context-pack receipts are missing, `support/implementation-conformance-review.md` is missing, or `support/post-implementation-drift-churn-review.md` is missing.

## Required Post-Implementation Receipts

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
