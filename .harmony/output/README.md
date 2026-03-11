# Output

Deliverables produced by skills, workflows, and agent work.

## Contents

| Subdirectory | Purpose | Naming Convention |
|--------------|---------|-------------------|
| `_meta/architecture/` | Output subsystem specification docs | `README.md` |
| `artifacts/` | Standalone deliverables | Context-dependent |
| `drafts/` | Work-in-progress documents | Context-dependent |
| `plans/` | Design and implementation plans | `YYYY-MM-DD-{description}.md` |
| `reports/` | Audit reports and analysis results | `YYYY-MM-DD-{description}.md` |
| `reports/audits/` | Bounded-audit evidence bundles | `YYYY-MM-DD-{slug}/` |
| `reports/migrations/` | Migration verification evidence bundles | `YYYY-MM-DD-{slug}/` |
| `reports/workflows/` | Workflow execution bundles | `YYYY-MM-DD-{slug}/` |
| `reports/decisions/` | Decision-specific optional evidence bundles | `NNN-{slug}/` |

## Convention Authority

- This domain has no local `practices/` surface.
- It inherits naming and authoring conventions from `/.harmony/conventions.md`.
- `_meta/architecture/` remains a reference surface.

## Contract

- Write deliverables here, not in source directories.
- Reports use date-prefixed filenames for chronological ordering.
- Bounded-audit evidence bundles belong under `reports/audits/<YYYY-MM-DD>-<slug>/`.
- Migration evidence bundles belong under `reports/migrations/<YYYY-MM-DD>-<slug>/`.
- Workflow execution bundles belong under `reports/workflows/<YYYY-MM-DD>-<slug>/`.
  They must satisfy the workflow bundle contract in
  `reports/workflows/README.md`.
- Decision evidence bundles (when needed) belong under
  `reports/decisions/<NNN>-<slug>/`.
- Drafts are mutable; reports are typically final.
- Skills and workflows specify their output paths in `registry.yml`.
