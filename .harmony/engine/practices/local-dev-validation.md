# Local Development Validation

## Required Local Checks

- `bash .harmony/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- `cargo check --manifest-path .harmony/engine/runtime/crates/Cargo.toml`

## Migration Checks

- Verify no legacy `/.harmony/runtime/` references remain.
- Verify engine governance and practice docs are updated with runtime changes.
