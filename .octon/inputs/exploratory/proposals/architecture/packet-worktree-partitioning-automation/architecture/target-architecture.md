# Target Architecture

Proposal-packet closeout can inspect worktree residue and classify paths into
publishable evidence, cleanup-safe residue, protected retained evidence, and
manual-review buckets.

Classification does not authorize deletion by itself. Cleanup remains governed
by explicit cleanup authorization receipts and must preserve protected retained
evidence, active control state, build-to-delete evidence, and manual-review
artifacts.
