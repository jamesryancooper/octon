---
title: Verify Durable Implementation State
description: Confirm durable implementation evidence and adjacent validators before terminal claims.
---

# Step 2: Verify Durable Implementation State

## Consumed Evidence

- Bound profile.
- Proposal manifest and promotion targets.
- Implementation run receipt.

## Produced Evidence

- Durable implementation state evidence refs.
- State ledger entry `verify-durable-implementation-state`.

## Actions

1. Confirm the packet is an implemented proposal packet or block with exact
   next route `promote-proposal`.
2. Confirm declared promotion targets exist or have explicit not-applicable
   rationale in implementation evidence.
3. Run target-family validators selected by the profile, including generated
   and input non-authority, run-health, capability publication, extension
   publication, closeout-worktree alignment, default-work-unit alignment,
   change-closeout alignment, Git/GitHub exact-SHA route validation, and
   hosted-no-PR validation when applicable.
4. Record every validator command and evidence ref.

## Side Effect Class

Read-only validation plus retained evidence write.

## Re-Entry Condition

Re-enter when promotion targets, validator selection, or implementation
evidence changes.

## Stop Condition

Stop with `blocked` when durable implementation state is missing, stale, or
outside declared target scope.

## Receipt Fields

- `durable_implementation_state_evidence_refs`
- `generated_input_non_authority.validation_ref`
- `run_health.validation_ref`
- `capability_publication.validation_ref`
- `extension_publication.validation_ref`
- `state_ledger[].state_id: verify-durable-implementation-state`
