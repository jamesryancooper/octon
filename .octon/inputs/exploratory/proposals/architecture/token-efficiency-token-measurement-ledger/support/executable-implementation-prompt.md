# Executable Implementation Prompt

## Objective

Implement child proposal `token-efficiency-token-measurement-ledger`: Add lifecycle-level token-budget ledgers, provider-usage capture, repeated-source accounting, and CI token regression measurement.

## Promotion Targets

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`


## Exact Promotion Targets

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`

## Required Validators

- test-lifecycle-runner.sh
- test-context-pack-builder.sh
- new test-token-budget-ledger.sh
- new token regression fixture for proposal-program mock run

## Evidence

Retain source digests, compact artifact outputs, raw/full evidence refs, validator manifests, token ledgers, route/model receipts, context-pack refs, rollback refs, `support/implementation-conformance-review.md`, and `support/post-implementation-drift-churn-review.md`.

## Model Route

Default route: deterministic-first; small model only for human summary

Token ceiling: 4k model-visible tokens for summary; 0 LLM tokens for ledger generation

Escalate when: provider usage mismatch, missing model accounting, source-token ledger cannot reconstruct context totals

## Closeout Refusal

Refuse closeout/archive-ready status if validators fail, compact artifacts are stale, raw evidence cannot be verified, generated/read-model surfaces are stale, rollback evidence is missing, authorization/context-pack receipts are missing, `support/implementation-conformance-review.md` is missing, or `support/post-implementation-drift-churn-review.md` is missing.

## Required Post-Implementation Receipts

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
