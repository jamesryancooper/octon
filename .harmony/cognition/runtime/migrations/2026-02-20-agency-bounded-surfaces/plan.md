---
title: Agency Bounded Surfaces Clean-Break Migration Plan
description: Clean-break migration plan for separating agency runtime artifacts, governance contracts, and operating practices.
---

# Clean-Break Migration Plan

## 1) Summary

- Name: Agency bounded surfaces clean-break
- Owner: `architect`
- Motivation: Establish explicit separation between runtime artifacts and governance contracts to improve boundary clarity and CI enforceability.
- Scope: `/.harmony/agency/**` plus all active references to agency contract paths in harness docs, templates, scripts, and validators.

## 2) What Is Being Removed (Explicit)

- Legacy actor roots:
  - `/.harmony/agency/agents/`
  - `/.harmony/agency/assistants/`
  - `/.harmony/agency/teams/`
- Legacy governance roots:
  - `/.harmony/agency/CONSTITUTION.md`
  - `/.harmony/agency/DELEGATION.md`
  - `/.harmony/agency/MEMORY.md`
- Legacy discovery links in `/.harmony/agency/manifest.yml` and dependent docs/scripts/templates.

## 3) What Is the New SSOT (Explicit)

- Runtime actor authority:
  - `/.harmony/agency/actors/agents/`
  - `/.harmony/agency/actors/assistants/`
  - `/.harmony/agency/actors/teams/`
- Governance authority:
  - `/.harmony/agency/governance/CONSTITUTION.md`
  - `/.harmony/agency/governance/DELEGATION.md`
  - `/.harmony/agency/governance/MEMORY.md`
- Discovery authority:
  - `/.harmony/agency/manifest.yml` registries -> `actors/*/registry.yml`

## 4) Clean-Break Constraints (Affirm)

- [x] No dual-mode execution
- [x] No compatibility shims or adapters
- [x] No transitional flags
- [x] Legacy removed in the same change set

## 5) Removal Plan

### Code

- Delete:
  - Legacy root actor directories and legacy root governance files (via move + source removal).
- Replace call-sites:
  - Update scripts, templates, manifests, and docs to canonical `actors/` and `governance/` paths.
- Remove routing:
  - Remove legacy registry paths in agency manifest and validation expectations.

### Contracts

- Remove legacy schema/manifest keys:
  - `registries.*` old values (`agents/registry.yml`, `assistants/registry.yml`, `teams/registry.yml`).
- Add/adjust new schema/manifest keys:
  - `registries.*` -> `actors/agents/registry.yml`, `actors/assistants/registry.yml`, `actors/teams/registry.yml`.

### Docs

- Remove legacy docs:
  - Remove active references to legacy root agency paths across harness docs/templates.
- Update references:
  - Update root and agency orientation docs to bounded surfaces (`actors/`, `governance/`, `practices/`).

### Tests and Validation

- Delete legacy tests:
  - N/A (no dedicated legacy test files).
- Add/adjust tests for new SSOT:
  - Update `validate-agency.sh` and `validate-harness-structure.sh` to require new paths and fail on legacy reintroduction.

## 6) Replacement Plan

- New components/files:
  - `/.harmony/agency/actors/README.md`
  - `/.harmony/agency/governance/README.md`
  - `/.harmony/cognition/_meta/architecture/bounded-surfaces-contract.md`
- New entrypoints:
  - Agency manifest registry paths under `actors/*`.
- New reason codes/enums:
  - N/A.

## 7) Verification

### A) Static Verification

- [x] No active legacy identifiers remain in scoped source (excluding append-only historical artifacts).
- [x] No active legacy paths remain.

### B) Runtime Verification

- [x] Agency validation path exercised end-to-end.
- [x] Old path is impossible (legacy path checks fail closed in validators).

### C) CI Verification

- [x] CI gate scripts updated to prevent legacy reintroduction:
  - `/.harmony/agency/_ops/scripts/validate/validate-agency.sh`
  - `/.harmony/assurance/_ops/scripts/validate-harness-structure.sh`

## 8) Definition of Done

- [x] Single authority only
- [x] Legacy deleted (code, docs, contracts)
- [x] All call-sites updated
- [x] CI gates pass locally
- [x] Plan links to evidence

## 9) Rollback

Rollback is full commit-range revert of this migration. No partial rollback modes are allowed.

## Evidence

- `/.harmony/output/reports/migrations/2026-02-20-agency-bounded-surfaces/evidence.md`
- `/.harmony/cognition/runtime/decisions/021-bounded-surfaces-contract-and-agency-migration.md`
