# Rollback Plan

Rollback is straightforward if the implementation is promoted correctly:

- Revert framework contract additions or mark them retired through compatibility retirement if already referenced.
- Revert instance self-evolution policies.
- Preserve `state/evidence/evolution/**` as historical retained evidence.
- Mark `state/control/evolution/**` entries as revoked/retired rather than deleting if live runs reference them.
- Remove generated evolution projections by regeneration.
- Archive proposal packet if rejected or superseded.
