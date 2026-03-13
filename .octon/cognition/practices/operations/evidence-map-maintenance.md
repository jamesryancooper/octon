---
title: Evidence Map Maintenance Runbook
description: Procedure for maintaining runtime evidence map coverage and correctness.
---

# Evidence Map Maintenance Runbook

## Purpose

Keep runtime evidence discovery aligned with decision and migration records.

## Canonical Inputs

- `/.octon/cognition/runtime/migrations/index.yml`
- `/.octon/cognition/runtime/decisions/index.yml`
- `/.octon/output/reports/migrations/README.md`
- `/.octon/output/reports/decisions/README.md`

## Canonical Output

- `/.octon/cognition/runtime/evidence/index.yml`

## Procedure

1. Add or update source records:
   - migration records in `/.octon/cognition/runtime/migrations/index.yml`
   - optional decision evidence bundles in `/.octon/output/reports/decisions/<NNN>-<slug>/`
2. Run:
   - `bash .octon/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh`
3. Validate:
   - `bash .octon/cognition/_ops/runtime/scripts/validate-generated-runtime-artifacts.sh`
   - `bash .octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh`

## Guardrails

- Do not manually edit `/.octon/cognition/runtime/evidence/index.yml`.
- Do not point evidence bundles to non-canonical report locations.
- Do not bypass generated-artifact drift checks.
