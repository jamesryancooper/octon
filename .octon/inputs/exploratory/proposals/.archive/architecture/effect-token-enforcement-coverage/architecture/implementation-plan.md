# Implementation Plan

_Status: Draft child implementation plan_

This plan is proposal-local. It does not authorize durable implementation.

## Dependencies

- `workflow-statechart-task-specific-execution-harness`

## Steps

1. Inventory material side-effect paths and classify their effect kinds.
2. Map each path to required AuthorizedEffect token verification and consumption receipt requirements.
3. Add negative tests for bypass, stale token, wrong effect class, wrong route, wrong support tuple, and already-consumed token cases.
4. Update runtime enforcement surfaces only after schema and validator proof exists.

## Promotion Targets

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/engine/runtime/crates/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`

## Validation

- Material side-effect inventory completeness validation.
- Authorized effect token enforcement validator and bypass tests.
- Runtime crate test coverage for successful and rejected token consumption.

## Evidence Required Before Canonical Claim

- Material side-effect inventory and coverage matrix.
- Token consumption validation reports.
- Runtime test receipts for bypass denial and valid path acceptance.

## Cutover Boundary

This child may not claim live runtime behavior until implementation-conformance and post-implementation drift/churn receipts prove durable promoted changes. Final canonical Governed Workflow Runtime terminology remains gated by `migration-cutover-compatibility-retirement`.
