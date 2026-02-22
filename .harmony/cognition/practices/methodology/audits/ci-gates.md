---
title: CI Gates for Bounded Audits
description: Required CI controls that enforce audit coverage, finding identity, and convergence contracts.
---

# CI Gates for Bounded Audits

## Purpose

Prevent infinite audit loops and non-reproducible findings.

## Required Gates (MUST)

1. Audit bundle contract gate
   - Fail if any audit bundle directory under `/.harmony/output/reports/audits/` is missing required files.
2. Coverage gate
   - Fail if `coverage.yml` reports `unaccounted_files > 0`.
3. Findings identity gate
   - Fail if `findings.yml` has duplicate IDs, missing acceptance criteria, or unstable ID format.
4. Determinism receipt gate
   - Fail if run receipt metadata is missing required fields (`commit_sha`, `scope_hash`, `prompt_hash`, `seed` or unsupported marker, `params_hash`, `findings_hash`).
5. Convergence gate
   - For remediation reruns, fail if K-run policy fails (`stable=false` or `union_blocking_findings > 0`).
6. Done gate
   - Fail if consolidated done expression evaluates false.
   - `done=true` is valid only when:
     - `stable=true`
     - `union_blocking_findings=0`
     - `open_findings_at_or_above_threshold=0`

## Required Repository Artifacts

Maintain these SSOT paths:

- `/.harmony/cognition/practices/methodology/audits/README.md`
- `/.harmony/cognition/practices/methodology/audits/findings-contract.md`
- `/.harmony/cognition/runtime/audits/index.yml`
- `/.harmony/output/reports/audits/README.md`
