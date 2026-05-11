# Implementation Plan

_Status: Draft child implementation plan_

This plan is proposal-local. It does not authorize durable implementation.

## Dependencies

- `workflow-statechart-task-specific-execution-harness`

## Steps

1. Define agent-node-v1 and model-call-receipt-v1 fields including input context hash, model policy, budget, output schema, validation result, and replay envelope.
2. Define terminal states, timeout behavior, retry eligibility, and revocation behavior for agent nodes.
3. Specify how tool allowlists and connector references bind to effect-token and connector-admission surfaces.
4. Add validators for agent-owned authority violations and missing receipts.

## Promotion Targets

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/constitution/contracts/runtime/`
- `.octon/instance/governance/policies/`
- `.octon/framework/assurance/runtime/_ops/scripts/`

## Validation

- Agent-node schema positive and negative fixtures.
- Model-call receipt completeness validation.
- Context-pack digest binding validation.
- Forbidden authority claim scan for agent outputs and prompts.

## Evidence Required Before Canonical Claim

- Agent-node and model-call schema fixtures.
- Validator receipts for output validation and budget enforcement.
- Review evidence tying agent nodes to harness/statechart contracts.

## Cutover Boundary

This child may not claim live runtime behavior until implementation-conformance and post-implementation drift/churn receipts prove durable promoted changes. Final canonical Governed Workflow Runtime terminology remains gated by `migration-cutover-compatibility-retirement`.
