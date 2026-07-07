# Validation Plan

## Proposal Validators

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-loop-breaker --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-loop-breaker`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-loop-breaker`

## Future Implementation Validators

- `cargo test -p kernel lifecycle_program::tests::repeated_recovery_route_stops_on_unchanged_blocker_fingerprint`
- `validate-proposal-program-readiness-projection.sh --package <fixture-program>`
- `validate-proposal-lifecycle-terminal-freshness.sh --proposal <fixture-program> --targeted`
- `test-proposal-lifecycle-residue-fingerprint.sh`

## Negative Controls

- Unchanged blocker fingerprints do not permit another cleanup route.
- Changed blocker fingerprints permit only bounded retry.
- Parent summaries cannot reset child-owned blocker state.
- Generated outputs cannot authorize recovery.
