# Validation Plan

## Proposal Validators

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-change-closeout-reconciliation --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-change-closeout-reconciliation`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-change-closeout-reconciliation`

## Future Implementation Validators

- `validate-change-closeout-lifecycle-alignment.sh --receipt <receipt>`
- `validate-hosted-no-pr-landing.sh --receipt <receipt>`

## Negative Controls

- Merge claims without Change closeout receipts fail.
- Local main sync claims without receipt evidence fail.
- Branch cleanup claims without receipt evidence fail.
- GitHub host state and chat narrative do not mint authority.
