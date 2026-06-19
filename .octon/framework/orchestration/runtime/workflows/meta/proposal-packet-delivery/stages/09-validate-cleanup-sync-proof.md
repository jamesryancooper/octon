# Stage 09: Validate Cleanup, Sync, And Terminal Proof

Validate branch cleanup, repo hygiene cleanup, final sync, terminal current-state
proof, and worktree hygiene after the last mutation.

Required checks:

- Branch cleanup requires branch cleanup authorization.
- Repo hygiene deletion requires cleanup authorization and uses
  `repo-hygiene-cleanup`.
- Local `main`, `origin/main`, and `landed_ref` equality is proven before
  `synced`.
- Terminal current-state proof is fresh after the final mutation.
- Terminal proof is emitted only after landing evidence, final sync proof,
  cleanup authorization, cleanup disposition, rollback posture, and validation
  proof exist.
- Terminal proof records `landed_ref` separately from the proof sink or
  receipt path.
- Missing terminal proof prerequisites downgrade the actual outcome and block
  terminal success or `cleaned`.
- Terminal proof must not require a source-branch commit after landing and
  must not mutate `origin/main`, local `main`, the landed ref, or the source
  branch.
- `cleaned` is rejected when the worktree is dirty.
