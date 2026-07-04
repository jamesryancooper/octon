# Implementation Plan

1. Add branch role labels: source-dirty-anchor,
   route-owned-delivery-branch, correction, cleanup, retained-protected, and
   retired-stale.
2. Add retireability checks for no unique commits, upstream state, local remote
   refs, protected naming/status, open PR references, and checked-out state.
3. Integrate dirty checked-out branch handling with local-worktree retirement.
4. Emit branch-retirement authorization before switching or deleting.
5. Verify branch deletion, surviving branch alignment, and retained residue.
6. Add fixtures for safe retirement and every blocked case.
