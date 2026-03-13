---
title: Artifact Surface Clean-Break Rename Plan
description: Clean-break migration plan to replace optional content-plane architecture naming/path authority with artifact-surface naming/path authority.
---

# Clean-Break Migration Plan

## 1) Summary

- Name: Content-plane -> artifact-surface clean-break rename
- Owner: `architect`
- Motivation: Remove legacy optional-surface naming and align active
  architecture docs with the foundational plane model and artifact-oriented
  terminology.
- Scope:
  - `/.octon/cognition/_meta/architecture/artifact-surface/**`
  - cross-surface references in continuity and knowledge docs
  - migration governance records and legacy banlist

## 2) What Is Being Removed (Explicit)

Legacy optional-surface naming/path authority:

- Optional surface path: `/.octon/cognition/_meta/architecture/content-plane/`
- Runtime layer doc: `runtime-content-layer.md`
- Legacy terminology tokens in active docs:
  - `Content Plane`
  - `HCP`
  - `Octon Content Graph`

## 3) What Is the New SSOT (Explicit)

Canonical optional-surface naming/path authority:

- Optional surface path: `/.octon/cognition/_meta/architecture/artifact-surface/`
- Runtime layer doc: `runtime-artifact-layer.md`
- Canonical terminology tokens in active docs:
  - `Artifact Surface`
  - `HAS`
  - `Octon Artifact Graph`

## 4) Clean-Break Constraints (Affirm)

- [x] No dual-mode execution
- [x] No compatibility shims or adapters
- [x] No transitional flags
- [x] Legacy removed in the same change set

## 5) Removal Plan

### Code/Docs

- Rename optional architecture directory to `artifact-surface`.
- Rename runtime layer doc to `runtime-artifact-layer.md`.
- Replace legacy path/token call-sites across active docs.
- Reframe optional-surface references in foundational integration docs.

### Contracts

- Update active related-doc links to the new optional-surface path.
- Update migration governance indexes and evidence map entries.
- Add legacy-banlist entries for removed optional-surface path/file.

### Validation

- Static sweeps for removed `content-plane` tokens/path in active `.octon`
  docs.
- Diff hygiene checks on touched markdown files.
- Migration evidence bundle recorded under canonical migration reports path.

## 6) Replacement Plan

- New runtime migration record:
  - `/.octon/cognition/runtime/migrations/2026-02-22-artifact-surface-clean-break-rename/plan.md`
- New decision record:
  - `/.octon/cognition/runtime/decisions/037-artifact-surface-clean-break-rename.md`
- New migration evidence bundle:
  - `/.octon/output/reports/migrations/2026-02-22-artifact-surface-clean-break-rename/`

## 7) Verification

### A) Static Verification

- [x] Legacy optional-surface path removed from active docs.
- [x] Legacy `runtime-content-layer.md` path removed from active docs.
- [x] Legacy `Content Plane`/`HCP` terms removed from active docs.

### B) Runtime/Contract Verification

- [x] Foundational integration contract resolves optional surface through
  `artifact-surface` path.
- [x] Knowledge-plane related docs resolve optional surface through
  `artifact-surface` path.

### C) Governance Verification

- [x] Runtime decisions index updated with ADR 037.
- [x] Runtime migrations index updated with migration record.
- [x] Runtime evidence index updated with migration evidence record.
- [x] Legacy-banlist updated to block reintroduction.

## 8) Definition of Done

- [x] Single authority only
- [x] Legacy deleted (path + naming in active docs)
- [x] All call-sites updated
- [x] Runtime migration and decision records added
- [x] Evidence bundle recorded

Required evidence artifacts:

- `/.octon/output/reports/migrations/2026-02-22-artifact-surface-clean-break-rename/evidence.md`
- `/.octon/cognition/runtime/decisions/037-artifact-surface-clean-break-rename.md`

## 9) Rollback

Rollback is full commit-range revert of this migration. No partial rollback
modes are allowed.
