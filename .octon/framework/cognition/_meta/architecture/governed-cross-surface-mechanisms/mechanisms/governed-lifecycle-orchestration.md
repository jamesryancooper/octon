# Governed Lifecycle Orchestration Mechanism

## Non-Authority Status

This detail page is architecture documentation. It is not a lifecycle contract,
runtime route, execution authorization, proposal receipt, closeout receipt, or
generated read model.

## Authority Surfaces

- product feature navigation:
  `.octon/framework/product/features/governed-lifecycle-orchestration.md`
- lifecycle and interaction receipt contracts:
  `.octon/framework/product/contracts/lifecycle-*.schema.json`
- runtime implementation:
  `.octon/framework/engine/runtime/crates/kernel/src/lifecycle.rs`
  and `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- route execution adapter:
  `.octon/framework/engine/runtime/crates/lifecycle_executor`
- mutable operational truth:
  `.octon/state/control/execution/runs/**`
- retained evidence:
  `.octon/state/evidence/runs/workflows/**`
- generated runtime handles:
  `.octon/generated/effective/**`
- generated operator read models:
  `.octon/generated/cognition/**`

## Boundary

Lifecycle Runner planning, gates, receipt freshness, checkpoints, replay, and
route selection are not the same authority as route execution. Lifecycle
Executor Adapter invocation and observation do not make generated projections,
proposal-local receipts, host state, chat state, tool availability, or model
memory authoritative.

Parent proposal-program evidence may summarize child packet state, but it does
not satisfy child manifests, subtype manifests, reviews, implementation
prompts, validators, promotion targets, conformance receipts, drift/churn
receipts, closeout receipts, archive metadata, or terminal outcomes.

Lifecycle interaction receipts carry advisory context only. A target lifecycle
must independently validate scope, authority, freshness, rollback posture,
receipts, gates, hosted controls, delegation proof, and target-owned policy.

## Validators

- `.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-contracts.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-interaction-receipts.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-governed-cross-surface-mechanisms.sh`
