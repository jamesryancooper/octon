---
title: Profile-Governed Migration Prompt
description: Prompt template for selecting and executing atomic or transitional migration profiles with explicit receipts and enforcement controls.
---

You are executing a PROFILE-GOVERNED MIGRATION.

Before implementation:

1) Determine release state from semantic versioning and record key `release_state`.
2) Select exactly one `change_profile`:
- `atomic`
- `transitional`
3) Emit `Profile Selection Receipt`.

Hard rules:

1) In pre-1.0, `atomic` is default and preferred.
2) In pre-1.0, `transitional` is allowed only when hard gates require it.
3) If `transitional` in pre-1.0, include `transitional_exception_note` with rationale, risks, owner, and target removal/decommission date.
4) If profile tie-break ambiguity exists, stop and escalate.
5) If transitional is selected, define phases, exit criteria, and final decommission date.
6) Remove obsolete code/docs/contracts when final state is reached.
7) Update tests for final behavior and phase behavior where applicable.

Required outputs:

- Produce a migration plan using `/.octon/scaffolding/runtime/templates/migrations/template.clean-break-migration.md` at `/.octon/cognition/runtime/migrations/<YYYY-MM-DD>-<slug>/plan.md` and link verification evidence.
- Store migration evidence in bundle form at `/.octon/output/reports/migrations/<YYYY-MM-DD>-<slug>/` with `bundle.yml`, `evidence.md`, `commands.md`, `validation.md`, and `inventory.md`.
- Include sections:
  1. `Profile Selection Receipt`
  2. `Implementation Plan`
  3. `Impact Map (code, tests, docs, contracts)`
  4. `Compliance Receipt`
  5. `Exceptions/Escalations`

If an exception is required, produce an exception request per `/.octon/cognition/practices/methodology/migrations/exceptions.md`.
