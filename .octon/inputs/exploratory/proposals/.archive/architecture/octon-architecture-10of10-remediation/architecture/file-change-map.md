# File Change Map

## Create

| Path | Purpose |
|---|---|
| `.octon/framework/constitution/contracts/retention/evidence-store-v1.schema.json` | Retained evidence backend contract schema. |
| `.octon/framework/constitution/contracts/authority/promotion-receipt-v1.schema.json` | Receipt schema for promotion/activation. |
| `.octon/framework/constitution/contracts/disclosure/run-card-v1.schema.json` | RunCard disclosure schema. |
| `.octon/framework/constitution/contracts/disclosure/harness-card-v1.schema.json` | HarnessCard disclosure schema. |
| `.octon/framework/constitution/contracts/assurance/support-target-proof-bundle-v1.schema.json` | Support tuple proof bundle schema. |
| `.octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md` | Required side-effect path coverage contract. |
| `.octon/framework/engine/runtime/spec/evidence-store-v1.md` | Runtime retained evidence store contract. |
| `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md` | Formal run lifecycle state machine. |
| `.octon/framework/engine/runtime/spec/operator-read-models-v1.md` | Non-authoritative operator view contract. |
| `.octon/framework/engine/runtime/spec/promotion-activation-v1.md` | Promotion and publication lifecycle contract. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-contract-registry.sh` | Validate canonical registry and generated docs. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-authorization-boundary-coverage.sh` | Validate side-effect path coverage. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-evidence-completeness.sh` | Validate retained evidence completeness. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh` | Validate generated surfaces are not authority inputs. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh` | Validate raw inputs/proposals are not runtime/policy dependencies. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-promotion-receipts.sh` | Validate promotion/activation receipts. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-support-target-proofing.sh` | Validate admitted tuple proof bundles. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-operator-read-models.sh` | Validate generated views trace to canonical sources. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-runtime-docs-consistency.sh` | Validate docs align with registry/runtime contracts. |
| `.octon/instance/governance/contracts/promotion-receipts.yml` | Repo-owned promotion receipt policy. |
| `.octon/instance/governance/contracts/support-target-proofing.yml` | Repo-owned proofing requirements for support admissions. |
| `.octon/instance/governance/policies/promotion-semantics.yml` | Policy forbidding quiet authority creation. |
| `.octon/instance/cognition/decisions/architecture-10of10-remediation-adoption.md` | Adoption decision for the remediation program. |
| `.octon/instance/cognition/decisions/architecture-topology-registry-consolidation.md` | Decision for contract registry consolidation. |
| `.octon/instance/cognition/decisions/authorization-boundary-coverage-closeout.md` | Closeout decision for enforcement coverage. |
| `.octon/instance/cognition/decisions/evidence-store-and-proof-plane-closeout.md` | Closeout decision for evidence durability. |
| `.octon/instance/cognition/decisions/promotion-semantics-hardening.md` | Decision for promotion semantics. |
| `.octon/state/evidence/validation/architecture/10of10-remediation/` | Closure evidence root. |

## Modify

| Path | Required change |
|---|---|
| `.octon/framework/cognition/_meta/architecture/contract-registry.yml` | Make it the single machine-readable registry for topology, authority, consumers, validators, publication, and generated docs. |
| `.octon/framework/cognition/_meta/architecture/specification.md` | Reduce hand-maintained path matrices; reference generated docs from registry. |
| `.octon/README.md` | Keep concise class-root summary; generated from registry or registry-checked. |
| `.octon/instance/bootstrap/START.md` | Move historical/cutover-heavy content out; keep steady-state boot path. |
| `.octon/instance/ingress/AGENTS.md` | Remove duplicated read-order content once generated from ingress manifest/registry. |
| `.octon/framework/constitution/contracts/registry.yml` | Register new retention, promotion, run-card, harness-card, support-proof contracts. |
| `.octon/framework/constitution/obligations/evidence.yml` | Add evidence-store completeness and retention backend references. |
| `.octon/framework/constitution/obligations/fail-closed.yml` | Add explicit denial for missing promotion receipts and missing authorization coverage. |
| `.octon/framework/engine/runtime/README.md` | Link runtime lifecycle, evidence-store, authorization coverage, and operator read-model specs. |
| `.octon/framework/engine/runtime/crates/authority_engine/src/lib.rs` | Re-export decomposed modules. |
| `.octon/framework/engine/runtime/crates/authority_engine/src/implementation.rs` | Shrink to compatibility facade or remove after modularization. |
| `.github/workflows/architecture-conformance.yml` | Add registry, boundary, evidence, promotion, read-model validators. |
| `.github/workflows/deny-by-default-gates.yml` | Include authorization coverage and bypass negative tests. |
| `.github/workflows/runtime-binaries.yml` | Enforce strict packaging expectations for target runtime lanes. |

## Relocate or archive

| Source | Target | Reason |
|---|---|---|
| Active-doc wave/cutover narrative in `specification.md` and `START.md` | `.octon/instance/cognition/decisions/**` or `.octon/state/evidence/migration/**` | Keep active docs steady-state and reduce operator complexity. |
| Proposal-lineage closeout explanations in active docs | Decision records and migration evidence | Proposal packets are historical lineage, not runtime authority. |
| Direct project-finding publication language | Promotion-semantics policy and decision record | Eliminate quiet authority creation path. |

## Delete after replacement

| Path/pattern | Condition |
|---|---|
| Duplicate hand-maintained topology tables in active docs | Generated equivalents exist and registry validator passes. |
| Deprecated compatibility artifacts for run lifecycle | Formal run lifecycle state machine and migration evidence are complete. |
| Any generated/effective output lacking generation lock and publication receipt | Replacement publication path exists or surface is removed from runtime use. |

## Regenerate

| Path | Generator/source |
|---|---|
| `.octon/generated/cognition/summaries/operators/**` | Operator read-model generator from authority/control/evidence/continuity roots. |
| `.octon/generated/cognition/projections/materialized/runs/**` | Run lifecycle and evidence roots. |
| `.octon/generated/cognition/projections/materialized/evidence/**` | Evidence-store index. |
| `.octon/generated/effective/governance/support-target-matrix.yml` | `instance/governance/support-targets.yml` plus proof dossiers. |
| `.octon/generated/proposals/registry.yml` | Proposal manifests only; discovery projection. |

## Validate

| Validator | Applies to |
|---|---|
| `validate-architecture-contract-registry.sh` | Topology registry and generated docs. |
| `validate-authorization-boundary-coverage.sh` | Runtime material path inventory and call coverage. |
| `validate-evidence-completeness.sh` | Run/lab/control/publication evidence roots. |
| `validate-generated-non-authority.sh` | All generated consumers. |
| `validate-input-non-authority.sh` | Runtime/policy imports and path reads. |
| `validate-promotion-receipts.sh` | Promotions from inputs/generated to authority/control/effective. |
| `validate-support-target-proofing.sh` | Tuple admissions and support claims. |
| `validate-operator-read-models.sh` | Generated operator projections. |
| `validate-runtime-docs-consistency.sh` | Runtime README/spec/docs alignment. |
