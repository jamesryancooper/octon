---
title: Clean-Break Governance Contract Cutover Plan
description: Single-event migration plan to cut over governance execution to the new clean-break contract set and retire legacy fallback surfaces.
---

# Clean-Break Migration Plan

## 1) Summary

- Name: Clean-break governance contract cutover
- Owner: `architect`
- Motivation: Complete migration to one canonical governance contract set with fail-closed versioning, SSOT authority precedence, and mandatory explainable policy receipts.
- Scope:
  - `/.octon/cognition/practices/methodology/migrations/`
  - `/.octon/capabilities/governance/policy/deny-by-default.v2.yml`
  - `/.octon/engine/runtime/policy` and `/.octon/engine/runtime/crates/policy_engine`
  - `/.octon/cognition/_meta/architecture/specification.md`
  - `/.octon/orchestration/runtime/workflows/`
  - `/.octon/assurance/runtime/_ops/scripts/`

## 2) What Is Being Removed (Explicit)

Legacy fallback and competing governance/onboarding execution surfaces:

- Discoverable onboarding fallback workflow id/command:
  - `onboard-new-developer`
  - `/onboard-new-developer`
- Deprecated manifest/registry routing for legacy onboarding path.

## 3) What Is the New SSOT (Explicit)

Canonical governance contract set after cutover:

- Clean-break migration doctrine and rollback contract:
  - `/.octon/cognition/practices/methodology/migrations/README.md`
- Decision authority:
  - `/.octon/cognition/runtime/decisions/039-clean-break-governance-cutover-contract.md`
- ACP operating-mode authority:
  - `/.octon/capabilities/governance/policy/deny-by-default.v2.yml`
- Policy receipt/digest authority:
  - `/.octon/engine/runtime/spec/policy-receipt-v1.schema.json`
  - `/.octon/engine/runtime/spec/policy-digest-v1.md`
- Harness version and rejection contract:
  - `/.octon/octon.yml`
  - `/.octon/assurance/runtime/_ops/scripts/validate-harness-version-contract.sh`
- Runtime/governance/practices SSOT precedence authority:
  - `/.octon/cognition/_meta/architecture/specification.md`
  - `/.octon/assurance/runtime/_ops/scripts/validate-ssot-precedence-drift.sh`
- Canonical onboarding execution path:
  - `/.octon/orchestration/runtime/workflows/tasks/agent-led-happy-path.md`

## 4) Clean-Break Constraints (Affirm)

- [x] No dual-mode execution after cutover
- [x] No compatibility shims or fallback toggles
- [x] No legacy discoverable governance fallback path
- [x] Rollback contract is full revert only

## 5) Removal Plan

### Legacy Surface Retirement

- Remove `onboard-new-developer` from workflow discovery (`manifest.yml`, `registry.yml`, task group members).
- Retain `onboard-new-developer.md` as non-discoverable historical artifact with explicit retirement banner.
- Add legacy token banlist entries to prevent reintroduction.

### Contract Gate Hardening

- Enforce harness version compatibility via `validate-harness-version-contract.sh`.
- Enforce SSOT precedence drift checks via `validate-ssot-precedence-drift.sh`.
- Keep capability/engine and policy contract validations fail-closed.

## 6) Replacement Plan

- Runtime migration record:
  - `/.octon/cognition/runtime/migrations/2026-02-24-clean-break-governance-cutover/plan.md`
- Decision record:
  - `/.octon/cognition/runtime/decisions/039-clean-break-governance-cutover-contract.md`
- Migration evidence bundle:
  - `/.octon/output/reports/migrations/2026-02-24-clean-break-governance-cutover/`

## 7) Verification

### A) Static Verification

- [x] Legacy onboarding workflow id removed from manifest/registry discovery.
- [x] Legacy onboarding token banlist updated.
- [x] Canonical onboarding path remains discoverable as sole recommended path.

### B) Runtime/Contract Verification

- [x] Harness version compatibility validator passes.
- [x] SSOT precedence drift validator passes.
- [x] Workflow contract validator passes.
- [x] Harness alignment profile passes.
- [x] Deny-by-default policy doctor and capability/engine consistency gates pass.

### C) Governance Verification

- [x] Runtime decisions index includes ADR 039.
- [x] Runtime migrations index includes this migration record.
- [x] Runtime evidence index includes this migration evidence record.

## 8) Definition of Done

- [x] Single governance contract authority set active
- [x] Legacy discoverable onboarding fallback retired
- [x] Fail-closed versioning and precedence drift gates enforced
- [x] Migration/evidence indexes updated
- [x] Validation suite green for affected gates

Required evidence artifacts:

- `/.octon/output/reports/migrations/2026-02-24-clean-break-governance-cutover/evidence.md`
- `/.octon/output/reports/migrations/2026-02-24-clean-break-governance-cutover/validation.md`

## 9) Rollback

Rollback is full commit-range revert of this cutover migration. Partial rollback or mixed old/new governance execution is prohibited.
