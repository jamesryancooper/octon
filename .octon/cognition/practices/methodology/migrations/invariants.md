---
title: Architectural Invariants for Profile-Governed Migrations
description: Repository-level invariants that preserve explicit profile selection, deterministic migration behavior, and final-state convergence.
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

# Architectural Invariants for Profile-Governed Migrations

These are repository-level invariants and are expected to remain true over time.

## Invariants (MUST)

1. Profile-first execution: every migration has exactly one selected `change_profile` before implementation.
2. Receipt-first execution: every migration includes `Profile Selection Receipt` evidence before implementation evidence.
3. Hard-gate determinism: profile selection is driven by declared facts and hard-gate logic, not ad-hoc preference.
4. Tie-break escalation: profile conflicts (`atomic` and `transitional` both appearing true) are escalated, never auto-resolved.
5. Pre-1.0 default discipline: in `pre-1.0` mode, `atomic` is default unless hard gates require `transitional`.
6. Transitional boundedness: every transitional migration has explicit phases, exit criteria, and a final decommission/removal date.
7. Final-state convergence: transitional coexistence is temporary and must be removed at final state.
8. Contract authority: schemas, manifests, templates, and validators enforce profile-governance requirements.

## Enforcement Artifacts (Concrete)

These invariants are enforced through repository contracts and CI policy surfaces:

- `/.octon/cognition/practices/methodology/migrations/ci-gates.md`
- `/.octon/cognition/practices/methodology/migrations/legacy-banlist.md`
- `/.octon/cognition/practices/methodology/migrations/index.yml`
- `/.github/workflows/main-pr-first-guard.yml`
- `/.github/workflows/pr-quality.yml`
- `/.github/workflows/alignment-check.yml`

## Allowed Patterns (MAY)

- Atomic clean-break migrations with one-step cutover.
- Transitional phased migrations when hard gates require coexistence.
- Transitional exception notes in pre-1.0 with explicit ownership and removal date.
