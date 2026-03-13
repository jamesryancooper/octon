# Contracts (OpenAPI + JSON Schema)

This directory is the source of truth for service and data boundaries.

- `openapi.yaml` - API contract for operations in scope
- `schemas/feature-name.schema.json` - payload schema used by requests,
  responses, and events

If the feature emits on-disk artifacts (JSON, JSONL, manifests), define
artifact schemas here and reference their `schema_version` in the component
guide.

## CI Suggestions

- OpenAPI diff check: fail PRs on breaking contract changes
- JSON Schema validation in tests
- Consumer/provider contract tests if external consumers exist

## Example Command Patterns

- OpenAPI diff: `<openapi-diff-tool> --base <base-spec> --revision <new-spec>`
- Schema validation: `<test-command> <schema-validation-suite>`
