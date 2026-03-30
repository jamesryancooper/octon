---
title: Unified Execution Constitution Phase 6 Simplification And Deletion
description: Atomic migration record for orchestrator-path simplification, label-lane deletion, and retirement of duplicated constitutional surfaces from the required path.
---

# Migration Plan

## Governing Input

- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/README.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/architecture/implementation-plan.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/architecture/simplification-deletion-model.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/architecture/acceptance-criteria.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/resources/unified-execution-constitution-audit.md`

## Profile Selection Receipt

- Date: 2026-03-29
- Version source(s): `/version.txt`, `/.octon/octon.yml`
- Current version before cutover: `0.6.7`
- Target version after cutover: `0.6.7`
- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- Selection facts:
  - downtime tolerance: medium; the work deletes active-path overlays and
    label-shaped workflow behavior, but all affected surfaces are repo-local
    and can change coherently
  - external consumer coordination ability: not required; the cutover is
    internal to Octon’s governance, agency, scaffolding, and GitHub control
    plane
  - data migration and backfill needs: low; existing evidence remains valid,
    but docs, validators, and workflow semantics must be updated together
  - rollback mechanism: revert the Phase 6 change set to restore the thicker
    agency shim stack and label-lane workflow mirrors
  - blast radius and uncertainty: medium-high; agency docs, bootstrap
    scaffolding, validators, and GitHub workflows all participate
  - compliance and policy constraints: orchestrator must remain the single
    clear kernel execution profile, and host-native labels must not act as lane
    or approval signals
- Hard-gate outcomes:
  - `orchestrator` must be the clear kernel execution profile
  - persona-heavy overlays must be out of the scaffolded and required path
  - at least one host-shaped authority path must be deleted rather than merely
    re-labeled
  - duplicated constitutional surfaces must be historical shims only
- Tie-break status: `atomic` selected because the simplification only works if
  agency pathing, workflow behavior, and validators agree in one change set
- Transitional Exception Note: N/A
- `transitional_exception_note`: N/A

## Implementation Summary

- Name: Unified execution constitution Phase 6 simplification and deletion
- Owner: Octon maintainers
- Motivation: make the orchestrator path unmistakably canonical, demote persona
  overlays from the required path, delete label-native authority mirrors, and
  retire duplicated constitutional surfaces from the live interpretive stack
- Scope:
  - simplify agency read order onto the orchestrator contract
  - delete scaffolded and active `SOUL.md` overlays from runtime agents
  - demote agency `CONSTITUTION.md` to a historical shim outside the required
    path
  - remove autonomy and AI-gate label mirrors from GitHub workflows and
    supporting scripts
  - update validators and CI so the simplified path is enforced

## Atomic Execution

1. Make `runtime/agents/orchestrator/AGENT.md` the clear kernel execution
   profile beneath the constitutional kernel and ingress.
2. Delete active and scaffolded `SOUL.md` overlays so persona text is no longer
   on the default path.
3. Retire the agency constitutional shim from the required path while keeping
   it explicitly historical and non-authoritative.
4. Delete autonomy-lane and AI-gate label mirrors from live GitHub workflows
   and local helper scripts.
5. Update validators, CI, and migration evidence so the Phase 6 exit criteria
   are machine-checkable.

## Impact Map

### Agency kernel simplification

- `/.octon/framework/agency/{README.md,manifest.yml,_meta/architecture/**}`
- `/.octon/framework/agency/runtime/agents/**`
- `/.octon/framework/agency/governance/**`
- `/.octon/instance/ingress/AGENTS.md`
- `/.octon/framework/scaffolding/runtime/bootstrap/init-project.sh`
- `/.octon/framework/scaffolding/runtime/templates/octon/**`

### Host-shaped authority deletion

- `/.github/workflows/{ai-review-gate.yml,pr-auto-merge.yml,pr-triage.yml,pr-clean-state-enforcer.yml,pr-stale-close.yml}`
- `/.octon/framework/agency/_ops/scripts/{ai-gate/aggregate-decision.sh,git/git-pr-ship.sh,github/sync-github-labels.sh,validate/validate-autonomy-labels.sh}`
- `/.octon/framework/agency/practices/{pull-request-standards.md,github-autonomy-runbook.md,git-autonomy-playbook.md}`

### Validation and CI

- `/.octon/framework/agency/_ops/scripts/validate/validate-agency.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/{validate-bootstrap-ingress.sh,validate-execution-governance.sh,validate-phase6-simplification-deletion.sh}`
- `/.github/workflows/{agency-validate.yml,architecture-conformance.yml}`

## Verification Evidence

- ADR:
  `/.octon/instance/cognition/decisions/082-unified-execution-constitution-phase6-simplification-deletion.md`
- Evidence bundle:
  `/.octon/state/evidence/migration/2026-03-29-unified-execution-constitution-phase6-simplification-deletion/`

## Rollback

- revert the Phase 6 change set
- restore the deleted `SOUL.md` overlays only as part of the same full revert
- restore label-lane workflow mirrors only as part of the same full revert
- do not leave the repo in a mixed state where docs say the orchestrator path
  is canonical but workflows or scaffolding still depend on retired overlays or
  label signals
