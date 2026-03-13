---
title: AI Agent Instructions for Profile-Governed Migrations
description: Agent operating rules for selecting and executing atomic or transitional change profiles under migration governance policy.
---

# AI Agent Instructions: Profile-Governed Migrations

This file name is retained for continuity. The governing model is now profile-based (`atomic` or `transitional`).

## Operating Mode

- Treat any interface, contract, or authority change as a migration.
- Select exactly one `change_profile` before implementation.
- Emit `Profile Selection Receipt` before implementation evidence.

## Hard Constraints (MUST)

1. Apply semantic release-state gate (`pre-1.0` vs `stable`) and record machine key `release_state`.
2. In `pre-1.0`, default to `atomic`.
3. Choose `transitional` only when hard gates require it.
4. If `transitional` in pre-1.0, include `transitional_exception_note`:
   - rationale
   - risks
   - owner
   - target removal/decommission date
5. If profile tie-break ambiguity exists, stop and escalate.

## Prohibited (MUST NOT)

- Starting implementation without one selected profile and receipt.
- Using `transitional` in pre-1.0 without required exception note.
- Leaving transitional coexistence in place after final decommission date.
- Silent fallback between profiles.

## Required Outputs (MUST)

- Create or update a migration plan from `/.octon/scaffolding/runtime/templates/migrations/template.clean-break-migration.md`
  at `/.octon/cognition/runtime/migrations/<YYYY-MM-DD>-<slug>/plan.md`
- Update `/.octon/cognition/practices/methodology/migrations/legacy-banlist.md` when legacy surfaces are removed.
- Provide verification evidence in `/.octon/output/reports/migrations/<YYYY-MM-DD>-<slug>/`
  with `bundle.yml`, `evidence.md`, `commands.md`, `validation.md`, and `inventory.md`
- Include required top-level sections:
  1. `Profile Selection Receipt`
  2. `Implementation Plan`
  3. `Impact Map (code, tests, docs, contracts)`
  4. `Compliance Receipt`
  5. `Exceptions/Escalations`

## If an Exception Is Required

Stop and produce an exception request aligned with:

- `/.octon/cognition/practices/methodology/migrations/exceptions.md`
