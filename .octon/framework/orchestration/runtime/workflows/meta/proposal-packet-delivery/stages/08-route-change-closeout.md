# Stage 08: Route Change Closeout

Route the coherent Change through `closeout-change` or `closeout-worktree`.

Required checks:

- Already-archived packets with fresh archive evidence route to
  `closeout-change` or `closeout-worktree` for hosted landing, final sync,
  branch cleanup authorization, terminal current-state proof, and worktree
  hygiene.
- Branch-no-pr landing requires a materialized landing authorization receipt
  before hosted mutation.
- PR fallback is rejected when the profile forbids PR creation.
- Git mutation authority remains with Change closeout.
- Partition-clean archive readiness evidence from prior stages is preserved as
  evidence only; `closeout-change` remains the owner of commit, push, hosted
  no-PR landing, final sync, rollback handle, branch cleanup authorization,
  terminal current-state proof, and the final `cleaned` claim.
- Rollback handles are recorded before landing claims.
- Landing proof names the landed ref.
- Terminal proof is retained by `closeout-change` after landing, final sync,
  cleanup authorization, cleanup disposition, rollback posture, and validation
  proof exist.
- Terminal proof does not require a source-branch commit after landing and
  does not mutate `origin/main`, local `main`, the landed ref, or the source
  branch.
