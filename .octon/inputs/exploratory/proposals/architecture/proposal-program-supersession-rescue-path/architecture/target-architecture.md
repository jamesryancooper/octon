# Target Architecture

Proposal-program runs can safely supersede themselves when the active run is polluted.

## Target Behavior

- Freeze the polluted run into a non-authorizing evidence bundle.
- Partition deliverable changes from foreign/manual residue and local-only runtime residue.
- Carry forward validated child-owned receipts by path and digest.
- Create a clean isolated successor run when continued lifecycle execution is still needed.
- Route deliverable changes to normal `closeout-change` or `closeout-worktree` when lifecycle execution is complete enough for closeout.
- Preserve foreign/manual residue with explicit disposition.

## Safety Properties

- Frozen polluted-run evidence cannot authorize mutation.
- Parent summaries cannot satisfy child-owned receipt requirements.
- Successor runs must bind current baseline, ownership classification, and carried evidence refs.
- Normal closeout remains owned by the Change closeout routes.
