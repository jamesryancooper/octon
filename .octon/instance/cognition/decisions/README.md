---
title: Runtime Decision Records
description: Canonical append-only ADR records and discovery index for cognition runtime decisions.
---

# Runtime Decision Records

This directory is the canonical runtime surface for full ADR artifacts.

## Purpose

- Keep full append-only ADR records in one runtime-owned location.
- Provide generated lightweight decision summaries in
  `/.octon/generated/cognition/summaries/decisions.md`.
- Provide machine discovery through a single index.
- Allow optional companion evidence bundles when deeper verification receipts are needed.

## Contract

- Each ADR record MUST live in:
  - `/.octon/instance/cognition/decisions/<NNN>-<slug>.md`
- ADR numeric prefixes (`<NNN>`) MUST be unique across decision files and
  index entries.
- Machine discovery MUST resolve through:
  - `/.octon/instance/cognition/decisions/index.yml`
- Human-oriented summary is generated and remains in:
  - `/.octon/generated/cognition/summaries/decisions.md`

## Optional Evidence Bundles

When decision-specific verification evidence is needed, store it in:

- `/.octon/state/evidence/decisions/repo/reports/<NNN>-<slug>/`
- runtime evidence map:
  - `/.octon/framework/cognition/runtime/evidence/index.yml`

Bundle contract (when present):

- `bundle.yml`
- `evidence.md`
- `commands.md`
- `validation.md`
- `inventory.md`
