# Implementation Plan

_Status: Draft child implementation plan_

This plan is proposal-local. It does not authorize durable implementation.

## Dependencies

- `agent-node-model-call-contract`
- `workflow-history-replay-idempotency-compensation`
- `effect-token-enforcement-coverage`

## Steps

1. Define provenance requirements for agent-node, model-call, replay, idempotency, retry, compensation, and effect-token receipts.
2. Update evidence obligations and retention/disclosure contracts to require role-separated refs.
3. Add validators for missing provenance, generated/input dependency, stale evidence, and disclosure gaps.
4. Define closeout evidence bundles required before Governed Workflow Runtime claims can be canonical.

## Promotion Targets

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/constitution/obligations/evidence.yml`
- `.octon/framework/constitution/contracts/retention/`
- `.octon/framework/constitution/contracts/disclosure/`
- `.octon/framework/assurance/runtime/_ops/scripts/`

## Validation

- Evidence obligation id validation.
- Receipt provenance schema validation.
- Generated/input non-authority dependency scan.
- Disclosure completeness validation.

## Evidence Required Before Canonical Claim

- Evidence obligation and retention contract diffs.
- Provenance validator receipts.
- Closeout bundle sample and negative fixtures.

## Cutover Boundary

This child may not claim live runtime behavior until implementation-conformance and post-implementation drift/churn receipts prove durable promoted changes. Final canonical Governed Workflow Runtime terminology remains gated by `migration-cutover-compatibility-retirement`.
