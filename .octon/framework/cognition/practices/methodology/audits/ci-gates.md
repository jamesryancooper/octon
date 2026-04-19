---
title: CI Gates for Bounded Audits
description: Required CI controls that enforce audit coverage, finding identity, and convergence contracts.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-05
canonical_links:
  - "/AGENTS.md"
  - "/.octon/framework/execution-roles/governance/CONSTITUTION.md"
  - "/.octon/framework/execution-roles/governance/DELEGATION.md"
  - "/.octon/framework/execution-roles/governance/MEMORY.md"
  - "/.octon/framework/cognition/practices/methodology/authority-crosswalk.md"
---

# CI Gates for Bounded Audits

## Purpose

Prevent infinite audit loops and non-reproducible findings.

## Required Gates (MUST)

1. Audit bundle contract gate
   - Scope checks to in-change audit bundles only (new/modified bundle directories in current diff plus current bundle references touched in `/.octon/instance/cognition/context/shared/audits/index.yml`).
   - Fail if any in-scope audit bundle directory under `/.octon/state/evidence/validation/audits/` is missing required files.
2. Coverage gate
   - Fail if `coverage.yml` reports `unaccounted_files > 0`.
3. Findings identity gate
   - Fail if `findings.yml` has duplicate IDs, missing acceptance criteria, or unstable ID format.
4. Determinism receipt gate
   - Fail if run receipt metadata is missing required fields (`run_id`, `commit_sha`, `scope_hash`, `prompt_hash`, `params_hash`, `findings_hash`).
   - Fail if neither `seed` nor explicit `seed_unsupported` marker is present.
   - Fail if neither `system_fingerprint` nor explicit `fingerprint_unsupported` marker is present.
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

- `/.octon/framework/cognition/practices/methodology/audits/README.md`
- `/.octon/framework/cognition/practices/methodology/audits/findings-contract.md`
- `/.octon/instance/cognition/context/shared/audits/index.yml`
- `/.octon/state/evidence/validation/audits/README.md`
