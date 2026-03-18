---
title: Capabilities Bounded Surfaces Clean-Break Migration Plan
description: Clean-break migration plan for separating capabilities runtime artifacts, governance contracts, and operating practices.
---

# Clean-Break Migration Plan

## 1) Summary

- Name: Capabilities bounded surfaces clean-break
- Owner: `architect`
- Motivation: Establish explicit separation between capability runtime artifacts, governance contracts, and operating practices to improve structural clarity and fail-closed validation.
- Scope: `/.octon/framework/capabilities/**` plus active references in harness docs, scripts, workflows, templates, and CI workflows.

## 2) What Is Being Removed (Explicit)

- Legacy root runtime paths:
  - `/.octon/framework/capabilities/commands/`
  - `/.octon/framework/capabilities/skills/`
  - `/.octon/framework/capabilities/tools/`
  - `/.octon/framework/capabilities/services/`
- Legacy root governance path:
  - `/.octon/framework/capabilities/_ops/policy/`
- Legacy runtime conventions path:
  - `/.octon/framework/capabilities/services/conventions/`

## 3) What Is the New SSOT (Explicit)

- Runtime capability authority:
  - `/.octon/framework/capabilities/runtime/commands/`
  - `/.octon/framework/capabilities/runtime/skills/`
  - `/.octon/framework/capabilities/runtime/tools/`
  - `/.octon/framework/capabilities/runtime/services/`
- Governance authority:
  - `/.octon/framework/capabilities/governance/policy/`
- Practices authority:
  - `/.octon/framework/capabilities/practices/services-conventions/`

## 4) Clean-Break Constraints (Affirm)

- [x] No dual-mode execution
- [x] No compatibility shims or adapters
- [x] No transitional flags
- [x] Legacy removed in the same change set

## 5) Removal Plan

### Code

- Delete:
  - Legacy root capabilities runtime and governance paths listed above.
- Replace call-sites:
  - Update manifests, registries, scripts, workflows, docs, and CI references to canonical runtime/governance/practices surfaces.
- Remove routing:
  - Remove all active discovery/routing dependencies on legacy root capability paths.

### Contracts

- Remove legacy schema or manifest keys:
  - Legacy manifest/registry path references to root runtime locations.
- Add or adjust new schema or manifest keys:
  - Canonical references to `capabilities/runtime/*`, `capabilities/governance/*`, and `capabilities/practices/*`.

### Docs

- Remove legacy docs:
  - Remove active references to legacy capabilities root runtime and policy paths.
- Update references:
  - Update orientation and architecture docs to bounded surfaces (`runtime/`, `governance/`, `practices/`).

### Tests and Validation

- Delete legacy tests:
  - N/A (no dedicated legacy test files).
- Add or adjust tests for new SSOT:
  - Update capability/runtime validators and harness structure validator to require new paths and fail on deprecated path reintroduction.

## 6) Replacement Plan

- New components or files:
  - `/.octon/framework/capabilities/runtime/README.md`
  - `/.octon/framework/capabilities/governance/README.md`
  - `/.octon/framework/capabilities/practices/README.md`
  - `/.octon/framework/capabilities/practices/services-conventions/README.md`
  - `/.octon/instance/cognition/decisions/023-capabilities-bounded-surfaces-clean-break-migration.md`
- New entrypoints:
  - `/.octon/framework/capabilities/runtime/commands/manifest.yml`
  - `/.octon/framework/capabilities/runtime/skills/manifest.yml`
  - `/.octon/framework/capabilities/runtime/tools/manifest.yml`
  - `/.octon/framework/capabilities/runtime/services/manifest.yml`
  - `/.octon/framework/capabilities/governance/policy/deny-by-default.v2.yml`
- New reason codes or enums:
  - N/A.

## 7) Verification

### A) Static Verification

- [x] No active legacy identifiers remain in scoped source (excluding append-only history, migration logs, and explicit validator deny lists).
- [x] No active legacy paths remain.

### B) Runtime Verification

- [x] New runtime/governance/practices paths exercised end-to-end.
- [x] Old paths are impossible (legacy path checks fail closed in validators).

### C) CI Verification

- [x] CI gate scripts updated or added to prevent legacy reintroduction:
  - `/.octon/framework/assurance/_ops/scripts/validate-harness-structure.sh`
  - `/.octon/framework/capabilities/_ops/scripts/validate-deny-by-default.sh`
  - `/.octon/framework/capabilities/_ops/scripts/validate-ra-acp-migration.sh`

## 8) Definition of Done

- [x] Single authority only
- [x] Legacy deleted (code, docs, contracts)
- [x] All call-sites updated
- [x] CI gates pass locally
- [x] Plan links to evidence

## 9) Rollback

Rollback is full commit-range revert of this migration. No partial rollback modes are allowed.

## Evidence

- `/.octon/state/evidence/migration/2026-02-20-capabilities-bounded-surfaces/evidence.md`
- `/.octon/instance/cognition/decisions/023-capabilities-bounded-surfaces-clean-break-migration.md`
