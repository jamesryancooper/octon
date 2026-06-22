# Acceptance Criteria

- Planner returns a blocker vector containing parent, child, generated artifact, worktree hygiene, lifecycle tooling, git delivery, and authorization scopes when present.
- Diagnostics that cannot block any next route are separated from actionable blockers.
- Route-ready states remain clear and are not mixed with stale nonblocking details.

## Safety Acceptance

- No parent evidence replaces child-owned evidence.
- No PR fallback is introduced.
- No protected retained evidence is deleted.
- No generated output is hand-edited.
