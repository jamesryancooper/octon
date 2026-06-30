# Stage 07: Route Change Closeout

Route the coherent Change through `closeout-change` or `closeout-worktree`.

Required checks:

- Branch-no-pr landing requires a materialized landing authorization receipt before hosted mutation.
- Git mutation preflight must pass before branch-local commit, push, hosted no-PR landing, sync, cleanup, or branch deletion; record typed blockers such as `git-index-write-denied` or `git-ref-write-denied` instead of retrying blindly.
- Dirty or stale source posture selects a route-owned clean worktree from current `origin/main`, with include-path classification before reconstruction, broad stage-all, staging, or commit.
- Handoff to `closeout-change` or `closeout-worktree` includes explicit include paths, exclude paths, route hints, target lifecycle outcome, validation floor, rollback posture, profile constraints, source receipt refs, retained readiness receipt ref, and blocker context.
- PR fallback is rejected when the profile forbids PR creation.
- Git mutation authority remains with Change closeout.
- Rollback handles are recorded before landing claims.
- Landing proof names the landed ref.
- Missing landing, branch, hosted, exception, or human approval emits `SC-004-approval-required`; unsafe Git state emits `SC-003-unsafe-mutation`.
