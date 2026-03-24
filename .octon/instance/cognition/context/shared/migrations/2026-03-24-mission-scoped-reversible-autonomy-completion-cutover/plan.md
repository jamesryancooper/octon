---
title: Mission-Scoped Reversible Autonomy Completion Cutover
description: Atomic clean-break migration plan for completing MSRAOM with normalized mission control state, effective scenario routing, control receipts, and route-aware generated views.
---

# Migration Plan

## Profile Selection Receipt

- Date: 2026-03-24
- Version source(s): `/.octon/octon.yml`, `/version.txt`
- Current version: `0.5.6`
- Target version: `0.6.0`
- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- Selection facts:
  - downtime tolerance: one-step repo-local cutover is acceptable
  - external coordination required: none; all affected consumers are local
    runtime, docs, validators, and CI
  - live mission migration burden: none; mission registry has no active entries
  - rollback mechanism: revert the branch as one change set and regenerate
    affected derived outputs
  - hard boundaries: no dual live model, no second mutable control plane, no
    mission-less autonomous fallback, and no rewrite of historical evidence

## Implementation Plan

- Release metadata and docs:
  - bump `version.txt` and `.octon/octon.yml` to `0.6.0`
  - publish mission effective-route and summary/projection roots in
    `octon.yml#resolution.runtime_inputs`
  - update architecture SSOT, runtime-vs-ops, engine README, bootstrap docs,
    and mission-governance principles so docs match the final live model
- Contract and schema normalization:
  - keep `execution-request-v2`, `execution-receipt-v2`, and
    `policy-receipt-v2` canonical
  - normalize mission control files to the proposal contract family
  - upgrade `control-receipt-v1` to the richer state-mutation receipt model
  - add `scenario-resolution-v1`
- Runtime and orchestration:
  - make kernel authorization derive effective mission autonomy from charter,
    mission policy, ACP policy, executor profile, and live control truth
  - remove hardcoded fallback recovery behavior for material work
  - make orchestration helpers and runtime honor directives, schedule,
    breaker/safing state, and explicit break-glass mutations
- Derived outputs and validation:
  - publish freshness-bounded effective scenario routes under
    `generated/effective/orchestration/missions/**`
  - make mission/operator summaries and projections consume those routes plus
    canonical control/evidence/continuity state
  - harden validators and tests so the cutover fails closed when any live
    surface drifts from the declared model

## Verification Evidence

- focused kernel tests for mission autonomy context, lease state, recovery
  derivation, and stale-route rejection
- helper/runtime tests for control-state seeding, directive precedence,
  breaker/safing, and control receipt emission
- generated-output checks for mission summaries, operator digests, mission
  projections, and scenario-resolution freshness
- `alignment-check.sh --profile mission-autonomy`
- `validate-runtime-effective-state.sh`

Required evidence bundle location:

- `/.octon/state/evidence/migration/2026-03-24-mission-scoped-reversible-autonomy-completion-cutover/`

## Rollback

- rollback strategy: revert the completion cutover as one branch-level change
  set and regenerate affected derived artifacts
- rollback triggers: runtime still permits mission-less autonomy, route-aware
  generated outputs drift from canonical sources, control mutations do not emit
  retained receipts, or scheduler/runtime behavior ignores effective
  scenario-resolution state
