# Task Workflows

This directory contains canonical task workflow units with `workflow.yml`,
`stages/`, and generated `guide/` content.

## Workflows

- `agent-led-happy-path/`
- `bootstrap-doctor/`
- `add-api-endpoint/`
- `add-ui-feature/`
- `fix-a-bug/`
- `handle-security-issue/`
- `repo-consequential-preflight/`
- `run-repo-shell-supported-scenario/`
- `run-data-migration/`

Retired workflow artifacts are kept only for historical traceability and are not discoverable via manifest/registry routing.

## Discovery

Each workflow is discoverable through:

- `.octon/framework/orchestration/runtime/workflows/manifest.yml`
- `.octon/framework/orchestration/runtime/workflows/registry.yml`
