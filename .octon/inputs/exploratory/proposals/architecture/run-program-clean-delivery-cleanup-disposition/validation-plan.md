# Validation Plan

## Proposal Validators

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-cleanup-disposition --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-cleanup-disposition`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-cleanup-disposition`

## Future Implementation Validators

- `classify-proposal-worktree-hygiene.sh --target <fixture-program> --lifecycle proposal-program`
- `validate-closeout-worktree-wrapper.sh --report <report>`
- `cleanup-local-run-artifacts.sh --dry-run`

## Negative Controls

- Detection without disposition does not authorize deletion.
- Protected state/control/evidence residue is not deleted by cleanup helpers.
- Foreign tracked changes route to preservation or escalation.
- Repeated cleanup preflight blockers do not cycle blindly.
