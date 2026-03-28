---
title: Wave 6 Retirement, Cutover, And Closeout
description: Transitional migration plan for Wave 6 retirement, cutover, and closeout.
---

# Migration Plan

## Profile Selection Receipt

- Date: 2026-03-28
- Version source(s): `/.octon/octon.yml`
- Current version before cutover: `0.6.7`
- Target version after cutover: `0.6.7`
- `release_state`: `pre-1.0`
- `change_profile`: `transitional`
- Selection facts:
  - downtime tolerance: low for partial landings; constitutional contracts,
    runtime authorization, GitHub policy workflows, and validators must agree
    in the same branch to avoid a fail-closed or drifted intermediate state
  - external consumer coordination ability: low external dependency pressure,
    but repo-local coordination is required across constitution, runtime,
    assurance, generated cognition, and PR automation surfaces
  - data migration and backfill needs: medium; migration indexes, decision
    summaries, mission read models, and proposal registry state must be
    refreshed after the durable sources change
  - rollback mechanism: revert the Wave 6 cutover as one change set so
    runtime, workflows, validators, and documentation return to the prior
    staged state together
  - blast radius and uncertainty: high; this cutover removes live shims from
    authority, runtime, bootstrap, GitHub automation, and read-model surfaces
  - compliance and policy constraints: no consequential path may keep a hidden
    host or environment approval route once the final constitutional model is
    declared live
- Hard-gate outcomes:
  - mission-only execution metadata must disappear from active contracts,
    mission schemas, and mission exemplars in the same branch
  - host-shaped approval flows and environment approval shims must be removed
    from both runtime and GitHub workflows together
  - constitutional family status, obligations, validators, and read models
    must converge on one final active model with no live transitional markers
  - proposal lifecycle may advance only after durable targets no longer depend
    on the proposal path for live behavior
- Tie-break status: `transitional` selected because the branch must cut over
  multiple live surfaces together even though the resulting state contains no
  ongoing coexistence window
- `transitional_exception_note`:
  - rationale: retire the remaining shims in one coordinated cutover instead
    of leaving a branch where runtime, workflows, validators, and docs disagree
    about authority or execution truth
  - risks:
    - PR automation could remain coupled to deleted label-based approval logic
    - mission contracts or validators could still require retired transitional
      fields
    - proposal/read-model closeout could advance before durable targets are
      actually proposal-independent
  - owner: `Octon governance`
  - target_removal_date: `2026-03-28`

## Implementation Summary

- Name: Wave 6 retirement, cutover, and closeout
- Owner: Octon maintainers
- Motivation: retire the remaining transitional execution shims so the final
  constitutional, authority, runtime, assurance, disclosure, and adapter model
  is the only live Octon execution model
- Scope:
  - promote constitutional families, obligations, precedence, and support
    declarations from transitional to fully active status
  - remove mission-only execution metadata from active objective and mission
    contracts, schemas, docs, and validators
  - remove host-shaped approval and waiver logic from runtime and GitHub
    automation surfaces
  - update durable documentation, validators, generators, and read models so
    they describe and enforce only the final model
  - record promotion evidence and final closeout decisions under durable
    cognition and evidence paths

## Transitional Execution

1. Retire runtime, workflow, and validator shims in the same branch as the
   constitutional status cutover.
2. Remove mission-only execution metadata only after run-root lifecycle state
   is already the sole active execution-time truth.
3. Refresh generated decision summaries and any affected read models after the
   durable sources converge.
4. Advance proposal lifecycle only after validating that no durable target
   still depends on proposal-local planning artifacts.

## Impact Map

### Constitutional and governance surfaces

- `/.octon/framework/constitution/**`
- `/.octon/instance/bootstrap/{OBJECTIVE.md,START.md}`
- `/.octon/instance/cognition/context/shared/intent.contract.yml`
- `/.octon/instance/governance/support-targets.yml`

### Runtime, missions, and host automation

- `/.octon/framework/engine/runtime/**`
- `/.octon/framework/agency/_ops/scripts/**`
- `/.github/workflows/{pr-autonomy-policy.yml,pr-auto-merge.yml,pr-triage.yml,pr-stale-close.yml,pr-clean-state-enforcer.yml,ai-review-gate.yml}`
- `/.octon/instance/orchestration/missions/**`
- `/.octon/state/control/execution/**`

### Assurance and generated read models

- `/.octon/framework/assurance/runtime/_ops/scripts/**`
- `/.octon/framework/assurance/runtime/_ops/tests/**`
- `/.octon/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh`
- `/.octon/generated/cognition/**`
- `/.octon/generated/proposals/registry.yml`

## Verification Evidence

- Validation receipts:
  `/.octon/state/evidence/migration/2026-03-28-wave6-retirement-cutover/validation.md`
- Command log:
  `/.octon/state/evidence/migration/2026-03-28-wave6-retirement-cutover/commands.md`
- Change inventory:
  `/.octon/state/evidence/migration/2026-03-28-wave6-retirement-cutover/inventory.md`
- Cutover evidence:
  `/.octon/state/evidence/migration/2026-03-28-wave6-retirement-cutover/evidence.md`
- ADR:
  `/.octon/instance/cognition/decisions/074-wave6-retirement-cutover.md`
- Archived proposal package:
  `/.octon/inputs/exploratory/proposals/.archive/architecture/fully-unified-execution-constitution-for-governed-autonomous-work/`

## Exit Gate Status

- Wave 6 completion status: complete
- Exit gate checks:
  - no live consequential execution path depends on the deprecated model
  - no durable target depends on the proposal path for live behavior
  - retirement evidence exists for removed shims and compensating scaffolds
  - the implementing proposal is archived as implemented once
    proposal-independence is proven
- Remaining active Wave 6 gaps: none

## Rollback

- revert the Wave 6 change set as one unit
- restore the prior constitutional status markers, mission transitional fields,
  and GitHub workflow behavior together if rollback is required
- do not reintroduce host-shaped approval or mission-only execution shims
  without restoring the accompanying validators and documentation
