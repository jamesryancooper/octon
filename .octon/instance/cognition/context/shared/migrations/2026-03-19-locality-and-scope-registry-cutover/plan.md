---
title: Locality And Scope Registry Atomic Cutover
description: Atomic clean-break migration plan for promoting Packet 6 locality and scope enforcement.
---

# Migration Plan

## Profile Selection Receipt

- Date: 2026-03-19
- Version source(s): `/.octon/octon.yml`
- Current version: `0.5.0`
- Release state (`pre-1.0` or `stable`): `pre-1.0`
- `release_state` (`pre-1.0` or `stable`): `pre-1.0`
- `change_profile` (`atomic` or `transitional`): `atomic`
- Selection facts:
  - downtime tolerance: one-step cutover is acceptable because this is an
    internal harness authority and validation migration
  - external consumer coordination ability: not required; the harness is
    self-hosted in this repository
  - data migration/backfill needs: no staged backfill window; this is a
    structure, validator, doc, and generated-output convergence sweep
  - rollback mechanism: full revert of the cutover change set
  - blast radius and uncertainty: broad control-plane sweep across locality,
    validation, CI, scaffolding, and migration evidence
  - compliance/policy constraints: fail closed on ambiguous scope resolution,
    stale effective locality outputs, or alternate locality authority
- Hard-gate outcomes:
  - no zero-downtime requirement
  - no external coexistence requirement
  - no staged publication requirement
- Tie-break status: `atomic` selected without exception
- Transitional Exception Note (required when `change_profile=transitional` in pre-1.0): N/A
- `transitional_exception_note` (required when `change_profile=transitional` in pre-1.0):
  - rationale: N/A
  - risks: N/A
  - owner: N/A
  - target_removal_date: N/A

## Implementation Plan

- Name: Locality and scope registry atomic cutover
- Owner: `architect`
- Motivation: Promote Packet 6 so locality becomes one root-owned,
  machine-enforceable scope registry with compiled effective outputs and local
  quarantine semantics.
- Scope: locality manifests, scope manifests, scope-local durable context
  anchors, compiled effective locality outputs, locality validators, CI hooks,
  mission scope references, docs/templates, ADRs, and migration evidence.

### Atomic Profile Execution

- Clean-break approach:
  - materialize the canonical scope registry and one live scope in the same
    change set
  - add compiled effective locality outputs and mutable locality quarantine
    state with fail-closed validation
  - rewrite active docs, templates, and workflow guidance to the Packet 6
    locality contract
  - record one ADR and one migration evidence bundle
- Big-bang implementation steps:
  - create canonical scope manifests and scope-context anchors
  - add locality publication and validation scripts plus fixture-based tests
  - wire locality checks into harness alignment and CI flows
  - update architecture, bootstrap, agency, mission, and scaffolding surfaces
  - publish effective locality outputs and record migration evidence
- Big-bang rollout steps:
  - run locality validators, publication checks, and harness alignment locally
  - refresh generated ADR summaries from the updated decision index
  - publish one migration evidence bundle

### Transitional Profile Execution (if selected)

- Not applicable. Packet 6 is landing under `atomic`.

## Impact Map (code, tests, docs, contracts)

### Code

- Files changed:
  - locality manifests, scope definitions, scope-context anchors, publication
    scripts, validators, tests, CI hooks, scaffolding assets, ADRs, and
    migration evidence
- Legacy removals:
  - `nearest-registry-wins` locality semantics
  - convention-only locality without compiled effective outputs

### Tests

- Final-state tests:
  - `test-validate-locality-registry.sh`
  - `test-validate-locality-publication-state.sh`
  - `test-validate-repo-instance-boundary.sh`
  - `alignment-check.sh --profile harness`
- Phase-behavior tests (if transitional):
  - N/A

### Docs

- Updated docs/runbooks:
  - root README
  - bootstrap START/orientation surfaces
  - locality principle and capabilities architecture docs
  - shared-foundation and umbrella specification
  - update/migrate harness workflow stages

### Contracts

- Schemas/manifests/contracts changed:
  - locality manifest and registry enforcement
  - per-scope manifest schema contract
  - effective locality publication contract
  - locality quarantine contract
  - Packet 6 migration evidence bundle

## Compliance Receipt

- [x] Exactly one profile selected before implementation
- [x] Release-state gate applied
- [x] Pre-1.0 atomic default respected (or transitional exception documented)
- [x] Hard-gate fact collection recorded
- [x] Tie-break rule enforced
- [x] Obsolete/legacy surfaces removed at final state
- [x] Required validations executed and linked

## Exceptions/Escalations

- Current exceptions: scope continuity remains intentionally gated off until
  Packet 7
- Escalations raised: none
- Risk acceptance owner: Octon maintainers

## Verification Evidence

### Static Verification

- [x] Packet 6 docs enumerate canonical locality inputs, outputs, and
      quarantine surfaces
- [x] Active docs no longer describe locality as nearest-registry fallback

### Runtime Verification

- [x] Packet 6 locality validators pass in the live repo
- [x] Effective locality outputs publish from authoritative locality inputs

### CI Verification

- [x] Harness and smoke entrypoints exercise Packet 6 locality validator paths

Required evidence bundle location:

- `/.octon/state/evidence/migration/2026-03-19-locality-and-scope-registry-cutover/`
- bundle files:
  - `bundle.yml`
  - `evidence.md`
  - `commands.md`
  - `validation.md`
  - `inventory.md`

## Rollback

- Rollback strategy: full commit-range revert of this cutover
- Rollback trigger conditions:
  - locality validation cannot converge to one unambiguous scope registry
  - effective locality outputs cannot be published consistently from authored
    locality inputs
- Rollback evidence references:
  - `/.octon/state/evidence/migration/2026-03-19-locality-and-scope-registry-cutover/`
