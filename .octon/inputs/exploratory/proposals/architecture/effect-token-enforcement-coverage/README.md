# Effect Token Enforcement Coverage

_Status: Draft child architecture proposal_

This child packet belongs to the `governed-workflow-runtime-transition-program` parent program. It is a sibling proposal packet, not a nested child directory, and it remains non-authoritative proposal lineage under `inputs/**` unless promoted.

## Purpose

Prove coverage of typed AuthorizedEffect token verification across material side-effect paths before workflow-runtime claims widen.

## Scope

Material side-effect inventory, coverage matrix, bypass-negative tests, token verification receipts, runtime crate enforcement targets, and validator scripts.

## Dependencies

- `workflow-statechart-task-specific-execution-harness`

## Promotion Targets

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/engine/runtime/crates/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`

## Authority Boundaries

- The parent program coordinates sequence only and does not own this child manifest, receipts, validation verdicts, or promotion targets.
- Existing run lifecycle, execution authorization, context-pack, effect-token, evidence-store, support-target, and fail-closed contracts remain canonical until durable promotion and cutover evidence replace them.
- Proposal-local material, generated projections, MCP/tool availability, Durable Object state, external workflow engines, and agent output are not authority.
- No architectural claim from this child becomes canonical before durable repository surfaces and promotion evidence prove it.

## Non-Goals

- No widening of support targets or connector permissions.
- No replacement of Execution Authorization v1 or Authorized Effect Token v1 without validated promotion.
- No claim that all repo code paths are covered before coverage receipts prove it.

## Required Evidence Before Canonical Claim

- Material side-effect inventory and coverage matrix.
- Token consumption validation reports.
- Runtime test receipts for bypass denial and valid path acceptance.

## Validation Requirements

- Material side-effect inventory completeness validation.
- Authorized effect token enforcement validator and bypass tests.
- Runtime crate test coverage for successful and rejected token consumption.

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `architecture/target-architecture.md`
4. `architecture/implementation-plan.md`
5. `architecture/acceptance-criteria.md`
6. `validation-plan.md`
7. `RISK-REGISTER.md`
8. `support/implementation-grade-completeness-review.md`
