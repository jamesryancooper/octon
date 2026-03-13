---
title: Agency Actors-to-Runtime Clean-Break Migration Plan
description: Clean-break migration plan for replacing `/.octon/agency/actors/` with `/.octon/agency/runtime/` as the sole runtime surface.
---

# Clean-Break Migration Plan

## 1) Summary

- Name: Agency actors-to-runtime clean-break
- Owner: `architect`
- Motivation: Remove the legacy `actors/` runtime surface name and enforce `runtime/` as the single canonical authority for agency runtime artifacts.
- Scope: `/.octon/agency/**`, active references across docs/templates/validators, and migration governance artifacts.

## 2) What Is Being Removed (Explicit)

- Legacy runtime surface path:
  - `/.octon/agency/actors/`
- Legacy identifiers and references that treat `actors/` as canonical.
- Validator acceptance of `agency/actors` as an expected internal path.

## 3) What Is the New SSOT (Explicit)

- Canonical runtime authority:
  - `/.octon/agency/runtime/`
- Canonical runtime registries:
  - `/.octon/agency/runtime/agents/registry.yml`
  - `/.octon/agency/runtime/assistants/registry.yml`
  - `/.octon/agency/runtime/teams/registry.yml`

## 4) Clean-Break Constraints (Affirm)

- [x] No dual-mode execution
- [x] No compatibility shims or adapters
- [x] No transitional flags
- [x] Legacy removed in the same change set

## 5) Removal Plan

### Code

- Delete:
  - `/.octon/agency/actors/` directory.
- Replace call-sites:
  - Update agency docs, scaffolding templates, and validation scripts from `actors/` to `runtime/`.
- Remove routing:
  - Remove validator logic that resolves actor registries under `agency/actors/*`.

### Contracts

- Remove legacy schema or manifest keys:
  - Remove references that define `actors/` as the runtime surface in architecture/spec contracts.
- Add or adjust new schema or manifest keys:
  - Enforce `runtime/` references in agency and harness validation scripts.

### Docs

- Remove legacy docs:
  - Remove active agency docs that describe `actors/` as canonical.
- Update references:
  - Update root AGENTS guidance and scaffolding AGENTS templates to `runtime` surface naming.

### Tests and Validation

- Delete legacy tests:
  - N/A.
- Add or adjust tests for new SSOT:
  - Update validation scripts to fail when deprecated `agency/actors` paths reappear.

## 6) Replacement Plan

- New components or files:
  - `/.octon/cognition/runtime/migrations/2026-02-21-agency-actors-to-runtime/plan.md`
  - `/.octon/cognition/runtime/decisions/028-agency-runtime-surface-clean-break-rename.md`
- New entrypoints:
  - N/A.
- New reason codes or enums:
  - N/A.

## 7) Verification

### A) Static Verification

- [x] No active legacy `agency/actors` identifiers remain (excluding historical append-only migration/decision records).
- [x] No `/.octon/agency/actors/` path remains on disk.

### B) Runtime Verification

- [x] Agency validation resolves registries and contracts from `runtime/*` only.
- [x] Harness validation fails on reintroduction of deprecated agency paths including `agency/actors`.

### C) CI Verification

- [x] CI guardrails updated/added to prevent legacy reintroduction:
  - `/.octon/agency/_ops/scripts/validate/validate-agency.sh`
  - `/.octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh`

## 8) Definition of Done

- [x] Single authority only
- [x] Legacy deleted (code, docs, contracts)
- [x] All call-sites updated
- [x] CI gates pass locally
- [x] Plan links to evidence

## 9) Rollback

Rollback is full commit-range revert of this migration. No partial rollback modes are allowed.

## Evidence

- `/.octon/output/reports/migrations/2026-02-21-agency-actors-to-runtime/evidence.md`
- `/.octon/cognition/runtime/decisions/028-agency-runtime-surface-clean-break-rename.md`
