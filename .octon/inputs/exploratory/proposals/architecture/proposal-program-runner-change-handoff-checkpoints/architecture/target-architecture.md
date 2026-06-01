# Target Architecture

The proposal-program controller can emit non-authorizing lifecycle interaction
handoffs to `closeout-change` or `closeout-worktree` after mutating child
routes or batches. The handoff requests evidence and partitioning only. It
does not authorize Git mutation, cleanup deletion, publication, promotion, or
archive.
