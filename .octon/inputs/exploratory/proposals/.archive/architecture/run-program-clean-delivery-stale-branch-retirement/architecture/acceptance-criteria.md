# Acceptance Criteria

- Stale local branches with no unique commits are retired automatically when
  current evidence proves no upstream-only state, open PR, protected status, or
  checked-out dependency remains.
- Checked-out dirty stale branches route through local-worktree retirement
  instead of stopping by default.
- Deletion receipts record stale ref, surviving ref, upstream/PR/protection
  checks, authorized switch/delete actions, and rollback notes.
- Cleanup reports name every retained local branch with role label, ref,
  unique-commit status, and retention or retirement reason.
- Branches with unique commits, protected status, unresolved upstream/PR state,
  or unpreservable dirty residue block before deletion.
