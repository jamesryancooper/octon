# Implementation Plan

_Status: Draft child implementation plan_

This plan is proposal-local. It does not authorize durable implementation.

## Dependencies

- `workflow-statechart-task-specific-execution-harness`

## Steps

1. Define workflow-history-v1 and replay-reconstruction-v1 schemas tied to existing run journals and evidence store rules.
2. Define idempotency, retry, and compensation record schemas with explicit unsupported cases.
3. Add validators for missing history, replay drift, duplicate idempotency keys, invalid retries, and unsupported compensation claims.
4. Define evidence placement and disclosure requirements for replay and compensation outcomes.

## Promotion Targets

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/constitution/contracts/runtime/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/state/evidence/`

## Validation

- Replay reconstruction fixtures for valid, drifted, incomplete, and unsupported histories.
- Idempotency and retry policy negative tests.
- Compensation plan validation and unsupported-rollback disclosure checks.

## Evidence Required Before Canonical Claim

- Replay reconstruction reports over sample histories.
- Idempotency/retry/compensation fixtures and validator receipts.
- Evidence-store placement receipts.

## Cutover Boundary

This child may not claim live runtime behavior until implementation-conformance and post-implementation drift/churn receipts prove durable promoted changes. Final canonical Governed Workflow Runtime terminology remains gated by `migration-cutover-compatibility-retirement`.
