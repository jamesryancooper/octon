# Executable Implementation Prompt

## Objective

Implement child proposal `token-efficiency-proposal-artifact-index-spine`: Create proposal/program spines, artifact indexes with token estimates, stage-role classification, and spine/slice/annex defaults.

## Promotion Targets

- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/`

Generated proposal registry outputs under `.octon/generated/proposals/` are affected read-model artifacts only, not promotion targets.


## Exact Promotion Targets

- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/`

## Required Validators

- proposal registry validation
- proposal artifact index schema validation
- proposal spine freshness test
- generated registry cannot replace manifest negative control

## Evidence

Retain source digests, compact artifact outputs, raw/full evidence refs, validator manifests, token ledgers, route/model receipts, context-pack refs, rollback refs, `support/implementation-conformance-review.md`, and `support/post-implementation-drift-churn-review.md`.

## Model Route

Default route: deterministic generation; small model optional for short descriptions

Token ceiling: 2k summary; indexes generated without LLM

Escalate when: manifest mismatch, source digest drift, proposal path treated as authority, missing required lifecycle source

## Closeout Refusal

Refuse closeout/archive-ready status if validators fail, compact artifacts are stale, raw evidence cannot be verified, generated/read-model surfaces are stale, rollback evidence is missing, authorization/context-pack receipts are missing, `support/implementation-conformance-review.md` is missing, or `support/post-implementation-drift-churn-review.md` is missing.

## Required Post-Implementation Receipts

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
