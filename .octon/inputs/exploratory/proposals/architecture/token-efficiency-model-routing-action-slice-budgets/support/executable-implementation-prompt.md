# Executable Implementation Prompt

## Objective

Implement child proposal `token-efficiency-model-routing-action-slice-budgets`: Add deterministic-first routing, token ceilings, route decision receipts, escalation triggers, fallback behavior, and short action-slice loops.

## Promotion Targets

- `.octon/instance/governance/policies/model-routing.yml`
- `.octon/instance/governance/policies/token-budgets.yml`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`


## Exact Promotion Targets

- `.octon/instance/governance/policies/model-routing.yml`
- `.octon/instance/governance/policies/token-budgets.yml`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`

## Required Validators

- model-routing receipt emission test
- route bypass negative control
- action-slice budget regression test
- deterministic preflight fixture tests

## Evidence

Retain source digests, compact artifact outputs, raw/full evidence refs, validator manifests, token ledgers, route/model receipts, context-pack refs, rollback refs, `support/implementation-conformance-review.md`, and `support/post-implementation-drift-churn-review.md`.

## Model Route

Default route: deterministic-first; high-reasoning only on escalation

Token ceiling: slice-specific; final completion ≤8k, child dispatch ≤12k base, architecture exception ≤40k

Escalate when: authority ambiguity, architecture decision, rollback conflict, support-proof interpretation, promotion evidence conflict, archive/recovery failure, unexplained test failure

## Closeout Refusal

Refuse closeout/archive-ready status if validators fail, compact artifacts are stale, raw evidence cannot be verified, generated/read-model surfaces are stale, rollback evidence is missing, authorization/context-pack receipts are missing, `support/implementation-conformance-review.md` is missing, or `support/post-implementation-drift-churn-review.md` is missing.

## Required Post-Implementation Receipts

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
