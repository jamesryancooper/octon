---
title: Verify Implementation Conformance
description: Require current implementation conformance before terminal readiness.
---

# Step 3: Verify Implementation Conformance

## Consumed Evidence

- `support/implementation-conformance-review.md`
- implementation conformance validator output

## Produced Evidence

- State ledger entry `verify-implementation-conformance`.

## Actions

1. Require a current `support/implementation-conformance-review.md` receipt.
2. Run
   `validate-proposal-implementation-conformance.sh --package <proposal_path>`.
3. Block if the receipt is absent, stale, failing, or has unresolved items.

## Side Effect Class

Read-only validation plus retained evidence write.

## Re-Entry Condition

Re-enter when conformance receipt, implementation evidence, or validator output
changes.

## Stop Condition

Stop with `blocked` and next route `run-packet-implementation` or
`run-packet-verification-and-correction-loop` when conformance is missing or
fails.

## Receipt Fields

- `implementation.conformance_receipt_ref`
- `implementation.conformance_validator_ref`
- `implementation.conformance_fresh`
- `state_ledger[].state_id: verify-implementation-conformance`
