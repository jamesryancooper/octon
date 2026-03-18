---
title: Scaffolding Bounded Surfaces Clean-Break Migration Plan
description: Clean-break migration plan for separating scaffolding runtime artifacts, governance contracts, and operating practices.
---

# Clean-Break Migration Plan

## 1) Summary

- Name: Scaffolding bounded surfaces clean-break
- Owner: `architect`
- Motivation: Establish explicit separation of scaffolding runtime assets, governance patterns, and operating practices so discovery and enforcement are deterministic.
- Scope: `/.octon/framework/scaffolding/**` plus active references in harness docs, workflows, commands, skills, templates, and validators.

## 2) What Is Being Removed (Explicit)

- Legacy scaffolding root runtime paths:
  - `/.octon/framework/scaffolding/templates/`
  - `/.octon/framework/scaffolding/_ops/scripts/`
- Legacy scaffolding root operating paths:
  - `/.octon/framework/scaffolding/prompts/`
  - `/.octon/framework/scaffolding/examples/`
- Legacy scaffolding root governance path:
  - `/.octon/framework/scaffolding/patterns/`

## 3) What Is the New SSOT (Explicit)

- Runtime scaffolding authority:
  - `/.octon/framework/scaffolding/runtime/templates/`
  - `/.octon/framework/scaffolding/runtime/_ops/scripts/`
- Governance scaffolding authority:
  - `/.octon/framework/scaffolding/governance/patterns/`
- Practices scaffolding authority:
  - `/.octon/framework/scaffolding/practices/prompts/`
  - `/.octon/framework/scaffolding/practices/examples/`

## 4) Clean-Break Constraints (Affirm)

- [x] No dual-mode execution
- [x] No compatibility shims or adapters
- [x] No transitional flags
- [x] Legacy removed in the same change set

## 5) Removal Plan

### Code

- Delete:
  - Legacy scaffolding root paths listed above.
- Replace call-sites:
  - Update docs, workflows, skills, command docs, template manifests, and scripts to canonical scaffolding runtime/governance/practices paths.
- Remove routing:
  - Remove validation and bootstrap dependencies on legacy root scaffolding paths.

### Contracts

- Remove legacy schema or manifest keys:
  - Legacy template and script path references in active manifests and workflow contracts.
- Add or adjust new schema or manifest keys:
  - Canonical scaffolding path references under `runtime/`, `governance/`, and `practices/`.

### Docs

- Remove legacy docs:
  - Remove active references to legacy scaffolding root paths.
- Update references:
  - Update root orientation docs and scaffolding architecture docs to bounded surfaces.

### Tests and Validation

- Delete legacy tests:
  - N/A (no dedicated legacy test files).
- Add or adjust tests for new SSOT:
  - Update harness validators to require new scaffolding surfaces and fail on legacy path reintroduction.

## 6) Replacement Plan

- New components or files:
  - `/.octon/framework/scaffolding/runtime/README.md`
  - `/.octon/framework/scaffolding/governance/README.md`
  - `/.octon/framework/scaffolding/practices/README.md`
  - `/.octon/instance/cognition/decisions/025-scaffolding-bounded-surfaces-clean-break-migration.md`
- New entrypoints:
  - `/.octon/framework/scaffolding/runtime/_ops/scripts/init-project.sh`
  - `/.octon/framework/scaffolding/runtime/templates/octon/manifest.json`
  - `/.octon/framework/scaffolding/governance/patterns/README.md`
- New reason codes or enums:
  - N/A.

## 7) Verification

### A) Static Verification

- [x] No active legacy identifiers remain in scoped source (excluding append-only history, migration logs, and explicit deny-lists).
- [x] No legacy scaffolding root paths remain.

### B) Runtime Verification

- [x] Canonical scaffolding runtime bootstrap path exercised.
- [x] Old paths are impossible (legacy path checks fail closed in validators).

### C) CI Verification

- [x] CI gate scripts updated or added to prevent legacy reintroduction:
  - `/.octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
  - `/.octon/instance/bootstrap/init.sh`

## 8) Definition of Done

- [x] Single authority only
- [x] Legacy deleted (code, docs, contracts)
- [x] All call-sites updated
- [x] CI gates pass locally
- [x] Plan links to evidence

## 9) Rollback

Rollback is full commit-range revert of this migration. No partial rollback modes are allowed.

## Evidence

- `/.octon/state/evidence/migration/2026-02-20-scaffolding-bounded-surfaces/evidence.md`
- `/.octon/instance/cognition/decisions/025-scaffolding-bounded-surfaces-clean-break-migration.md`
