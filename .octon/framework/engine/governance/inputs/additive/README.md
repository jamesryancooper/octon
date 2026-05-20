# Additive Input Governance

This surface governs additive input material before it becomes normalized,
published, or projected Octon capability.

## Canonical Rules

- Incoming intake units live only under
  `inputs/additive/.incoming/<intake-id>/` until classification.
- Retained intake copies live only under
  `inputs/additive/.archive/<intake-id>/` when retention is safe, justified, and
  evidenced.
- Normalized extension packs live only under
  `inputs/additive/extensions/<pack-id>/` after classification and
  normalization.
- Raw additive intake and archive copies are non-authoritative source material.
- Runtime, policy, generated, state/control, publication, and host-projection
  consumers must never consume `.incoming/**` or `.archive/**` as authority.

## Subcontracts

- `incoming-intake-processing.md`
