# Constitutional Retention Contracts

`/.octon/framework/constitution/contracts/retention/**` defines the active
retention, replay, and externalized-evidence lifecycle model for governed
execution.

## Status

The retention family is active.

- per-run evidence classification lives under:
  `/.octon/state/evidence/runs/<run-id>/evidence-classification.yml`
- run continuity remains mutable under `/.octon/state/continuity/runs/**`
- retained run and control evidence remain append-oriented under:
  `/.octon/state/evidence/{runs/**,control/execution/**}`
- replay-heavy or externally retained immutable payloads are indexed under:
  `/.octon/state/evidence/external-index/**`

## Storage Classes

- `git-inline`: retained directly under canonical in-repo evidence roots
- `git-pointer`: canonical run evidence stores a stable in-repo pointer to
  another retained artifact family
- `external-immutable`: canonical run evidence stores a content-addressed
  pointer to an immutable payload outside the Git tree, with the lookup index
  retained under `state/evidence/external-index/**`

## Packet Evidence Classes

- `Class A`: Git-inline authored disclosures, approvals, decisions, and summary
  artifacts
- `Class B`: Git-pointer manifests and pointer files that locate replayable
  evidence
- `Class C`: External immutable payloads indexed from the Git tree by digest

## Canonical Files

- `family.yml`
- `evidence-classification-v1.schema.json`
- `external-replay-index-v1.schema.json`
- `replay-storage-class-v1.schema.json`
