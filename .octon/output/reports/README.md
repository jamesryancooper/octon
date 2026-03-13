# Reports

Typed report surfaces live here.

## Structure

| Subdirectory | Purpose |
|--------------|---------|
| `analysis/` | Standalone report files and machine-readable summaries |
| `packages/` | Multi-file report sets that are not evidence bundles |
| `operations/` | Tooling-generated operational artifacts |
| `audits/` | Authoritative bounded-audit evidence bundles |
| `migrations/` | Authoritative migration evidence bundles |
| `workflows/` | Authoritative workflow execution bundles |
| `decisions/` | Optional decision evidence bundles |

## Contract

- Do not write new dated report files directly into `reports/`.
- Use `analysis/` for final standalone reports (`.md`, `.json`, `.yml`).
- Use `packages/` when the deliverable is a report set with multiple files.
- Use `operations/` for runtime/tooling artifacts such as apply audits and patch previews.
- Keep the bundle-specific contracts in `audits/`, `migrations/`, `workflows/`, and `decisions/`.
