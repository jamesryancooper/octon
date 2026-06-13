---
title: Verify Post-Implementation Drift
description: Require current drift/churn evidence before terminal readiness.
---

# Step 4: Verify Post-Implementation Drift

## Consumed Evidence

- `support/post-implementation-drift-churn-review.md`
- post-implementation drift validator output

## Produced Evidence

- State ledger entry `verify-post-implementation-drift`.

## Actions

1. Require a current `support/post-implementation-drift-churn-review.md`
   receipt.
2. Run
   `validate-proposal-post-implementation-drift.sh --package <proposal_path>`.
3. Block if the receipt is absent, stale, failing, or has unresolved items.

## Side Effect Class

Read-only validation plus retained evidence write.

## Re-Entry Condition

Re-enter when drift/churn receipt, implementation evidence, or validator output
changes.

## Stop Condition

Stop with `blocked` and next route `run-packet-verification-and-correction-loop`
when post-implementation drift fails.

## Receipt Fields

- `implementation.post_implementation_drift_receipt_ref`
- `implementation.post_implementation_drift_validator_ref`
- `implementation.post_implementation_drift_fresh`
- `state_ledger[].state_id: verify-post-implementation-drift`
