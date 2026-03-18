# Step 2: Structure Migration

Apply structural changes to align with the v2 root-manifest and profile model.

## Actions

1. Create or confirm Packet 2 structural surfaces:
   - `inputs/additive/extensions/`
   - `inputs/additive/extensions/.archive/`
   - `instance/extensions.yml`
2. Remove legacy top-level portability keys from `octon.yml` and replace them
   with nested `topology`, `versioning.extensions`, and `zones` declarations.
3. Do not introduce partial compatibility aliases; migrate directly to the v2
   manifest shape.
4. Preserve the five class roots and avoid reintroducing legacy mixed-path
   top-level structure.

## Verification

- required Packet 2 files exist: `octon.yml`, `framework/manifest.yml`,
  `instance/manifest.yml`, `instance/extensions.yml`
- required Packet 2 directories exist: `inputs/additive/extensions/`
- no legacy top-level portability keys remain in `octon.yml`
