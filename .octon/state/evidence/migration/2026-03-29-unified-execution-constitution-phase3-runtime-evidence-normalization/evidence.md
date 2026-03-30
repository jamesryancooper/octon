# Unified Execution Constitution Phase 3 Evidence

This bundle captures the Phase 3 runtime and evidence normalization cutover.

Key proof points:

- `run-manifest.yml` is now the canonical bound run-manifest model
- `runtime-state.yml` and `handoff.yml` point at artifact-rooted resume inputs
  rather than acting as partial stand-ins for the manifest
- per-run `evidence-classification.yml` encodes the packet’s Class A/B/C model
- the `release-and-boundary-sensitive` sample run retains a real external
  immutable replay index under `state/evidence/external-index/**`
- validators now check the Phase 3 exit criteria directly
