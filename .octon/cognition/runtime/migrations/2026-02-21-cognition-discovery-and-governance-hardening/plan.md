---
title: Cognition Discovery and Governance Hardening Plan
description: Clean-break migration plan to harden ADR identity integrity, expand machine-discovery indexes, and strengthen cognition drift guardrails for long-term maintainability.
---

# Clean-Break Migration Plan

## 1) Summary

- Name: Cognition discovery and governance hardening
- Owner: `architect`
- Motivation: Improve long-term maintainability and agent efficiency by eliminating decision identity ambiguity, adding machine-discoverable cognition indexes, and hardening guardrails for drift-sensitive cognition surfaces.
- Scope:
  - `/.octon/cognition/runtime/decisions/**`
  - `/.octon/cognition/governance/**`
  - `/.octon/cognition/practices/**`
  - `/.octon/cognition/runtime/context/**`
  - `/.octon/cognition/_meta/architecture/**`
  - `/.octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
  - `/.octon/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh`

## 2) What Is Being Removed (Explicit)

- Duplicate ADR numeric identity (`ADR-013`) in two distinct decision files.
- README-only discovery for cognition governance/practices surfaces.
- Structural-only checks for some cognition drift-sensitive surfaces.

## 3) What Is the New SSOT (Explicit)

- Unique numeric ADR identity with one file per numeric prefix.
- Machine-readable discovery indexes for cognition governance and practices surfaces.
- Stronger guardrails that validate decision identity integrity and broader cognition drift alignment.

## 4) Clean-Break Constraints (Affirm)

- [x] No dual-mode execution
- [x] No compatibility shims or adapters
- [x] No transitional flags
- [x] Legacy ambiguity removed in same change set

## 5) Removal Plan

### Phase 0: Scaffolding and baseline

- Create migration plan and evidence bundle skeleton.
- Create ADR for architecture hardening decision.
- Capture baseline validator outputs for before/after comparison.

### Phase 1: ADR identity integrity

- Rename planning-services ADR from `013-*` to `034-*`.
- Update decision index and references.
- Add fail-closed checks for duplicate decision IDs and filename/index numeric mismatch.

### Phase 2: Discovery index expansion

- Add `governance/index.yml`, `practices/index.yml`, and `practices/methodology/index.yml`.
- Update cognition orientation docs to expose these canonical indexes.
- Add index-contract checks to harness validation.

### Phase 3: Agent efficiency improvements

- Add section-level machine indexes for heavyweight methodology/architecture docs.
- Keep existing canonical files while enabling targeted section reads.

### Phase 4: Drift/semantics hardening

- Expand audit-subsystem-health alignment watchers to include cognition runtime context and broader governance/practices surfaces.
- Promote metrics scorecard from draft stub to operational contract with explicit owners, thresholds, and cadences.
- Add index semantic checks to reduce documentation-only drift risk.

### Phase 5: Finalization

- Update migration and decision indexes.
- Run full local validation suite.
- Capture final evidence artifacts and close migration.

## 6) Replacement Plan

- New runtime migration record:
  - `/.octon/cognition/runtime/migrations/2026-02-21-cognition-discovery-and-governance-hardening/plan.md`
- New migration evidence bundle:
  - `/.octon/output/reports/migrations/2026-02-21-cognition-discovery-and-governance-hardening/`
- New decision record:
  - `/.octon/cognition/runtime/decisions/035-cognition-discovery-and-governance-hardening.md`

## 7) Verification

### A) Static Verification

- [x] No duplicate ADR numeric IDs.
- [x] Governance/practices machine indexes exist and resolve all referenced files.
- [x] Heavier cognition docs expose section indexes for targeted loading.

### B) Runtime Verification

- [x] Harness structure validator enforces new discovery/index contracts.
- [x] Audit alignment validator watches updated cognition drift surfaces.

### C) CI Verification

- [x] Skills/workflows/harness alignment gates pass with updated contracts.

## 8) Definition of Done

- [x] Single authority only
- [x] Legacy ambiguity deleted
- [x] All call-sites updated
- [x] CI/validation gates pass locally
- [x] Plan links to evidence

Required evidence artifacts:

- `/.octon/output/reports/migrations/2026-02-21-cognition-discovery-and-governance-hardening/evidence.md`
- `/.octon/output/reports/migrations/2026-02-21-cognition-discovery-and-governance-hardening/commands.md`
- `/.octon/output/reports/migrations/2026-02-21-cognition-discovery-and-governance-hardening/validation.md`
- `/.octon/output/reports/migrations/2026-02-21-cognition-discovery-and-governance-hardening/inventory.md`
- `/.octon/cognition/runtime/decisions/035-cognition-discovery-and-governance-hardening.md`

## 9) Rollback

Rollback is full commit-range revert of this migration. No partial rollback modes are allowed.
