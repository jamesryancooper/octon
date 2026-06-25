# Stage 06: Route Change Closeout

Route the coherent Change through `closeout-change` or `closeout-worktree`.

Required checks:

- Branch-no-pr landing requires a materialized landing authorization receipt before hosted mutation.
- Git mutation preflight must pass before branch-local commit, push, hosted no-PR landing, sync, cleanup, or branch deletion; record typed blockers such as `git-index-write-denied` or `git-ref-write-denied` instead of retrying blindly.
- PR fallback is rejected when the profile forbids PR creation.
- Git mutation authority remains with Change closeout.
- Rollback handles are recorded before landing claims.
- Landing proof names the landed ref.
