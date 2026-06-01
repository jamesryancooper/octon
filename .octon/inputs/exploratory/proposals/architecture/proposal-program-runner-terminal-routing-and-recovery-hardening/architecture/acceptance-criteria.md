# Acceptance Criteria

- Default `proposal-program` runs remain handoff-only.
- `--execute-routes` dispatches only through the shared lifecycle executor
  adapter.
- Workflow retries use attempt-safe canonical workflow run ids or explicit
  resume proof; duplicate workflow run-id collisions fail closed with retained
  evidence and do not loop.
- `closeout-change` and `closeout-worktree` are lifecycle interactions or
  declared route-owned handoffs, not runner-local cleanup or Git mutation.
- Parent controller evidence owns aggregate child terminal blocker ledgers;
  child receipts remain child-owned and parent route receipts consume but do
  not replace them.
- Promotion evidence paths are child-bound before `promote-proposal` workflow
  dispatch.
- Publication freshness blockers are classified before durable workflow
  dispatch when possible and route to canonical recovery guidance.
- Parent review refresh does not churn on irrelevant volatile run-control
  evidence.
- Archive workflow completion observes active-path moves or writes blocked
  archive evidence with route, run id, child id, blocker class, and next route.
- Tests cover the final duplicate workflow run-id failure, generated freshness
  drift, change handoff checkpoints, aggregate terminal blockers, promotion
  evidence binding, parent review freshness, archive observation, replay, and
  fail-closed authority boundaries.
