# Implementation Plan

_Status: Draft child implementation plan_

This plan is proposal-local. It does not authorize durable implementation.

## Dependencies

- `framing-boundary-and-terminology-guardrails`

## Steps

1. Define workflow-statechart-v1 states, transitions, invalid transitions, and relation to Run Lifecycle v1.
2. Define task-specific execution harness schema and harness compilation receipt fields.
3. Specify generated statechart diagram/read-model outputs as derived-only projections.
4. Add validators for schema placement, control-root binding, generated non-authority, and parity with existing run lifecycle rules.

## Promotion Targets

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/constitution/contracts/runtime/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/generated/cognition/projections/materialized/`

## Validation

- Statechart schema validation with positive and negative fixtures.
- Run Lifecycle v1 parity validation.
- Control/evidence/generated/input placement validation.
- Harness compilation receipt validation.

## Evidence Required Before Canonical Claim

- Statechart schema fixtures and validator receipts.
- Harness compilation examples and negative fixtures.
- Run Lifecycle v1 parity review evidence.

## Cutover Boundary

This child may not claim live runtime behavior until implementation-conformance and post-implementation drift/churn receipts prove durable promoted changes. Final canonical Governed Workflow Runtime terminology remains gated by `migration-cutover-compatibility-retirement`.
