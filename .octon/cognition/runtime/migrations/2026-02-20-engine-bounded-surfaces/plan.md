---
title: Engine Bounded Surfaces Clean-Break Migration Plan
description: Clean-break migration plan for renaming the top-level runtime domain to engine and splitting runtime/governance/practices surfaces.
---

# Clean-Break Migration Plan

## 1) Summary

- Name: Engine bounded surfaces clean-break
- Owner: `architect`
- Motivation: Replace the legacy top-level `runtime/` domain with a bounded `engine/` domain that separates executable authority, normative contracts, and operating standards.
- Scope: `/.octon/engine/**`, legacy `/.octon/runtime/**` removal, and all active references in scripts, manifests, workflows, docs, and validators.

## 2) What Is Being Removed (Explicit)

- Legacy top-level runtime domain:
  - `/.octon/runtime/`
- Legacy runtime authority entrypoint paths:
  - `runtime/run`
  - `runtime/run.cmd`
- Legacy runtime-root path references in active scripts/docs/workflows.

## 3) What Is the New SSOT (Explicit)

- Engine runtime authority:
  - `/.octon/engine/runtime/`
  - `/.octon/engine/runtime/run`
  - `/.octon/engine/runtime/run.cmd`
- Engine governance contracts:
  - `/.octon/engine/governance/`
- Engine operating standards:
  - `/.octon/engine/practices/`
- Engine support namespaces:
  - `/.octon/engine/_ops/`
  - `/.octon/engine/_meta/`

## 4) Clean-Break Constraints (Affirm)

- [x] No dual-mode execution
- [x] No compatibility shims or adapters
- [x] No transitional flags
- [x] Legacy removed in the same change set

## 5) Removal Plan

### Code

- Delete:
  - `/.octon/runtime/**`
- Replace call-sites:
  - Update runtime launch paths to `engine/runtime/run`.
  - Update engine-aware path resolution in runtime crates and scripts.
- Remove routing:
  - Remove validator acceptance of top-level `runtime/` domain.

### Contracts

- Remove legacy schema or manifest keys:
  - Remove active portability/discovery references pointing at `runtime/*` top-level paths.
- Add or adjust new schema or manifest keys:
  - Declare canonical `engine/` surfaces in `/.octon/octon.yml` and architecture contracts.

### Docs

- Remove legacy docs:
  - Remove active structure docs that define `/.octon/runtime/` as a top-level domain.
- Update references:
  - Update START/README/specification and service entrypoint docs to canonical engine paths.

### Tests and Validation

- Delete legacy tests:
  - N/A.
- Add or adjust tests for new SSOT:
  - Update harness-structure validator and runtime/service validation scripts to enforce `engine` paths.

## 6) Replacement Plan

- New components or files:
  - `/.octon/engine/runtime/README.md`
  - `/.octon/engine/governance/README.md`
  - `/.octon/engine/governance/protocol-versioning.md`
  - `/.octon/engine/governance/compatibility-policy.md`
  - `/.octon/engine/governance/release-gates.md`
  - `/.octon/engine/practices/README.md`
  - `/.octon/engine/practices/release-runbook.md`
  - `/.octon/engine/practices/incident-operations.md`
  - `/.octon/engine/practices/local-dev-validation.md`
  - `/.octon/engine/_meta/architecture/README.md`
  - `/.octon/cognition/runtime/decisions/026-engine-bounded-surfaces-clean-break-migration.md`
- New entrypoints:
  - `/.octon/engine/runtime/run`
  - `/.octon/engine/runtime/run.cmd`
- New reason codes or enums:
  - N/A.

## 7) Verification

### A) Static Verification

- [x] No active legacy identifiers remain in scoped source (excluding historical decision/migration records and generated build artifacts).
- [x] No legacy top-level runtime paths remain.

### B) Runtime Verification

- [x] Engine runtime launcher path resolves and is exercised via validation scripts.
- [x] Old top-level runtime path is impossible (validator fails when reintroduced).

### C) CI Verification

- [x] CI gate scripts updated to prevent legacy runtime reintroduction:
  - `/.octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
  - `/.octon/capabilities/runtime/services/_ops/scripts/validate-filesystem-interfaces.sh`

## 8) Definition of Done

- [x] Single authority only
- [x] Legacy deleted (code, docs, contracts)
- [x] All call-sites updated
- [x] CI gates pass locally
- [x] Plan links to evidence

## 9) Rollback

Rollback is full commit-range revert of this migration. No partial rollback modes are allowed.

## Evidence

- `/.octon/output/reports/migrations/2026-02-20-engine-bounded-surfaces/evidence.md`
- `/.octon/cognition/runtime/decisions/026-engine-bounded-surfaces-clean-break-migration.md`
