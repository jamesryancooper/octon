# Implementation Plan

1. Update `closeout-worktree` and `repo-hygiene-cleanup` guidance to use
   proposal lifecycle worktree partitioning.
2. Update worktree hygiene classification to distinguish publishable,
   cleanup-safe, protected, and manual-review paths.
3. Keep cleanup helper behavior dry-run by default with explicit authorization
   for deletion.
4. Add fixtures for protected evidence, local run residue, and cleanup-safe
   generated residue.
5. Record child-owned implementation, conformance, drift/churn, validation, and
   rollback evidence before promotion.
