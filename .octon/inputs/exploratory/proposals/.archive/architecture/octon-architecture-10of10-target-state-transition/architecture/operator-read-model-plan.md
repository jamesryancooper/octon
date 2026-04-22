# Operator Read-Model Plan

## Objective

Make Octon's target-state architecture inspectable without turning generated projections into authority.

## Required projections

| Projection | Path | Role |
|---|---|---|
| Architecture map | `generated/cognition/projections/materialized/architecture-map.md` | Human-readable map of class roots, registries, and shims |
| Runtime route map | `generated/cognition/projections/materialized/runtime-route-map.md` | Summary of current route-bundle state, freshness, and consumers |
| Support pack route map | `generated/cognition/projections/materialized/support-pack-route-map.md` | Summary of support tuples, pack routes, and non-live surfaces |

## Required fields on every projection

- generated_at
- source_refs
- freshness status
- publication or generation receipt ref when applicable
- non-authority disclaimer
- promotion path if a finding requires authored change

## `octon doctor --architecture` output

The doctor report should print:

- active root manifest version
- structural registry status
- delegated registry freshness
- generated/effective runtime route bundle status
- stale generated/effective files
- support tuple path normalization status
- support proof freshness
- admitted/stage-only/unadmitted pack routes
- active/quarantined extension state
- retained compatibility shims and retirement due dates
- validator pass/fail summary
- top blocking reason codes

Operator views may mirror canonical truth but must never substitute for it.
