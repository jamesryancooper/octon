# Blocker Ledger And Recovery Delta Summaries

This is a child architecture proposal packet in the Token-Efficient Proposal Program Controller.

## Purpose

Replace repeated blocker history replay with stable blocker IDs, fingerprints, latest transitions, and bounded recovery deltas.

## Parent Program

Parent: `token-efficient-proposal-program-controller`

## Phase

`phase-3` / group `recovery`

## Non-Authority Statement

This child is a non-authoritative proposal input. It does not implement changes or authorize execution. Durable outputs must land in the declared promotion targets outside the proposal workspace.

## Model Route

Default route: deterministic aggregator; medium only on nonzero or conflicting blockers

Token ceiling: 2k for zero-blocker runs; 8k for nonzero-blocker recovery summary

Escalation trigger: blocker fingerprint drift, child authority boundary ambiguity, recovery loop repeats without progress

## Core Changes

- Emit blocker-ledger.yml with blocker_id, child_id, blocker class, latest transition, prior/current fingerprint, recovery budget, and evidence refs.
- Make recovery prompts read latest delta and failing slices instead of stale receipt/archive history.
- Preserve child-owned authority: parent ledger summarizes but never satisfies child receipts.
- Add progress fingerprinting to prevent repeated recovery loops.

## Validators

- blocker-ledger fingerprinting test
- aggregate-terminal-blockers deterministic zero-blocker test
- recovery loop no-progress negative control

## Governance

Parent blocker ledger is evidence index; child receipts remain authoritative for child outcomes.
