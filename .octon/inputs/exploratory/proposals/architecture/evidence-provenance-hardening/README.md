# Evidence Provenance Hardening

_Status: Draft child architecture proposal_

This child packet belongs to the `governed-workflow-runtime-transition-program` parent program. It is a sibling proposal packet, not a nested child directory, and it remains non-authoritative proposal lineage under `inputs/**` unless promoted.

## Purpose

Harden provenance, retention, disclosure, and receipt requirements for workflow transitions, agent nodes, model calls, effect-token checks, replay, retries, compensation, and closeout.

## Scope

Evidence obligation deltas, provenance fields, retained evidence roots, disclosure contracts, receipt chaining, external index references, and validators.

## Dependencies

- `agent-node-model-call-contract`
- `workflow-history-replay-idempotency-compensation`
- `effect-token-enforcement-coverage`

## Promotion Targets

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/constitution/obligations/evidence.yml`
- `.octon/framework/constitution/contracts/retention/`
- `.octon/framework/constitution/contracts/disclosure/`
- `.octon/framework/assurance/runtime/_ops/scripts/`

## Authority Boundaries

- The parent program coordinates sequence only and does not own this child manifest, receipts, validation verdicts, or promotion targets.
- Existing run lifecycle, execution authorization, context-pack, effect-token, evidence-store, support-target, and fail-closed contracts remain canonical until durable promotion and cutover evidence replace them.
- Proposal-local material, generated projections, MCP/tool availability, Durable Object state, external workflow engines, and agent output are not authority.
- No architectural claim from this child becomes canonical before durable repository surfaces and promotion evidence prove it.

## Non-Goals

- No use of proposal-local artifacts as durable evidence.
- No use of generated summaries as control or evidence truth.
- No full cryptographic attestation requirement unless separately scoped.

## Required Evidence Before Canonical Claim

- Evidence obligation and retention contract diffs.
- Provenance validator receipts.
- Closeout bundle sample and negative fixtures.

## Validation Requirements

- Evidence obligation id validation.
- Receipt provenance schema validation.
- Generated/input non-authority dependency scan.
- Disclosure completeness validation.

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `architecture/target-architecture.md`
4. `architecture/implementation-plan.md`
5. `architecture/acceptance-criteria.md`
6. `validation-plan.md`
7. `RISK-REGISTER.md`
8. `support/implementation-grade-completeness-review.md`
