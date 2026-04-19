---
title: Architectural Invariants for Bounded Audits
description: Repository-level invariants that keep audits finite, reproducible, and convergent.
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

# Bounded Audit Invariants

These invariants are expected to remain true over time.

## Invariants (MUST)

1. One coverage ledger per audit: all in-scope files are accounted for exactly once.
2. One finding identity rule: IDs are deterministic from taxonomy + normalized location + predicate.
3. One done gate expression: done state is machine-checkable and free of subjective clauses.
4. One severity threshold per run: threshold changes require a new run receipt.
5. One consolidated findings set per job: pass outputs are merged and deduplicated before reporting.
6. One convergence decision per remediation cycle: pass/fail derives from K-run policy only.
7. One evidence bundle per run slug: all artifacts required by `README.md` are present.

## Allowed Patterns (MAY)

- Add non-blocking informational findings below threshold.
- Use unsupported markers for unavailable model controls (for example when seed/fingerprint are not exposed), with explicit note in receipt.
- Maintain legacy narrative reports in parallel, provided bundle contract artifacts remain authoritative.
