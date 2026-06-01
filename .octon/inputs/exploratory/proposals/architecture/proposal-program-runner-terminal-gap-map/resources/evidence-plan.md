# Evidence Plan

## Packet Revision Evidence

- Structural validation:
  `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh`
- Architecture subtype validation:
  `.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh`
- Implementation-readiness validation:
  `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh`
- Baseline review-gate validation and digest:
  `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh`
- Revision receipt:
  `support/revisions/proposal-program-runner-terminal-gap-map-revision-20260601T015030Z.md`

## Live Evidence Roots To Recheck Downstream

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/workflow_leaf.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/observer.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/adapter.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/authorization.rs`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
- `.octon/framework/orchestration/runtime/workflows/meta/promote-proposal/`
- `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/`
- `.octon/generated/effective/runtime/route-bundle.lock.yml`
- `.octon/state/control/execution/runs/**`
- `.octon/state/evidence/runs/**`

## Required Downstream Evidence Classes

- Behavior proof for workflow retry id allocation and archive observation.
- Boundary proof for child-owned receipts, parent aggregate summaries, and
  non-authorizing closeout handoff.
- Runtime authorization proof for delegated promotion and recovery actions.
- Generated-output freshness proof for publication drift detection.
- Regression proof for duplicate workflow id failure, unsafe resume, stale
  generated state, wrong-child promotion evidence, review churn, and archive
  observation.
