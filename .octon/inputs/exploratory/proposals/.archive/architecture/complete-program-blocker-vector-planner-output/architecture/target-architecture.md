# Target Architecture

Produce a complete blocker vector before mutation and distinguish blockers, diagnostics, and route-ready state.

## Target Behavior

- Planner returns a blocker vector containing parent, child, generated artifact, worktree hygiene, lifecycle tooling, git delivery, and authorization scopes when present.
- Diagnostics that cannot block any next route are separated from actionable blockers.
- Route-ready states remain clear and are not mixed with stale nonblocking details.

## Safety Properties

- Child authority is preserved.
- Parent summaries cannot satisfy child-owned evidence.
- Generated outputs remain derived-only and non-authoritative.
- Material side effects remain explicitly authorization-gated.
- PR fallback remains forbidden where branch-no-PR delivery is in scope.
