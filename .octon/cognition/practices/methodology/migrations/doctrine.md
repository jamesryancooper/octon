---
title: Change-Profile Migration Doctrine
description: Default migration doctrine requiring explicit profile selection and governed execution gates.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-05
canonical_links:
  - "/AGENTS.md"
  - "/.octon/agency/governance/CONSTITUTION.md"
  - "/.octon/agency/governance/DELEGATION.md"
  - "/.octon/agency/governance/MEMORY.md"
  - "/.octon/cognition/practices/methodology/authority-crosswalk.md"
---

# Change-Profile Migration Doctrine

## 0) Terms

- `change_profile`: governance profile selected for a change (`atomic` or `transitional`).
- `release_state`: semantic release mode (`pre-1.0` or `stable`).
- `transitional_exception_note`: required in `pre-1.0` when `change_profile=transitional`; must include `rationale`, `risks`, `owner`, and `target_removal_date`.
- Atomic migration: single-cutover migration with one authoritative post-merge path.
- Transitional migration: phased migration that temporarily allows coexistence to satisfy hard gates.
- Hard gates: non-negotiable conditions that require transitional execution.

## 1) Primary Rule

All migrations MUST select exactly one profile before implementation:

- `atomic`
- `transitional`

No migration may proceed without a `Profile Selection Receipt`.

## 2) Release-Maturity Gate (MUST)

1. Determine semantic release state.
2. `pre-1.0`: `< 1.0.0` or prerelease (`alpha`, `beta`, `rc`).
3. `stable`: `>= 1.0.0` and not prerelease.
4. In `pre-1.0`, default to `atomic`.
5. In `pre-1.0`, `transitional` is allowed only when hard gates require it and `transitional_exception_note` is present.
6. In `stable`, apply normal profile selection logic without `atomic` default bias.

## 3) Selection Method (MUST)

### A) Fact Collection

Collect and record:

- downtime tolerance
- external consumer coordination ability
- data migration/backfill needs
- rollback mechanism
- blast radius and uncertainty
- compliance/policy constraints

### B) Hard Gates

Choose `transitional` if any are true:

- zero-downtime requirement prevents one-step cutover
- external consumers cannot migrate in one coordinated release
- live migration/backfill requires temporary coexistence for correctness
- operational risk requires progressive exposure and staged validation

If none are true, choose `atomic`.

### C) Tie-Break

If both profile conditions appear true, stop and escalate with a profile exception request.

## 4) Execution Constraints (MUST)

### Atomic

- one-step implementation and rollout
- no temporary coexistence surfaces
- remove obsolete legacy surfaces in same change set
- rollback path explicit (typically full revert)

### Transitional

- explicit phases
- phase exit criteria
- final decommission/removal date
- final-state cleanup required
- tests for phase behavior and final behavior

## 5) Required Verification (MUST)

A migration is incomplete unless it proves:

- selected profile and rationale are documented
- required fields for selected profile are present
- docs/contracts/tests align with selected profile
- CI enforces anti-regression for legacy/profile constraints

## 6) Merge Rule (MUST)

A migration branch must not merge until:

- required plan sections are complete,
- profile-specific constraints are satisfied,
- CI gates pass.

## 7) Exception Policy

Exceptions are controlled. See `exceptions.md`.
