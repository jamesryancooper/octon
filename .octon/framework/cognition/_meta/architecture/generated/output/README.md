# Generated And Evidence Output Architecture

Octon no longer uses a single `output/` class root. Generated and
human-facing output artifacts now land in canonical class-root destinations.

## Purpose

- Keep drafts, plans, generated views, and evidence reports separated by
  artifact class.
- Preserve chronological outputs with deterministic naming.
- Maintain subsystem architecture metadata for structural linting consistency.

## Contract

- Draft deliverables belong under `/.octon/inputs/exploratory/drafts/`.
- Plan deliverables belong under `/.octon/inputs/exploratory/plans/`.
- Standalone validation and analysis reports belong under
  `/.octon/state/evidence/validation/analysis/`.
- Authoritative bounded-audit bundles belong under
  `/.octon/state/evidence/validation/audits/<YYYY-MM-DD>-<slug>/`.
- Workflow execution bundles belong under
  `/.octon/state/evidence/runs/workflows/<YYYY-MM-DD>-<slug>/`.
- Migration evidence bundles belong under
  `/.octon/state/evidence/migration/<YYYY-MM-DD>-<slug>/`.
- Decision evidence bundles belong under
  `/.octon/state/evidence/decisions/repo/reports/<NNN>-<slug>/`.
- Runtime-facing generated views belong under `/.octon/generated/effective/**`.
- Transient generated build/cache artifacts belong under `/.octon/generated/.tmp/**`.
