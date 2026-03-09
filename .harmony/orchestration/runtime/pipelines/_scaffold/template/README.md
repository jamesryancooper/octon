# Pipeline Template

Use this template when authoring a new canonical pipeline.

## Files

| File | Purpose |
|------|---------|
| `pipeline.yml` | Canonical per-pipeline contract |
| `stages/01-stage.md` | First canonical stage asset |
| `stages/99-verify.md` | Final verification stage asset |

## Rules

- `pipeline.yml` is authoritative for execution semantics.
- `stages/` are canonical runtime assets.
- Optional `schemas/`, `fixtures/`, and `_ops/` remain local to the pipeline.
- Workflow projections are generated from pipeline metadata and stage assets,
  not the other way around in steady state.
- Do not introduce live dependencies on `/.design-packages/`.

## Minimum Completion

A new pipeline is not ready until:

- the pipeline validates with `validate-pipelines.sh`
- its workflow projection metadata is complete
- its done-gate is explicit and fail-closed
- its mutation stages declare scope conservatively
