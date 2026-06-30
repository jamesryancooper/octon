# Acceptance Criteria

- `validate-run-program-clean-delivery.sh` passes in static mode when the
  clean-delivery validator chain is present and each composed static validator
  passes.
- `validate-run-program-clean-delivery.sh --receipt <receipt>` passes only for
  a valid `proposal-program-delivery-receipt-v1` with `actual_outcome:
  cleaned`, fresh terminal proof, clean worktree hygiene, final sync equality,
  no open blockers, and target-owned receipt preservation.
- `test-run-program-clean-delivery-validator.sh` proves one success fixture and
  rejects non-cleaned outcome, stale terminal proof, and aggregate evidence
  substitution.
- Tests do not require network, hosted mutation, Git mutation, archive,
  cleanup, branch cleanup, generated publication, or terminal proof synthesis.
- The validator is read-only and does not mutate files or refs.
