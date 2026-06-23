# Validation Plan

## Proposal Validators

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-validator-runtime-resolver --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-validator-runtime-resolver`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-validator-runtime-resolver`

## Future Implementation Validators

- `cargo test -p kernel lifecycle_program::tests::validator_dispatch_uses_supported_bash_runtime`
- `validate-proposal-program-structure.sh --package <fixture-program>`
- `octon lifecycle plan --lifecycle proposal-program --target <fixture-program>`

## Negative Controls

- Verify the change fails closed when required evidence is missing or stale.
- Verify parent summaries cannot replace child-owned receipts.
- Verify generated outputs remain non-authoritative.
