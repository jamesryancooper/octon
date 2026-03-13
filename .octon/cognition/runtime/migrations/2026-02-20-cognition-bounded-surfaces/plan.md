---
title: Cognition Bounded Surfaces Clean-Break Migration Plan
description: Clean-break migration plan for restructuring cognition into runtime/governance/practices surfaces with explicit _ops and _meta namespaces.
---

# Clean-Break Migration Plan

## 1) Summary

- Name: Cognition bounded surfaces clean-break
- Owner: `architect`
- Motivation: Align cognition with the bounded-surface architecture contract by separating runtime artifacts, governance contracts, and operating methodology into canonical surfaces with no legacy parallel paths.
- Scope: `/.octon/cognition/**`, plus all active references, validators, templates, and contracts that route to cognition paths.

## 2) What Is Being Removed (Explicit)

- Legacy cognition root runtime/governance/practice paths:
  - `/.octon/cognition/context/`
  - `/.octon/cognition/decisions/`
  - `/.octon/cognition/analyses/`
  - `/.octon/cognition/knowledge-plane/`
  - `/.octon/cognition/principles/`
  - `/.octon/cognition/pillars/`
  - `/.octon/cognition/purpose/`
  - `/.octon/cognition/methodology/`
- Legacy principles-local operational/documentation paths:
  - `/.octon/cognition/principles/_ops/`
  - `/.octon/cognition/principles/_meta/docs/`
- Legacy active call-sites that referenced removed cognition paths.

## 3) What Is the New SSOT (Explicit)

- Runtime authority and artifacts:
  - `/.octon/cognition/runtime/context/`
  - `/.octon/cognition/runtime/decisions/`
  - `/.octon/cognition/runtime/analyses/`
  - `/.octon/cognition/runtime/knowledge-plane/`
- Governance contracts:
  - `/.octon/cognition/governance/principles/`
  - `/.octon/cognition/governance/pillars/`
  - `/.octon/cognition/governance/purpose/`
- Operating standards:
  - `/.octon/cognition/practices/methodology/`
- Operational scripts/state:
  - `/.octon/cognition/_ops/principles/scripts/`
- Non-structural references:
  - `/.octon/cognition/_meta/principles/`

## 4) Clean-Break Constraints (Affirm)

- [x] No dual-mode execution
- [x] No compatibility shims or adapters
- [x] No transitional flags
- [x] Legacy removed in the same change set

## 5) Removal Plan

### Code

- Delete:
  - Legacy cognition root directories listed above.
- Replace call-sites:
  - Update active docs/scripts/templates/tests to the new cognition canonical surfaces.
- Remove routing:
  - Remove validator acceptance for legacy cognition root directories.

### Contracts

- Remove legacy schema or manifest keys:
  - Remove active contract references to legacy cognition root surface paths.
- Add or adjust new schema or manifest keys:
  - Enforce cognition bounded surfaces in harness structure validators and architecture contracts.

### Docs

- Remove legacy docs:
  - Remove active documentation that treats cognition root paths as canonical.
- Update references:
  - Update AGENTS/template AGENTS, architecture/spec docs, migration docs, and CODEOWNERS to canonical cognition surfaces.

### Tests and Validation

- Delete legacy tests:
  - N/A.
- Add or adjust tests for new SSOT:
  - Update migration guard fixtures and principles lint fixture harness paths.
  - Update harness structure validation checks for cognition bounded surfaces and deprecated legacy paths.

## 6) Replacement Plan

- New components or files:
  - `/.octon/cognition/runtime/README.md`
  - `/.octon/cognition/governance/README.md`
  - `/.octon/cognition/practices/README.md`
  - `/.octon/cognition/_ops/README.md`
  - `/.octon/cognition/runtime/migrations/2026-02-20-cognition-bounded-surfaces/plan.md`
  - `/.octon/cognition/runtime/decisions/027-cognition-bounded-surfaces-clean-break-migration.md`
- New entrypoints:
  - `/.octon/cognition/runtime/context/index.yml` (canonical context index)
  - `/.octon/cognition/governance/principles/principles.md` (canonical immutable charter path)
- New reason codes or enums:
  - N/A.

## 7) Verification

### A) Static Verification

- [x] No active legacy cognition identifiers or paths remain (excluding append-only historical records and intentional fixture assertions).
- [x] No legacy cognition root paths remain on disk.

### B) Runtime Verification

- [x] New cognition paths are exercised through governance lint and migration guard tests.
- [x] Old paths are impossible under harness validation (deprecated-path checks fail on reintroduction).

### C) CI Verification

- [x] CI guardrails updated to prevent legacy reintroduction:
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

- `/.octon/output/reports/migrations/2026-02-20-cognition-bounded-surfaces/evidence.md`
- `/.octon/cognition/runtime/decisions/027-cognition-bounded-surfaces-clean-break-migration.md`
