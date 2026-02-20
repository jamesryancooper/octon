---
title: Engine Bounded Surfaces Clean-Break Migration Plan
description: Clean-break migration plan for renaming the top-level runtime domain to engine and splitting runtime/governance/practices surfaces.
---

# Clean-Break Migration Plan

## 1) Summary

- Name: Engine bounded surfaces clean-break
- Owner: `architect`
- Motivation: Replace the legacy top-level `runtime/` domain with a bounded `engine/` domain that separates executable authority, normative contracts, and operating standards.
- Scope: `/.harmony/engine/**`, legacy `/.harmony/runtime/**` removal, and all active references in scripts, manifests, workflows, docs, and validators.

## 2) What Is Being Removed (Explicit)

- Legacy top-level runtime domain:
  - `/.harmony/runtime/`
- Legacy runtime authority entrypoint paths:
  - `runtime/run`
  - `runtime/run.cmd`
- Legacy runtime-root path references in active scripts/docs/workflows.

## 3) What Is the New SSOT (Explicit)

- Engine runtime authority:
  - `/.harmony/engine/runtime/`
  - `/.harmony/engine/runtime/run`
  - `/.harmony/engine/runtime/run.cmd`
- Engine governance contracts:
  - `/.harmony/engine/governance/`
- Engine operating standards:
  - `/.harmony/engine/practices/`
- Engine support namespaces:
  - `/.harmony/engine/_ops/`
  - `/.harmony/engine/_meta/`

## 4) Clean-Break Constraints (Affirm)

- [x] No dual-mode execution
- [x] No compatibility shims or adapters
- [x] No transitional flags
- [x] Legacy removed in the same change set

## 5) Removal Plan

### Code

- Delete:
  - `/.harmony/runtime/**`
- Replace call-sites:
  - Update runtime launch paths to `engine/runtime/run`.
  - Update engine-aware path resolution in runtime crates and scripts.
- Remove routing:
  - Remove validator acceptance of top-level `runtime/` domain.

### Contracts

- Remove legacy schema or manifest keys:
  - Remove active portability/discovery references pointing at `runtime/*` top-level paths.
- Add or adjust new schema or manifest keys:
  - Declare canonical `engine/` surfaces in `/.harmony/harmony.yml` and architecture contracts.

### Docs

- Remove legacy docs:
  - Remove active structure docs that define `/.harmony/runtime/` as a top-level domain.
- Update references:
  - Update START/README/specification and service entrypoint docs to canonical engine paths.

### Tests and Validation

- Delete legacy tests:
  - N/A.
- Add or adjust tests for new SSOT:
  - Update harness-structure validator and runtime/service validation scripts to enforce `engine` paths.

## 6) Replacement Plan

- New components or files:
  - `/.harmony/engine/runtime/README.md`
  - `/.harmony/engine/governance/README.md`
  - `/.harmony/engine/governance/protocol-versioning.md`
  - `/.harmony/engine/governance/compatibility-policy.md`
  - `/.harmony/engine/governance/release-gates.md`
  - `/.harmony/engine/practices/README.md`
  - `/.harmony/engine/practices/release-runbook.md`
  - `/.harmony/engine/practices/incident-operations.md`
  - `/.harmony/engine/practices/local-dev-validation.md`
  - `/.harmony/engine/_meta/architecture/README.md`
  - `/.harmony/cognition/decisions/026-engine-bounded-surfaces-clean-break-migration.md`
- New entrypoints:
  - `/.harmony/engine/runtime/run`
  - `/.harmony/engine/runtime/run.cmd`
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
  - `/.harmony/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
  - `/.harmony/capabilities/runtime/services/_ops/scripts/validate-filesystem-interfaces.sh`

## 8) Definition of Done

- [x] Single authority only
- [x] Legacy deleted (code, docs, contracts)
- [x] All call-sites updated
- [x] CI gates pass locally
- [x] Plan links to evidence

## 9) Rollback

Rollback is full commit-range revert of this migration. No partial rollback modes are allowed.

## Evidence

- `/.harmony/output/reports/2026-02-20-engine-bounded-surfaces-migration-evidence.md`
- `/.harmony/cognition/decisions/026-engine-bounded-surfaces-clean-break-migration.md`
