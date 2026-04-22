# Tradeoff Analysis

## Why not re-found the architecture?

Re-foundation is not warranted. The current class-root, authority, generated,
run/mission, support, and extension models are strong. Replacing them would
increase risk without solving the real blockers.

## Why not leave the architecture as-is?

Current architecture is strong but not 10/10. The remaining gaps are not merely
cosmetic: enforcement coverage, support claim partitioning, proof maturity,
publication freshness, and complexity management determine whether the system is
operationally trustworthy.

## Why partition support artifacts physically?

Parsing route fields is not enough for target-state claim hygiene. Path placement
should make live/stage-only/unadmitted/retired state obvious before reading
content.

## Why keep `octon.yml` rather than split it completely?

The root manifest is the correct anchor for roots, profiles, and defaults. The
issue is load, not placement. Delegate bulky policy while keeping the manifest as
root resolver.

## Why not make generated architecture maps authoritative?

Generated maps improve legibility but would violate Octon's own architecture if
they became authority. They should be traceable, fresh, and useful, but never
canonical.

## Why not create a new proof control plane?

The existing evidence roots and proof planes are sufficient. The target state
needs closure artifacts and validators, not a new authority family.

## Why keep workflow compatibility wrappers temporarily?

They support migration, but they must remain explicitly compatibility-only and
must route through run-first lifecycle.
