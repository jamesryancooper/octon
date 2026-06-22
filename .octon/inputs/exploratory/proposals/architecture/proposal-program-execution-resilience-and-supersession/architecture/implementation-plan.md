# Implementation Plan

Implement the program as four staged PRs, each backed by its child packet and its own validation receipts.

## PR 1: Loop Breaker

Child packet: `proposal-program-loop-breaker`.

Implement stable blocker fingerprints, repeated-route detection, cleanup terminality, publication-drift priority, and token or attempt caps. This PR addresses the immediate cleanup-loop failure mode while preserving existing child ownership and route authority.

## PR 2: Ownership Baseline And Leases

Child packet: `proposal-program-ownership-baseline-and-leases`.

Implement start-of-run baseline capture, route write leases, isolated worktree gating, and deterministic owned/foreign classification. This PR gives later rescue routing a provable surface model before mutation.

## PR 3: Supersession/Rescue Path

Child packet: `proposal-program-supersession-rescue-path`.

Implement polluted-run freeze, deliverable partitioning, child-owned receipt carry-forward, and clean successor-run or normal Change closeout routing. This PR handles polluted parent runs without losing validated child evidence.

## PR 4: Autonomous Partition Evidence

Child packet: `closeout-worktree-autonomous-partition-evidence`.

Strengthen `closeout-worktree` to return non-mutating partition reports when ownership is provable. This PR makes parent lifecycle recovery able to consume partition evidence without granting cleanup, archive, delivery, branch, or child-closeout authority.

## Integration Order

1. Land PR 1 first because it breaks repeated cleanup loops.
2. Land PR 2 before rescue behavior so leased and foreign surfaces are classified before mutation.
3. Land PR 3 after ownership classification is available.
4. Land PR 4 after the lifecycle can request and consume non-mutating partition evidence.

Each child implementation must update its own durable targets, validators, fixtures, and receipts. The parent remains a coordination packet and cannot replace child-owned evidence.
