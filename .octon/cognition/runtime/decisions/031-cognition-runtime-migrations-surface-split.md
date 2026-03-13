# ADR 031: Cognition Runtime Migrations Surface Split

- Date: 2026-02-21
- Status: Accepted
- Deciders: Octon maintainers
- Supersedes: Dated migration record placement under `cognition/practices/methodology/migrations/`

## Context

The clean-break migration policy directory (`cognition/practices/methodology/migrations/`) accumulated both:

- migration doctrine/policy artifacts, and
- dated runtime migration execution records.

This mixed concerns between methodology governance and runtime records, reducing structural clarity and discoverability.

Migration evidence reports also lived at the `output/reports/` root, mixed with non-migration report classes.

## Decision

Adopt a clean-break split:

- Keep migration policy doctrine in:
  - `/.octon/cognition/practices/methodology/migrations/`
- Move all dated migration plan records to:
  - `/.octon/cognition/runtime/migrations/<YYYY-MM-DD>-<slug>/plan.md`
- Add canonical discovery index:
  - `/.octon/cognition/runtime/migrations/index.yml`
- Move migration evidence reports to:
  - `/.octon/output/reports/migrations/`

No compatibility mirror is retained for dated record folders under the practices migration policy surface.

## Consequences

### Benefits

- Separates policy/doctrine from runtime migration records.
- Improves migration record discoverability via a single runtime index.
- Consolidates migration evidence outputs under a dedicated output class path.

### Risks

- Existing links or automation targeting legacy dated plan paths can break.
- Existing references to root-level migration evidence reports can drift.

### Mitigations

- One-shot path update across migration plans, reports, templates, and docs.
- Add harness structure guardrails to fail if legacy placement reappears.
- Add legacy-banlist entries for removed dated migration record prefixes.
- Capture verification receipts in a dedicated migration evidence report.
