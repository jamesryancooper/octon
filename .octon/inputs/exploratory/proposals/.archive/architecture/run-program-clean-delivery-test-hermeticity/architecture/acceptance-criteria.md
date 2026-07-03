# Acceptance Criteria

- `test-classify-proposal-worktree-hygiene.sh` passes without modifying tracked generated run-health projections.
- `test-run-health-read-model.sh` passes with temporary or fixture-owned output locations.
- `generate-run-health-read-model.sh` remains covered by meaningful generator tests.
- Post-test `git status --short -- .octon/generated/cognition/projections/materialized/runs` is empty when starting from a clean generated projection state.
- Tests do not delete, reset, or mask unrelated generated state.
