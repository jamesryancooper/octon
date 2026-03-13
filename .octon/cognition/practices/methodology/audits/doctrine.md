---
title: Bounded Audit Doctrine
description: Default bounded-audit doctrine requiring finite scope, deterministic receipts, multi-pass aggregation, and explicit convergence gates.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-05
canonical_links:
  - "/AGENTS.md"
  - "/.octon/agency/governance/CONSTITUTION.md"
  - "/.octon/agency/governance/DELEGATION.md"
  - "/.octon/agency/governance/MEMORY.md"
  - "/.octon/cognition/practices/methodology/authority-crosswalk.md"
---

# Bounded Audit Doctrine

## 0) Terms

- Bounded audit: an audit run with fixed scope, fixed taxonomy, fixed severity threshold, and explicit done criteria.
- Coverage accounting: explicit accounting for every in-scope file as scanned, summarized/sampled, or excluded with reason.
- Convergence run set: repeated reruns after remediation used to verify stability under controlled seeds and parameters.

## 1) Primary Rule

All audits must be finite and convergent by construction.

## 2) Non-Negotiable Constraints (MUST)

1. Finite scope: each audit defines inclusive scope roots and explicit exclusions.
2. Taxonomy required: each finding must map to a declared issue category.
3. Severity gate required: blocking findings are those at or above declared threshold.
4. Coverage proof required: unaccounted in-scope files must be zero.
5. Stable finding IDs required: findings use deterministic IDs and do not re-key without cause.
6. Acceptance criteria required: each finding includes objective resolution checks.
7. Deterministic run receipt required: each run records commit, seed, parameters, scope hash, prompt hash, and model fingerprint (or explicit unsupported marker).
8. Multi-pass required: audits run multiple independent lenses in one job and merge with dedupe.
9. Convergence gate required: post-remediation reruns must satisfy the K-run stability rule.
10. Regression-proofing required: resolved blocking findings must be converted into an automated check where feasible.

## 3) Multi-Pass Contract (MUST)

A bounded audit run includes at least:

- Pass A: contract/schema invariants
- Pass B: runtime enforcement and gates
- Pass C: tests/CI/receipts/regressions
- Pass D: docs/spec drift and taxonomy consistency

Merged output must be normalized, deduplicated, and assigned stable finding IDs.

## 4) Convergence Rule (MUST)

After remediation:

1. Run the bounded audit K times (default K=3).
2. Hold commit, prompt, scope, and parameters constant.
3. Use declared seed policy for each run.
4. Compute union of findings at/above threshold.

Pass condition:

- union set is empty, and
- run-to-run findings hashes are stable.

If not met, treat as audit-spec defect (scope, taxonomy, or coverage drift), not infinite rerun debt.

## 5) Remediation Discipline (MUST)

- Remediation should be minimal-change and scoped to finding acceptance criteria.
- Every remediation run must include:
  - targeted re-audit of changed files, and
  - full automated gate suite.
- Subjective findings may be downgraded to backlog; they must not block done gate without objective predicate.
