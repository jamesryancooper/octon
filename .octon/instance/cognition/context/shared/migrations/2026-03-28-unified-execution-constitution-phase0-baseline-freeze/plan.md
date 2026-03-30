---
title: Unified Execution Constitution Phase 0 Baseline Freeze
description: Atomic migration record for the packet-governed Phase 0 baseline freeze against the live repository state.
---

# Migration Plan

## Governing Input

- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/README.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/architecture/implementation-plan.md`
- `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/architecture-proposal.yml`
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
  - downtime tolerance: high; Phase 0 adds retained planning and disclosure
    artifacts only and does not change live runtime resolution
  - external consumer coordination ability: not required; the work stays
    repo-local and additive
  - data migration and backfill needs: low; only the new Phase 0 inventory,
    frozen-input manifest, and baseline HarnessCard need to be written
  - rollback mechanism: revert the new migration record, evidence bundle, and
    baseline HarnessCard without leaving split runtime authority
  - blast radius and uncertainty: low-to-medium; the artifacts guide later
    extraction work, but they do not alter the active execution path
  - compliance and policy constraints: the baseline must record the live
    architecture accurately, keep the packet as governing input, and avoid
    creating a second authority path in `inputs/**`
- Hard-gate outcomes:
  - no zero-downtime, external-coordination, or coexistence hard gate requires
    a transitional rollout for Phase 0 itself
  - the repo already contains later-phase constitutional surfaces, so Phase 0
    must document the live state rather than attempt a historical rollback
  - target-state correctness for this phase means durable retained evidence and
    frozen inputs outside the proposal workspace
- Tie-break status: `atomic` selected because Phase 0 is an additive
  evidence-and-inventory cutover with no live runtime coexistence requirement
- Transitional Exception Note: N/A
- `transitional_exception_note`: N/A

## Implementation Summary

- Name: Unified execution constitution Phase 0 baseline freeze
- Owner: Octon maintainers
- Motivation: establish a durable, reviewable Phase 0 baseline against the
  live repo so Phase 1 extraction can proceed from explicit inventory, frozen
  inputs, and bounded disclosure instead of packet prose alone
- Scope:
  - produce a baseline internal HarnessCard v0 under retained lab evidence
  - inventory live authority, runtime, proof, and evidence surfaces outside
    the proposal workspace
  - freeze the core constitutional inputs Phase 1 extraction must treat as
    source material, shim boundaries, or de-authorization boundaries
  - register the migration and ADR in canonical cognition discovery surfaces

## Atomic Execution

1. Record the packet-governed Phase 0 migration plan and ADR in canonical
   cognition surfaces.
2. Write a Phase 0 evidence bundle with inventory, frozen-input digests,
   command log, and validation receipts under `state/evidence/migration/**`.
3. Publish a baseline internal HarnessCard v0 under
   `state/evidence/lab/harness-cards/**` that explicitly bounds the claim to
   internal repo-local baseline disclosure.
4. Update canonical discovery indexes so the new Phase 0 record is reviewable
   without reading the proposal workspace directly.

## Impact Map

### Cognition and migration records

- `/.octon/instance/cognition/context/shared/migrations/{index.yml,2026-03-28-unified-execution-constitution-phase0-baseline-freeze/**}`
- `/.octon/instance/cognition/context/shared/evidence/index.yml`
- `/.octon/instance/cognition/decisions/{index.yml,076-unified-execution-constitution-phase0-baseline-freeze.md}`

### Retained evidence and disclosure

- `/.octon/state/evidence/migration/2026-03-28-unified-execution-constitution-phase0-baseline-freeze/**`
- `/.octon/state/evidence/lab/harness-cards/hc-phase0-unified-execution-constitution-baseline-v0-20260328.{yml,md}`

### Governing live surfaces inventoried or frozen

- `/.octon/framework/constitution/**`
- `/.octon/instance/{ingress,bootstrap,cognition/context/shared}/**`
- `/.octon/framework/cognition/{_meta/architecture,governance/principles}/**`
- `/.octon/state/control/execution/**`
- `/.octon/state/continuity/runs/**`
- `/.octon/state/evidence/{runs,lab,control/execution,external-index}/**`

## Verification Evidence

- ADR:
  `/.octon/instance/cognition/decisions/076-unified-execution-constitution-phase0-baseline-freeze.md`
- Evidence bundle:
  `/.octon/state/evidence/migration/2026-03-28-unified-execution-constitution-phase0-baseline-freeze/`
- Baseline HarnessCard v0:
  `/.octon/state/evidence/lab/harness-cards/hc-phase0-unified-execution-constitution-baseline-v0-20260328.yml`

## Rollback

- revert the Phase 0 migration record, evidence bundle, and baseline
  HarnessCard
- keep the live constitutional, runtime, and evidence surfaces unchanged
- do not partially remove the indexes while leaving dangling migration or ADR
  references
