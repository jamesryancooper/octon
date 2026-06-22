# Acceptance Criteria

- Repeated cleanup route selection stops when blocker fingerprint and cleanup evidence are unchanged.
- A changed blocker fingerprint permits one bounded retry.
- Publication drift routes before cleanup when drift explains the blocker.
- Token and attempt budgets are enforced before another recovery route is dispatched.
- Planner output records enough evidence to explain why the route continued, stopped, or changed.
- Negative controls prove parent summaries do not satisfy child-owned evidence or reset loop state.
