# Validation Plan

## Proposal Validators

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-ownership-baseline-and-leases --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-ownership-baseline-and-leases`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-ownership-baseline-and-leases`

## Future Implementation Validators

- `cargo test -p kernel lifecycle_program::tests::route_write_lease_blocks_foreign_path_mutation`
- `classify-proposal-worktree-hygiene.sh --target <fixture-program> --lifecycle proposal-program`
- `validate-proposal-program-child-readiness.sh --package <fixture-program>`
- `validate-proposal-program-readiness-projection.sh --package <fixture-program>`

## Negative Controls

- Missing lease blocks mutation.
- Stale lease blocks mutation.
- Foreign/manual path blocks mutation.
- Protected evidence path blocks mutation.
- Parent route lease cannot cover child-owned receipts.
