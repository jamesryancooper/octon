---
title: Bind Terminal Profile
description: Bind packet path, requested outcome, route posture, evidence expectations, validators, and forbidden authority requests.
---

# Step 1: Bind Terminal Profile

## Consumed Evidence

- `proposal_path`
- optional `profile_path`
- proposal `proposal.yml`

## Produced Evidence

- Bound profile under workflow evidence.
- State ledger entry `bind-profile`.

## Actions

1. Resolve `proposal_path` and requested `target_outcome`.
2. Require `target_outcome` to be `archive-ready` or `blocked`.
3. Validate any supplied profile with
   `validate-proposal-packet-terminal-closeout-profile.sh --profile <profile>`.
4. Reject profile requests for archive relocation, proposal status mutation,
   direct generated publication, Git mutation, residue deletion, host state
   authority, chat authority, tool authority, or model-memory authority.

## Side Effect Class

Evidence write only.

## Re-Entry Condition

Re-enter when the profile changes, packet path changes, or target outcome
changes.

## Stop Condition

Stop with `blocked` when the profile is invalid or requests forbidden
authority.

## Receipt Fields

- `profile.profile_ref`
- `profile.profile_digest`
- `profile.profile_validation_evidence_ref`
- `state_ledger[].state_id: bind-profile`
