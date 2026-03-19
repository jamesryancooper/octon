---
title: Repo-Instance Architecture Atomic Cutover
description: Atomic clean-break migration plan for promoting Packet 4 repo-instance authority.
---

# Migration Plan

## Profile Selection Receipt

- Date: 2026-03-18
- Version source(s): `/.octon/octon.yml`
- Current version: `0.5.0`
- Release state (`pre-1.0` or `stable`): `pre-1.0`
- `release_state` (`pre-1.0` or `stable`): `pre-1.0`
- `change_profile` (`atomic` or `transitional`): `atomic`
- Selection facts:
  - downtime tolerance: one-step cutover is acceptable because this is an
    internal harness authority migration
  - external consumer coordination ability: not required; the harness is
    self-hosted in this repository
  - data migration/backfill needs: none outside repo-local structure, doc, and
    validator rewrites
  - rollback mechanism: full revert of the cutover change set
  - blast radius and uncertainty: broad doc and validator sweep, but within one
    authoritative harness root
  - compliance/policy constraints: fail closed on mixed authority or partial
    packet-4 structure
- Hard-gate outcomes:
  - no zero-downtime requirement
  - no external migration coexistence requirement
  - no backfill window that requires staged publication
- Tie-break status: `atomic` selected without exception
- Transitional Exception Note (required when `change_profile=transitional` in pre-1.0): N/A
- `transitional_exception_note` (required when `change_profile=transitional` in pre-1.0):
  - rationale: N/A
  - risks: N/A
  - owner: N/A
  - target_removal_date: N/A

## Implementation Plan

- Name: Repo-instance architecture atomic cutover
- Owner: `architect`
- Motivation: Promote Packet 4 so `instance/**` becomes the only canonical
  repo-owned durable authority layer.
- Scope: `/.octon/instance/**` plus active docs, workflows, templates,
  validators, and CI surfaces that still rely on mixed repo-instance path
  assumptions.

### Atomic Profile Execution

- Clean-break approach:
  - materialize missing packet-4 instance structure in the same change set
  - rewrite active operator and contract surfaces to the packet-4 path model
  - add fail-closed repo-instance boundary validation and wire it into the
    harness gate
  - record migration evidence as one promotion bundle
- Big-bang implementation steps:
  - create canonical mission and overlay-capable instance surfaces
  - add repo-instance boundary validator and tests
  - update harness docs, workflows, templates, and CI wiring
  - promote the proposal status to `implemented`
- Big-bang rollout steps:
  - run packet-4 validation gates locally
  - run `repo_snapshot` export verification
  - publish one migration evidence bundle

### Transitional Profile Execution (if selected)

- Not applicable. Packet 4 is landing under `atomic`.

## Impact Map (code, tests, docs, contracts)

### Code

- Files changed:
  - instance structure, validators, workflow stages, scaffolding templates,
    bootstrap docs, migration evidence, proposal status surfaces
- Legacy removals:
  - active mixed-path repo-instance references in packet-4 control-plane docs

### Tests

- Final-state tests:
  - repo-instance boundary validator fixtures
  - harness alignment gate including packet-4 checks
  - export profile verification for `repo_snapshot`
- Phase-behavior tests (if transitional):
  - N/A

### Docs

- Updated docs/runbooks:
  - root README
  - instance bootstrap and catalog surfaces
  - shared-foundation and umbrella specification
  - mission and locality guidance

### Contracts

- Schemas/manifests/contracts changed:
  - repo-instance structure contract
  - harness structure validator expectations
  - packet-4 migration evidence bundle

## Compliance Receipt

- [x] Exactly one profile selected before implementation
- [x] Release-state gate applied
- [x] Pre-1.0 atomic default respected (or transitional exception documented)
- [x] Hard-gate fact collection recorded
- [x] Tie-break rule enforced
- [x] Obsolete/legacy surfaces removed at final state
- [x] Required validations executed and linked

## Exceptions/Escalations

- Current exceptions:
  - generated decision summary remains temporarily at
    `/.octon/instance/cognition/context/shared/decisions.md` until Packet 10
    and Packet 11 rehome that generated surface
- Escalations raised: none
- Risk acceptance owner: Octon maintainers

## Verification Evidence

### Static Verification

- [ ] No prohibited legacy packet-4 path drift remains in active control-plane
      surfaces
- [x] Required packet-4 instance structure exists

### Runtime Verification

- [x] Harness gate passes with repo-instance boundary enforcement
- [x] `repo_snapshot` exports `instance/**` without packet-4 drift

### CI Verification

- [x] CI and smoke entrypoints exercise packet-4 validator paths

Required evidence bundle location:

- `/.octon/state/evidence/migration/2026-03-18-repo-instance-architecture-cutover/`
- bundle files:
  - `bundle.yml`
  - `evidence.md`
  - `commands.md`
  - `validation.md`
  - `inventory.md`

## Rollback

- Rollback strategy: full commit-range revert of this cutover
- Rollback trigger conditions:
  - repo-instance validator cannot converge to a single authority path set
  - harness alignment gates fail closed after promotion
- Rollback evidence references:
  - `/.octon/state/evidence/migration/2026-03-18-repo-instance-architecture-cutover/`
