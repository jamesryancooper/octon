---
title: Unified Execution Constitution Phase 2 Objective And Authority Cutover
description: Atomic migration record for workspace-charter re-home, canonical authority artifacts, and host projection de-authoritization.
---

# Migration Plan

## Governing Input

- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/README.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/architecture/implementation-plan.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/architecture/acceptance-criteria.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/resources/unified-execution-constitution-audit.md`

## Profile Selection Receipt

- Date: 2026-03-28
- Version source(s): `/.octon/octon.yml`, `/version.txt`
- Current version before cutover: `0.6.7`
- Target version after cutover: `0.6.7`
- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- Selection facts:
  - downtime tolerance: medium; this cutover changes objective bindings,
    runtime authority routing, and GitHub projection logic, but all changes can
    land in one coherent branch without a required dual-authority rollout
  - external consumer coordination ability: not required; the changes stay
    repo-local and GitHub-host projection changes remain under repo control
  - data migration and backfill needs: medium; the workspace charter pair must
    be re-homed, sample run authority artifacts must be backfilled, and GitHub
    workflows must dual-write control signals into canonical approval artifacts
  - rollback mechanism: revert the Phase 2 change set, restoring the prior
    workspace-charter paths and GitHub label-gated merge behavior
  - blast radius and uncertainty: high; this touches runtime authorization,
    objective files, validators, and GitHub workflow control paths
  - compliance and policy constraints: host-native labels may not remain the
    authority source, and the current repo must end with canonical
    approvals/grants/leases/revocations plus instance-owned workspace charter
    authority
- Hard-gate outcomes:
  - no external consumer or zero-downtime constraint requires a staged
    coexistence window for this repo-local cutover
  - target-state correctness requires re-homing workspace authority into
    `instance/charter/**` now instead of preserving the bootstrap pair as the
    canonical path
  - GitHub projection can remain as UX, but merge authority must no longer read
    control labels as the source of truth
- Tie-break status: `atomic` selected because the repo can move to the
  Phase 2 model in one branch while retaining old paths only as explicit shims
- Transitional Exception Note: N/A
- `transitional_exception_note`: N/A

## Implementation Summary

- Name: Unified execution constitution Phase 2 objective and authority cutover
- Owner: Octon maintainers
- Motivation: re-home workspace authority into `instance/charter/**`, make
  run-contract and stage-attempt artifacts part of the canonical execution
  path, populate canonical authority artifacts, and demote GitHub labels to
  projection-only status
- Scope:
  - add `instance/charter/{README.md,workspace.md,workspace.yml}`
  - preserve `instance/bootstrap/OBJECTIVE.md` and
    `instance/cognition/context/shared/intent.contract.yml` as compatibility
    shims only
  - update runtime and authored bindings to point at the new workspace charter
    pair
  - seed canonical approval, grant, exception lease, and revocation artifacts
  - add GitHub host-projection dual-write into canonical approval artifacts and
    remove label-based merge authority

## Atomic Execution

1. Add the canonical workspace charter pair under `instance/charter/**` and
   rebind objective-family/runtime pointers to it.
2. Convert the old bootstrap/cognition objective pair into explicit shims.
3. Populate canonical approval/grant/lease/revocation artifacts and align
   seeded authority evidence with them.
4. Update GitHub workflows so they dual-write control signals into canonical
   approval artifacts and no longer use labels as merge authority.

## Impact Map

### Workspace charter and objective binding

- `/.octon/instance/charter/**`
- `/.octon/instance/bootstrap/OBJECTIVE.md`
- `/.octon/instance/cognition/context/shared/intent.contract.yml`
- `/.octon/framework/constitution/contracts/objective/{README.md,workspace-charter-pair.yml}`
- `/.octon/framework/constitution/contracts/registry.yml`
- `/.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- `/.octon/octon.yml`
- `/.octon/framework/engine/runtime/config/policy-interface.yml`
- `/.octon/instance/ingress/AGENTS.md`
- `/.octon/README.md`
- `/.octon/instance/bootstrap/START.md`

### Runtime and authority artifacts

- `/.octon/framework/engine/runtime/crates/kernel/src/{authorization.rs,pipeline.rs,workflow.rs}`
- `/.octon/framework/orchestration/runtime/_ops/scripts/write-run.sh`
- `/.octon/state/control/execution/runs/**`
- `/.octon/state/control/execution/approvals/**`
- `/.octon/state/control/execution/exceptions/leases.yml`
- `/.octon/state/control/execution/revocations/grants.yml`
- `/.octon/state/evidence/control/execution/**`

### GitHub host projection and validation

- `/.octon/framework/engine/_ops/scripts/project-github-control-approval.sh`
- `/.github/workflows/{ai-review-gate.yml,pr-auto-merge.yml}`
- `/.octon/framework/assurance/runtime/_ops/scripts/{validate-objective-binding-cutover.sh,validate-execution-governance.sh,validate-harness-structure.sh}`

## Verification Evidence

- ADR:
  `/.octon/instance/cognition/decisions/078-unified-execution-constitution-phase2-objective-authority-cutover.md`
- Evidence bundle:
  `/.octon/state/evidence/migration/2026-03-28-unified-execution-constitution-phase2-objective-authority-cutover/`

## Rollback

- revert the Phase 2 change set
- restore the prior workspace objective bindings and GitHub auto-merge label
  gating
- do not leave runtime pointers, validators, and host workflows split across
  the old and new authority models
