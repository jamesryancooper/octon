---
name: octon-impact-map-and-validation-selector
description: >
  Composite extension-pack skill that routes touched paths, proposal packets,
  refactor targets, or mixed inputs to the correct impact-map and
  validation-selection leaf.
license: MIT
compatibility: Designed for Octon extension-pack publication and host projection.
metadata:
  author: Octon Framework
  created: "2026-04-15"
  updated: "2026-04-15"
skill_sets: [executor, integrator, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/state/control/skills/checkpoints/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Octon Impact Map And Validation Selector

Resolve the matching input family, then produce:

1. an impact map
2. the minimum credible validation set
3. the rationale trace for that set
4. the recommended next canonical route

## Route Matrix

- `touched-paths` for observed repo deltas
- `proposal-packet` for one proposal packet path or id
- `refactor-target` for rename, move, or restructure intent
- `mixed-inputs` when more than one primary input family is present

## Core Workflow

1. Normalize the provided primary inputs.
2. Resolve one published route with `resolve-extension-route.sh`.
3. Return the route receipt immediately when `dry_run_route=true`.
4. Stop on any non-`resolved` routing outcome.
5. Resolve prompt freshness for the selected prompt set.
6. Execute the selected leaf bundle and return the shared output contract.

## Shared Output Contract

- `impact_map`
- `minimum_credible_validation_set`
- `rationale_trace`
- `recommended_next_step`

## Boundaries

- Additive only. Do not mint authority from raw pack paths.
- Reuse existing validators, audits, workflows, and repo-hygiene surfaces.
- Prefer deterministic routing and explicit traceability over heuristics.
- Fail closed when no credible validation mapping exists.

## References

- `context/routing.contract.yml`
- `context/selection-rules.md`
- `context/reuse-map.md`
