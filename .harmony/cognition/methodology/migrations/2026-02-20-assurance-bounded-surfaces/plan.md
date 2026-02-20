---
title: Assurance Bounded Surfaces Clean-Break Migration Plan
description: Clean-break migration plan for separating assurance runtime artifacts, governance contracts, and operating practices.
---

# Clean-Break Migration Plan

## 1) Summary

- Name: Assurance bounded surfaces clean-break
- Owner: `architect`
- Motivation: Establish explicit separation of assurance runtime artifacts, governance contracts, and operating practices to improve architectural clarity and fail-closed enforcement.
- Scope: `/.harmony/assurance/**` plus active references in harness docs, scripts, workflows, templates, runtime tooling, and CI workflows.

## 2) What Is Being Removed (Explicit)

- Legacy root governance and contract paths:
  - `/.harmony/assurance/CHARTER.md`
  - `/.harmony/assurance/DOCTRINE.md`
  - `/.harmony/assurance/CHANGELOG.md`
- Legacy root checklist paths:
  - `/.harmony/assurance/complete.md`
  - `/.harmony/assurance/session-exit.md`
- Legacy root standards and trust paths:
  - `/.harmony/assurance/standards/`
  - `/.harmony/assurance/trust/`
- Legacy root runtime script and state paths:
  - `/.harmony/assurance/_ops/scripts/`
  - `/.harmony/assurance/_ops/state/`

## 3) What Is the New SSOT (Explicit)

- Runtime assurance authority:
  - `/.harmony/assurance/runtime/_ops/scripts/`
  - `/.harmony/assurance/runtime/_ops/state/`
  - `/.harmony/assurance/runtime/trust/`
- Governance assurance authority:
  - `/.harmony/assurance/governance/CHARTER.md`
  - `/.harmony/assurance/governance/DOCTRINE.md`
  - `/.harmony/assurance/governance/CHANGELOG.md`
  - `/.harmony/assurance/governance/weights/`
  - `/.harmony/assurance/governance/scores/`
- Practices assurance authority:
  - `/.harmony/assurance/practices/complete.md`
  - `/.harmony/assurance/practices/session-exit.md`
  - `/.harmony/assurance/practices/standards/`

## 4) Clean-Break Constraints (Affirm)

- [x] No dual-mode execution
- [x] No compatibility shims or adapters
- [x] No transitional flags
- [x] Legacy removed in the same change set

## 5) Removal Plan

### Code

- Delete:
  - Legacy assurance root paths listed above.
- Replace call-sites:
  - Update CI workflows, harness validators, alignment checks, workflow docs, capability skill references, templates, and runtime defaults to canonical assurance surfaces.
- Remove routing:
  - Remove active routing and enforcement dependencies on legacy assurance root paths.

### Contracts

- Remove legacy schema or manifest keys:
  - Legacy path defaults in assurance runtime tool CLI defaults.
- Add or adjust new schema or manifest keys:
  - Canonical assurance defaults under `governance/*` and `runtime/_ops/*` in runtime tooling and CI.

### Docs

- Remove legacy docs:
  - Remove active references to legacy assurance root governance/checklist/standards/runtime paths.
- Update references:
  - Update root and subsystem architecture docs, START guidance, and template manifests to canonical assurance surfaces.

### Tests and Validation

- Delete legacy tests:
  - N/A (no dedicated legacy assurance test files).
- Add or adjust tests for new SSOT:
  - Update harness and alignment validators to enforce assurance bounded surfaces and fail on legacy path reintroduction.

## 6) Replacement Plan

- New components or files:
  - `/.harmony/assurance/runtime/README.md`
  - `/.harmony/assurance/governance/README.md`
  - `/.harmony/assurance/practices/README.md`
  - `/.harmony/assurance/practices/standards/README.md`
  - `/.harmony/cognition/decisions/024-assurance-bounded-surfaces-clean-break-migration.md`
- New entrypoints:
  - `/.harmony/assurance/runtime/_ops/scripts/compute-assurance-score.sh`
  - `/.harmony/assurance/runtime/_ops/scripts/assurance-gate.sh`
  - `/.harmony/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- New reason codes or enums:
  - N/A.

## 7) Verification

### A) Static Verification

- [x] No active legacy identifiers remain in scoped source (excluding append-only history, migration logs, and explicit validator deny lists).
- [x] No active legacy paths remain.

### B) Runtime Verification

- [x] New assurance runtime/governance/practices paths exercised end-to-end.
- [x] Old paths are impossible (legacy path checks fail closed in validators).

### C) CI Verification

- [x] CI gate scripts updated or added to prevent legacy reintroduction:
  - `/.harmony/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
  - `/.harmony/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh`
  - `/.github/workflows/assurance-weight-gates.yml`

## 8) Definition of Done

- [x] Single authority only
- [x] Legacy deleted (code, docs, contracts)
- [x] All call-sites updated
- [x] CI gates pass locally
- [x] Plan links to evidence

## 9) Rollback

Rollback is full commit-range revert of this migration. No partial rollback modes are allowed.

## Evidence

- `/.harmony/output/reports/2026-02-20-assurance-bounded-surfaces-migration-evidence.md`
- `/.harmony/cognition/decisions/024-assurance-bounded-surfaces-clean-break-migration.md`
