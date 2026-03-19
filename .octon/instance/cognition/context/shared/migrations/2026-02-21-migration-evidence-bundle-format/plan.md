---
title: Migration Evidence Bundle Format Plan
description: Clean-break migration plan to replace flat migration evidence files with multi-file evidence bundles.
---

# Clean-Break Migration Plan

## 1) Summary

- Name: Migration evidence bundle format
- Owner: `architect`
- Motivation: Replace flat migration evidence files with structured bundles that improve clarity, maintainability, and machine discovery.
- Scope:
  - `/.octon/state/evidence/migration/**`
  - `/.octon/instance/cognition/context/shared/migrations/**`
  - migration governance/docs/templates and harness guardrail scripts

## 2) What Is Being Removed (Explicit)

Legacy migration evidence surface:

- Flat migration evidence files under:
  - `/.octon/state/evidence/migration/<YYYY-MM-DD>-<slug>-evidence.md`
- Implicit single-file evidence convention where command receipts and validation receipts are not structurally separated.

## 3) What Is the New SSOT (Explicit)

Canonical migration evidence bundle surface:

- Bundle directories under:
  - `/.octon/state/evidence/migration/<YYYY-MM-DD>-<slug>/`
- Required bundle files:
  - `bundle.yml`
  - `evidence.md`
  - `commands.md`
  - `validation.md`
  - `inventory.md`

Canonical migration plan/index discovery remains under:

- `/.octon/instance/cognition/context/shared/migrations/`

## 4) Clean-Break Constraints (Affirm)

- [x] No dual-mode execution
- [x] No compatibility shims or adapters
- [x] No transitional flags
- [x] Legacy removed in the same change set

## 5) Removal Plan

### Code

- Move any flat migration evidence files to bundle directories.
- Add missing bundle files for existing migration evidence directories.
- Remove residual flat evidence paths from active migration surfaces.

### Contracts

- Update migration policy docs and templates to require bundle files.
- Update harness guardrails to fail closed on flat-file reintroduction and missing bundle files.
- Update migration discovery index entries and decision context records for bundle-format artifacts.

### Docs

- Update generated-output and validation-evidence architecture READMEs plus migration methodology docs for bundle conventions.
- Update clean-break migration prompt/instructions/template to require bundle evidence outputs at canonical `state/**` and `generated/**` destinations.

### Tests and Validation

- Run harness structure validation.
- Run audit-subsystem-health alignment validation.
- Run workflows and skills validations.
- Run alignment profile (`skills,workflows,harness`).
- Run static sweeps for removed flat evidence patterns.

## 6) Replacement Plan

- New components or files:
  - `/.octon/instance/cognition/decisions/032-migration-evidence-bundle-format.md`
  - `/.octon/instance/cognition/context/shared/migrations/2026-02-21-migration-evidence-bundle-format/plan.md`
  - `/.octon/state/evidence/migration/2026-02-21-migration-evidence-bundle-format/`
- Updated entrypoints/contracts:
  - `/.octon/state/evidence/migration/README.md`
  - `/.octon/framework/cognition/_meta/architecture/README.md`
  - `/.octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
  - migration clean-break templates/prompts/instructions

## 7) Verification

### A) Static Verification

- [x] No flat `*-evidence.md` migration files remain in `/.octon/state/evidence/migration/`.
- [x] All migration evidence bundles contain required files.

### B) Runtime Verification

- [x] Harness validator enforces bundle structure and metadata.
- [x] Runtime migration index resolves this migration plan, ADR, and evidence artifact.

### C) CI Verification

- [x] Migration governance docs/guards define and enforce bundle contract.

## 8) Definition of Done

- [x] Single authority only
- [x] Legacy deleted (paths, docs, contracts)
- [x] All call-sites updated
- [x] CI/validation gates pass locally
- [x] Plan links to evidence

Required evidence artifacts:

- `/.octon/state/evidence/migration/2026-02-21-migration-evidence-bundle-format/evidence.md`
- `/.octon/instance/cognition/decisions/032-migration-evidence-bundle-format.md`

## 9) Rollback

Rollback is full commit-range revert of this migration. No partial rollback modes are allowed.
