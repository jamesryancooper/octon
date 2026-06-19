# Acceptance Criteria

- Worktree residue is classified into publishable, cleanup-safe, protected, and
  manual-review buckets.
- Protected retained evidence is never deleted as branch cleanup.
- Cleanup-safe residue deletion requires explicit authorization.
- Classification output can block parent closeout when foreign or ambiguous
  paths remain.
- Parent evidence does not satisfy child cleanup receipts.
