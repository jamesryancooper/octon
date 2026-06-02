# Executable Implementation Prompt

## Objective

Implement child proposal `token-efficiency-evidence-index-raw-log-summaries`: Add per-run evidence indexes, raw-log summaries, failing-slice manifests, and evidence readers that prefer compact refs over raw logs.

## Promotion Targets

- `.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`


## Exact Promotion Targets

- `.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`

## Required Validators

- new raw-log summary hash-matching test
- new failing-slice manifest reconstruction test
- test-lifecycle-interaction-receipts.sh
- replay validation over raw evidence refs

## Evidence

Retain source digests, compact artifact outputs, raw/full evidence refs, validator manifests, token ledgers, route/model receipts, context-pack refs, rollback refs, `support/implementation-conformance-review.md`, and `support/post-implementation-drift-churn-review.md`.

## Model Route

Default route: deterministic; medium only for ambiguous failure classification

Token ceiling: 2k for failure summary; raw log body handle-only by default

Escalate when: summary hash mismatch, failing slice cannot be found, validator dispute, replay audit request

## Closeout Refusal

Refuse closeout/archive-ready status if validators fail, compact artifacts are stale, raw evidence cannot be verified, generated/read-model surfaces are stale, rollback evidence is missing, authorization/context-pack receipts are missing, `support/implementation-conformance-review.md` is missing, or `support/post-implementation-drift-churn-review.md` is missing.

## Required Post-Implementation Receipts

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
