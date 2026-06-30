# Extension Publication Handle v1

This contract defines the runtime-effective handle posture for extension
publication state.

## Covered surfaces

- `generated/effective/extensions/catalog.effective.yml`
- `generated/effective/extensions/generation.lock.yml`
- `state/control/extensions/active.yml`
- `state/control/extensions/quarantine.yml`

## Required checks

- generation id alignment between active state, catalog, and generation lock
- publication receipt linkage and digest
- desired-config and root-manifest digest linkage
- quarantine state respected by runtime routing
- compatibility receipt linkage retained but non-authoritative

## Runtime rule

Route-bundle authorization must fail closed when extension publication is not
published, when quarantine is non-empty, or when the generation lock or
receipt drifts.

Direct edits under `generated/effective/**`, raw additive input used as runtime
route authority, missing generation locks, or stale publication receipts map to
`SC-006-generated-freshness-drift` for proposal-program delivery diagnostics.
