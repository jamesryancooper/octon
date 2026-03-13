---
title: Cognition Sidecar Section Indexes Plan
description: Clean-break migration plan to replace section surrogate directories with sidecar section indexes colocated with canonical cognition docs.
---

# Clean-Break Migration Plan

## 1) Summary

- Name: Cognition sidecar section indexes
- Owner: `architect`
- Motivation: Improve architectural clarity and long-term maintainability by replacing surrogate `sections/` docs with sidecar `*.index.yml` contracts tied directly to canonical sources.
- Scope:
  - `/.octon/cognition/practices/methodology/**`
  - `/.octon/cognition/_meta/architecture/**`
  - `/.octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
  - `/.octon/capabilities/runtime/skills/audit/audit-subsystem-health/references/alignment-contract.md`
  - `/.octon/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh`

## 2) What Is Being Removed (Explicit)

- `/.octon/cognition/practices/methodology/sections/`
- `/.octon/cognition/_meta/architecture/sections/`
- Index references that resolve through those directory surfaces.

## 3) What Is the New SSOT (Explicit)

- Sidecar section indexes colocated with canonical docs:
  - `/.octon/cognition/practices/methodology/README.index.yml`
  - `/.octon/cognition/practices/methodology/implementation-guide.index.yml`
  - `/.octon/cognition/_meta/architecture/README.index.yml`
  - `/.octon/cognition/_meta/architecture/resources.index.yml`

## 4) Clean-Break Constraints (Affirm)

- [x] No dual-mode execution
- [x] No compatibility shims or adapters
- [x] No transitional flags
- [x] Legacy `sections/` artifacts removed in same change set

## 5) Removal Plan

### Code and contracts

- Replace `sections/index.yml` references in discovery indexes with sidecar index paths.
- Update readme discovery guidance for sidecar architecture.
- Remove both `sections/` directories.

### Guardrails

- Require sidecar index files in discovery contracts.
- Enforce sidecar source/heading integrity checks.
- Fail closed if legacy `sections/` directories reappear.

### Records

- Add ADR-036 and decision addendum.
- Add migration record and evidence bundle.

## 6) Verification

### A) Static Verification

- [x] No `sections/` directories remain in targeted cognition surfaces.
- [x] Sidecar index files exist and resolve source files.
- [x] Sidecar indexed headings are present in source markdown.

### B) Runtime Verification

- [x] Harness structure validator enforces sidecar contracts and legacy removal.
- [x] Alignment validator remains green with updated skill artifacts/version.

### C) CI Verification

- [x] Skills/workflows/harness alignment profiles pass locally.

## 7) Definition of Done

- [x] Single authority only
- [x] Legacy deleted
- [x] All call-sites updated
- [x] Validation gates pass locally
- [x] Evidence bundle complete

## 8) Rollback

Rollback is full commit-range revert of this migration. No partial rollback modes are allowed.
