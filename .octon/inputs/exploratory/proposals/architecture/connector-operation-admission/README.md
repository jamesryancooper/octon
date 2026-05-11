# Connector Operation Admission

_Status: Draft child architecture proposal_

This child packet belongs to the `governed-workflow-runtime-transition-program` parent program. It is a sibling proposal packet, not a nested child directory, and it remains non-authoritative proposal lineage under `inputs/**` unless promoted.

## Purpose

Define connector/tool operation admission so availability of a connector, MCP server, browser, API, or tool is never treated as permission.

## Scope

Operation-level connector admission records, trust dossiers, support-target binding, effect-token binding, invocation receipts, denial reasons, and validators.

## Dependencies

- `effect-token-enforcement-coverage`
- `evidence-provenance-hardening`

## Promotion Targets

- `.octon/instance/governance/connector-admissions/`
- `.octon/instance/governance/connectors/`
- `.octon/framework/constitution/contracts/adapters/`
- `.octon/framework/assurance/runtime/_ops/scripts/`

## Authority Boundaries

- The parent program coordinates sequence only and does not own this child manifest, receipts, validation verdicts, or promotion targets.
- Existing run lifecycle, execution authorization, context-pack, effect-token, evidence-store, support-target, and fail-closed contracts remain canonical until durable promotion and cutover evidence replace them.
- Proposal-local material, generated projections, MCP/tool availability, Durable Object state, external workflow engines, and agent output are not authority.
- No architectural claim from this child becomes canonical before durable repository surfaces and promotion evidence prove it.

## Non-Goals

- No MCP integration approval by implication.
- No Durable Object adapter implementation.
- No external workflow-engine adapter implementation.
- No support-target widening from connector availability.

## Required Evidence Before Canonical Claim

- Connector admission fixtures and validator reports.
- Operation invocation receipts for accepted and denied cases.
- Support-target binding and effect-token verification receipts.

## Validation Requirements

- Connector admission schema validation.
- Availability-is-not-permission negative tests.
- Support-target and effect-token binding validation.
- Invocation receipt completeness validation.

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `architecture/target-architecture.md`
4. `architecture/implementation-plan.md`
5. `architecture/acceptance-criteria.md`
6. `validation-plan.md`
7. `RISK-REGISTER.md`
8. `support/implementation-grade-completeness-review.md`
