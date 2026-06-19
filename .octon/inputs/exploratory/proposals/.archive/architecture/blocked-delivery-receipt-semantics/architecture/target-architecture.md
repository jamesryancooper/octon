# Target Architecture

Proposal-packet delivery receipts should support two sharply separated states:

- A `blocked` delivery receipt is structurally valid only when it records
  explicit blockers, the next owning lifecycle, and target-owned evidence
  posture.
- A `cleaned` delivery receipt remains strict and requires all pass fields,
  target-owned receipts, final sync proof, terminal current-state proof, and
  clean worktree evidence.

## Durable Authorities

- `.octon/framework/product/contracts/proposal-packet-delivery-receipt-v1.schema.json`
  owns the machine-readable receipt shape.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-receipt.sh`
  owns deterministic validation of receipt outcomes.

## Inherited Context

The parent program identified a historical blocked delivery receipt that was
truthful as evidence but hostile to validator acceptance. This child preserves
that finding as lineage only. It does not edit historical receipts, promote
proposal files as authority, or make blocked evidence equivalent to success.

## Required Behavior

- `actual_outcome: blocked` accepts explicit open blockers.
- Non-blocked outcomes reject open blockers.
- `actual_outcome: cleaned` keeps all current success requirements.
- Receipt validation errors must distinguish missing blocker evidence from
  missing success evidence.
- Aggregate delivery receipts must continue to classify proposal-local files,
  generated prompts, generated outputs, dashboards, chat, and model memory as
  non-authority or derived-only.
