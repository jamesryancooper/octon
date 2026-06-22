# Validation Plan

## Proposal Validators

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/complete-program-blocker-vector-planner-output --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/complete-program-blocker-vector-planner-output`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/complete-program-blocker-vector-planner-output`

## Future Implementation Validators

- `cargo test -p kernel lifecycle_program::tests::program_blocker_vector_reports_all_scopes`
- `octon lifecycle plan --lifecycle proposal-program --target <fixture-program>`
- `validate-proposal-program-structure.sh --package <fixture-program>`

## Negative Controls

- Verify the change fails closed when required evidence is missing or stale.
- Verify parent summaries cannot replace child-owned receipts.
- Verify generated outputs remain non-authoritative.
