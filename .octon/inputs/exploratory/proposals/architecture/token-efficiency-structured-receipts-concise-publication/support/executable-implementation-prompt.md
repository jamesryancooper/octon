# Executable Implementation Prompt

## Objective

Implement child proposal `token-efficiency-structured-receipts-concise-publication`: Move evidence to machine-readable receipts, concise closeout projections, compact publication summaries, and on-demand expanded reports.

## Promotion Targets

- `.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- `.octon/framework/assurance/runtime/_ops/scripts/`


## Exact Promotion Targets

- `.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- `.octon/framework/assurance/runtime/_ops/scripts/`

## Required Validators

- closeout-change lifecycle alignment validation
- closeout worktree wrapper tests
- structured receipt schema validation
- expanded report reconstruction test

## Evidence

Retain source digests, compact artifact outputs, raw/full evidence refs, validator manifests, token ledgers, route/model receipts, context-pack refs, rollback refs, `support/implementation-conformance-review.md`, and `support/post-implementation-drift-churn-review.md`.

## Model Route

Default route: small/medium summary; deterministic schema and evidence ref validation

Token ceiling: closeout projection ≤4k; expanded report generated only on demand

Escalate when: missing evidence ref, closeout authorization ambiguity, rollback evidence missing, support-proof claim conflict

## Closeout Refusal

Refuse closeout/archive-ready status if validators fail, compact artifacts are stale, raw evidence cannot be verified, generated/read-model surfaces are stale, rollback evidence is missing, authorization/context-pack receipts are missing, `support/implementation-conformance-review.md` is missing, or `support/post-implementation-drift-churn-review.md` is missing.

## Required Post-Implementation Receipts

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
