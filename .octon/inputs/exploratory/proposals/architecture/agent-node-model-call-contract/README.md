# Agent Node Model Call Contract

_Status: Draft child architecture proposal_

This child packet belongs to the `governed-workflow-runtime-transition-program` parent program. It is a sibling proposal packet, not a nested child directory, and it remains non-authoritative proposal lineage under `inputs/**` unless promoted.

## Purpose

Define agents as bounded workflow activity nodes and define the model-call receipt, validation, budget, and authority limits needed to admit them safely.

## Scope

Agent-node schema, model-call receipt contract, context digest binding, allowed tools/connectors by reference, output schema validation, cost/budget posture, terminal states, and forbidden authority claims.

## Dependencies

- `workflow-statechart-task-specific-execution-harness`

## Promotion Targets

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/constitution/contracts/runtime/`
- `.octon/instance/governance/policies/`
- `.octon/framework/assurance/runtime/_ops/scripts/`

## Authority Boundaries

- The parent program coordinates sequence only and does not own this child manifest, receipts, validation verdicts, or promotion targets.
- Existing run lifecycle, execution authorization, context-pack, effect-token, evidence-store, support-target, and fail-closed contracts remain canonical until durable promotion and cutover evidence replace them.
- Proposal-local material, generated projections, MCP/tool availability, Durable Object state, external workflow engines, and agent output are not authority.
- No architectural claim from this child becomes canonical before durable repository surfaces and promotion evidence prove it.

## Non-Goals

- No agent-owned queues, schedules, closeout, or workflow transition authority.
- No connector/MCP permission model beyond references to later connector admission.
- No universal replay guarantee for probabilistic outputs.
- No runtime implementation claim before durable schemas and validators land.

## Required Evidence Before Canonical Claim

- Agent-node and model-call schema fixtures.
- Validator receipts for output validation and budget enforcement.
- Review evidence tying agent nodes to harness/statechart contracts.

## Validation Requirements

- Agent-node schema positive and negative fixtures.
- Model-call receipt completeness validation.
- Context-pack digest binding validation.
- Forbidden authority claim scan for agent outputs and prompts.

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `architecture/target-architecture.md`
4. `architecture/implementation-plan.md`
5. `architecture/acceptance-criteria.md`
6. `validation-plan.md`
7. `RISK-REGISTER.md`
8. `support/implementation-grade-completeness-review.md`
