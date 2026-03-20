---
title: Memory Routing And Decision Surfaces Atomic Cutover
description: Atomic clean-break migration plan for promoting Packet 11 memory routing, ADR authority, and generated summary enforcement.
---

# Migration Plan

## Profile Selection Receipt

- Date: 2026-03-20
- Version source(s): `/.octon/octon.yml`
- Current version: `0.5.1`
- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- Selection facts:
  - downtime tolerance: one-step cutover is acceptable because this is an
    internal harness control-plane migration
  - external consumer coordination ability: not required; the harness is
    self-hosted in this repository
  - data migration/backfill needs: no staged coexistence window; this is a
    doc/index/validator/generator/template convergence sweep plus removal of
    one duplicate generated summary surface
  - rollback mechanism: full revert of the cutover change set
  - blast radius and uncertainty: broad active-reference rewrite across
    architecture docs, bootstrap docs, skills, workflows, validators,
    scaffolding, and cognition generation scripts
  - compliance/policy constraints: fail closed on duplicate summary
    destinations, wrong-class memory placement, ADR/state confusion, or
    invalid scope continuity assumptions
- Hard-gate outcomes:
  - no zero-downtime requirement
  - no external coexistence requirement
  - no staged publication requirement
- Tie-break status: `atomic` selected without exception

## Implementation Plan

- Name: Memory routing and decision surfaces atomic cutover
- Owner: `architect`
- Motivation: Promote Packet 11 so Octon uses one fail-closed memory-routing
  contract for durable context, ADR authority, active continuity, retained
  evidence, and generated cognition views.
- Scope: memory policy, shared context routing, ADR discovery/readmes, repo and
  scope continuity guidance, operational decision evidence docs, cognition
  summary generation and validation scripts, active reference surfaces,
  scaffolding/workflow guidance, Packet 11 closeout ADR, proposal archival, and
  migration evidence.

### Atomic Profile Execution

- Clean-break approach:
  - remove the duplicate generated ADR summary from
    `instance/cognition/context/shared/decisions.md` in the same change set
    that repoints every active consumer to
    `generated/cognition/summaries/decisions.md`
  - align `framework/**`, `instance/**`, `state/**`, and `generated/**`
    contracts so memory-like artifacts have one canonical home and no active
    alternate path remains
  - harden validators and generators in the same change set so the retired
    instance-local summary path cannot reappear silently
  - preserve historical retained evidence as historical evidence unless a file
    is still an active control-plane input
  - record one Packet 11 closeout ADR and one migration evidence bundle
  - archive the Packet 11 proposal package with an `implemented` disposition
- Big-bang implementation steps:
  - delete the instance-local generated decisions summary
  - cut the cognition generator and generated-artifact validator to the
    generated-only summary model
  - rewrite active docs, workflows, skills, templates, and checklists to read
    the generated summary and write ADRs through
    `instance/cognition/decisions/**`
  - update memory-routing, continuity, and evidence docs to the final Packet 11
    one-home model
  - update boundary validators and fixtures so duplicate summary destinations
    and wrong-class memory placement fail closed
  - add the Packet 11 closeout ADR, migration plan, and migration evidence
    bundle
  - archive the proposal package and rewrite the generated proposal registry

## Impact Map (code, tests, docs, contracts)

### Code

- cognition generation scripts and generated-artifact validators
- repo-instance and harness-structure validators plus their fixtures
- active workflow, skill, and scaffolding assets that still pointed at the
  retired summary path

### Tests

- `sync-runtime-artifacts.sh --check`
- `validate-generated-runtime-artifacts.sh`
- `validate-harness-structure.sh`
- `validate-repo-instance-boundary.sh`
- `validate-continuity-memory.sh`
- `alignment-check.sh --profile harness`

### Docs

- root/bootstrap orientation surfaces
- memory policy and umbrella architecture contracts
- shared context routing docs and continuity docs
- ADR discovery docs
- active practices, workflows, and templates

### Contracts

- Packet 11 memory-routing contract
- generated-cognition summary publication contract
- repo-instance wrong-class placement contract
- continuity/evidence retention boundary contract
- proposal archive and proposal-registry contract

## Compliance Receipt

- [x] Exactly one profile selected before implementation
- [x] Release-state gate applied
- [x] Pre-1.0 atomic default respected
- [x] Hard-gate fact collection recorded
- [x] No compatibility shims or dual summary destinations introduced
- [x] Required validations executed and linked

## Exceptions/Escalations

- Current exceptions: none
- Escalations raised: none
- Risk acceptance owner: Octon maintainers

## Verification Evidence

Required evidence bundle location:

- `/.octon/state/evidence/migration/2026-03-20-memory-routing-and-decision-surfaces-cutover/`

Required bundle files:

- `bundle.yml`
- `evidence.md`
- `commands.md`
- `validation.md`
- `inventory.md`
