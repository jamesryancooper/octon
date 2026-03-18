---
title: CI Gates for Profile-Governed Migrations
description: Required CI controls that enforce profile selection, receipt completeness, and final-state migration convergence.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-05
canonical_links:
  - "/AGENTS.md"
  - "/.octon/framework/agency/governance/CONSTITUTION.md"
  - "/.octon/framework/agency/governance/DELEGATION.md"
  - "/.octon/framework/agency/governance/MEMORY.md"
  - "/.octon/framework/cognition/practices/methodology/authority-crosswalk.md"
---

# CI Gates for Profile-Governed Migrations

## Purpose

Prevent profile-selection drift and incomplete migration governance execution.

## Required Gates (MUST)

1. Profile selection receipt presence
   - CI must fail when required `Profile Selection Receipt` fields are missing in migration/governance plans.
2. Release-state and profile consistency
   - CI must fail when `release_state` and selected `change_profile` violate selection rules.
   - Pre-1.0 transitional selection without required `transitional_exception_note` subkeys must fail:
     - `rationale`
     - `risks`
     - `owner`
     - `target_removal_date`
3. Required plan sections
   - CI must fail when required top-level sections are missing:
     - `Profile Selection Receipt`
     - `Implementation Plan`
     - `Impact Map (code, tests, docs, contracts)`
     - `Compliance Receipt`
     - `Exceptions/Escalations`
4. Transitional boundedness
   - CI must fail when `change_profile=transitional` and any are missing:
     - phases
     - phase exit criteria
     - final decommission/removal date
5. Legacy identifier banlist
   - CI must fail if banned legacy identifiers or paths reappear.
6. Migration record surface split
   - CI must fail if dated migration records appear under:
     - `/.octon/framework/cognition/practices/methodology/migrations/`
   - CI must require runtime migration discovery index at:
     - `/.octon/instance/cognition/context/shared/migrations/index.yml`
7. Migration evidence bundle contract
   - CI must fail if flat migration evidence files appear at:
     - `/.octon/state/evidence/migration/<YYYY-MM-DD>-<slug>-evidence.md` (deprecated flat evidence form only)
   - CI must require date-prefixed migration bundle directories only:
     - `/.octon/state/evidence/migration/<YYYY-MM-DD>-<slug>/`
   - CI must fail if any in-scope migration evidence bundle directory is missing required files:
     - `bundle.yml`, `evidence.md`, `commands.md`, `validation.md`, `inventory.md`

## Implementation Options (Non-Prescriptive)

- Grep-based checks for required headings and keys
- Schema validation tests for profile receipt fields
- Registry/template validation for section contracts
- Contract-aware policy checks in validator scripts

## Required Repository Artifact

Maintain the SSOT banlist at:

- `/.octon/framework/cognition/practices/methodology/migrations/legacy-banlist.md`

Maintain the canonical runtime migration index at:

- `/.octon/instance/cognition/context/shared/migrations/index.yml`
