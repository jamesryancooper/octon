---
title: Closeout Worktree Checkpoints
---

# Checkpoints

Record a wrapper checkpoint before every delegated singular closeout:

- current branch and HEAD;
- worktree inventory command refs;
- residue classification ref;
- candidate partition table;
- selected candidate id and include/exclude paths;
- retained, deferred, blocked, ambiguous, and foreign items;
- route and target outcome hints passed to `closeout-change`;
- rollback or discard posture for the selected candidate.

Record a checkpoint after every delegated singular closeout:

- actual outcome reported by `closeout-change`;
- Change receipt or blocker ref;
- validation evidence or blocker;
- cleanup disposition;
- re-inventory ref;
- re-classification ref;
- next candidate or stop reason.

The wrapper is resumable only from retained checkpoints that preserve the
candidate partition, the latest re-inventory and re-classification evidence,
and the final disposition already assigned to each processed candidate.
