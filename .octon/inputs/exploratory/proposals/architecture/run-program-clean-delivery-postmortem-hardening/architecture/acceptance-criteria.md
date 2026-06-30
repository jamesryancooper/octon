# Acceptance Criteria

- Stale parent architecture review receipts fail validation and route to the
  owning review refresh path.
- Parent lifecycle completion cannot be reported as clean delivery without a
  concrete Proposal Program Delivery receipt.
- Proposal Program Delivery clean outcomes require receipt, evidence index,
  terminal proof, worktree hygiene, final sync, and no open blockers.
- Change closeout can reconcile or explicitly downgrade manual landing,
  sync, cleanup, and branch deletion actions after an earlier branch-local
  receipt.
- Cleanup disposition distinguishes detected residue, protected residue,
  preserved residue, deletion authorization, and final terminal cleanliness.
- Aggregate clean-delivery validation runs disclosure-tier validation and
  rejects dirty worktree, final sync false, open blockers, missing receipt, and
  stale receipt evidence cases.
- Worktree hygiene tests do not modify tracked generated read models in the
  repository worktree.
- Parent program evidence never replaces child-owned receipts, child
  validation verdicts, child closeout evidence, child archive metadata, Change
  receipts, or terminal proof.
