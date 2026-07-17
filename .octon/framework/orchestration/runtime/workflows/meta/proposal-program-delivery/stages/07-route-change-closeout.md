# Stage 07: Enforce Publication Containment

This read-only barrier does not route program work to `closeout-change`,
`closeout-worktree`, a hosted provider, or a cleanup route during SI-00.

Required checks:

- Admit only `implemented` or `archive-ready` with `route=stage-only`.
- Reject direct-main, hosted branch-no-PR landing, `landed`, `synced`,
  `cleaned`, cleanup, and omitted/default effectful requests with
  `RP00_CONTAINMENT_PUBLICATION_DISABLED`.
- Preserve exact child and parent candidate refs, worktrees, rollback handles,
  include/exclude classifications, and unrelated work.
- Do not dispatch Git, provider, publication, final-sync, cleanup, branch
  deletion, or residue deletion operations.
- Report RP-06/RP-08 as the later owner for publication or cleanup requests.
