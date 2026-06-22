# Validation Plan

## Proposal Validators

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/batched-review-and-architecture-digest-refresh --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/batched-review-and-architecture-digest-refresh`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/batched-review-and-architecture-digest-refresh`

## Future Implementation Validators

- `test-batched-review-digest-refresh.sh`
- `validate-proposal-review-gate.sh --package <fixture> --require-implementation-authorization`
- `validate-architectural-review-receipts.sh --receipt <fixture>/support/pre-integration-architecture-review.yml --package <fixture> --mode pre-integration-architecture-review --require-pass`

## Negative Controls

- Verify the change fails closed when required evidence is missing or stale.
- Verify parent summaries cannot replace child-owned receipts.
- Verify generated outputs remain non-authoritative.
