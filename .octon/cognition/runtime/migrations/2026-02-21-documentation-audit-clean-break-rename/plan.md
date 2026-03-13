---
title: Documentation Audit Clean-Break Rename Plan
description: Clean-break migration plan to replace the documentation-quality-gate workflow identifier and runtime path with documentation-audit.
---

# Clean-Break Migration Plan

## 1) Summary

- Name: Documentation quality-gate identifier clean-break rename
- Owner: `architect`
- Motivation: Remove the final workflow identifier/path overlap after the quality-gate domain split by adopting audit-domain naming for documentation release checks.
- Scope:
  - `/.octon/orchestration/runtime/workflows/**`
  - workflow references in active agency/cognition/capabilities/scaffolding docs
  - migration guardrails and validation checks for legacy path reintroduction

## 2) What Is Being Removed (Explicit)

Legacy workflow identity and path authority:

- workflow id: `documentation-quality-gate`
- workflow command: `/documentation-quality-gate`
- workflow runtime path: `/.octon/orchestration/runtime/workflows/audit/documentation-quality-gate/`
- report artifact name: `YYYY-MM-DD-documentation-quality-gate.md`

## 3) What Is the New SSOT (Explicit)

Canonical workflow identity and path authority:

- workflow id: `documentation-audit`
- workflow command: `/documentation-audit`
- workflow runtime path: `/.octon/orchestration/runtime/workflows/audit/documentation-audit/`
- report artifact name: `YYYY-MM-DD-documentation-audit.md`

## 4) Clean-Break Constraints (Affirm)

- [x] No dual-mode execution
- [x] No compatibility shims or adapters
- [x] No transitional flags
- [x] Legacy removed in the same change set

## 5) Removal Plan

### Code

- Delete legacy workflow runtime directory:
  - `/.octon/orchestration/runtime/workflows/audit/documentation-quality-gate/`
- Replace call-sites:
  - workflow manifest id/path/member references
  - workflow registry key/command/io references
  - direct command/path references in active docs/templates
- Add guardrails:
  - validator deprecated-path check for removed workflow directory
  - legacy-banlist identifiers and paths

### Contracts

- Remove legacy workflow id and command references in:
  - `/.octon/orchestration/runtime/workflows/manifest.yml`
  - `/.octon/orchestration/runtime/workflows/registry.yml`
- Add canonical workflow id and command references in same files.

### Docs

- Update active references to `/documentation-audit` and new workflow path in:
  - agency runtime team docs
  - documentation policy and authoring guidance
  - scaffolding documentation standards template
  - orchestration workflow README

### Tests and Validation

- Run workflow contract validation.
- Run skills/workflows/harness alignment profile to ensure no drift.
- Run static sweeps for legacy identifier and path absence.

## 6) Replacement Plan

- New components or files:
  - migration plan folder:
    - `/.octon/cognition/runtime/migrations/2026-02-21-documentation-audit-clean-break-rename/`
  - decision record:
    - `/.octon/cognition/runtime/decisions/030-documentation-audit-clean-break-rename.md`
- New entrypoints:
  - `/documentation-audit`
- Removed entrypoints:
  - `/documentation-quality-gate`

## 7) Verification

### A) Static Verification

- [x] No legacy identifiers remain (excluding migration/history/output artifacts):
  - `documentation-quality-gate`
  - `/documentation-quality-gate`
- [x] No legacy workflow paths remain:
  - `/.octon/orchestration/runtime/workflows/audit/documentation-quality-gate/`

### B) Runtime Verification

- [x] New path exercised by contract validation (manifest/registry/path resolution)
- [x] Old path impossible (directory removed + validator deprecated-path enforcement)

### C) CI Verification

- [x] CI/local guardrails updated to prevent legacy reintroduction

## 8) Definition of Done

- [x] Single authority only
- [x] Legacy deleted (code, docs, contracts)
- [x] All call-sites updated
- [x] CI/validation gates pass locally
- [x] Plan links to evidence

Required evidence artifacts:

- `/.octon/output/reports/migrations/2026-02-21-documentation-audit-clean-break-rename/evidence.md`
- `/.octon/cognition/runtime/decisions/030-documentation-audit-clean-break-rename.md`

## 9) Rollback

Rollback is full commit-range revert of this migration. No partial rollback modes are allowed.
