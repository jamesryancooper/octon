---
title: Bounded Audit Plan - Audit Contract Bootstrap
description: Bootstrap bounded-audit runtime record and compliant evidence bundle.
---

# Bounded Audit Plan: 2026-02-22-audit-contract-bootstrap

## 1) Summary

- Name: Audit Contract Bootstrap
- Owner: architect
- Motivation: Establish one concrete bounded-audit runtime record plus evidence bundle to validate the layered contract end to end.
- Scope roots:
  - `/.octon/cognition/practices/methodology/audits/`
  - `/.octon/cognition/runtime/audits/`
  - `/.octon/output/reports/audits/`
- Explicit exclusions:
  - `/.octon/ideation/`
  - non-audit workflow families

## 2) Taxonomy and Threshold

- Taxonomy:
  - Contract/Schema
  - Security
  - Correctness
  - Reversibility/Safety Gates
  - Tests/CI/Receipts
  - Docs/Spec Drift
- Blocking severity threshold: MUST/FAIL only

## 3) Coverage Contract

- [x] Every in-scope file must be accounted for in `coverage.yml`.
- [x] Exclusions are explicit and justified.
- [x] Unaccounted files target: `0`.

## 4) Determinism Contract

- Model/provider: N/A (bootstrap scaffold record)
- Parameters: fixed placeholder hashes in `convergence.yml`
- Seed policy: `seed_unsupported: true`
- Fingerprint policy: `fingerprint_unsupported: true`
- Run receipt fields captured:
  - `commit_sha`
  - `scope_hash`
  - `prompt_hash`
  - `params_hash`
  - `findings_hash`
  - `stable`
  - `union_blocking_findings`
  - `open_findings_at_or_above_threshold`
  - `done`

## 5) Multi-Pass Plan

- Pass A (contract/schema invariants): verify bundle file contract.
- Pass B (runtime/gates): verify index cross references.
- Pass C (tests/CI/receipts): run assurance validators.
- Pass D (docs/taxonomy consistency): verify policy/runtime/report alignment.
- Merge/dedupe method: deterministic merge with stable IDs, empty set for this bootstrap run.

## 6) Finding Identity Contract

- Stable ID rule: `AUD-<taxonomy>-<location_hash>-<predicate_hash>`.
- Required finding fields: per `findings-contract.md`.
- Acceptance criteria enforcement: mandatory for all non-empty finding entries.

## 7) Remediation Contract

- Minimal-change remediation policy: only adjust files required to satisfy failing acceptance criteria.
- Targeted re-audit rule: re-run changed-scope checks after remediation.
- Full gate rerun rule: run harness + audit convergence validators.
- Regression-proofing requirement: convert recurring findings to machine checks.

## 8) Convergence Gate

- K value (default 3): 3
- Stability criteria: stable findings hash and empty union at/above threshold.
- Failure handling path: treat as audit-spec/coverage defect and revise contract inputs.

## 9) Definition of Done (MUST)

- [x] `open_findings_at_or_above_threshold == 0`
- [x] `coverage.unaccounted_files == 0`
- [x] `convergence.stable == true`
- [x] Evidence bundle complete and validated

Required evidence bundle location:

- `/.octon/output/reports/audits/2026-02-22-audit-contract-bootstrap/`
