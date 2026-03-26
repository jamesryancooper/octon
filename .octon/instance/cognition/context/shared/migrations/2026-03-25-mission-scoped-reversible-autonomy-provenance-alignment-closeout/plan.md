---
title: Mission-Scoped Reversible Autonomy Provenance Alignment Closeout
description: Atomic migration plan for normalizing the final MSRAOM proposal lineage, proposal discovery, ADR discovery, migration discovery, and operator-facing guidance after the landed 0.6.3 runtime closeout.
---

# Migration Plan

## Profile Selection Receipt

- Date: 2026-03-25
- Version source(s): `version.txt`, `/.octon/octon.yml`
- Current version: `0.6.3`
- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- Selection facts:
  - the MSRAOM runtime closeout is already landed, so the remaining work is
    bounded to proposal, registry, decision, migration, evidence, and
    operator-facing guidance surfaces
  - the affected surfaces share one repo-local trust boundary and do not
    justify staged coexistence
  - rollback remains full-branch revert plus proposal-registry regeneration,
    not any dual live provenance model
  - the cutover is only complete if archive manifests, registry projection,
    ADR discovery, migration discovery, and docs converge together
- Hard-gate outcomes:
  - no runtime release bump required
  - no transitional profile justified
  - no partial merge accepted if historical proposal lineage remains ambiguous

## Implementation Plan

- Name: Mission-Scoped Reversible Autonomy provenance alignment closeout
- Owner: Octon maintainers
- Motivation: normalize the final MSRAOM historical lineage so archive
  manifests, generated proposal discovery, ADR discovery, migration discovery,
  and operator-facing docs all reflect the already-landed `0.6.3` runtime
  closeout
- Scope:
  - normalize the archived steady-state and final-closeout proposal manifests
  - archive the provenance-alignment implementing packet as the final lineage
    record
  - add one provenance-closeout ADR and one matching migration plan
  - add the matching migration evidence bundle
  - regenerate the proposal registry
  - update root docs and architecture docs to point readers to runtime truth
    first and proposal history second

### Atomic Profile Execution

- Clean-break approach:
  - one integration branch
  - no staged archive normalization
  - no mixed registry state where archived MSRAOM packets remain omitted
  - no historical ADR rewrite; append-only correction lands through ADR 068
  - the implementing proposal is archived only in the same transaction as the
    durable closeout records and regenerated registry
- Big-bang implementation steps:
  1. Normalize archived steady-state and final-closeout manifests plus missing
     archive-local metadata artifacts.
  2. Archive the provenance-alignment implementing packet with implemented
     archive metadata and promotion-evidence references.
  3. Add ADR 068 and this migration plan; update decision and migration
     discovery indexes.
  4. Create the matching migration evidence bundle.
  5. Update `/.octon/README.md`, `/.octon/instance/bootstrap/START.md`, and
     the umbrella architecture docs to reference runtime truth and provenance
     closeout explicitly.
  6. Regenerate `/.octon/generated/proposals/registry.yml`.
  7. Run proposal, registry, version, architecture, and alignment validation on
     the final tree.
- Big-bang rollout steps:
  1. Merge only after the final tree is validator-clean and registry-clean.
  2. Treat the merged tree as the only supported MSRAOM provenance model.
  3. If the final tree cannot be made coherent in one step, do not merge.

## Impact Map

### Proposal lineage and discovery

- `/.octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy-steady-state-cutover/**`
- `/.octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy-final-closeout-cutover/**`
- `/.octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy-provenance-alignment-closeout/**`
- `/.octon/generated/proposals/registry.yml`

### Decision and migration discovery

- `/.octon/instance/cognition/decisions/068-mission-scoped-reversible-autonomy-provenance-alignment-closeout.md`
- `/.octon/instance/cognition/decisions/index.yml`
- `/.octon/instance/cognition/context/shared/migrations/2026-03-25-mission-scoped-reversible-autonomy-provenance-alignment-closeout/plan.md`
- `/.octon/instance/cognition/context/shared/migrations/index.yml`
- `/.octon/state/evidence/migration/2026-03-25-mission-scoped-reversible-autonomy-provenance-alignment-closeout/**`

### Operator-facing guidance

- `/.octon/README.md`
- `/.octon/instance/bootstrap/START.md`
- `/.octon/framework/cognition/_meta/architecture/specification.md`
- `/.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md`

### Expected no-change zones

- `/.octon/framework/orchestration/runtime/**`
- `/.octon/framework/engine/runtime/**`
- `/.octon/instance/governance/policies/mission-autonomy.yml`
- `/.octon/instance/governance/ownership/registry.yml`
- `/.octon/state/control/execution/**`
- `/.octon/state/evidence/control/**`
- `/.octon/state/evidence/runs/**`
- `/.octon/generated/effective/**`
- `/.octon/generated/cognition/**`
- `/.github/workflows/**`

## Compliance Receipt

- [x] Exactly one profile selected before implementation
- [x] Release-state gate applied
- [x] Pre-1.0 atomic default respected
- [x] Hard-gate fact collection recorded
- [x] Tie-break rule enforced
- [x] Required validations linked

## Verification Evidence

- Validation receipts: `validation.md`
- Command log: `commands.md`
- Change inventory: `inventory.md`
- ADR:
  `/.octon/instance/cognition/decisions/068-mission-scoped-reversible-autonomy-provenance-alignment-closeout.md`
- Evidence bundle:
  `/.octon/state/evidence/migration/2026-03-25-mission-scoped-reversible-autonomy-provenance-alignment-closeout/`

## Rollback

- revert the full provenance-alignment change set
- restore the previous archived proposal manifests if needed
- regenerate the proposal registry from the reverted manifests
- remove ADR 068 and the provenance-alignment migration record if the revert
  restores the pre-closeout provenance state
