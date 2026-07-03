# Validation Plan

## Proposal Validators

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-delivery-receipt-completion --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-delivery-receipt-completion`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-delivery-receipt-completion`

## Future Implementation Validators

- `validate-proposal-program-delivery-receipt.sh --receipt <receipt>`
- `validate-proposal-program-delivery-evidence-index.sh --index <index>`
- `validate-run-program-clean-delivery.sh --receipt <receipt>`

## Negative Controls

- Missing delivery receipts fail.
- Incomplete evidence indexes fail.
- Parent delivery summaries cannot replace child-owned receipts.
- Generated projections cannot substitute for retained delivery evidence.
