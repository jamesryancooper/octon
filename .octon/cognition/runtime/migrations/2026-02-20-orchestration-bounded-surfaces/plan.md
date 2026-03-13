---
title: Orchestration Bounded Surfaces Clean-Break Migration Plan
description: Clean-break migration plan for separating orchestration runtime artifacts, governance contracts, and operating practices.
---

# Clean-Break Migration Plan

## 1) Summary

- Name: Orchestration bounded surfaces clean-break
- Owner: `architect`
- Motivation: Establish explicit separation between orchestration runtime artifacts, governance contracts, and operating practices to improve boundary clarity and enforceability.
- Scope: `/.octon/orchestration/**` plus active references in harness docs, templates, scripts, runtime integrations, and CI workflows.

## 2) What Is Being Removed (Explicit)

- Legacy root runtime paths:
  - `/.octon/orchestration/workflows/`
  - `/.octon/orchestration/missions/`
- Legacy root governance paths:
  - `/.octon/orchestration/incidents.md`
  - `/.octon/orchestration/incident-response.md`
- Legacy template runtime paths:
  - `/.octon/scaffolding/templates/octon/orchestration/workflows/`
  - `/.octon/scaffolding/templates/octon/orchestration/missions/`
  - `/.octon/scaffolding/templates/<legacy-docs-template>/orchestration/workflows/`

## 3) What Is the New SSOT (Explicit)

- Runtime orchestration authority:
  - `/.octon/orchestration/runtime/workflows/`
  - `/.octon/orchestration/runtime/missions/`
- Governance authority:
  - `/.octon/orchestration/governance/incidents.md`
- Practices authority:
  - `/.octon/orchestration/practices/`
- Template authority:
  - `/.octon/scaffolding/templates/octon/orchestration/runtime/workflows/`
  - `/.octon/scaffolding/templates/octon/orchestration/runtime/missions/`
  - `/.octon/scaffolding/templates/<legacy-docs-template>/orchestration/runtime/workflows/`

## 4) Clean-Break Constraints (Affirm)

- [x] No dual-mode execution
- [x] No compatibility shims or adapters
- [x] No transitional flags
- [x] Legacy removed in the same change set

## 5) Removal Plan

### Code

- Delete:
  - Legacy root orchestration runtime and governance paths.
- Replace call-sites:
  - Update runtime crate references, scripts, CI workflows, templates, and docs to canonical runtime/governance surfaces.
- Remove routing:
  - Remove compatibility redirect artifact (`incident-response.md`) and point all references to governance SSOT.

### Contracts

- Remove legacy schema or manifest keys:
  - Legacy path references in harness/template manifests and validators.
- Add or adjust new schema or manifest keys:
  - Canonical references to `orchestration/runtime/*` and `orchestration/governance/*`.

### Docs

- Remove legacy docs:
  - Remove active references to legacy orchestration root paths.
- Update references:
  - Update orientation docs to bounded surfaces (`runtime/`, `governance/`, `practices/`).

### Tests and Validation

- Delete legacy tests:
  - N/A (no dedicated legacy test files).
- Add or adjust tests for new SSOT:
  - Update `validate-harness-structure.sh` and `validate-workflows.sh` to require new paths and fail on legacy reintroduction.

## 6) Replacement Plan

- New components or files:
  - `/.octon/orchestration/runtime/README.md`
  - `/.octon/orchestration/governance/README.md`
  - `/.octon/orchestration/practices/README.md`
  - `/.octon/cognition/runtime/decisions/022-orchestration-bounded-surfaces-clean-break-migration.md`
- New entrypoints:
  - `/.octon/orchestration/runtime/workflows/manifest.yml`
  - `/.octon/orchestration/runtime/missions/registry.yml`
  - `/.octon/orchestration/governance/incidents.md`
- New reason codes or enums:
  - N/A.

## 7) Verification

### A) Static Verification

- [x] No active legacy identifiers remain in scoped source (excluding append-only historical artifacts).
- [x] No active legacy paths remain.

### B) Runtime Verification

- [x] Workflow validation path exercised end-to-end.
- [x] Old runtime path is impossible (legacy path checks fail closed in validators).

### C) CI Verification

- [x] CI gate scripts updated or added to prevent legacy reintroduction:
  - `/.octon/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh`
  - `/.octon/assurance/_ops/scripts/validate-harness-structure.sh`

## 8) Definition of Done

- [x] Single authority only
- [x] Legacy deleted (code, docs, contracts)
- [x] All call-sites updated
- [x] CI gates pass locally
- [x] Plan links to evidence

## 9) Rollback

Rollback is full commit-range revert of this migration. No partial rollback modes are allowed.

## Evidence

- `/.octon/output/reports/migrations/2026-02-20-orchestration-bounded-surfaces/evidence.md`
- `/.octon/cognition/runtime/decisions/022-orchestration-bounded-surfaces-clean-break-migration.md`
