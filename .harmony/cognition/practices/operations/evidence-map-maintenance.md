---
title: Evidence Map Maintenance Runbook
description: Procedure for maintaining runtime evidence map coverage and correctness.
---

# Evidence Map Maintenance Runbook

## Purpose

Keep runtime evidence discovery aligned with decision and migration records.

## Canonical Inputs

- `/.harmony/cognition/runtime/migrations/index.yml`
- `/.harmony/cognition/runtime/decisions/index.yml`
- `/.harmony/output/reports/migrations/README.md`
- `/.harmony/output/reports/decisions/README.md`

## Canonical Output

- `/.harmony/cognition/runtime/evidence/index.yml`

## Procedure

1. When a new migration record is added, add/update its evidence entry under `records`.
2. When decision evidence bundles are introduced, add corresponding entries.
3. Keep `path` references relative and resolvable from the evidence index location.
4. Keep `kind` accurate (`migration` or `decision`).
5. Keep `source_record` aligned to the governing runtime index.
6. Run structure validation and correct any missing-target failures.

## Guardrails

- Do not point evidence entries to non-canonical report locations.
- Do not leave stale records after record ID/path renames.
