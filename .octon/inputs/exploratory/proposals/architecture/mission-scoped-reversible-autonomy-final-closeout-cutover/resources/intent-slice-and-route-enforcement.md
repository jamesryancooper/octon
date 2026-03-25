# Intent, Slice, And Route Enforcement

## Final rule for material autonomous work

Material autonomous work may proceed only when all of the following are true:

1. lease is active or explicitly break-glass-authorized
2. mode state is current
3. scenario resolution is fresh and linked
4. intent register is fresh
5. a current intent entry exists
6. the current intent entry references a current action slice
7. the slice provides boundary, recovery, and action-class semantics
8. policy permits the work
9. required evidence/recovery prerequisites are satisfied

If any of the above is false, runtime tightens to `STAGE_ONLY`, `SAFE`, or `DENY`.

## Observe-only carveout

Observe-only missions may remain empty-intent only while they remain observe-only.
The moment they fork bounded operate work, the same intent-and-slice rule applies.

## Route precedence

The final route precedence is:

1. mission class default
2. effective scenario family
3. current intent entry
4. current action slice specificity
5. directive / breaker / safing / break-glass overlays (tightening only)

### Consequence
- mission class sets defaults
- effective scenario family refines operator and scheduling posture
- action slice supplies the most specific boundary/recovery/externality semantics
- control overlays may only tighten, never silently broaden

## Route provenance fields

The generated route should explicitly record:

- `mission_class`
- `effective_scenario_family`
- `effective_action_class`
- `scenario_family_source`
- `boundary_source`
- `recovery_source`
- `tightening_overlays`

## Fail-closed rules

### If intent is missing or stale
- observe-only: allow only observe behavior
- material autonomy: `STAGE_ONLY` or `DENY`

### If slice is missing
- material autonomy: `STAGE_ONLY` or `DENY`

### If route is stale
- `STAGE_ONLY`, `SAFE`, or `DENY`

### If recovery cannot be derived
- `STAGE_ONLY`, `SAFE`, or `DENY`

### If a route would fall back to generic `service.execute`
- legal only for non-material internal runtime behavior
- illegal for material autonomous work

## Validation requirements

The validator suite must prove:

- non-empty intent for material autonomy
- slice linkage for current intent
- intent freshness and route freshness
- route provenance populated
- no material generic recovery fallback
- observe-only carveout behaves exactly as declared
