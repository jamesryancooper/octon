# Filesystem Graph Plane Split (2026-02-16)

## Objective

Implement an early-stage architecture split for better operability, simplicity, and evolvability:

- Keep `filesystem-graph` as compatibility facade.
- Introduce writer plane (`filesystem-snapshot`).
- Introduce query plane (`filesystem-discovery`).
- Introduce separate watcher plane (`filesystem-watch`) with OS-agnostic polling hints.

## Delivered Changes

1. Runtime plane services added and registered:

- `interfaces/filesystem-snapshot`
- `interfaces/filesystem-discovery`
- `interfaces/filesystem-watch`

2. Runtime tier catalogs updated:

- `.harmony/capabilities/services/manifest.runtime.yml`
- `.harmony/capabilities/services/registry.runtime.yml`

3. Legacy service catalogs updated:

- `.harmony/capabilities/services/manifest.yml`
- `.harmony/capabilities/services/registry.yml`
- `.harmony/capabilities/services/capabilities.yml` (adds `interfaces` category)

4. Command entrypoints moved to split planes (runtime direct):

- `/snapshot-build`, `/snapshot-diff` -> `interfaces/filesystem-snapshot`
- `/discover-*` -> `interfaces/filesystem-discovery`
- new `/watch-poll` -> `interfaces/filesystem-watch`
- `/filesystem-graph` retained as compatibility command

5. Separate watcher service implemented (Rust/WASM):

- `watch.poll` operation with bounded scan limits and deterministic event ordering
- persisted cursor state via runtime state files with bounded sampled state payload
- default exclusion for volatile paths and `.git`

6. Runtime policy updated for new services:

- `.harmony/runtime/config/policy.yml`

7. Validation gates/scripts updated for split-plane wiring and new command mappings.

## Validation Evidence

Executed successfully:

- `bash .harmony/capabilities/services/_ops/scripts/validate-services.sh`
- `bash .harmony/capabilities/services/_ops/scripts/validate-service-independence.sh --mode services-core`
- `.harmony/runtime/run validate`
- `bash .harmony/capabilities/services/_ops/scripts/validate-filesystem-graph.sh`
- `bash .harmony/capabilities/services/_ops/scripts/test-filesystem-graph-determinism.sh`
- `bash .harmony/capabilities/services/_ops/scripts/test-filesystem-graph-integration.sh`
- `bash .harmony/capabilities/services/_ops/scripts/test-filesystem-graph-slo.sh --profile ci --no-report`
- `bash .harmony/capabilities/services/_ops/scripts/test-filesystem-graph-perf-regression.sh --profile ci --no-report`
- `FILESYSTEM_GRAPH_VALIDATE_SLO=1 FILESYSTEM_GRAPH_VALIDATE_PERF=1 bash .harmony/capabilities/services/_ops/scripts/validate-filesystem-graph.sh`

## Notes

- `filesystem-snapshot` and `filesystem-discovery` currently package shared implementation behavior from the existing filesystem-graph runtime artifact; manifests now enforce split API surfaces.
- `filesystem-watch` is implemented as a separate service for portability and concern isolation.
