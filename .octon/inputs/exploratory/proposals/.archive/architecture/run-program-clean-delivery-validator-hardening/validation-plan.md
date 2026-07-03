# Validation Plan

## Proposal Validators

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-validator-hardening --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-validator-hardening`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-validator-hardening`

## Future Implementation Validators

- `validate-run-program-clean-delivery.sh --receipt <receipt>`
- `validate-evidence-disclosure-tiers.sh --target <evidence-root>`
- `test-run-program-clean-delivery-validator.sh`

## Negative Controls

- Missing delivery receipt fails.
- Missing delivery evidence index fails.
- Open blockers fail.
- Stale disclosure validation fails.
- Dirty worktree and remote/local mismatch fail terminal proof.
