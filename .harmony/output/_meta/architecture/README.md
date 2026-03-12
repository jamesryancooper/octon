# Output Architecture

Output stores generated deliverables and now follows the same structural
contract as other subsystems.

## Purpose

- Keep artifacts, drafts, plans, and reports separated from source domains.
- Preserve chronological outputs with deterministic naming.
- Maintain subsystem architecture metadata for structural linting consistency.

## Contract

- Generated content belongs under `output/` subdirectories (`artifacts/`,
  `drafts/`, `plans/`, `reports/`).
- `output/reports/` is a category index, not a flat write target.
- Standalone report files belong under
  `output/reports/analysis/<YYYY-MM-DD>-<slug>.<ext>`.
- Multi-file report sets that are not evidence bundles belong under
  `output/reports/packages/<slug>/` or
  `output/reports/packages/<YYYY-MM-DD>-<slug>/`.
- Tooling-generated operational artifacts belong under
  `output/reports/operations/`.
- Migration evidence bundles belong under
  `output/reports/migrations/<YYYY-MM-DD>-<slug>/` and include
  `bundle.yml`, `evidence.md`, `commands.md`, `validation.md`, and
  `inventory.md`.
- Decision evidence bundles (optional) belong under
  `output/reports/decisions/<NNN>-<slug>/` and, when present, include
  `bundle.yml`, `evidence.md`, `commands.md`, `validation.md`, and
  `inventory.md`.
- Architecture metadata for this subsystem lives under
  `output/_meta/architecture/`.
