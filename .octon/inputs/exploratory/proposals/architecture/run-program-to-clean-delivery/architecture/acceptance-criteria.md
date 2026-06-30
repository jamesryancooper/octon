# Acceptance Criteria

- A governed proposal program can proceed through child review/revise,
  implementation, verification/correction, promotion/status correction, child
  closeout, parent closeout, archive readiness, Change delivery, branch
  cleanup, terminal proof, and final clean-state validation with minimal
  operator intervention.
- Route-owned retries and corrections happen automatically when policy allows.
- Stale route-owned receipts and generated proposal metadata refresh
  automatically at stable digest boundaries.
- Parent and child authority preservation is validated.
- Branch-no-pr delivery writes publishable landing and cleanup evidence before
  local terminal proof is synthesized.
- Final validation proves `HEAD`, `main`, and `origin/main` alignment; no
  staged, unstaged, untracked, publishable, foreign, or ambiguous residue; a
  valid terminal proof; and `git_clean_terminal`.
- Automation stops only for true authority, safety, ownership, external
  approval, or validation blockers.
