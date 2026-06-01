# Implementation Plan

1. Extend or clarify lifecycle interaction contracts for child-batch handoff
   checkpoints.
2. Add scheduler checkpoints after child implementation and after promotion
   evidence convergence when route-created residue is present.
3. Require include/exclude path boundaries and returned evidence references.
4. Preserve `closeout-change` and `closeout-worktree` ownership.
5. Add tests proving handoff evidence does not authorize cleanup or Git
   mutation.
