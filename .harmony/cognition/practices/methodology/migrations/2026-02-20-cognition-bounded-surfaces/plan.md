---
title: Cognition Bounded Surfaces Clean-Break Migration Plan
description: Clean-break migration plan for restructuring cognition into runtime/governance/practices surfaces with explicit _ops and _meta namespaces.
---

# Clean-Break Migration Plan

## 1) Summary

- Name: Cognition bounded surfaces clean-break
- Owner: `architect`
- Motivation: Align cognition with the bounded-surface architecture contract by separating runtime artifacts, governance contracts, and operating methodology into canonical surfaces with no legacy parallel paths.
- Scope: `/.harmony/cognition/**`, plus all active references, validators, templates, and contracts that route to cognition paths.

## 2) What Is Being Removed (Explicit)

- Legacy cognition root runtime/governance/practice paths:
  - `/.harmony/cognition/context/`
  - `/.harmony/cognition/decisions/`
  - `/.harmony/cognition/analyses/`
  - `/.harmony/cognition/knowledge-plane/`
  - `/.harmony/cognition/principles/`
  - `/.harmony/cognition/pillars/`
  - `/.harmony/cognition/purpose/`
  - `/.harmony/cognition/methodology/`
- Legacy principles-local operational/documentation paths:
  - `/.harmony/cognition/principles/_ops/`
  - `/.harmony/cognition/principles/_meta/docs/`
- Legacy active call-sites that referenced removed cognition paths.

## 3) What Is the New SSOT (Explicit)

- Runtime authority and artifacts:
  - `/.harmony/cognition/runtime/context/`
  - `/.harmony/cognition/runtime/decisions/`
  - `/.harmony/cognition/runtime/analyses/`
  - `/.harmony/cognition/runtime/knowledge-plane/`
- Governance contracts:
  - `/.harmony/cognition/governance/principles/`
  - `/.harmony/cognition/governance/pillars/`
  - `/.harmony/cognition/governance/purpose/`
- Operating standards:
  - `/.harmony/cognition/practices/methodology/`
- Operational scripts/state:
  - `/.harmony/cognition/_ops/principles/scripts/`
- Non-structural references:
  - `/.harmony/cognition/_meta/principles/`

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
  - `/.harmony/cognition/runtime/README.md`
  - `/.harmony/cognition/governance/README.md`
  - `/.harmony/cognition/practices/README.md`
  - `/.harmony/cognition/_ops/README.md`
  - `/.harmony/cognition/practices/methodology/migrations/2026-02-20-cognition-bounded-surfaces/plan.md`
  - `/.harmony/cognition/runtime/decisions/027-cognition-bounded-surfaces-clean-break-migration.md`
- New entrypoints:
  - `/.harmony/cognition/runtime/context/index.yml` (canonical context index)
  - `/.harmony/cognition/governance/principles/principles.md` (canonical immutable charter path)
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
  - `/.harmony/assurance/runtime/_ops/scripts/validate-harness-structure.sh`

## 8) Definition of Done

- [x] Single authority only
- [x] Legacy deleted (code, docs, contracts)
- [x] All call-sites updated
- [x] CI gates pass locally
- [x] Plan links to evidence

## 9) Rollback

Rollback is full commit-range revert of this migration. No partial rollback modes are allowed.

## Evidence

- `/.harmony/output/reports/2026-02-20-cognition-bounded-surfaces-migration-evidence.md`
- `/.harmony/cognition/runtime/decisions/027-cognition-bounded-surfaces-clean-break-migration.md`
