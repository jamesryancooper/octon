# Validation Plan

## Proposal Validators

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/branch-no-pr-bounded-authorization-envelope --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/branch-no-pr-bounded-authorization-envelope`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/branch-no-pr-bounded-authorization-envelope`

## Future Implementation Validators

- `validate-branch-no-pr-delivery-authorization-envelope.sh --envelope <envelope>`
- `test-branch-no-pr-bounded-authorization-envelope.sh`
- `validate-proposal-program-delivery-workflow.sh`
- `validate-proposal-program-delivery-receipt.sh --receipt <receipt>`

## Negative Controls

- Verify the change fails closed when required evidence is missing or stale.
- Verify parent summaries cannot replace child-owned receipts.
- Verify generated outputs remain non-authoritative.
