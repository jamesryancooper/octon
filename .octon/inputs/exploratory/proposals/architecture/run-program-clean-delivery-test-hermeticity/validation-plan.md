# Validation Plan

## Proposal Validators

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-test-hermeticity --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-test-hermeticity`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-test-hermeticity`

## Future Implementation Validators

- `test-classify-proposal-worktree-hygiene.sh`
- `test-run-health-read-model.sh`
- `git status --short -- .octon/generated/cognition/projections/materialized/runs`

## Negative Controls

- Test execution does not write tracked generated health files.
- Tests do not delete or reset generated state to hide dirty output.
- Generator coverage remains behavior-proving with temporary or fixture-owned outputs.
- Generated projections remain derived-only and non-authoritative.
