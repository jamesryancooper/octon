# Migration Cutover Plan

## Cutover posture

Use staged hardening, not a big-bang re-foundation. The foundational architecture is already correct enough to preserve. The cutover introduces stricter validators and runtime modularity without widening live support.

## Cutover slices

### Slice A — Hygiene and identifiers

- Deduplicate obligation IDs.
- Add uniqueness validators.
- Remove active-doc transition residue.
- No runtime behavior change.

Rollback: revert validators and ID changes before promotion if reason-code consumers break.

### Slice B — Registry extensions and generated maps

- Add registry metadata for coverage and generated maps.
- Publish maps as derived-only read models.
- No runtime dependency on generated maps.

Rollback: remove generated map publication metadata and projections.

### Slice C — Coverage inventory and validators

- Add side-effect inventory.
- Add coverage map.
- Add fail-closed validator but start in report-only mode for one branch cycle if needed.

Rollback: keep inventory as draft while blocking validators are corrected.

### Slice D — Runtime refactor

- Split kernel and authority modules behind equivalent behavior.
- Add phase-result artifacts.
- Keep public CLI semantics stable.

Rollback: use module-level feature guard or revert refactor while preserving schemas.

### Slice E — Proof and support sufficiency

- Add evidence completeness receipts.
- Raise support dossier sufficiency.
- Generate SupportCards.

Rollback: keep previous support claims only if they still meet existing support-target declarations and do not cite target-state sufficiency.

### Slice F — Compatibility retirement

- Add metadata first.
- Migrate consumers.
- Remove only after no active dependency.

Rollback: restore compatibility projection with owner/expiry metadata.

## Cutover rule

No slice may promote if it causes runtime or policy to depend on this proposal path. Durable targets must stand alone.
