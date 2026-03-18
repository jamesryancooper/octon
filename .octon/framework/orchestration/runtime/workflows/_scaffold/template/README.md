# Workflow Template

This scaffold is the canonical starting point for new workflow units.

## Included

- `workflow.yml`
- `stages/01-stage.md`
- `stages/99-verify.md`

`README.md` is not scaffolded by hand. It is generated from the canonical
workflow contract and stage assets.

## Rules

- Author canonical behavior in `workflow.yml` and `stages/`.
- Keep optional `schemas/`, `fixtures/`, `_ops/`, and `references/` local to
  the workflow unit.
- Do not add a root `WORKFLOW.md`.
- Do not depend on temporary design-package paths.
