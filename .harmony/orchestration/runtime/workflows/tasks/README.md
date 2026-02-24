# Task Workflows

This directory contains single-file, human-invoked task workflows migrated from `.harmony/orchestration/runtime/workflows/tasks/`.

## Workflows

- `agent-led-happy-path.md` (canonical onboarding flow)
- `add-api-endpoint.md`
- `add-ui-feature.md`
- `fix-a-bug.md`
- `handle-security-issue.md`
- `run-data-migration.md`

Retired workflow artifacts are kept only for historical traceability and are not discoverable via manifest/registry routing.

## Discovery

Each workflow is discoverable through:

- `.harmony/orchestration/runtime/workflows/manifest.yml`
- `.harmony/orchestration/runtime/workflows/registry.yml`
