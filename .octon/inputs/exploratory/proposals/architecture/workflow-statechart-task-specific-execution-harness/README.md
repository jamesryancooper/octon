# Workflow Statechart Task Specific Execution Harness

_Status: Draft child architecture proposal_

This child packet belongs to the `governed-workflow-runtime-transition-program` parent program. It is a sibling proposal packet, not a nested child directory, and it remains non-authoritative proposal lineage under `inputs/**` unless promoted.

## Purpose

Define the minimum workflow statechart and task-specific execution harness contract needed before Octon can claim a workflow-first runtime shape.

## Scope

Statechart semantics, harness compilation records, binding to Run Lifecycle v1, generated diagram non-authority, validator shape, and migration-neutral compatibility with existing run contracts.

## Dependencies

- `framing-boundary-and-terminology-guardrails`

## Promotion Targets

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/constitution/contracts/runtime/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/generated/cognition/projections/materialized/`

## Authority Boundaries

- The parent program coordinates sequence only and does not own this child manifest, receipts, validation verdicts, or promotion targets.
- Existing run lifecycle, execution authorization, context-pack, effect-token, evidence-store, support-target, and fail-closed contracts remain canonical until durable promotion and cutover evidence replace them.
- Proposal-local material, generated projections, MCP/tool availability, Durable Object state, external workflow engines, and agent output are not authority.
- No architectural claim from this child becomes canonical before durable repository surfaces and promotion evidence prove it.

## Non-Goals

- No external workflow engine adoption.
- No Durable Object coordination adapter.
- No agent-node/model-call contract beyond the harness slots needed by a later child.
- No runtime cutover or compatibility retirement by itself.

## Required Evidence Before Canonical Claim

- Statechart schema fixtures and validator receipts.
- Harness compilation examples and negative fixtures.
- Run Lifecycle v1 parity review evidence.

## Validation Requirements

- Statechart schema validation with positive and negative fixtures.
- Run Lifecycle v1 parity validation.
- Control/evidence/generated/input placement validation.
- Harness compilation receipt validation.

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `architecture/target-architecture.md`
4. `architecture/implementation-plan.md`
5. `architecture/acceptance-criteria.md`
6. `validation-plan.md`
7. `RISK-REGISTER.md`
8. `support/implementation-grade-completeness-review.md`
