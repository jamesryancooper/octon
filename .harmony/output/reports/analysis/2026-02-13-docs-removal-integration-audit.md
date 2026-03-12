# Docs Removal Integration Audit

Date: 2026-02-13

## Summary

This audit verifies that documents removed under `docs/` were either:

- integrated into canonical `.harmony` locations, or
- intentionally removed as non-canonical docs-as-code artifacts.

## Removed Docs Counts

- Total deleted under `docs/`: 99
- Deleted from `docs/services/**`: 55
- Deleted hidden docs-as-code artifacts under `docs/**/.harmony/**`: 42
- Deleted principles legacy docs (`docs/principles*`): 2

## Integration Actions

### 1) Services docs fully integrated

All removed `docs/services/**` markdown files were integrated under:

- `.harmony/capabilities/services/**`

Mapping rule:

- `docs/services/<path>.md` -> `.harmony/capabilities/services/<path>.md`
- `docs/services/README.md` -> `.harmony/capabilities/services/_meta/docs/platform-overview.md`

Validation result:

- `services_integration=all_present`

### 2) Canonical links updated

Active harness docs now reference `.harmony/capabilities/services/**` (not deleted `docs/services/**`).

### 3) Legacy nested docs-as-code artifacts pruned

Removed non-canonical index/inbox/archive artifacts located in:

- `docs/.harmony/**`
- `docs/engines/.harmony/**`
- `docs/runtimes/.harmony/**`
- `docs/architecture/continuity-plane/.harmony/**`

These were transient migration/index artifacts and are not canonical harness documentation.

### 4) Principles docs already represented in harness cognition

Legacy deletions under `docs/principles*` are covered by existing canonical docs:

- `.harmony/cognition/principles/README.md`
- `.harmony/cognition/pillars/README.md`
- `.harmony/cognition/purpose/README.md`

## Notes

Historical records under `.harmony/output/**` and ideation artifacts under `.harmony/ideation/**` may still reference old `docs/...` paths for provenance. These were intentionally not rewritten in this audit.
