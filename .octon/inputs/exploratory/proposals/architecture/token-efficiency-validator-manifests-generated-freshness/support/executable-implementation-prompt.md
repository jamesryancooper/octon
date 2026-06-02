# Executable Implementation Prompt

## Objective

Implement child proposal `token-efficiency-validator-manifests-generated-freshness`: Add validator result manifests, failing slices, publication freshness manifests, generated/read-model digest handles, and compact run-health manifests.

## Promotion Targets

- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/framework/engine/runtime/spec/operator-read-models-v1.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/`


## Exact Promotion Targets

- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/framework/engine/runtime/spec/operator-read-models-v1.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/`

## Required Validators

- test-validate-publication-freshness-gates.sh
- test-run-health-read-model.sh
- new validator-result manifest schema tests
- stale generated handle negative control

## Evidence

Retain source digests, compact artifact outputs, raw/full evidence refs, validator manifests, token ledgers, route/model receipts, context-pack refs, rollback refs, `support/implementation-conformance-review.md`, and `support/post-implementation-drift-churn-review.md`.

## Model Route

Default route: deterministic; medium only on failing validator classification

Token ceiling: 3k for failing-slice explanation; 0 LLM for pass manifests

Escalate when: stale generated handle, failing negative control, validator stdout cannot be mapped to manifest

## Closeout Refusal

Refuse closeout/archive-ready status if validators fail, compact artifacts are stale, raw evidence cannot be verified, generated/read-model surfaces are stale, rollback evidence is missing, authorization/context-pack receipts are missing, `support/implementation-conformance-review.md` is missing, or `support/post-implementation-drift-churn-review.md` is missing.

## Required Post-Implementation Receipts

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
