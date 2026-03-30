---
title: Unified Execution Constitution Phase 7 Build-To-Delete Institutionalization
description: Atomic migration record for institutionalizing retirement review, adapter/support-target review, drift review, and ablation-backed deletion as durable governance and validation surfaces.
---

# Migration Plan

## Governing Input

- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/README.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/architecture/implementation-plan.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/architecture/validation-plan.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/architecture/acceptance-criteria.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/architecture/simplification-deletion-model.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/resources/unified-execution-constitution-audit.md`

## Profile Selection Receipt

- Date: 2026-03-29
- Version source(s): `/version.txt`, `/.octon/octon.yml`
- Current version before cutover: `0.6.7`
- Target version after cutover: `0.6.7`
- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- Selection facts:
  - downtime tolerance: medium; the work replaces one-off closeout metadata
    with durable governance and CI gates, so contract, evidence, and validator
    surfaces must agree in one change
  - external consumer coordination ability: not required; the affected surfaces
    are repo-local governance, validation, and retained evidence paths
  - data migration and backfill needs: low; older closeout evidence remains as
    lineage, but the canonical packet and blocking review set move to
    build-to-delete review roots
  - rollback mechanism: revert the Phase 7 change set to restore the earlier
    closeout packet and remove the new retirement registry and review contracts
  - blast radius and uncertainty: medium; governance contracts, architecture CI,
    and closeout validation all participate
  - compliance and policy constraints: every compensating mechanism must carry
    owner, support scope, value metric, review date, retirement trigger, and
    required ablation suite
- Hard-gate outcomes:
  - a retirement registry is canonical and complete for registered, historical,
    and retired transitional surfaces
  - drift-review, support-target-review, adapter-review, and retirement-review
    are durable blocking review contracts
  - ablation-driven deletion is a durable workflow with same-change receipts
  - validators and CI enforce the build-to-delete packet before a final
    target-state claim is treated as valid
- Tie-break status: `atomic` selected because the review set, review receipts,
  retirement registry, and closeout validator must move together or the repo
  would claim a gate it cannot enforce
- Transitional Exception Note: N/A
- `transitional_exception_note`: N/A

## Implementation Summary

- Name: Unified execution constitution Phase 7 build-to-delete
  institutionalization
- Owner: Octon maintainers
- Motivation: turn build-to-delete from a one-off closeout packet into an
  ongoing governance system with explicit review contracts, retirement
  inventory, and ablation-backed deletion evidence
- Scope:
  - add a canonical retirement registry for active, historical, and retired
    compensating mechanisms
  - define recurring drift, support-target, adapter, and retirement reviews
    with owners, triggers, and evidence requirements
  - add an ablation-driven deletion workflow contract and receipt model
  - re-point closeout governance and validation to the build-to-delete review
    packet
  - update CI and validators so Phase 7 remains enforceable beyond this branch

## Atomic Execution

1. Replace the older one-date closeout packet with durable review contracts plus
   a canonical build-to-delete review packet root.
2. Publish a retirement registry that records registered, historical-retained,
   and retired transitional surfaces with review dates and retirement paths.
3. Add an ablation-driven deletion workflow so deletion and retention decisions
   carry non-regression evidence instead of narrative intent alone.
4. Update closeout validation and architecture CI so the final target-state
   claim fails closed when any review or ablation receipt is missing.
5. Record Phase 7 governance/evidence artifacts and verify that the packet's
   final target-state claim criteria are satisfied.

## Impact Map

### Governance Contracts

- `/.octon/instance/governance/contracts/{README.md,retirement-policy.yml,retirement-registry.yml,drift-review.yml,support-target-review.yml,adapter-review.yml,retirement-review.yml,ablation-deletion-workflow.yml,closeout-reviews.yml}`
- `/.octon/framework/constitution/contracts/registry.yml`

### Validation And CI

- `/.octon/framework/assurance/runtime/_ops/scripts/{validate-phase7-build-to-delete-institutionalization.sh,validate-execution-constitution-closeout.sh}`
- `/.github/workflows/architecture-conformance.yml`

### Retained Evidence And Review Packets

- `/.octon/state/evidence/validation/publication/{README.md,build-to-delete/**}`
- `/.octon/state/evidence/migration/2026-03-29-unified-execution-constitution-phase7-build-to-delete-institutionalization/**`
- `/.octon/instance/cognition/{decisions/083-unified-execution-constitution-phase7-build-to-delete-institutionalization.md,decisions/index.yml,context/shared/migrations/index.yml}`

## Verification Evidence

- ADR:
  `/.octon/instance/cognition/decisions/083-unified-execution-constitution-phase7-build-to-delete-institutionalization.md`
- Evidence bundle:
  `/.octon/state/evidence/migration/2026-03-29-unified-execution-constitution-phase7-build-to-delete-institutionalization/`
- Canonical review packet:
  `/.octon/state/evidence/validation/publication/build-to-delete/2026-03-29/`

## Rollback

- revert the Phase 7 change set
- restore the earlier closeout packet as canonical only as part of the same full
  revert
- do not leave the repo in a mixed state where retirement targets are registered
  but the review set or closeout validator still points at the historical packet
