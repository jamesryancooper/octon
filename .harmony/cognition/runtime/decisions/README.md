---
title: Runtime Decision Records
description: Canonical append-only ADR records and discovery index for cognition runtime decisions.
---

# Runtime Decision Records

This directory is the canonical runtime surface for full ADR artifacts.

## Purpose

- Keep full append-only ADR records in one runtime-owned location.
- Preserve lightweight decision summaries in `/.harmony/cognition/runtime/context/decisions.md`.
- Provide machine discovery through a single index.
- Allow optional companion evidence bundles when deeper verification receipts are needed.

## Contract

- Each ADR record MUST live in:
  - `/.harmony/cognition/runtime/decisions/<NNN>-<slug>.md`
- Machine discovery MUST resolve through:
  - `/.harmony/cognition/runtime/decisions/index.yml`
- Human-oriented summary and active decision table remain in:
  - `/.harmony/cognition/runtime/context/decisions.md`

## Optional Evidence Bundles

When decision-specific verification evidence is needed, store it in:

- `/.harmony/output/reports/decisions/<NNN>-<slug>/`

Bundle contract (when present):

- `bundle.yml`
- `evidence.md`
- `commands.md`
- `validation.md`
- `inventory.md`
