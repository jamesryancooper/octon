# ADR 041: Principles Major Framing Human Override Contract

- Date: 2026-02-24
- Status: Superseded by ADR 042
- Deciders: Octon maintainers
- Superseded-by:
  - `042-principles-charter-human-override-direct-edit-policy`
- Amends:
  - `040-principles-charter-successor-v2026-02-24`
- Related:
  - `/.octon/cognition/governance/principles/principles.md`
  - `/.octon/cognition/governance/principles/README.md`
  - `/.octon/cognition/governance/principles/index.yml`

## Context

The constitutional charter at
`/.octon/cognition/governance/principles/principles.md` is
`human-override-only` by policy (immutable by default, direct edits allowed only
with explicit human override). Charter-evolution language requires stronger
governance when major framing shifts are proposed.

The major framing-shift path now requires a human override that is explicit,
bounded, and auditable. That requirement must be reflected in the authoritative
charter and discovery indexes so agents cannot treat framing overrides as
implicit or automated.

## Decision

Adopt a human-only major framing-shift override contract in the authoritative
charter and sync discovery surfaces.

Required override fields in the charter:

1. `rationale`
2. `responsible_owner`
3. `review_date`
4. `override_scope`
5. `reviewed_by` (review and agreement evidence)
6. `exception_log` (intentional, non-automated exception record)

Operational rule:

- Automation may propose framing changes, but it must not approve or apply a
  major framing-shift override.

## Consequences

### Benefits

- Aligns charter governance with explicit human override intent.
- Improves auditability and boundary clarity for major framing shifts.
- Prevents silent or purely automated framing overrides.

### Costs

- Adds review and logging overhead for major framing changes.
- Requires strict metadata completeness before framing override adoption.

## Notes

- This ADR is superseded by ADR 042 and retained for decision-chain integrity.
