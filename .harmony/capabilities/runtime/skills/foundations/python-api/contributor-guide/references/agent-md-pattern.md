# AGENT.md Structure Pattern

Generate this file by reading actual project state. Replace placeholders
with discovered values.

---

```markdown
# Project Agent Instructions

This file captures repository-specific expectations for automated and human contributors.

## Source of Truth

Read these docs before making architecture-impacting changes:

1. `docs/architecture-spec.md`
2. `docs/implementation-blueprint.md`
3. `docs/contracts/openapi-v1.yaml`
4. `docs/contracts/*.schema.json`
5. `docs/quality-gates-and-release-criteria.md`
6. `docs/testing-strategy.md`

## Module Layout

Use package boundaries aligned with the architecture:

- `src/{{PACKAGE_NAME}}/api`: public HTTP contract and FastAPI entrypoints.
- `src/{{PACKAGE_NAME}}/workflows`: orchestration/workflow definitions.
- `src/{{PACKAGE_NAME}}/models`: schema-aligned Pydantic domain models.
- `src/{{PACKAGE_NAME}}/services`: domain/service layer.
- `src/{{PACKAGE_NAME}}/rendering`: rendering and conversion logic.
- `src/{{PACKAGE_NAME}}/config`: typed configuration loading.
- `src/{{PACKAGE_NAME}}/observability`: structured logging and telemetry helpers.

## Coding Conventions

1. Python {{PYTHON_VERSION}} only.
2. Keep models and API payloads strict (`extra="forbid"` for contracts).
3. Prefer explicit types and typed return values.
4. Do not introduce new dependencies without updating `docs/dependency-compatibility-matrix.md`.
5. Contract changes must include schema/OpenAPI updates and tests in the same PR.

## Testing Expectations

1. Unit tests for business logic and validators.
2. Contract tests for OpenAPI and JSON schema alignment.
3. Integration tests under `tests/integration` must be compose-backed and opt-in (`RUN_INTEGRATION_TESTS=1`).

## Commands Before Commit

Run these from repo root:

\`\`\`bash
just fmt
just check
\`\`\`

If integration code changed:

\`\`\`bash
RUN_INTEGRATION_TESTS=1 pytest -q tests/integration
\`\`\`

## Pull Request Hygiene

1. Keep changes focused and reversible.
2. Document one-way-door decisions in `docs/adr`.
3. Update relevant docs when behavior, contracts, or operational assumptions change.
```
