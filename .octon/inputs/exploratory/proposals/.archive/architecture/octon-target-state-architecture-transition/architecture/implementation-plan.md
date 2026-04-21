# Implementation Plan

## Workstream 0 — Proposal acceptance and branch setup

- Validate this proposal packet against the proposal and architecture-proposal standards.
- Confirm all promotion targets are `.octon/**` and outside the proposal tree.
- Record implementation branch profile and release state.

## Workstream 1 — Identifier and active-doc hygiene

1. Deduplicate `FCR-017`, `FCR-018`, and `FCR-019` in `fail-closed.yml`.
2. Deduplicate `EVI-013` and `EVI-014` in `evidence.yml`.
3. Add validators for unique obligation IDs and reason-code stability.
4. Remove historical wave language from active docs or move it to ADR/evidence lineage.
5. Reconcile skill host projection language to generated-routing projection only.

Promotion gate: obligation validators and active-doc hygiene validator pass.

## Workstream 2 — Structural registry extension

1. Add material-side-effect inventory and authorization coverage map references to the structural registry.
2. Add generated navigation map publication metadata.
3. Add compatibility-retirement metadata for retained projections.
4. Update the architecture specification as a narrative companion only.

Promotion gate: architecture conformance validator passes and generated map definition is publication-ready.

## Workstream 3 — Authorization coverage proof

1. Create side-effect inventory schema and initial inventory.
2. Create coverage map schema and coverage records for current runtime command/service/workflow/publication paths.
3. Add static and runtime validators for unmediated material paths.
4. Add negative-control tests for generated-as-authority, host-as-authority, and unmediated side-effect cases.

Promotion gate: `validate-authorization-boundary-coverage.sh` emits retained evidence with no uncovered material path.

## Workstream 4 — Runtime modularization

1. Split kernel command handling into `commands/**`.
2. Move request construction to `request_builders/**`.
3. Add side-effect classification module.
4. Split authority engine implementation into phase modules.
5. Emit phase result artifacts for denials, stage-only, and grants.

Promotion gate: existing runtime command behavior is preserved; phase-level tests pass; coverage map points to new modules.

## Workstream 5 — Proof-plane hardening

1. Add evidence completeness receipt schema or contract.
2. Add support tuple proof bundle format.
3. Add RunCard/HarnessCard/SupportCard generation from retained evidence only.
4. Add proof-query generated read model.
5. Add validators for evidence completeness and generated/effective freshness.

Promotion gate: a sample consequential run closes with complete authority, lifecycle, replay, disclosure, and evidence-classification artifacts.

## Workstream 6 — Support dossier sufficiency

1. Update support review contract to require representative positive and negative proof.
2. Update support dossiers with stricter live-claim sufficiency thresholds.
3. Retain support proof bundles under evidence roots.
4. Ensure stage-only/non-live surfaces remain excluded from live claims.

Promotion gate: all admitted live support tuples have current proof bundle and generated SupportCard projection.

## Workstream 7 — Compatibility retirement

1. Inventory compatibility projections and shims.
2. Add owner/consumer/expiry metadata.
3. Migrate validators/runtime consumers to canonical path families or generated maps.
4. Retain retirement evidence.
5. Remove retired shims only after validation proves no active dependency.

Promotion gate: compatibility retirement map shows no unmanaged transitional surface.

## Workstream 8 — Closeout

1. Run full validation plan.
2. Retain promotion evidence under `state/evidence/validation/architecture-target-state-transition/**`.
3. Publish generated maps with receipts and freshness metadata.
4. Create ADR `101-target-state-architecture-transition.md`.
5. Archive this proposal only after durable targets stand without proposal-path dependency.
