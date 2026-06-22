# Validation Plan

## Proposal Validators

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/delivery-retained-evidence-index --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/delivery-retained-evidence-index`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/delivery-retained-evidence-index`

## Future Implementation Validators

- `validate-proposal-program-delivery-evidence-index.sh --index <index>`
- `test-proposal-program-delivery-evidence-index.sh`
- `validate-proposal-program-delivery-receipt.sh --receipt <receipt>`

## Negative Controls

- Verify the change fails closed when required evidence is missing or stale.
- Verify parent summaries cannot replace child-owned receipts.
- Verify generated outputs remain non-authoritative.
