# Implementation Plan

This proposal turns the super-root taxonomy into a durable control-plane
contract. The remaining work is not a topology rewrite; it is a manifest,
validator, workflow, and documentation tightening effort.

## Workstream 1: Finalize The Root Manifest Shape

- Rework `.octon/octon.yml` so the ratified root-manifest semantics are
  explicit:
  - super-root binding
  - class-root bindings
  - harness release version
  - supported schema versions
  - extension API version
  - profile definitions
  - raw-input dependency policy
  - generated-staleness policy
  - human-led or excluded zones
  - migration workflow references
- Deprecate transitional field shapes once validators and workflows understand
  the final contract.

## Workstream 2: Tighten Companion Manifests

- Extend `framework/manifest.yml` to include every ratified framework-scoped
  control field required by profile and compatibility enforcement.
- Extend `instance/manifest.yml` to include every ratified instance-scoped
  control field required by overlay enablement, locality binding, and feature
  gating.
- Keep companion manifests subordinate to `octon.yml`; do not let them become
  parallel root authority surfaces.

## Workstream 3: Implement The Final Profile Semantics

- Ensure `bootstrap_core` installs only the framework bundle plus minimal
  instance seed.
- Rework `repo_snapshot` selection so it is driven by enabled pack state plus
  full dependency closure rather than broad path inclusion.
- Rework `pack_bundle` so it is selector-driven and self-contained for the
  chosen packs.
- Reframe `full_fidelity` as advisory clone guidance instead of a synthetic
  export payload.

## Workstream 4: Enforce Snapshot Completeness And Boundary Rules

- Add export validation that proves enabled-pack payload and dependency closure
  before `repo_snapshot` publication.
- Add validation that rejects forbidden profile inclusions such as proposals,
  state, or generated outputs in the wrong profile.
- Keep raw-input dependency enforcement fail-closed even when raw inputs are
  included in selected export payloads.
- Reject stale required effective outputs when downstream runtime or policy
  behavior depends on them.

## Workstream 5: Align Desired, Actual, And Compiled Extension State

- Treat `instance/extensions.yml` as desired config only.
- Use `state/control/extensions/active.yml` as actual active published state.
- Use `state/control/extensions/quarantine.yml` for blocked packs and
  dependents.
- Publish runtime-facing extension behavior only through
  `generated/effective/extensions/**`.
- Keep publication atomic so snapshot selection and runtime effective views
  resolve against the same validated generation.

## Workstream 6: Update Operator Guidance And Workflow Surfaces

- Rewrite `.octon/README.md` and `.octon/instance/bootstrap/START.md` so
  install/export/update guidance uses the ratified profile model.
- Update architecture references so `octon.yml` is described as authoritative
  control metadata rather than a partial portability descriptor.
- Update workflow docs and runbooks so exact repo reproduction always points to
  normal Git clone semantics.

## Workstream 7: Add Cutover Gates And Remove Transitional Semantics

- Add validators that block mixed old/new profile semantics during migration.
- Remove broad path rules once selector-driven pack closure and advisory
  `full_fidelity` behavior are live.
- Preserve compatibility shims only where necessary and only with explicit
  expiration conditions.

## Downstream Dependency Impact

This proposal blocks or constrains downstream work in:

- framework/core architecture
- repo-instance architecture
- overlay and ingress model
- locality and scope registry
- state/evidence/continuity architecture
- extension input internalization
- proposal input internalization
- generated/effective publication
- portability, trust, and provenance contracts
- unified validation and quarantine semantics
- migration rollout

## Exit Condition

This proposal is complete only when the durable `.octon/` control plane uses a
manifest-defined profile model for install, export, and update behavior, and
no canonical workflow, validator, or operator guide depends on transitional
broad-path snapshot semantics.
