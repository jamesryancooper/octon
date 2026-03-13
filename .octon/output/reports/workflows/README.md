# Workflow Reports

Workflow execution bundles live here.

## Contract

- Workflow run bundles use date-prefixed directories:
  - `YYYY-MM-DD-<slug>/`
- Workflow bundles are not bounded-audit evidence bundles.
- Bounded audits remain under:
  - `/.octon/output/reports/audits/`
- Each authoritative workflow bundle must include:
  - `bundle.yml`
  - `summary.md`
  - `commands.md`
  - `validation.md`
  - `inventory.md`
  - `reports/`
  - `stage-inputs/`
  - `stage-logs/`
- `bundle.yml` must declare:
  - `kind: workflow-execution-bundle`
  - `id: <bundle-directory-name>`
  - `summary: summary.md`
  - `commands: commands.md`
  - `validation: validation.md`
  - `inventory: inventory.md`
  - `reports_dir: reports`
  - `stage_inputs_dir: stage-inputs`
  - `stage_logs_dir: stage-logs`
- Workflow bundles may include additional workflow-specific files alongside the
  minimum contract files.
