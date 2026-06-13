---
title: Emit Terminal Receipt
description: Emit archive-ready or blocked terminal receipt without archive relocation.
---

# Step 10: Emit Terminal Receipt

## Consumed Evidence

- All prior state ledger entries.
- Profile, validator, publication, hygiene, review, Git/GitHub, and archive
  boundary evidence.

## Produced Evidence

- `proposal-packet-terminal-closeout-receipt-v1` under workflow evidence.
- Packet-local receipt projection at `support/proposal-terminal-closeout.yml`.
- State ledger entry `emit-terminal-receipt`.

## Actions

1. Build the aggregate terminal receipt from target-owned evidence refs.
2. Set `terminal_verdict: archive-ready` only when all required gates pass,
   retained evidence is current, hygiene is unblocked, and
   `blocker.class: none`.
3. Set `terminal_verdict: blocked` with exact blocker, failing evidence ref,
   and next canonical route when any gate fails.
4. Validate the receipt with
   `validate-proposal-packet-terminal-closeout-receipt.sh --receipt <receipt>`.
5. Do not move the packet into `.archive`.
6. Do not mutate `proposal.yml#status`.
7. Do not replace target-owned receipts.
8. When the receipt validates as `archive-ready`, report `archive-proposal` as
   the next canonical route; do not run it inside this workflow.

## Side Effect Class

Packet-local receipt projection and retained evidence write only.

## Re-Entry Condition

Re-enter when any cited evidence changes or receipt validation fails.

## Stop Condition

Stop with `blocked` when receipt validation fails or archive relocation is
attempted.

## Receipt Fields

- `terminal_verdict`
- `blocker`
- `archive_boundary.archive_owner_ref`
- `archive_boundary.relocation_performed: false`
- `target_owned_evidence_policy.aggregate_receipt_replaces_target_owned_receipts: false`
- `state_ledger[].state_id: emit-terminal-receipt`
