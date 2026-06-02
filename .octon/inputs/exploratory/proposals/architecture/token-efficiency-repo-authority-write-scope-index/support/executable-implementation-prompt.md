# Executable Implementation Prompt

## Objective

Implement child proposal `token-efficiency-repo-authority-write-scope-index`: Precompute advisory repo authority graph and promotion-target/write-scope index to avoid repeated repo re-learning.

## Promotion Targets

- `.octon/framework/cognition/_meta/architecture/`
- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`


## Exact Promotion Targets

- `.octon/framework/cognition/_meta/architecture/`
- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`

## Required Validators

- repo authority graph source digest test
- target-family boundary validation
- stale graph fail-closed negative control
- promotion-target/write-scope index coverage test

## Evidence

Retain source digests, compact artifact outputs, raw/full evidence refs, validator manifests, token ledgers, route/model receipts, context-pack refs, rollback refs, `support/implementation-conformance-review.md`, and `support/post-implementation-drift-churn-review.md`.

## Model Route

Default route: deterministic graph generation; medium for ambiguous ownership descriptions

Token ceiling: 6k for ambiguity report; graph generated without LLM

Escalate when: source-of-truth ambiguity, generated surface incorrectly selected as promotion target, mixed target family risk

## Closeout Refusal

Refuse closeout/archive-ready status if validators fail, compact artifacts are stale, raw evidence cannot be verified, generated/read-model surfaces are stale, rollback evidence is missing, authorization/context-pack receipts are missing, `support/implementation-conformance-review.md` is missing, or `support/post-implementation-drift-churn-review.md` is missing.

## Required Post-Implementation Receipts

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
