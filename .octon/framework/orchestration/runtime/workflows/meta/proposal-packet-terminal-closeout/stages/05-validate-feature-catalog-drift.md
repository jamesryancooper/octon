---
title: Validate Product Feature Catalog Drift
description: Require current feature catalog drift evidence before archive-ready.
---

# Step 5: Validate Product Feature Catalog Drift

## Consumed Evidence

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- product feature catalog validation output
- feature catalog drift receipt

## Produced Evidence

- State ledger entry `validate-feature-catalog-drift`.
- `feature-catalog-drift-receipt-v1` retained evidence.

## Actions

1. Run `validate-product-feature-catalog.sh`.
2. Emit or verify a current `feature-catalog-drift-receipt-v1` receipt.
3. Run
   `validate-feature-catalog-drift-closeout.sh --receipt <feature-catalog-drift-receipt>`.
4. Block `archive-ready` when unresolved missing catalog entries, missing
   feature notes, under-documented refs, status mismatches, stale refs,
   incorrect grouping, or other unresolved catalog obligations remain.

## Side Effect Class

Read-only validation plus retained evidence write.

## Re-Entry Condition

Re-enter when product feature catalog entries, feature notes, implementation
evidence, validation refs, or the feature catalog drift receipt changes.

## Stop Condition

Stop with `blocked` and next route `revise-product-feature-catalog` when the
drift receipt reports `blocked-unresolved-drift`.

## Authority Boundary

The drift receipt is evidence only. It does not rewrite product docs, authorize
catalog mutation, replace proposal-local implementation receipts, or widen
runtime/support authority. Generated outputs, raw inputs, host UI state,
chat/model memory, and tool availability remain non-authority.

## Receipt Fields

- `feature_catalog_drift.receipt_ref`
- `feature_catalog_drift.validator_ref`
- `feature_catalog_drift.fresh`
- `feature_catalog_drift.verdict`
- `feature_catalog_drift.outcome`
- `feature_catalog_drift.unresolved_count`
- `feature_catalog_drift.affected_feature_ids`
- `feature_catalog_drift.required_documentation_actions`
- `feature_catalog_drift.authority_notes`
- `state_ledger[].state_id: validate-feature-catalog-drift`
