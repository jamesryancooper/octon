# Phase 3 Change Inventory

## Summary

- Added a dedicated `run-manifest-v1` contract and made `run-manifest.yml` the
  canonical bound run-manifest artifact.
- Reduced `runtime-state.yml` to mutable execution status and updated
  `handoff.yml` to point at the manifest, replay pointers, and evidence
  classification.
- Added `evidence-classification-v1` and encoded the packet’s Class A/B/C
  evidence model in seeded run bundles.
- Added external immutable replay index integration for the supported
  `release-and-boundary-sensitive` run class and exercised it in the wave4
  sample run.

## Canonical Run-Manifest Decision

- Adopted `/.octon/state/control/execution/runs/<run-id>/run-manifest.yml` as
  the canonical bound run-manifest model.
- Kept `runtime-state.yml` as mutable lifecycle status only.
- Updated run-contract schemas, runtime family metadata, policy/runtime docs,
  and seeded run contracts to point at `run-manifest.yml`.

## Evidence Classification Model

- Added `/.octon/framework/constitution/contracts/retention/evidence-classification-v1.schema.json`
- Updated retention doctrine to define:
  - `Class A` -> Git-inline authored disclosures, approvals, decisions, and
    summaries
  - `Class B` -> Git-pointer manifests and pointer/index artifacts
  - `Class C` -> External immutable replay and trace payloads
- Added canonical per-run evidence classification files:
  - `/.octon/state/evidence/runs/run-wave3-runtime-bridge-20260327/evidence-classification.yml`
  - `/.octon/state/evidence/runs/run-wave4-benchmark-evaluator-20260327/evidence-classification.yml`

## Replay And External Index Integration

- Updated replay manifests and replay pointers to separate:
  - in-repo replay manifests (`Class B`)
  - external immutable replay indexes (`Class C`)
- Added the canonical external replay index sample:
  - `/.octon/state/evidence/external-index/runs/run-wave4-benchmark-evaluator-20260327.yml`
- Bound the wave4 manifest, replay pointers, retained evidence manifest, and
  orchestration projection to that index.

## Validators And Enforcement

- Updated:
  - `/.octon/framework/orchestration/runtime/runs/_ops/scripts/validate-runs.sh`
  - `/.octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
  - `/.octon/framework/assurance/runtime/_ops/scripts/validate-runtime-lifecycle-normalization.sh`
  - `/.octon/framework/assurance/runtime/_ops/scripts/validate-execution-constitution-closeout.sh`
- Added:
  - `/.octon/framework/assurance/runtime/_ops/scripts/validate-unified-execution-phase3-runtime-evidence-normalization.sh`

## Phase 3 Exit Status

- Run state is resumable from artifacts: satisfied by `run-manifest.yml`,
  `runtime-state.yml`, `handoff.yml`, checkpoints, replay pointers, and
  retained evidence/classification references in both seeded runs.
- Evidence retention classes are enforced: satisfied by the retention family,
  disclosure-retention policy, per-run evidence classification files, and
  updated validators.
- Replay indexing works for supported run classes: satisfied by the
  `release-and-boundary-sensitive` wave4 sample run retaining an external
  immutable replay index and citing it from replay pointers and replay
  manifest artifacts.
