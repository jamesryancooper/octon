# Implementation Plan

## Phase 0 — Promotion setup

1. Validate this proposal packet structure.
2. Record an implementation run contract for the promotion effort.
3. Record support tuple and execution profile for the implementation run.
4. Confirm no promotion target depends on this proposal path.

## Phase 1 — Support path normalization and proof refresh

1. Move support admissions and dossiers into declared claim-state partitions:
   - `live/`
   - `stage-only/`
   - `unadmitted/`
   - `retired/`
2. Update `support-targets.yml`, proof bundles, support cards, generated support matrix, and validators.
3. Retain flat files only as compatibility shims if needed; add retirement entries.
4. Add `validate-support-target-path-normalization.sh`.
5. Regenerate support proof bundles and support cards.

## Phase 2 — Runtime-resolution delegation

1. Add runtime-resolution v1 spec and schema.
2. Add `instance/governance/runtime-resolution.yml`.
3. Thin `octon.yml` to root anchors and references.
4. Add generated/effective runtime route-bundle schema and generator.
5. Add route-bundle lock and publication receipt.
6. Update architecture registry and specification.

## Phase 3 — Publication freshness hard gate

1. Add publication freshness gates v2.
2. Implement `GeneratedEffectiveHandle` in a runtime resolver crate or equivalent module.
3. Replace direct runtime reads of generated/effective outputs with handle-based reads.
4. Add tests that stale generated/effective outputs deny or stage before runtime consumption.

## Phase 4 — Authorization-boundary completion

1. Expand material side-effect inventory and coverage map.
2. Bind every path to request builder, authorization call, grant bundle, receipt, and negative controls.
3. Ensure `authorize_execution` requires current route-bundle digest and freshness proof.
4. Add negative-control tests for generated-as-authority, host-projection-as-authority, stale route bundle,
   missing support tuple, unadmitted pack, unpublished extension, and missing run contract.

## Phase 5 — Pack-route compilation

1. Preserve framework pack contracts.
2. Preserve instance governance pack intent.
3. Compile runtime-facing pack routes into `generated/effective/capabilities/pack-routes.effective.yml`.
4. Reclassify `instance/capabilities/runtime/packs/**` as compatibility projection or retire it.
5. Add tests proving pack routes cannot widen beyond support-target admissions.

## Phase 6 — Extension active-state compaction

1. Reduce `state/control/extensions/active.yml` to compact digest pointers.
2. Move dependency closure and `required_inputs` expansion to generation lock.
3. Enforce quarantine state before publication or runtime use.
4. Regenerate effective extension catalog, artifact map, and generation lock.
5. Add compactness and quarantine hard-gate validators.

## Phase 7 — Operator and proof surfaces

1. Add `octon doctor --architecture` summary coverage for target-state dimensions.
2. Generate non-authoritative architecture, runtime route, and support pack maps.
3. Retain validation evidence under `state/evidence/validation/architecture/10of10-target-transition/**`.
4. Generate closure certification and promotion receipt.

## Phase 8 — Compatibility retirement

1. Mark retained shims in retirement register with owners, sunset criteria, and validators.
2. Remove proposal-path dependencies from durable surfaces.
3. Archive this packet after promotion and closure evidence land.
