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
- Architecture metadata for this subsystem lives under
  `output/_meta/architecture/`.
