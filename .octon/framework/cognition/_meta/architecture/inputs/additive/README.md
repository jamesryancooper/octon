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
- Long-lived `.incoming/<intake-id>/` directories require an
  `intake-status.yml` marker until removed, archived, or normalized.

## Canonical Intake Layout

```text
inputs/additive/.incoming/<intake-id>/
  <downloaded or imported source artifacts>

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

## Governance

Incoming intake processing is governed by:

- `/.octon/framework/engine/governance/inputs/additive/incoming-intake-processing.md`

Extension-pack governance after normalization is governed by:

- `/.octon/framework/engine/governance/extensions/README.md`
