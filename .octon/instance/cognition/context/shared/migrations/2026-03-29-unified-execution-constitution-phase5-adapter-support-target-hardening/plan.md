---
title: Unified Execution Constitution Phase 5 Adapter Support Target Hardening
description: Atomic migration record for adapter contract hardening, governed capability-pack admission, and fail-closed support-target enforcement.
---

# Migration Plan

## Governing Input

- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/README.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/architecture/implementation-plan.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/architecture/portability-adapters-support-targets.md`
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
  - downtime tolerance: medium; adapter contracts, support-target declarations,
    pack admission, and runtime enforcement must move together, but all changes
    are repo-local and can land in one branch
  - external consumer coordination ability: not required; the Phase 5 work
    remains internal to Octon’s governance, runtime, and CI surfaces
  - data migration and backfill needs: low-to-medium; seeded evidence and
    validation surfaces need updated adapter/support-target framing, but no
    broad state migration is required
  - rollback mechanism: revert the Phase 5 change set to restore the thinner
    adapter manifests and pre-pack-admission routing
  - blast radius and uncertainty: high; runtime authorization, support-target
    declarations, constitutional contracts, capability surfaces, and CI gates
    all participate
  - compliance and policy constraints: unsupported tuples must fail closed, new
    support claims must remain adapter-conformance-backed, and browser/API
    packs may only be admitted if governed criteria are satisfied
- Hard-gate outcomes:
  - model adapters must publish conformance suites, contamination/reset policy,
    support-tier declarations, and known limitations
  - host adapters must publish the canonical host-family set: GitHub, CI,
    local CLI, and Studio
  - governed capability packs must exist as explicit surfaces, with browser/API
    remaining unadmitted unless supported by criteria and evidence
  - runtime must deny unsupported tuples rather than treating the matrix as
    advisory
- Tie-break status: `atomic` selected because the target-state-correct
  architecture requires authored contracts, runtime enforcement, and CI
  validation to agree in one coherent change set
- Transitional Exception Note: N/A
- `transitional_exception_note`: N/A

## Implementation Summary

- Name: Unified execution constitution Phase 5 adapter and support-target
  hardening
- Owner: Octon maintainers
- Motivation: harden adapter contracts and conformance, publish the real
  support-target matrix, add governed capability-pack admission, and fail
  closed on unsupported tuples
- Scope:
  - enrich constitutional and runtime adapter manifests
  - add canonical host adapter coverage for GitHub, CI, local CLI, and Studio
  - publish governed capability-pack contracts plus repo-local pack admission
  - tighten the support-target matrix to explicit allowed capability packs
  - enforce adapter manifests and pack admission in runtime authorization
  - add Phase 5 validation and CI enforcement

## Atomic Execution

1. Harden model adapter contracts so conformance suites, contamination reset
   posture, support-tier declarations, and known limitations are explicit.
2. Finalize host adapter contracts so GitHub, CI, local CLI, and Studio are
   all published as replaceable, non-authoritative host families.
3. Add governed capability-pack contracts and repo-local pack admission, with
   browser/API remaining unadmitted and fail-closed.
4. Extend runtime authorization to validate adapter manifests and pack
   admission before allowing support-tier claims.
5. Update validators, CI, and migration evidence so the Phase 5 exit criteria
   are machine-checkable and discoverable.

## Impact Map

### Constitutional and governance contracts

- `/.octon/framework/constitution/contracts/adapters/**`
- `/.octon/framework/constitution/contracts/registry.yml`
- `/.octon/framework/constitution/precedence/normative.yml`
- `/.octon/instance/governance/support-targets.yml`
- `/.octon/instance/capabilities/runtime/packs/**`

### Runtime enforcement and capability surfaces

- `/.octon/framework/engine/runtime/adapters/**`
- `/.octon/framework/engine/runtime/crates/kernel/src/{authorization.rs,pipeline.rs,workflow.rs}`
- `/.octon/framework/engine/runtime/{config/policy-interface.yml,spec/*.md}`
- `/.octon/framework/capabilities/packs/**`
- `/.octon/octon.yml`

### Validation and CI

- `/.octon/framework/assurance/runtime/_ops/scripts/{validate-wave5-agency-adapter-hardening.sh,validate-phase5-adapter-support-target-hardening.sh,validate-harness-structure.sh,validate-execution-governance.sh}`
- `/.github/workflows/architecture-conformance.yml`

## Verification Evidence

- ADR:
  `/.octon/instance/cognition/decisions/081-unified-execution-constitution-phase5-adapter-support-target-hardening.md`
- Evidence bundle:
  `/.octon/state/evidence/migration/2026-03-29-unified-execution-constitution-phase5-adapter-support-target-hardening/`

## Rollback

- revert the Phase 5 change set
- remove the capability-pack contracts and runtime pack admission registry
  introduced here
- restore the prior thinner adapter manifests and authorization logic only as
  part of the same full revert
- do not leave runtime in a state where support-target declarations reference
  pack or adapter details that the authorization path no longer enforces
