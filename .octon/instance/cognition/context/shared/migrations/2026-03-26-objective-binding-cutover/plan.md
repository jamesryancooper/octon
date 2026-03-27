---
title: Objective Binding Cutover
description: Transitional migration plan for Wave 1 objective binding cutover.
---

# Migration Plan

## Profile Selection Receipt

- Date: 2026-03-26
- Version source(s): `/.octon/octon.yml`
- Current version before cutover: `0.6.3`
- Target version after cutover: `0.6.3`
- `release_state`: `pre-1.0`
- `change_profile`: `transitional`
- Selection facts:
  - downtime tolerance: internal harness work can absorb staged cutovers, but
    the blast radius is too wide for a safe atomic switch from mission-first to
    run-first execution
  - external consumer coordination ability: low external dependency pressure,
    but significant repo-local coordination across runtime, governance,
    bootstrap, assurance, and generated read models
  - data migration and backfill needs: high; mission control, retained
    evidence, generated read models, and approval/disclosure state need an
    explicit bridge to the run model
  - rollback mechanism: revert the latest completed wave, regenerate affected
    effective outputs, and restore the prior mission-centric behavior for any
    not-yet-retired surfaces
  - blast radius and uncertainty: very high; this cutover touches objective
    binding, runtime state topology, validator obligations, and mission
    guidance
  - compliance and policy constraints: no consequential execution may lose
    objective binding, authority routing, or retained evidence guarantees
- Hard-gate outcomes:
  - mission-first and run-first execution need a temporary coexistence window
  - current mission-backed flows must remain valid while run-contract
    scaffolding and validators land
  - workspace, mission, and run objective responsibilities need one
    constitutional contract family before runtime lifecycle can move fully to
    run roots
  - mission-only execution assumptions must gain explicit retirement metadata
- Tie-break status: `transitional` selected because a hard gate requires
  temporary coexistence and backfill
- `transitional_exception_note`:
  - rationale: introduce constitutional objective contracts and run-control
    roots without breaking the existing mission-backed operating model
  - risks:
    - doc and validator drift between mission-first and run-first semantics
    - partial objective binding if the new roots are added without parity
      checks
    - legacy orchestration-facing run projections remaining more permissive
      than the constitutional objective model
  - owner: `Octon governance`
  - target_removal_date: `2026-06-30`

## Implementation Summary

- Name: Objective binding cutover
- Owner: Octon maintainers
- Motivation: ratify the workspace objective pair as constitutional authority,
  define run-contract and stage-attempt contracts, add the canonical
  run-control root, and make mission-only execution explicitly transitional
- Scope:
  - add constitutional objective family contracts under
    `/.octon/framework/constitution/contracts/objective/**`
  - align `OBJECTIVE.md` and `intent.contract.yml` to the workspace-charter
    role
  - align mission registry, templates, and live mission guidance so mission
    remains the continuity container while run contracts become the atomic
    execution unit
  - add canonical run-control roots under
    `/.octon/state/control/execution/runs/`
  - update docs, schemas, and validators for Wave 1 coexistence semantics

## Transitional Execution

1. Publish the constitutional objective contract family and ratify the current
   workspace objective pair inside it.
2. Preserve mission authority under `instance/orchestration/missions/**` while
   marking mission-only execution as transitional with an explicit retirement
   gate.
3. Add the canonical run-control root and stage-attempt placement contract
   without moving the full runtime lifecycle there yet.
4. Update validator coverage so the new objective model is fail-closed against
   drift.

## Impact Map

### Constitutional and bootstrap authority

- `/.octon/framework/constitution/contracts/**`
- `/.octon/framework/constitution/precedence/normative.yml`
- `/.octon/framework/constitution/obligations/fail-closed.yml`
- `/.octon/instance/bootstrap/OBJECTIVE.md`
- `/.octon/instance/cognition/context/shared/intent.contract.yml`

### Mission and control surfaces

- `/.octon/instance/orchestration/missions/**`
- `/.octon/state/control/execution/runs/**`
- `/.octon/state/control/README.md`
- `/.octon/state/evidence/runs/README.md`

### Architecture, runtime config, and assurance

- `/.octon/README.md`
- `/.octon/instance/bootstrap/START.md`
- `/.octon/framework/cognition/_meta/architecture/{specification.md,contract-registry.yml,runtime-vs-ops-contract.md}`
- `/.octon/framework/cognition/governance/principles/mission-scoped-reversible-autonomy.md`
- `/.octon/framework/engine/{README.md,runtime/config/policy-interface.yml,runtime/spec/*.json,runtime/spec/policy-interface-v1.md}`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-objective-binding-cutover.sh`

## Verification Evidence

- Validation receipts: `validation.md`
- Command log: `commands.md`
- Change inventory: `inventory.md`
- ADR:
  `/.octon/instance/cognition/decisions/069-objective-binding-cutover.md`
- Evidence bundle:
  `/.octon/state/evidence/migration/2026-03-26-objective-binding-cutover/`

## Rollback

- revert the full Wave 1 objective-binding change set
- restore the prior workspace-objective and mission guidance surfaces as the
  only live objective model
- remove the run-control root and validator wiring added for Wave 1 if the
  branch is reverted
- do not leave a partial state where run contracts are declared but no longer
  validated
