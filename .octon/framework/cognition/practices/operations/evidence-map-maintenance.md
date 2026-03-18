---
title: Evidence Map Maintenance Runbook
description: Procedure for maintaining runtime evidence map coverage and correctness.
---

# Evidence Map Maintenance Runbook

## Purpose

Keep runtime evidence discovery aligned with decision and migration records.

## Canonical Inputs

- `/.octon/instance/cognition/context/shared/migrations/index.yml`
- `/.octon/instance/cognition/decisions/index.yml`
- `/.octon/state/evidence/migration/README.md`
- `/.octon/state/evidence/decisions/repo/reports/README.md`

## Canonical Output

- `/.octon/framework/cognition/runtime/evidence/index.yml`

## Procedure

1. Add or update source records:
   - migration records in `/.octon/instance/cognition/context/shared/migrations/index.yml`
   - optional decision evidence bundles in `/.octon/state/evidence/decisions/repo/reports/<NNN>-<slug>/`
2. Run:
   - `bash .octon/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh`
3. Validate:
   - `bash .octon/framework/cognition/_ops/runtime/scripts/validate-generated-runtime-artifacts.sh`
   - `bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`

## Guardrails

- Do not manually edit `/.octon/framework/cognition/runtime/evidence/index.yml`.
- Do not point evidence bundles to non-canonical report locations.
- Do not bypass generated-artifact drift checks.
