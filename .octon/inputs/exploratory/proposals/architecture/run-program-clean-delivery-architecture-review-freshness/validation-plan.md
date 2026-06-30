# Validation Plan

## Proposal Validators

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture-review-freshness --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture-review-freshness`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture-review-freshness`

## Future Implementation Validators

- `validate-architectural-review-receipts.sh --receipt <receipt> --package <packet> --require-pass`
- `validate-proposal-review-gate.sh --package <packet> --require-accepted`
- `cargo test -p octon_kernel review_packet_completion_requires_fresh_accepted_architecture_review_receipt`

## Negative Controls

- Stale `packet_digest` receipts fail.
- Missing architecture-review receipts fail.
- Parent lifecycle summaries cannot satisfy child-owned architecture-review receipt requirements.
- Generated outputs cannot authorize review acceptance.
