# File-Change Map

## Authored authority changes

| Target | Change |
|---|---|
| `.octon/octon.yml` | Thin root manifest: retain roots, profiles, generated commit defaults; point dense runtime-resolution to delegated registries |
| `.octon/framework/cognition/_meta/architecture/contract-registry.yml` | Add runtime-resolution, runtime-effective route bundle, support-path normalization, pack-route publication, and extension-active-state compactness path families |
| `.octon/framework/cognition/_meta/architecture/specification.md` | Update human-readable structural narrative without duplicating full path matrices |
| `.octon/framework/constitution/obligations/fail-closed.yml` | Add or refine reason-code references for stale route bundle, support-path drift, pack-route widening, extension-state staleness, and generated/effective direct read |
| `.octon/framework/constitution/obligations/evidence.yml` | Add evidence obligations for runtime-effective route bundle publication, pack-route compilation, support-path normalization, and extension active-state compactness |
| `.octon/instance/governance/runtime-resolution.yml` | New repo-owned runtime-resolution selector/inputs surface |
| `.octon/instance/governance/support-targets.yml` | Normalize tuple refs to partitioned admissions/dossiers and maintain bounded claim semantics |
| `.octon/instance/governance/contracts/support-pack-admission-alignment.yml` | Strengthen pack/support no-widening contract |
| `.octon/instance/governance/retirement-register.yml` | Add flat support path, workflow wrapper, and compatibility projection retirement entries |

## Runtime/spec changes

| Target | Change |
|---|---|
| `.octon/framework/engine/runtime/spec/runtime-resolution-v1.md` | New contract for root-manifest delegation and runtime route resolution |
| `.octon/framework/engine/runtime/spec/runtime-resolution-v1.schema.json` | Schema for instance runtime-resolution input |
| `.octon/framework/engine/runtime/spec/runtime-effective-route-bundle-v1.schema.json` | Schema for compiled runtime-facing route bundle |
| `.octon/framework/engine/runtime/spec/publication-freshness-gates-v2.md` | Hard-gate generated/effective consumption contract |
| `.octon/framework/engine/runtime/spec/authorization-boundary-coverage.yml` | Include route-bundle and freshness-hard-gate negative controls |
| `.octon/framework/engine/runtime/crates/runtime_resolver/src/lib.rs` | Runtime resolver and `GeneratedEffectiveHandle` implementation |
| `.octon/framework/engine/runtime/crates/core/src/config.rs` | Load delegated runtime-resolution pointers and enforce generated/effective handles |
| `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs` | Require fresh route bundle before grant emission |

## Generated/effective outputs to regenerate

These are not authored authority. They must be regenerated with receipts and locks.

| Target | Change |
|---|---|
| `.octon/generated/effective/runtime/route-bundle.yml` | Compiled runtime route bundle |
| `.octon/generated/effective/runtime/route-bundle.lock.yml` | Source digest/freshness lock |
| `.octon/generated/effective/capabilities/pack-routes.effective.yml` | Runtime-facing pack route compilation |
| `.octon/generated/effective/capabilities/pack-routes.lock.yml` | Pack route source/freshness lock |
| `.octon/generated/effective/governance/support-target-matrix.yml` | Rebuild from normalized support partitions |
| `.octon/generated/effective/extensions/**` | Rebuild after active-state compactness change |

## State/control and evidence changes

| Target | Change |
|---|---|
| `.octon/state/control/extensions/active.yml` | Compact active extension state; move expansion to generated lock |
| `.octon/state/control/extensions/quarantine.yml` | Preserve quarantine state and enforce as hard runtime input |
| `.octon/state/evidence/validation/architecture/10of10-target-transition/**` | Retained implementation, publication, support, runtime, and closure evidence |

## Transitional/compatibility changes

| Target | Change |
|---|---|
| `.octon/instance/capabilities/runtime/packs/**` | Reclassify as compatibility projection or retire after generated/effective pack route adoption |
| flat `.octon/instance/governance/support-target-admissions/*.yml` | Move to partitioned roots or retain as deprecated shim only |
| flat `.octon/instance/governance/support-dossiers/*/dossier.yml` | Move to partitioned roots or retain as deprecated shim only |
| workflow compatibility wrapper | Retain until run-first coverage and tests prove all workflow paths bind run contracts |
