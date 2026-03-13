# Output

Deliverables produced by skills, workflows, and agent work.

## Contents

| Subdirectory | Purpose | Naming Convention |
|--------------|---------|-------------------|
| `_meta/architecture/` | Output subsystem specification docs | `README.md` |
| `artifacts/` | Standalone deliverables | Context-dependent |
| `drafts/` | Work-in-progress documents | Context-dependent |
| `plans/` | Design and implementation plans | `YYYY-MM-DD-{description}.md` |
| `reports/` | Report category index and evidence root | `README.md` |
| `reports/analysis/` | Standalone analysis reports and machine-readable summaries | `YYYY-MM-DD-{description}.{md,json,yml}` |
| `reports/packages/` | Multi-file report sets that are not bounded evidence bundles | `YYYY-MM-DD-{slug}/` or `{slug}/` |
| `reports/operations/` | Tooling-generated operational report artifacts | `{timestamp}-{slug}.{md,diff}` |
| `reports/audits/` | Bounded-audit evidence bundles | `YYYY-MM-DD-{slug}/` |
| `reports/migrations/` | Migration verification evidence bundles | `YYYY-MM-DD-{slug}/` |
| `reports/workflows/` | Workflow execution bundles | `YYYY-MM-DD-{slug}/` |
| `reports/decisions/` | Decision-specific optional evidence bundles | `NNN-{slug}/` |

## Convention Authority

- This domain has no local `practices/` surface.
- It inherits naming and authoring conventions from `/.octon/conventions.md`.
- `_meta/architecture/` remains a reference surface.

## Contract

- Write deliverables here, not in source directories.
- `reports/` is a navigational root. Do not dump report files directly into it.
- Standalone report files belong under `reports/analysis/`.
- Multi-file report sets that are not audit/migration/workflow/decision bundles belong under `reports/packages/`.
- Tooling artifacts such as studio apply audits and patch previews belong under `reports/operations/`.
- Bounded-audit evidence bundles belong under `reports/audits/<YYYY-MM-DD>-<slug>/`.
- Migration evidence bundles belong under `reports/migrations/<YYYY-MM-DD>-<slug>/`.
- Workflow execution bundles belong under `reports/workflows/<YYYY-MM-DD>-<slug>/`.
  They must satisfy the workflow bundle contract in
  `reports/workflows/README.md`.
- Decision evidence bundles (when needed) belong under
  `reports/decisions/<NNN>-<slug>/`.
- Drafts are mutable; reports are typically final.
- Skills and workflows specify their output paths in `registry.yml`.
