# Implementation Run

run_id: proposal-churn-filesystem-snapshot-retention-implementation-20260702
implemented_at: 2026-07-02T00:00:00Z
implementer: codex
verdict: pass

## Scope

Implemented filesystem snapshot retention by changing only the declared
filesystem-snapshot service, service contract metadata, and packet lifecycle
artifacts.

## Files Updated

- `.octon/framework/capabilities/runtime/services/interfaces/filesystem-snapshot/README.md`
- `.octon/framework/capabilities/runtime/services/interfaces/filesystem-snapshot/contract.md`
- `.octon/framework/capabilities/runtime/services/interfaces/filesystem-snapshot/contracts/invariants.md`
- `.octon/framework/capabilities/runtime/services/interfaces/filesystem-snapshot/rust/src/lib.rs`
- `.octon/framework/capabilities/runtime/services/interfaces/filesystem-snapshot/service.json`
- `.octon/framework/capabilities/runtime/services/interfaces/filesystem-snapshot/service.wasm`
- `.octon/inputs/exploratory/proposals/architecture/proposal-churn-filesystem-snapshot-retention/proposal.yml`
- `.octon/inputs/exploratory/proposals/architecture/proposal-churn-filesystem-snapshot-retention/navigation/artifact-catalog.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-churn-filesystem-snapshot-retention/support/implementation-run.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-churn-filesystem-snapshot-retention/support/implementation-conformance-review.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-churn-filesystem-snapshot-retention/support/post-implementation-drift-churn-review.md`

## Implementation Summary

- Added write-if-changed behavior for stable text outputs used by snapshot
  builds, including `hash-cache.jsonl` and the active `current` pointer.
- Added `protected_snapshot_ids` input validation for caller-declared snapshot
  references that must survive producer-owned GC.
- Added fail-closed reference-integrity checks for protected snapshots that are
  missing or incomplete.
- Added retention metadata to successful `snapshot.build` output.
- Updated service contract metadata and documentation for protected retention.
- Rebuilt `service.wasm` with the updated service implementation and updated
  `service.json.integrity.wasm_sha256`.

## Validators Run

- `cargo fmt`
- `CARGO_HOME=/private/tmp/octon-cargo-home-fs-snapshot CARGO_TARGET_DIR=/private/tmp/octon-cargo-target-fs-snapshot cargo test`
- `python3 -m json.tool .octon/framework/capabilities/runtime/services/interfaces/filesystem-snapshot/service.json`
- `CARGO_HOME=/private/tmp/octon-cargo-home-fs-snapshot CARGO_TARGET_DIR=/private/tmp/octon-fs-snapshot-component-target cargo component build --release --offline`
- `shasum -a 256 .octon/framework/capabilities/runtime/services/interfaces/filesystem-snapshot/service.wasm`
- `.octon/framework/engine/runtime/run validate`
- `.octon/framework/engine/runtime/run tool interfaces/filesystem-snapshot snapshot.build --json '{"root":".octon/framework/capabilities/runtime/services/interfaces/filesystem-snapshot/fixtures","state_dir":".octon/generated/.tmp/churn-fs-snapshot-test","set_current":true,"gc_max_snapshots":2}'`
- `.octon/framework/engine/runtime/run tool interfaces/filesystem-snapshot snapshot.build --json '{"root":".octon/framework/capabilities/runtime/services/interfaces/filesystem-snapshot/fixtures","state_dir":".octon/generated/.tmp/churn-fs-snapshot-test","set_current":true,"gc_max_snapshots":2,"protected_snapshot_ids":["snap-36f42c66a3253115"]}'`
- `.octon/framework/engine/runtime/run tool interfaces/filesystem-snapshot snapshot.build --json '{"root":".octon/framework/capabilities/runtime/services/interfaces/filesystem-snapshot/fixtures","state_dir":".octon/generated/.tmp/churn-fs-snapshot-test","set_current":true,"protected_snapshot_ids":["snap-deadbeef"]}'`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-state.sh`

## Live No-Op Evidence

- First and second fixture snapshot builds produced
  `snap-36f42c66a3253115`.
- File metadata under `.octon/generated/.tmp/churn-fs-snapshot-test` was
  unchanged after the second build: all files retained mtime `1783032215` and
  their original byte sizes.
- The second build reported `protected_snapshot_count: 1` and retained
  `protected_snapshot_ids: ["snap-36f42c66a3253115"]`.
- A missing protected snapshot failed closed with
  `ERR_FILESYSTEM_INTERFACES_SNAPSHOT_INVALID`.

## Exclusions

- No production filesystem snapshot output was pruned.
- No retained evidence was deleted.
- No generic generated/effective capability cleanup was performed.
- No host projection, source, input, archive, or optional retained-run-evidence
  behavior was changed.
