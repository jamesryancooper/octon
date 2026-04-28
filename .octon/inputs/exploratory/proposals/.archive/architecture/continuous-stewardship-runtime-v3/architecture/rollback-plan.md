# Rollback Plan

## Rollback Objective

Return Octon to the pre-v3 state without disturbing existing v1/v2 Engagement,
Work Package, Mission Runner, run lifecycle, or authorization surfaces.

## Reversible Changes

- Remove or disable `octon steward` CLI commands.
- Remove generated stewardship projections.
- Quarantine `state/control/stewardship/**` entries as retained evidence if any
  stewardship program was opened.
- Retain `state/evidence/stewardship/**` as historical proof rather than deleting.
- Remove instance stewardship program authority only after recording operator
  closure/revocation.
- Remove framework stewardship contracts only if no active/archived stewardship
  evidence references them; otherwise mark deprecated and retain lineage.

## Non-Rollbackable Evidence

Retained evidence should not be deleted. If v3 is rejected after partial rollout,
record a revocation/abandonment receipt and retain evidence under
`state/evidence/stewardship/**`.

## Rollback Gates

- No active Stewardship Epoch may remain open.
- No admitted trigger may remain unresolved.
- No mission handoff may be in-flight.
- No pending stewardship-aware Decision Request may block closure.
- Generated projections must be regenerated or removed.
