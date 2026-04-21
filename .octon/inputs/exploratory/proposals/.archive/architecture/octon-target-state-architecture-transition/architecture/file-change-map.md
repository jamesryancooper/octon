# File Change Map

## Modify existing authored authority

| Path | Change |
|---|---|
| `.octon/framework/cognition/_meta/architecture/contract-registry.yml` | Add material-side-effect inventory refs, authorization coverage publication metadata, generated map metadata, and compatibility retirement metadata. |
| `.octon/framework/cognition/_meta/architecture/specification.md` | Describe target-state coverage/proof/retirement model without duplicating registry matrices. |
| `.octon/framework/constitution/obligations/fail-closed.yml` | Deduplicate FCR IDs and add stable reason-code metadata, owners, evidence refs, and validator fixture refs. |
| `.octon/framework/constitution/obligations/evidence.yml` | Deduplicate EVI IDs and add proof-bundle/evidence-completeness requirements. |
| `.octon/framework/engine/runtime/spec/execution-authorization-v1.md` | Add coverage-proof obligation and phase-result references. |
| `.octon/instance/governance/contracts/support-target-review.yml` | Raise support-dossier sufficiency requirements for live claims. |
| `.octon/instance/governance/support-targets.yml` | Reference support proof bundle and SupportCard projection requirements without widening live support. |
| `.octon/framework/observability/README.md` | Add proof-query and runtime-event coverage guidance. |
| `.octon/framework/lab/README.md` | Replace historical active-doc language with steady-state lab proof model. |

## Add new authored specs and validators

| Path | Purpose |
|---|---|
| `.octon/framework/engine/runtime/spec/material-side-effect-inventory-v1.schema.json` | Schema for side-effect inventory. |
| `.octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.schema.json` | Schema for coverage map. |
| `.octon/framework/engine/runtime/spec/authorization-phase-result-v1.schema.json` | Schema for phase-level authorization results. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-fail-closed-obligation-ids.sh` | Unique, stable fail-closed reason-code validation. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-evidence-obligation-ids.sh` | Unique, stable evidence obligation validation. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-material-side-effect-inventory.sh` | Side-effect inventory validation. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-authorization-boundary-coverage.sh` | Coverage validation. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-generated-effective-freshness.sh` | Publication receipt and freshness validation. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-proof-bundle-completeness.sh` | Run/support proof completeness validation. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-active-doc-hygiene.sh` | Active-doc steady-state hygiene validation. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-compatibility-retirement.sh` | Transitional shim retirement validation. |

## Refactor runtime implementation

| Path | Change |
|---|---|
| `.octon/framework/engine/runtime/crates/kernel/src/main.rs` | Reduce to parse/dispatch shell. |
| `.octon/framework/engine/runtime/crates/kernel/src/commands/**` | Move command implementations. |
| `.octon/framework/engine/runtime/crates/kernel/src/request_builders/**` | Centralize typed `ExecutionRequest` construction. |
| `.octon/framework/engine/runtime/crates/kernel/src/side_effects/**` | Classify side effects and map to coverage inventory. |
| `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs` | Reduce to orchestrating public boundary. |
| `.octon/framework/engine/runtime/crates/authority_engine/src/phases/**` | Add phase modules and phase tests. |

## Add generated projections

Generated outputs remain non-authoritative.

| Path | Purpose |
|---|---|
| `.octon/generated/cognition/projections/definitions/architecture-map.yml` | Definition for generated architecture map. |
| `.octon/generated/cognition/projections/materialized/architecture-map.md` | Human/agent navigation map. |
| `.octon/generated/cognition/projections/materialized/authorization-coverage-map.md` | Coverage summary. |
| `.octon/generated/cognition/projections/materialized/compatibility-retirement-map.md` | Shim retirement view. |

## Add retained evidence

| Path | Purpose |
|---|---|
| `.octon/state/evidence/validation/architecture-target-state-transition/**` | Promotion validation, coverage reports, proof completeness receipts, and closure certification. |
| `.octon/state/evidence/validation/support-targets/**` | Support tuple proof bundles. |

## Add durable decision record

| Path | Purpose |
|---|---|
| `.octon/instance/cognition/decisions/101-target-state-architecture-transition.md` | ADR recording the target-state transition decision and promoted outputs. |
