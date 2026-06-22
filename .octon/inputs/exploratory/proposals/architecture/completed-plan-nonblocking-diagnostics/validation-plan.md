# Validation Plan

## Proposal Validators

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/completed-plan-nonblocking-diagnostics --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/completed-plan-nonblocking-diagnostics`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/completed-plan-nonblocking-diagnostics`

## Future Implementation Validators

- `cargo test -p kernel lifecycle_program::tests::completed_plan_hides_nonblocking_stale_receipt_details`
- `octon lifecycle plan --lifecycle proposal-program --target <archived-completed-fixture>`

## Negative Controls

- Verify the change fails closed when required evidence is missing or stale.
- Verify parent summaries cannot replace child-owned receipts.
- Verify generated outputs remain non-authoritative.
