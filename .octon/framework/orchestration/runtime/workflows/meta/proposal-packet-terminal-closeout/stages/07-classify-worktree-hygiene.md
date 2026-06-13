---
title: Classify Worktree Hygiene
description: Block archive-ready when foreign or ambiguous worktree residue remains.
---

# Step 7: Classify Worktree Hygiene

## Consumed Evidence

- Repo-hygiene classification evidence.
- Current worktree status.

## Produced Evidence

- Worktree hygiene classification evidence.
- State ledger entry `classify-worktree-hygiene`.

## Actions

1. Run proposal worktree hygiene classification for the target packet.
2. Record owned, in-scope, and foreign-or-ambiguous counts.
3. Block `archive-ready` when foreign or ambiguous residue remains.
4. Route non-packet residue to `closeout-worktree` or `closeout-change`.

## Side Effect Class

Read-only classification plus retained evidence write.

## Re-Entry Condition

Re-enter when worktree status changes or closeout-route return evidence
appears.

## Stop Condition

Stop with `blocked` and next route `closeout-worktree` or `closeout-change`
when worktree hygiene is blocked.

## Receipt Fields

- `worktree_hygiene.classification_ref`
- `worktree_hygiene.verdict`
- `worktree_hygiene.foreign_or_ambiguous_count`
- `worktree_hygiene.dirty_worktree`
- `state_ledger[].state_id: classify-worktree-hygiene`
