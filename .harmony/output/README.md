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
| `reports/migrations/` | Migration verification evidence bundles | `YYYY-MM-DD-{slug}/` |
| `reports/decisions/` | Decision-specific optional evidence bundles | `NNN-{slug}/` |

## Contract

- Write deliverables here, not in source directories.
- Reports use date-prefixed filenames for chronological ordering.
- Migration evidence bundles belong under `reports/migrations/<YYYY-MM-DD>-<slug>/`.
- Decision evidence bundles (when needed) belong under
  `reports/decisions/<NNN>-<slug>/`.
- Drafts are mutable; reports are typically final.
- Skills and workflows specify their output paths in `registry.yml`.
