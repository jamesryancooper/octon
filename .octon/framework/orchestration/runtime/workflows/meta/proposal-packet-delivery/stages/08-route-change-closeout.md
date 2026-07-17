# Stage 08: Enforce Publication Containment

This is a read-only containment barrier. It never routes to Change closeout,
dirty-worktree closeout, a hosted provider, or a cleanup owner during SI-00.

Required checks:

- Admit only `target_outcome: implemented` or `target_outcome: archive-ready`
  with `route=stage-only` and a matching containment-bound profile.
- Reject `direct-main`, hosted `branch-no-pr`, `landed`, `synced`, `cleaned`,
  cleanup, and omitted/default effectful requests with
  `RP00_CONTAINMENT_PUBLICATION_DISABLED`.
- Preserve the exact candidate refs, worktrees, branch state, unrelated work,
  rollback handles, and retained evidence.
- Emit no Git, GitHub, provider, publication, final-sync, branch-cleanup,
  worktree-cleanup, or residue-deletion request.
- Name RP-06/RP-08 as the later owning route when an operator requests a
  publication or cleanup outcome.

Historical receipt values may be parsed by receipt-only compatibility
validators, but they cannot authorize this current request or satisfy this
stage.
