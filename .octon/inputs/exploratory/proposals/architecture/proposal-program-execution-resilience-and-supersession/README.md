# Proposal-Program Execution Resilience And Supersession

This parent proposal program turns the resilience contract into four staged, child-owned implementation tracks.

Core contract: a proposal-program run must either execute in a provably owned or leased surface, make progress only when blocker evidence changes, or safely supersede itself into a clean delivery path without losing child-owned evidence.

The parent is coordination lineage only. It does not implement durable lifecycle behavior, mutate validators, refresh generated outputs, authorize cleanup, authorize archive, authorize delivery, mutate Git refs, or claim a terminal delivery outcome.

## Child Packets

- `proposal-program-loop-breaker` - Add blocker fingerprints, repeated-route detection, cleanup terminality, publication-drift priority, and token or attempt caps.
- `proposal-program-ownership-baseline-and-leases` - Add start-of-run baseline, route write leases, isolated worktree gate, and deterministic owned or foreign classification.
- `proposal-program-supersession-rescue-path` - Add polluted-run freeze, deliverable partitioning, child-owned receipt carry-forward, and clean successor-run or Change closeout routing.
- `closeout-worktree-autonomous-partition-evidence` - Strengthen `closeout-worktree` to return non-mutating partition reports when ownership is provable.

## Program Boundary

The staged PR plan is deliberate. PR 1 addresses the immediate repeated cleanup-loop blocker. PRs 2 through 4 harden the ownership and rescue model without turning the whole design into one large implementation patch.
