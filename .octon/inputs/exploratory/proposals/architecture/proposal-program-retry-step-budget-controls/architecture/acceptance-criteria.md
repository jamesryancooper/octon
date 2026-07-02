# Acceptance Criteria

- `octon lifecycle program retry --run-id <id> --max-steps <n>` is accepted by the CLI.
- Supplied retry `--max-steps` controls the retry attempt's bounded dispatch budget.
- Omitted retry options preserve current behavior and compatibility.
- Optional retry `--timeout-seconds` and `--max-child-concurrency` are either implemented with tests or explicitly deferred with no partial surface.
- Retry-time overrides cannot change run identity, lifecycle id, target, registry binding, or run inputs.
- Retry-time overrides cannot bypass cancellation, approval pauses, blocker states, worktree baseline checks, child dependency gates, or child-owned evidence gates.
- Documentation explains the new retry controls and the safe default posture.
- Regression tests cover default retry, explicit multi-step retry, child-filtered retry, and gate preservation.

