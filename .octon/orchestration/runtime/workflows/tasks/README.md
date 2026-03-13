# Task Workflows

This directory contains canonical task workflow units with `workflow.yml`,
`stages/`, and generated `guide/` content.

## Workflows

- `agent-led-happy-path/`
- `add-api-endpoint/`
- `add-ui-feature/`
- `fix-a-bug/`
- `handle-security-issue/`
- `run-data-migration/`

Retired workflow artifacts are kept only for historical traceability and are not discoverable via manifest/registry routing.

## Discovery

Each workflow is discoverable through:

- `.octon/orchestration/runtime/workflows/manifest.yml`
- `.octon/orchestration/runtime/workflows/registry.yml`
