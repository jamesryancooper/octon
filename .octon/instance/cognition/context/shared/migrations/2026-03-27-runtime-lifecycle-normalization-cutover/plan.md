---
title: Runtime Lifecycle Normalization Cutover
description: Transitional migration plan for Wave 3 runtime lifecycle normalization.
---

# Migration Plan

## Profile Selection Receipt

- Date: 2026-03-27
- Version source(s): `/.octon/octon.yml`
- Current version before cutover: `0.6.5`
- Target version after cutover: `0.6.5`
- `release_state`: `pre-1.0`
- `change_profile`: `transitional`
- Selection facts:
  - downtime tolerance: repo-local runtime and validator work can absorb staged
    cutovers, but the run-root lifecycle bridge still touches engine runtime,
    mission continuity, generated mission views, and orchestration helpers
  - external consumer coordination ability: low external dependency pressure,
    but meaningful repo-local coordination across constitutional contracts,
    runtime writers, shell tooling, generated read models, and assurance
  - data migration and backfill needs: high; mission-backed continuity and
    generated mission views must consume per-run evidence before older
    mission-only assumptions can retire
  - rollback mechanism: revert the Wave 3 change set, restore the older run
    root scaffolding, and regenerate mission summaries and views from the
    previous mission-backed logic
  - blast radius and uncertainty: high; this cutover touches execution-time
    binding, receipts, checkpoint placement, replay pointers, and the mission
    read-model bridge
  - compliance and policy constraints: no consequential stage may perform side
    effects before its canonical run control and evidence roots are bound
- Hard-gate outcomes:
  - mission-backed continuity must remain live while run-root lifecycle state
    becomes the primary execution-time unit of truth
  - generated mission summaries and mission views must consume per-run evidence
    rather than only generic mission continuity and evidence roots
  - runtime contract promotion, lifecycle writers, and validators must land in
    the same branch to avoid advisory-only drift
  - canonical checkpoint, rollback, replay, and retained-evidence families
    must exist even where older compatibility artifacts still remain
- Tie-break status: `transitional` selected because the mission-backed bridge
  and generated read-model backfill require temporary coexistence
- `transitional_exception_note`:
  - rationale: normalize run lifecycle state and evidence under canonical run
    roots without breaking the current mission-backed continuity path
  - risks:
    - generated mission views could continue pointing only at generic evidence
      roots instead of per-run run evidence
    - some compatibility root-level run evidence artifacts may remain while
      canonical receipts and replay pointers are backfilled
    - workflow-stage completion receipts still need staged follow-through in
      later waves to eliminate every compatibility artifact
  - owner: `Octon governance`
  - target_removal_date: `2026-06-30`

## Implementation Summary

- Name: Runtime lifecycle normalization cutover
- Owner: Octon maintainers
- Motivation: promote the constitutional runtime contract family, bind
  canonical run control and evidence roots before consequential side effects,
  publish runtime-state and rollback-posture control files, add checkpoint and
  replay families, and bridge mission continuity plus generated mission views
  onto per-run evidence
- Scope:
  - add constitutional runtime contracts under
    `/.octon/framework/constitution/contracts/runtime/**`
  - normalize engine runtime writers around canonical control and evidence run
    roots
  - expand `/.octon/state/control/execution/runs/<run-id>/**` with
    stage-attempts, checkpoints, runtime-state, and rollback-posture
  - expand `/.octon/state/evidence/runs/<run-id>/**` with receipts,
    checkpoints, replay pointers, trace pointers, and retained run evidence
  - update mission summaries, mission views, docs, and validators so they
    consume per-run evidence without breaking transitional mission-backed flows

## Transitional Execution

1. Promote the constitutional runtime contract family and publish the canonical
   Wave 3 file families.
2. Bind run control and run evidence roots before approval, policy receipt, or
   other consequential side effects are materialized.
3. Preserve mission continuity as the long-horizon continuity surface, but make
   generated mission views and summaries consume bound run evidence when runs
   exist.
4. Keep compatibility artifacts explicit and validator-backed until later
   retirement work removes them.

## Impact Map

### Constitutional and structural authority

- `/.octon/framework/constitution/contracts/runtime/**`
- `/.octon/framework/constitution/contracts/{registry.yml,objective/run-contract-v1.schema.json}`
- `/.octon/framework/constitution/precedence/normative.yml`
- `/.octon/octon.yml`
- `/.octon/framework/engine/runtime/config/policy-interface.yml`
- `/.octon/framework/cognition/_meta/architecture/{specification.md,contract-registry.yml}`

### Runtime and execution lifecycle

- `/.octon/framework/engine/runtime/crates/core/src/{config.rs,execution_integrity.rs,trace.rs}`
- `/.octon/framework/engine/runtime/crates/kernel/src/authorization.rs`
- `/.octon/framework/orchestration/runtime/_ops/scripts/write-run.sh`
- `/.octon/framework/orchestration/runtime/runs/{README.md,_ops/scripts/validate-runs.sh}`
- `/.octon/state/control/execution/runs/**`
- `/.octon/state/evidence/runs/**`

### Mission continuity and generated read models

- `/.octon/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh`
- `/.octon/framework/engine/runtime/spec/mission-view-v1.schema.json`
- `/.octon/generated/cognition/summaries/missions/**`
- `/.octon/generated/cognition/projections/materialized/missions/**`
- `/.octon/instance/orchestration/missions/{README.md,registry.yml}`
- `/.octon/framework/cognition/governance/principles/mission-scoped-reversible-autonomy.md`

### Assurance and evidence

- `/.octon/framework/assurance/runtime/_ops/scripts/validate-runtime-lifecycle-normalization.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/{validate-harness-structure.sh,validate-architecture-conformance.sh,validate-runtime-effective-state.sh,validate-mission-generated-summaries.sh,validate-mission-view-generation.sh}`
- `/.octon/framework/assurance/runtime/contracts/alignment-profiles.yml`
- `/.octon/state/evidence/migration/2026-03-27-runtime-lifecycle-normalization-cutover/`

## Verification Evidence

- Validation receipts: `validation.md`
- Command log: `commands.md`
- Change inventory: `inventory.md`
- ADR:
  `/.octon/instance/cognition/decisions/070-runtime-lifecycle-normalization-cutover.md`
- Evidence bundle:
  `/.octon/state/evidence/migration/2026-03-27-runtime-lifecycle-normalization-cutover/`

## Rollback

- revert the Wave 3 runtime-lifecycle change set
- restore the previous mission-backed generator and validator assumptions
- remove the runtime contract family and canonical lifecycle writers only if
  the full branch is being reverted
- do not leave a partial state where run roots are declared to own lifecycle
  state but the engine or validators no longer bind them
