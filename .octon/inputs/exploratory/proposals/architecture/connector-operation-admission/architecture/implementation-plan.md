# Implementation Plan

_Status: Draft child implementation plan_

This plan is proposal-local. It does not authorize durable implementation.

## Dependencies

- `effect-token-enforcement-coverage`
- `evidence-provenance-hardening`

## Steps

1. Define connector-operation-admission schema and invocation receipt fields.
2. Bind connector operations to support targets, trust dossiers, effect-token checks, rollback posture, and evidence roots.
3. Add validators that reject availability-as-permission for MCP, browser, API, and external tool surfaces.
4. Define explicit unsupported and lab-only admission outcomes.

## Promotion Targets

- `.octon/instance/governance/connector-admissions/`
- `.octon/instance/governance/connectors/`
- `.octon/framework/constitution/contracts/adapters/`
- `.octon/framework/assurance/runtime/_ops/scripts/`

## Validation

- Connector admission schema validation.
- Availability-is-not-permission negative tests.
- Support-target and effect-token binding validation.
- Invocation receipt completeness validation.

## Evidence Required Before Canonical Claim

- Connector admission fixtures and validator reports.
- Operation invocation receipts for accepted and denied cases.
- Support-target binding and effect-token verification receipts.

## Cutover Boundary

This child may not claim live runtime behavior until implementation-conformance and post-implementation drift/churn receipts prove durable promoted changes. Final canonical Governed Workflow Runtime terminology remains gated by `migration-cutover-compatibility-retirement`.
