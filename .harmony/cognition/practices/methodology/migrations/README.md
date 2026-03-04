---
title: Change-Profile Migration Governance
description: SSOT policy hub for profile-based migration governance, selection gates, exceptions, CI enforcement, and legacy banlist controls.
---

# Change-Profile Migration Governance

This directory defines migration policy and governance for how migrations are designed, executed, and verified in this repository.

## Purpose

Establish profile-based migration governance with deterministic selection rules:

- `atomic` profile for single-cutover changes
- `transitional` profile for staged coexistence when hard gates require it

## Machine Discovery

- `index.yml` - canonical machine-readable index for migration governance doctrine artifacts.

## Scope

A change is a migration when it changes any of the following in a way that can affect consumers (humans, tools, or internal subsystems):

- Interfaces (APIs, CLIs, file formats, schemas, manifests)
- Runtime authority or decisioning (policy engines, evaluators, routing)
- Persistence or data shape
- Configuration keys or semantics
- Directory or domain ownership (SSOT moves)

## Default Policy

Migrations MUST select exactly one `change_profile` before implementation:

- `atomic`
- `transitional`

### Pre-1.0 release-state gate

- `pre-1.0` mode: semantic version `< 1.0.0` or prerelease (`alpha`, `beta`, `rc`)
- `stable` mode: semantic version `>= 1.0.0` and not prerelease
- machine key: `release_state`

In `pre-1.0` mode, `atomic` is default and preferred.

`transitional` in `pre-1.0` is allowed only when hard gates require it and MUST include `transitional_exception_note` with `rationale`, `risks`, `owner`, and `target_removal_date`.

## Selection Contract

Before implementation, every migration MUST:

1. Collect profile facts:
   - downtime tolerance
   - external consumer coordination ability
   - data migration/backfill needs
   - rollback mechanism
   - blast radius and uncertainty
   - compliance/policy constraints
2. Apply hard gates:
   - choose `transitional` if any hard gate is true
   - otherwise choose `atomic`
3. Escalate when profile tie-break ambiguity exists.

## Required Artifacts

Every migration must include:

- A runtime migration plan record at:
  - `/.harmony/cognition/runtime/migrations/<YYYY-MM-DD>-<slug>/plan.md`
  - based on `/.harmony/scaffolding/runtime/templates/migrations/template.clean-break-migration.md`
- Verification evidence (tests, logs, receipts) linked from the plan, stored under:
  - `/.harmony/output/reports/migrations/<YYYY-MM-DD>-<slug>/`
  - required bundle files:
    - `bundle.yml`
    - `evidence.md`
    - `commands.md`
    - `validation.md`
    - `inventory.md`
- Banlist updates in `legacy-banlist.md` when legacy identifiers, paths, or keys are removed.

## Required Plan Sections

Migration plans and profile-governance implementation plans MUST include:

1. `Profile Selection Receipt`
2. `Implementation Plan`
3. `Impact Map (code, tests, docs, contracts)`
4. `Compliance Receipt`
5. `Exceptions/Escalations`

## Companion Documents

- `doctrine.md`
- `invariants.md`
- `exceptions.md`
- `ci-gates.md`
- `legacy-banlist.md`

## Runtime Migration Records

Canonical migration records and discovery index live at:

- `/.harmony/cognition/runtime/migrations/README.md`
- `/.harmony/cognition/runtime/migrations/index.yml`
