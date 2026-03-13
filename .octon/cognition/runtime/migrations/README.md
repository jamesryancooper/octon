---
title: Runtime Migration Records
description: Canonical runtime records for clean-break migrations, separated from migration policy doctrine.
---

# Runtime Migration Records

This directory is the canonical runtime surface for migration execution records.

## Purpose

- Keep migration plans in a runtime-owned location.
- Keep migration policy/doctrine in `/.octon/cognition/practices/methodology/migrations/`.
- Keep generated migration evidence bundles in
  `/.octon/output/reports/migrations/<YYYY-MM-DD>-<slug>/`.
- Keep runtime evidence discovery in:
  - `/.octon/cognition/runtime/evidence/index.yml`.

## Contract

- Each migration record MUST live in:
  - `/.octon/cognition/runtime/migrations/<YYYY-MM-DD>-<slug>/plan.md`
- Machine discovery MUST resolve through:
  - `/.octon/cognition/runtime/migrations/index.yml`
- Migration governance doctrine/banlist/exceptions remain in:
  - `/.octon/cognition/practices/methodology/migrations/`
- Migration evidence bundle contract requires:
  - `bundle.yml`
  - `evidence.md`
  - `commands.md`
  - `validation.md`
  - `inventory.md`

## Records

See `index.yml` for the canonical list and linked artifacts (plan, ADR, evidence).
