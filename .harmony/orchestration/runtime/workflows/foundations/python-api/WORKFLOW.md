---
name: python-api-foundation
description: >
  Orchestrate the six Python API foundation skills in dependency order:
  scaffold-package first, then contract-first-api / infra-manifest /
  dev-toolchain in parallel, then test-harness, then contributor-guide
  last. Supports partial runs and resume after interruption.
steps:
  - id: gather-input
    file: 01-gather-input.md
    description: Collect project name, description, Python version, and infrastructure dependencies.
  - id: scaffold-package
    file: 02-scaffold-package.md
    description: Run /scaffold-package to create package structure.
  - id: parallel-middle
    file: 03-parallel-middle.md
    description: Run /contract-first-api, /infra-manifest, and /dev-toolchain (independent).
  - id: test-harness
    file: 04-test-harness.md
    description: Run /test-harness after contracts, infra, and toolchain are in place.
  - id: contributor-guide
    file: 05-contributor-guide.md
    description: Run /contributor-guide last, reading all outputs.
  - id: smoke-test
    file: 06-smoke-test.md
    description: Run just check to validate the generated project.
  - id: verify
    file: 07-verify.md
    description: Validate workflow executed successfully.
# --- Harmony extensions ---
access: human
version: "1.0.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".harmony/continuity/checkpoints/"
parallel_steps:
  - group: "middle-tier"
    steps: ["03-parallel-middle"]
    join_at: "04-test-harness"
---

# Python API Foundation: Overview

Orchestrate a full Python API project scaffold by running the six
foundation skills in dependency order — from empty directory to a
working, linted, tested, documented project.

## Usage

```text
python-api-foundation <project-name> "<description>" <python-version> <services...>
```

**Examples:**

```text
# Minimal API (no infrastructure)
python-api-foundation myapp "Event processing API" python3.12

# Full stack with infrastructure
python-api-foundation myapp "Event processing API" python3.12 postgres nats redis s3 temporal

# Partial run — contracts + tests only (existing project)
python-api-foundation myapp --skip scaffold-package,infra-manifest,dev-toolchain,contributor-guide
```

## Target

A new or existing directory where a Python API project will be scaffolded.
The workflow creates or extends: `pyproject.toml`, `src/<package>/`,
`docs/contracts/`, `tests/`, `docker-compose.local.yml`, `justfile`,
`AGENT.md`, `CONTRIBUTING.md`, and CI config.

## Prerequisites

- Python 3.12+ available on PATH
- `uv` package manager installed
- `just` task runner installed (for smoke test)
- Docker / Docker Compose (if infrastructure services are declared)

## Failure Conditions

- No project name provided -> STOP, ask user
- `pyproject.toml` exists with conflicting package name -> STOP, confirm with user
- `/scaffold-package` fails -> STOP, nothing else can proceed
- A middle-tier skill fails -> CONTINUE with remaining skills, document failure
- `/test-harness` fails -> CONTINUE to contributor-guide, document failure
- `just check` fails -> document failures, do NOT block contributor-guide

## Steps

1. [Gather Input](./01-gather-input.md) - Collect and validate arguments
2. [Scaffold Package](./02-scaffold-package.md) - Create package structure
3. [Parallel Middle](./03-parallel-middle.md) - Contracts, infra, and toolchain
4. [Test Harness](./04-test-harness.md) - Testing infrastructure
5. [Contributor Guide](./05-contributor-guide.md) - Documentation generation
6. [Smoke Test](./06-smoke-test.md) - Run `just check` for validation
7. [Verify](./07-verify.md) - Validate workflow executed successfully

## Dependency Diagram

```text
01 gather-input
       │
       ▼
02 scaffold-package
       │
  ┌────┼────┐
  ▼    ▼    ▼
 03a  03b  03c     ← 03 parallel-middle
 api  infra tool
  └────┼────┘
       ▼
04 test-harness
       │
       ▼
05 contributor-guide
       │
       ▼
06 smoke-test
       │
       ▼
07 verify
```

## Verification Gate

Python API Foundation is NOT complete until:

- [ ] `pyproject.toml` exists with correct project name and dependencies
- [ ] `src/<package>/` tree exists with all standard sub-packages
- [ ] `docs/contracts/openapi-v1.yaml` exists (if contracts were generated)
- [ ] `tests/` directory has conftest, contract tests, and unit tests
- [ ] `docker-compose.local.yml` exists (if infrastructure was declared)
- [ ] `justfile` exists with standard targets
- [ ] `AGENT.md` and `CONTRIBUTING.md` exist
- [ ] `just check` passes (or failures are documented)
- [ ] Verification step passes

## Version History

| Version | Date       | Changes         |
| ------- | ---------- | --------------- |
| 1.0.0   | 2026-02-09 | Initial version |

## References

- **Foundation skill:** `.harmony/capabilities/runtime/skills/foundations/python-api/SKILL.md`
- **Child skills:** `.harmony/capabilities/runtime/skills/foundations/python-api/*/SKILL.md`
- **Workflow template:** `.harmony/orchestration/runtime/workflows/_scaffold/template/`
