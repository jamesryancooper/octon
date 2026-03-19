---
title: Cognition Runtime Migrations Surface Split Plan
description: Clean-break migration plan to separate migration policy artifacts from runtime migration records and centralize migration evidence report paths.
---

# Clean-Break Migration Plan

## 1) Summary

- Name: Cognition runtime migrations surface split
- Owner: `architect`
- Motivation: Remove mixed ownership in the cognition migration area by separating policy doctrine from runtime migration records and consolidating migration evidence reports under a dedicated output subtree.
- Scope:
  - `/.octon/framework/cognition/practices/methodology/migrations/**`
  - `/.octon/instance/cognition/context/shared/migrations/**`
  - `/.octon/state/evidence/migration/**`
  - migration templates/prompts/instructions and harness guardrail scripts

## 2) What Is Being Removed (Explicit)

Legacy mixed-location migration record patterns:

- Dated migration plan records under policy surface:
  - `/.octon/framework/cognition/practices/methodology/migrations/<YYYY-MM-DD>-<slug>/plan.md`
- Root-level migration evidence reports in output reports root:
  - `/.octon/state/evidence/migration/<YYYY-MM-DD>-<slug>/evidence.md` (legacy migration evidence class before bundle isolation)

## 3) What Is the New SSOT (Explicit)

Canonical split by artifact role:

- Migration policy doctrine (unchanged location):
  - `/.octon/framework/cognition/practices/methodology/migrations/`
- Runtime migration records (new canonical location):
  - `/.octon/instance/cognition/context/shared/migrations/<YYYY-MM-DD>-<slug>/plan.md`
  - `/.octon/instance/cognition/context/shared/migrations/index.yml`
- Migration evidence outputs (new canonical location):
  - `/.octon/state/evidence/migration/<YYYY-MM-DD>-<slug>/evidence.md`

## 4) Clean-Break Constraints (Affirm)

- [x] No dual-mode execution
- [x] No compatibility shims or adapters
- [x] No transitional flags
- [x] Legacy removed in the same change set

## 5) Removal Plan

### Code

- Move all dated migration plan records from practices migration policy surface to runtime migration surface.
- Move existing migration evidence reports from output reports root to `/.octon/state/evidence/migration/`.
- Add harness structure guardrails to fail closed if dated migration records reappear under practices or migration evidence reappears at reports root.

### Contracts

- Update migration template destination to runtime migration path.
- Update policy README and CI-gate docs to reflect split ownership and runtime migration index.
- Update audit-subsystem-health alignment contract and guardrail script watchers.
- Update legacy banlist with removed legacy migration record prefix path.

### Docs

- Update cognition and runtime READMEs to include `runtime/migrations/`.
- Update output docs to include migration evidence report subpath conventions.
- Add runtime migration index and README for centralized discovery.

### Tests and Validation

- Run harness structure validation.
- Run audit-subsystem-health alignment validation.
- Run workflows and skills validations.
- Run alignment profile (`skills,workflows,harness`).
- Run static sweeps for removed legacy migration record and report path patterns.

## 6) Replacement Plan

- New components or files:
  - `/.octon/instance/cognition/context/shared/migrations/README.md`
  - `/.octon/instance/cognition/context/shared/migrations/index.yml`
  - `/.octon/state/evidence/migration/README.md`
  - `/.octon/instance/cognition/context/shared/migrations/2026-02-21-cognition-runtime-migrations-surface-split/plan.md`
- Updated entrypoints/contracts:
  - clean-break migration template destination path
  - harness structure guardrails for migration-record and migration-evidence surfaces

## 7) Verification

### A) Static Verification

- [x] No dated migration records remain under practices migration policy surface.
- [x] No migration evidence reports remain in `/.octon/state/evidence/validation/` root.

### B) Runtime Verification

- [x] Runtime migration index resolves all existing migration records.
- [x] Legacy locations are impossible under guardrail checks.

### C) CI Verification

- [x] CI/local guardrails updated to prevent legacy reintroduction.

## 8) Definition of Done

- [x] Single authority only
- [x] Legacy deleted (paths, docs, contracts)
- [x] All call-sites updated
- [x] CI/validation gates pass locally
- [x] Plan links to evidence

Required evidence artifacts:

- `/.octon/state/evidence/migration/2026-02-21-cognition-runtime-migrations-surface-split/evidence.md`
- `/.octon/instance/cognition/decisions/031-cognition-runtime-migrations-surface-split.md`

## 9) Rollback

Rollback is full commit-range revert of this migration. No partial rollback modes are allowed.
