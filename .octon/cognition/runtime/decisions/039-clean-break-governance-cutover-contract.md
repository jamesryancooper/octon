# ADR 039: Clean-Break Governance Cutover Contract

- Date: 2026-02-24
- Status: Accepted
- Deciders: Octon maintainers
- Supersedes: Implicit/partial migration rollback and dual-path tolerance language
- Related:
  - `/.octon/cognition/practices/methodology/migrations/README.md`
  - `/.octon/cognition/practices/methodology/migrations/doctrine.md`
  - `/.octon/cognition/practices/methodology/migrations/invariants.md`

## Context

The migration program requires a strict contract before implementation work
proceeds. Existing migration guidance already favored clean-break behavior, but
it did not explicitly lock two high-risk governance outcomes:

1. executing old and new governance paths in parallel after cutover,
2. using partial rollback paths that leave mixed governance state.

Without an explicit contract, migrations can drift into long-lived transitional
states with ambiguous runtime authority and unclear recovery semantics.

## Decision

Adopt an explicit clean-break governance migration contract with four mandatory
rules:

1. Cutover is a single promotion event.
2. After cutover, old and new governance paths MUST NOT run in parallel.
3. Rollback after cutover is full-revert-only (revert the cutover promotion as
   a whole).
4. If full revert is not deterministic, promotion is blocked (fail closed).

## Consequences

### Benefits

- Deterministic runtime authority at all times.
- Elimination of prolonged dual-governance drift windows.
- Clear rollback semantics and simpler incident response.
- Stronger CI gating and easier auditability.

### Costs

- Reduced flexibility for partial rollback tactics.
- Requires stricter migration planning before promotion.

### Follow-on Work

1. Enforce run-profile-to-mode mapping with ACP ceilings and evidence contracts.
2. Add drift and consistency validators that fail closed in local and CI checks.
3. Record cutover evidence in a single migration promotion report.
