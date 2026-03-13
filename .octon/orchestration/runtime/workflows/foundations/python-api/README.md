---
name: "python-api-foundation"
description: "Orchestrate the six Python API foundation skills in dependency order: scaffold-package first, then contract-first-api / infra-manifest / dev-toolchain in parallel, then test-harness, then contributor-guide last. Supports partial runs and resume after interruption."
steps:
  - id: "gather-input"
    file: "stages/01-gather-input.md"
    description: "gather-input"
  - id: "scaffold-package"
    file: "stages/02-scaffold-package.md"
    description: "scaffold-package"
  - id: "parallel-middle"
    file: "stages/03-parallel-middle.md"
    description: "parallel-middle"
  - id: "test-harness"
    file: "stages/04-test-harness.md"
    description: "test-harness"
  - id: "contributor-guide"
    file: "stages/05-contributor-guide.md"
    description: "contributor-guide"
  - id: "smoke-test"
    file: "stages/06-smoke-test.md"
    description: "smoke-test"
  - id: "verify"
    file: "stages/07-verify.md"
    description: "verify"
---

# Python Api Foundation

_Generated README from canonical workflow `python-api-foundation`._

## Usage

```text
/python-api-foundation
```

## Purpose

Orchestrate the six Python API foundation skills in dependency order: scaffold-package first, then contract-first-api / infra-manifest / dev-toolchain in parallel, then test-harness, then contributor-guide last. Supports partial runs and resume after interruption.

## Target

This README summarizes the canonical workflow unit at `.octon/orchestration/runtime/workflows/foundations/python-api`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/orchestration/runtime/workflows/foundations/python-api/workflow.yml`.
- External runtime dependencies required by the target project are available.

## Parameters

- `project_name` (text, required=true): Project name (lowercase, hyphens)
- `description` (text, required=true): One-line project description
- `python_version` (text, required=true), default=`python3.12`: Python version (e.g., python3.12)
- `services` (text, required=false): Infrastructure services: postgres, nats, redis, s3, temporal
- `skip` (text, required=false): Comma-separated skill IDs to skip

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `project_scaffold` -> `src/{{package_name}}/`: Complete Python package structure
- `contracts` -> `docs/contracts/`: OpenAPI spec, JSON schemas, and versioning policy
- `test_suite` -> `tests/`: Three-tier test pyramid
- `contributor_docs` -> `AGENT.md`: AI agent orientation document

## Steps

1. [gather-input](./stages/01-gather-input.md)
2. [scaffold-package](./stages/02-scaffold-package.md)
3. [parallel-middle](./stages/03-parallel-middle.md)
4. [test-harness](./stages/04-test-harness.md)
5. [contributor-guide](./stages/05-contributor-guide.md)
6. [smoke-test](./stages/06-smoke-test.md)
7. [verify](./stages/07-verify.md)

## Verification Gate

- [ ] `pyproject.toml` exists with correct project name and dependencies
- [ ] `src/<package>/` tree exists with all standard sub-packages
- [ ] `docs/contracts/openapi-v1.yaml` exists (if contracts were generated)
- [ ] `tests/` directory has conftest, contract tests, and unit tests
- [ ] `docker-compose.local.yml` exists (if infrastructure was declared)
- [ ] `justfile` exists with standard targets
- [ ] `AGENT.md` and `CONTRIBUTING.md` exist
- [ ] `just check` passes (or failures are documented)
- [ ] Verification step passes

## References

- Canonical contract: `.octon/orchestration/runtime/workflows/foundations/python-api/workflow.yml`
- Canonical stages: `.octon/orchestration/runtime/workflows/foundations/python-api/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `python-api-foundation` |

