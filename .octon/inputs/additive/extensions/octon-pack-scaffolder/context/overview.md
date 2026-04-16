# Octon Pack Scaffolder Overview

`octon-pack-scaffolder` is a pure additive authoring helper for new extension
packs and common pack-local assets.

## MVP Surface

- one explicit family root: `octon-pack-scaffolder`
- six leaf scaffolds:
  - `create-pack`
  - `create-prompt-bundle`
  - `create-skill`
  - `create-command`
  - `create-context-doc`
  - `create-validation-fixture`

## Operating Model

- explicit `target` dispatch only
- additive writes only under
  `/.octon/inputs/additive/extensions/<pack-id>/`
- idempotent reruns against matching content
- fail-closed handling for conflicting existing content

## Non-Goals

- activating the pack in `instance/extensions.yml`
- publishing extension state
- managing quarantine or compatibility receipts
- introducing governance, runtime, or generated authority

Use `output-shapes.md` as the source of truth for generated file shapes and
`examples/` for minimal worked examples.
