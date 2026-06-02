# Executable Implementation Prompt

## Objective

Implement child proposal `token-efficiency-blocker-ledger-recovery-deltas`: Replace repeated blocker history replay with stable blocker IDs, fingerprints, latest transitions, and bounded recovery deltas.

## Promotion Targets

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/engine/runtime/spec/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`


## Exact Promotion Targets

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/engine/runtime/spec/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`

## Required Validators

- blocker-ledger fingerprinting test
- aggregate-terminal-blockers deterministic zero-blocker test
- recovery loop no-progress negative control

## Evidence

Retain source digests, compact artifact outputs, raw/full evidence refs, validator manifests, token ledgers, route/model receipts, context-pack refs, rollback refs, `support/implementation-conformance-review.md`, and `support/post-implementation-drift-churn-review.md`.

## Model Route

Default route: deterministic aggregator; medium only on nonzero or conflicting blockers

Token ceiling: 2k for zero-blocker runs; 8k for nonzero-blocker recovery summary

Escalate when: blocker fingerprint drift, child authority boundary ambiguity, recovery loop repeats without progress

## Closeout Refusal

Refuse closeout/archive-ready status if validators fail, compact artifacts are stale, raw evidence cannot be verified, generated/read-model surfaces are stale, rollback evidence is missing, authorization/context-pack receipts are missing, `support/implementation-conformance-review.md` is missing, or `support/post-implementation-drift-churn-review.md` is missing.

## Required Post-Implementation Receipts

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
