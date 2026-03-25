---
title: Mission-Scoped Reversible Autonomy Final Closeout Cutover
description: Atomic migration plan for the final Mission-Scoped Reversible Autonomy closeout cutover.
---

# Migration Plan

## Profile Selection Receipt

- Date: 2026-03-25
- Version source(s): `version.txt`, `/.octon/octon.yml`
- Current version before cutover: `0.6.2`
- Target version after cutover: `0.6.3`
- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- Selection facts:
  - affected surfaces are repo-local mission authority, mission control truth,
    control evidence, generated route/view outputs, runtime helpers, validators,
    and CI workflow gates
  - the repo already had one canonical MSRAOM implementation, so the safe shape
    remained one convergence branch rather than staged coexistence
  - release-version drift also required republishing extension and capability
    effective outputs in the same change
  - rollback remains full-branch revert rather than any dual-live operating
    model
- Hard-gate outcomes:
  - no compatibility window for pre-closeout lifecycle or route semantics
  - no advisory-only validator phase
  - no follow-on remediation packet is assumed after this closeout

## Implementation Summary

- Name: Mission-Scoped Reversible Autonomy final closeout cutover
- Owner: Octon maintainers
- Motivation: close the remaining lifecycle, provenance, evidence-loop, and
  gating gaps from the final implementation audit so MSRAOM is complete in
  repo authority, runtime helpers, generated read models, and CI
- Scope:
  - bump the repo release to `0.6.3`
  - normalize mission-autonomy boundary taxonomy and generated route provenance
  - add first-class directive/add, authorize-update/add, and autonomy
    burn/breaker reducer helpers
  - add lifecycle, intent, route-normalization, and mission-view validators
    plus lifecycle/reducer smoke tests
  - refresh the live validation mission route and generated awareness outputs
  - refresh extension and capability publication state for the manifest bump
  - write the final closeout ADR and evidence bundle

## Atomic Execution

1. Update release/version parity and mission-autonomy policy taxonomy.
2. Harden route publication, generated view emission, and control-mutation
   helper surfaces.
3. Add the final lifecycle/intent/route/view validators and smoke tests.
4. Expand the mission-autonomy alignment profile and architecture-conformance
   workflow to the final closeout gate set.
5. Refresh the live validation mission route, summaries, operator digest, and
   mission view.
6. Republish extension and capability effective outputs after the `0.6.3`
   manifest change.
7. Run the mission-autonomy validator stack, runtime-effective gate, and
   mission-autonomy alignment profile.

## Impact Map

### Runtime and policy

- `/.octon/framework/orchestration/runtime/_ops/scripts/*mission*`
- `/.octon/instance/governance/policies/mission-autonomy.yml`
- `/.octon/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh`

### Assurance and CI

- `/.octon/framework/assurance/runtime/_ops/scripts/validate-*mission*`
- `/.octon/framework/assurance/runtime/_ops/scripts/test-*mission*`
- `/.octon/framework/assurance/runtime/contracts/alignment-profiles.yml`
- `/.octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh`
- `/.github/workflows/architecture-conformance.yml`

### Contracts and docs

- `/.octon/README.md`
- `/.octon/instance/bootstrap/START.md`
- `/.octon/framework/cognition/_meta/architecture/{specification.md,runtime-vs-ops-contract.md,contract-registry.yml}`
- `/.octon/framework/cognition/governance/principles/mission-scoped-reversible-autonomy.md`
- `/.octon/framework/engine/runtime/spec/{scenario-resolution-v1.schema.json,action-slice-v1.schema.json}`

## Verification Evidence

- Validation receipts: `validation.md`
- Command log: `commands.md`
- Change inventory: `inventory.md`
- ADR:
  `/.octon/instance/cognition/decisions/067-mission-scoped-reversible-autonomy-final-closeout-cutover.md`
- Evidence bundle:
  `/.octon/state/evidence/migration/2026-03-25-mission-scoped-reversible-autonomy-final-closeout-cutover/`

## Rollback

- revert the full final-closeout change set
- restore the prior release/version and republish extension and capability
  effective outputs from the reverted manifest
- do not keep the final lifecycle/route/view validators while restoring the
  older partial closeout state
