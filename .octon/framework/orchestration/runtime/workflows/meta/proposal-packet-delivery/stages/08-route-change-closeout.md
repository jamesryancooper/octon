# Stage 08: Route Change Closeout

Route the coherent Change through `closeout-change` or `closeout-worktree`.

Required checks:

- Branch-no-pr landing requires a materialized landing authorization receipt
  before hosted mutation.
- PR fallback is rejected when the profile forbids PR creation.
- Git mutation authority remains with Change closeout.
- Rollback handles are recorded before landing claims.
- Landing proof names the landed ref.
