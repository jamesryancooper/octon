# Implementation Plan

1. Enumerate recoverable blocker classes and their target-owned recovery routes.
2. Add current-fingerprint binding to closeout-worktree return evidence.
3. Add residue classification fields for owned, in-scope, retained evidence,
   generated/publication, foreign, ambiguous, and manual-review classes.
4. Rerun the blocked child or parent gate after recovery evidence is emitted.
5. Continue sequential lifecycle execution when the rerun gate passes.
6. Add negative controls for stale fingerprints, destructive cleanup without
   authority, and unpreservable residue.
