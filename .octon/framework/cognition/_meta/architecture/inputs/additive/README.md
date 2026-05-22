# Additive Inputs

`inputs/additive/**` is the canonical raw-input surface for additive material
that may add Octon capability after governance, classification, validation, and
publication.

## Placement Rules

- Incoming intake units live only under
  `inputs/additive/.incoming/<intake-id>/` until classification.
- Retained rejected, superseded, historical, or quarantined intake units live
  under `inputs/additive/.archive/<intake-id>/` when the source material must
  remain available.
- Normalized extension packs live under
  `inputs/additive/extensions/<extension-pack-id>/` only after classification
  and normalization.
- Raw additive inputs are non-authoritative source material only.
- Runtime, policy, publication, generated, evidence, and host-projection
  consumers must never consume `.incoming/**`, `.archive/**`, or
  `extensions/**` as authority.
- New `.incoming/<intake-id>/` directories require an `intake.yml` envelope and
  `payload/` raw payload root. Legacy directories with `intake-status.yml`
  remain non-authoritative raw intake until separately migrated or disposed.

## Canonical Intake Layout

```text
inputs/additive/.incoming/<intake-id>/
  intake.yml
  payload/
  README.md

inputs/additive/.archive/<intake-id>/
  <post-decision retained intake copy>

inputs/additive/extensions/<extension-pack-id>/
  pack.yml
  README.md
  skills/
  commands/
  templates/
  prompts/
  context/
  validation/
```

`intake.yml` and `payload/` are required for the current incoming intake
contract. `README.md` is optional non-authoritative human context. No other
top-level entries are allowed in new intake units; raw payload must be below
`payload/`.

## Incoming Envelope

The incoming envelope uses:

- `schema_version: octon-additive-incoming-intake-unit-v1`
- `intake_id` matching the directory name
- `authority_mode: non_authoritative`
- `status`
- `staged_at`
- `submitted_by.type` and `submitted_by.name`
- `reason`
- `next_step`
- `route_hint`
- `payload.root: payload/`
- `payload.form`
- `provenance.status`, `provenance.origin_class`,
  `provenance.imported_from`, `provenance.origin_uri`,
  `provenance.source_digest_sha256`, and `provenance.attestation_refs`
- `risk.contains_executable`, `risk.contains_binary`,
  `risk.contains_secret_or_private_data`, `risk.redistribution_risk`, and
  `risk.size_class`

`<intake-id>` must match `^[a-z][a-z0-9]*(-[a-z0-9]+)*$`, match the envelope,
contain no path separators or dot segments, and avoid reserved Octon surface
names such as `.incoming`, `.archive`, `payload`, `generated`, `state`,
`runtime`, `extensions`, `policy`, `publication`, and `evidence`.

Schema:

- `/.octon/framework/cognition/_meta/architecture/inputs/additive/schemas/incoming-intake-unit.schema.json`

## Validation Boundary

Hard validator failures cover invalid path/id posture, missing or malformed
`intake.yml`, mismatched ids, invalid required fields, invalid enums or digest
format, missing or empty `payload/`, unexpected top-level raw payload, nested
`.incoming` or `.archive` roots, unsafe path controls, symlink or hardlink
escapes, and forbidden authority/projection staging.

Classification findings, not hard shape failures, cover missing or unverified
provenance, opaque binaries, executables, secrets/private data, proprietary or
redistribution risk, oversized payloads, candidate extension packs, candidate
core skills, and ambiguous routes. Those findings may block promotion or
require proposal-backed disposition, but they do not make a contained raw
intake unit look normalized or authoritative.

## Governance

Incoming intake processing is governed by:

- `/.octon/framework/engine/governance/inputs/additive/incoming-intake-processing.md`

Extension-pack governance after normalization is governed by:

- `/.octon/framework/engine/governance/extensions/README.md`
