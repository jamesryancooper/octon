# Workflow History Replay Idempotency Compensation

_Status: Draft child architecture proposal_

This child packet belongs to the `governed-workflow-runtime-transition-program` parent program. It is a sibling proposal packet, not a nested child directory, and it remains non-authoritative proposal lineage under `inputs/**` unless promoted.

## Purpose

Define workflow history, replay reconstruction, idempotency, retry, and compensation semantics without claiming universal rollback or transactionality.

## Scope

Workflow history records, replay reconstruction reports, idempotency keys, retry classes, compensation plans, failure receipts, evidence mirrors, and validator coverage for supported workflows.

## Dependencies

- `workflow-statechart-task-specific-execution-harness`

## Promotion Targets

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/constitution/contracts/runtime/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/state/evidence/`

## Authority Boundaries

- The parent program coordinates sequence only and does not own this child manifest, receipts, validation verdicts, or promotion targets.
- Existing run lifecycle, execution authorization, context-pack, effect-token, evidence-store, support-target, and fail-closed contracts remain canonical until durable promotion and cutover evidence replace them.
- Proposal-local material, generated projections, MCP/tool availability, Durable Object state, external workflow engines, and agent output are not authority.
- No architectural claim from this child becomes canonical before durable repository surfaces and promotion evidence prove it.

## Non-Goals

- No universal replay of arbitrary external systems.
- No guarantee of full rollback or global transactionality.
- No external workflow-engine authority.
- No Durable Object persistence as canonical control or evidence.

## Required Evidence Before Canonical Claim

- Replay reconstruction reports over sample histories.
- Idempotency/retry/compensation fixtures and validator receipts.
- Evidence-store placement receipts.

## Validation Requirements

- Replay reconstruction fixtures for valid, drifted, incomplete, and unsupported histories.
- Idempotency and retry policy negative tests.
- Compensation plan validation and unsupported-rollback disclosure checks.

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `architecture/target-architecture.md`
4. `architecture/implementation-plan.md`
5. `architecture/acceptance-criteria.md`
6. `validation-plan.md`
7. `RISK-REGISTER.md`
8. `support/implementation-grade-completeness-review.md`
