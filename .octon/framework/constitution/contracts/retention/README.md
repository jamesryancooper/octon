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
- `evidence-retention-contract-v1.schema.json`
- `evidence-classification-v1.schema.json`
- `evidence-disclosure-tiers-v1.yml`
- `publishable-evidence-receipt-v1.schema.json`
- `external-replay-index-v1.schema.json`
- `replay-storage-class-v1.schema.json`

## Evidence Disclosure Tier Gates

`validate-evidence-disclosure-tiers.sh` enforces the disclosure-tier boundary:

- tracked files under `.octon/state/evidence/local/**` fail except convention
  marker files such as `README.md`
- publishable receipts must declare `disclosure_tier`, required provenance,
  redaction, limitation, local evidence digest, authority-boundary, and
  concision fields
- publishable receipts warn above 64 KiB and fail above 256 KiB unless
  `concision.size_exception_authorized` includes an exception reference
- hosted/shared closeout receipts fail when validation evidence depends
  directly on local-only evidence, generated outputs, or input/proposal paths

Remediation is to summarize, redact, or digest local raw evidence into a
repo-publishable receipt under a retained evidence root, then cite that
publishable receipt from closeout or disclosure material. Generated read models
may point to retained evidence for operator context, but they do not satisfy
evidence, closeout, archive, runtime, or support gates.
