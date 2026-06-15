# Stage 07: Validate Cleanup, Sync, And Terminal Proof

Validate branch cleanup, repo hygiene cleanup, final sync, terminal current-state proof, and worktree hygiene after the last mutation.

Required checks:

- Branch cleanup requires branch cleanup authorization.
- Repo hygiene deletion requires cleanup authorization and uses `repo-hygiene-cleanup`.
- Local `main`, `origin/main`, and `landed_ref` equality is proven before `synced`.
- Terminal current-state proof is fresh after the final mutation.
- `cleaned` is rejected when the worktree is dirty.
