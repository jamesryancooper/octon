# ADR 043: Principles Charter Override Enforcement and Audit

- Date: 2026-02-24
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/cognition/governance/principles/principles.md`
  - `/.octon/cognition/governance/exceptions/principles-charter-overrides.md`
  - `/.octon/cognition/_ops/principles/scripts/lint-principles-governance.sh`
  - `/.octon/cognition/_ops/principles/scripts/audit-principles-charter-overrides.sh`
  - `/.github/workflows/main-pr-first-guard.yml`
  - `/.github/workflows/principles-charter-overrides-audit.yml`

## Context

The charter moved to `change_policy: human-override-only`, but enforcement gaps
remained:

1. no append-only record enforced per direct charter edit,
2. no explicit PR-first guard for `main` with break-glass fallback,
3. no recurring audit to detect stale or incomplete override records.

## Decision

Adopt strict operational controls for direct charter edits:

1. Direct edits to `principles.md` require append-only records in
   `principles-charter-overrides.md`.
2. Governance lint fails if charter edits occur without corresponding ledger
   updates or if required override evidence fields are incomplete.
3. `main` updates are PR-first; direct pushes require
   `BREAK-GLASS: OVR-YYYY-MM-DD-NNN` and ledger linkage.
4. Run recurring monthly audits of override records and fail when active
   records are stale or incomplete.

## Consequences

### Benefits

- Keeps direct charter edits auditable and attributable.
- Preserves PR-first delivery as default while retaining emergency capability.
- Detects override drift before it becomes normalized.

### Costs

- Adds process overhead for rare break-glass edits.
- Requires maintaining an additional governance ledger artifact.
