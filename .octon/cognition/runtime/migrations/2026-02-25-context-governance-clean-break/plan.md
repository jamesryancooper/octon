---
title: Context Governance Clean-Break Migration Plan
description: Single-cutover migration plan for instruction-layer precedence contracts, default-deny developer context gating, and context-acquisition telemetry enforcement.
---

# Clean-Break Migration Plan

## 1) Summary

- Name: Context governance clean-break migration
- Owner: `architect`
- Motivation: Shift context governance from prompt-layer drift into enforceable contracts, fail-closed policy gates, and runtime receipts with measurable overhead controls.
- Scope:
  - `/.octon/engine/governance/`
  - `/.octon/engine/runtime/spec/`
  - `/.octon/engine/runtime/policy`
  - `/.octon/capabilities/governance/policy/`
  - `/.octon/capabilities/runtime/services/`
  - `/.octon/assurance/runtime/_ops/scripts/`
  - `/.octon/orchestration/runtime/workflows/`

## 2) What Is Being Removed (Explicit)

Legacy context-governance behavior and tolerance surfaces:

- Material-run paths that do not emit instruction-layer manifests.
- Material-run paths that do not emit required context-acquisition counters.
- Developer-layer context acceptance outside the policy allowlist and section/size constraints.
- Receipt/provenance tolerance of missing required instruction-layer and acquisition fields.
- Compatibility aliases or optional keys retained only to preserve pre-cutover behavior.

## 3) What Is the New SSOT (Explicit)

Canonical post-cutover authorities:

- Instruction-layer precedence contract:
  - `/.octon/engine/governance/instruction-layer-precedence.md`
- Instruction-layer manifest schema:
  - `/.octon/engine/runtime/spec/instruction-layer-manifest-v1.schema.json`
- Receipt/provenance schema contract:
  - `/.octon/engine/runtime/spec/policy-receipt-v1.schema.json`
  - `/.octon/capabilities/governance/policy/acp-provenance-fields.schema.json`
- Default-deny context policy controls:
  - `/.octon/capabilities/governance/policy/deny-by-default.v2.yml`
- Assurance and workflow fail-closed enforcement:
  - `/.octon/assurance/runtime/_ops/scripts/alignment-check.sh`
  - `/.octon/orchestration/runtime/workflows/audit/audit-pre-release/`

## 4) Clean-Break Constraints (Affirm)

- [x] No dual-mode execution
- [x] No compatibility shims or adapters
- [x] No transitional flags
- [x] Legacy removed in the same change set

## 5) Removal Plan (MUST Be Concrete)

### Code

- Delete runtime branch logic that allows material runs without manifest emission.
- Delete runtime branch logic that allows missing context-acquisition fields.
- Remove legacy compatibility aliases in policy and receipt write surfaces.

### Contracts

- Remove legacy schema keys and optional compatibility fields.
- Add required instruction-layer and context-acquisition fields to canonical schemas.

### Docs

- Remove legacy context guidance that implies optional/parallel behavior.
- Update architecture, policy, and workflow docs to a single post-cutover model.

### Tests

- Remove fixtures that validate legacy optional behavior.
- Add/adjust fixtures that enforce required manifest and telemetry fields.

## 6) Replacement Plan

- New components or files:
  - `/.octon/engine/governance/instruction-layer-precedence.md`
  - `/.octon/engine/runtime/spec/instruction-layer-manifest-v1.schema.json`
  - `/.octon/assurance/runtime/_ops/scripts/validate-developer-context-policy.sh`
  - `/.octon/assurance/runtime/_ops/scripts/validate-context-overhead-budget.sh`
- New entrypoints:
  - Existing entrypoints retained; behavior hard-cut to new single path.
- New reason codes or enums:
  - Finalized and enforced via strict deny-by-default validation profile.

## 7) Verification (MUST)

### A) Static Verification

- [x] No legacy identifiers remain (pattern sweep complete)
- [x] No legacy compatibility paths remain

### B) Runtime Verification

- [x] New instruction-layer manifest path exercised end-to-end
- [x] New context-acquisition telemetry path exercised end-to-end
- [x] Old path impossible (removed entrypoints/branches)

### C) CI Verification

- [x] Legacy banlist updated and enforced
- [x] CI/assurance gates prevent legacy reintroduction

Verification evidence:

- `/.octon/output/reports/migrations/2026-02-25-context-governance-clean-break/commands.md`
- `/.octon/output/reports/migrations/2026-02-25-context-governance-clean-break/validation.md`
- `/.octon/output/reports/migrations/2026-02-25-context-governance-clean-break/evidence.md`
- `/.octon/output/reports/migrations/2026-02-25-context-governance-clean-break/inventory.md`

## 8) Definition of Done (MUST)

- [x] Single authority only
- [x] Legacy deleted (code, docs, contracts, tests)
- [x] All call-sites updated
- [x] CI gates pass
- [x] Plan links to evidence (logs, test output, receipts)

Required evidence bundle location:

- `/.octon/output/reports/migrations/2026-02-25-context-governance-clean-break/`
- required files:
  - `bundle.yml`
  - `evidence.md`
  - `commands.md`
  - `validation.md`
  - `inventory.md`

## 9) Rollback

Rollback is full commit-range revert of this migration cutover. Partial rollback, compatibility toggles, and mixed old/new runtime operation are prohibited.
