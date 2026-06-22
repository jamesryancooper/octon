# Validation Plan

## Proposal Validators

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/branch-no-pr-delivery-receipt-builder --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/branch-no-pr-delivery-receipt-builder`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/branch-no-pr-delivery-receipt-builder`

## Future Implementation Validators

- `test-branch-no-pr-delivery-receipt-builder.sh`
- `validate-change-closeout-state-machine.sh --receipt <receipt>`
- `validate-hosted-no-pr-landing.sh --receipt <receipt>`
- `validate-change-closeout-lifecycle-alignment.sh --receipt <receipt>`

## Negative Controls

- Verify the change fails closed when required evidence is missing or stale.
- Verify parent summaries cannot replace child-owned receipts.
- Verify generated outputs remain non-authoritative.
