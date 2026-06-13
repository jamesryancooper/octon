---
title: Validate Publication Freshness
description: Validate touched publication families and delegate repair only to canonical publishers.
---

# Step 5: Validate Publication Freshness

## Consumed Evidence

- Bound profile validator-family map.
- Generated publication and freshness validator outputs.

## Produced Evidence

- Publication freshness validator refs.
- Publisher refresh receipt refs when a canonical publisher is invoked.
- State ledger entry `validate-publication-freshness`.

## Actions

1. Run the profile-selected publication freshness validators.
2. If a freshness validator fails, identify the owning canonical publisher.
3. Invoke only the owning publisher when repair is allowed.
4. Rerun the failed validator and adjacent projection validators.
5. Block if repair would require direct generated/effective output edits or an
   unknown publisher.

The minimum adjacent publication validators are:

- `validate-generated-non-authority.sh`
- `validate-run-health-read-model.sh`
- `validate-capability-publication-state.sh`
- `validate-extension-publication-state.sh`

## Side Effect Class

Read-only validation plus retained evidence write. Canonical publisher
invocation is delegated and must retain its own publication receipt.

## Re-Entry Condition

Re-enter when generated projections, publisher receipts, or target family
selection changes.

## Stop Condition

Stop with `blocked` and next route `blocked` when publication freshness cannot
be repaired through an owning publisher.

## Receipt Fields

- `publication_freshness.validators`
- `publication_freshness.publisher_refresh_receipts`
- `publication_freshness.rerun_evidence_refs`
- `publication_freshness.direct_generated_output_edit_used: false`
- `state_ledger[].state_id: validate-publication-freshness`
