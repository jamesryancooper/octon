---
title: Bounded Audit Plan Template
description: Template for finite, convergent audits with explicit coverage and done-gate criteria.
---

# Bounded Audit Plan (Template)

Copy this into `/.octon/cognition/runtime/audits/<YYYY-MM-DD>-<slug>/plan.md`.

## 1) Summary

- Name:
- Owner:
- Motivation:
- Scope roots:
- Explicit exclusions:

## 2) Taxonomy and Threshold

- Taxonomy:
  - Contract/Schema
  - Security
  - Correctness
  - Reversibility/Safety Gates
  - Tests/CI/Receipts
  - Docs/Spec Drift
- Blocking severity threshold:

## 3) Coverage Contract

- [ ] Every in-scope file must be accounted for in `coverage.yml`.
- [ ] Exclusions are explicit and justified.
- [ ] Unaccounted files target: `0`.

## 4) Determinism Contract

- Model/provider:
- Parameters:
- Seed policy:
- Fingerprint policy:
- Run receipt fields captured:

## 5) Multi-Pass Plan

- Pass A (contract/schema invariants):
- Pass B (runtime/gates):
- Pass C (tests/CI/receipts):
- Pass D (docs/taxonomy consistency):
- Merge/dedupe method:

## 6) Finding Identity Contract

- Stable ID rule:
- Required finding fields:
- Acceptance criteria enforcement:

## 7) Remediation Contract

- Minimal-change remediation policy:
- Targeted re-audit rule:
- Full gate rerun rule:
- Regression-proofing requirement:

## 8) Convergence Gate

- K value (default 3):
- Stability criteria:
- Failure handling path:
- Required `convergence.yml` keys:
  - `commit_sha`
  - `scope_hash`
  - `prompt_hash`
  - `params_hash`
  - `seed` or `seed_unsupported: true`
  - `system_fingerprint` or `fingerprint_unsupported: true`
  - `findings_hash`
  - `stable`
  - `union_blocking_findings`
  - `open_findings_at_or_above_threshold`
  - `done`

## 9) Definition of Done (MUST)

- [ ] `open_findings_at_or_above_threshold == 0`
- [ ] `coverage.unaccounted_files == 0`
- [ ] `convergence.stable == true`
- [ ] Evidence bundle complete and validated

Required evidence bundle location:

- `/.octon/output/reports/audits/<YYYY-MM-DD>-<slug>/`
- required files:
  - `bundle.yml`
  - `findings.yml`
  - `coverage.yml`
  - `convergence.yml`
  - `evidence.md`
  - `commands.md`
  - `validation.md`
  - `inventory.md`
- required `bundle.yml` metadata:
  - `kind: audit-evidence-bundle`
  - `id: <bundle-directory-name>`
  - `findings: findings.yml`
  - `coverage: coverage.yml`
  - `convergence: convergence.yml`
  - `evidence: evidence.md`
  - `commands: commands.md`
  - `validation: validation.md`
  - `inventory: inventory.md`
