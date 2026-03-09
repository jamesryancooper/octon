# Workflow Projection Template

This scaffold exists for exceptional workflow-wrapper authoring and projection
inspection only.

Canonical orchestration authoring now starts from:

- `/.harmony/orchestration/runtime/pipelines/_scaffold/template/`

## Rules

- New canonical execution behavior belongs in a pipeline, not in a workflow
  projection.
- Workflow surfaces created from this template must be treated as projections or
  wrapper-local compatibility layers.
- If a workflow needs local helper assets such as `prompts/` or `references/`,
  those assets must remain inside the workflow directory and must not depend on
  `/.design-packages/`.

## See Also

- `/.harmony/orchestration/runtime/pipelines/_scaffold/template/`
- `/.harmony/orchestration/practices/pipeline-authoring-standards.md`
- `/.harmony/orchestration/practices/workflow-authoring-standards.md`
