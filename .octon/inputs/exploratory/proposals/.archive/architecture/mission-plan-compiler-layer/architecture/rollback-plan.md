# Rollback Plan

## Rollback Principle

The planning layer must be removable without breaking existing missions, action
slices, run contracts, authorization, retained evidence, replay, rollback, or
continuity.

## Pre-Promotion Rollback

Before durable promotion, rollback is deletion or archival of this proposal
packet and regeneration of the non-authoritative proposal registry.

## Post-Promotion Rollback

After durable promotion, rollback should:

- disable instance policy for hierarchical planning
- block new plan creation
- prevent stale or active plans from compiling further leaves
- preserve existing plan evidence as historical retained evidence
- leave run contracts, Run Journals, run evidence, and disclosures untouched
- delete and regenerate generated planning projections
- archive or retire plan control roots only after no active run references
  them as lineage

## Runtime Safety Test

Rollback succeeds only if:

- existing mission charters remain valid
- existing action slices remain valid
- existing run contracts remain valid
- run replay reconstructs without plan inputs
- generated planning projections can be deleted and rebuilt
- support-target claims remain unchanged

## Data Retention

Plan control state may be retired after active references close. Plan evidence
under `state/evidence/control/execution/planning/**` should remain retained
when it explains promoted or executed work lineage.
