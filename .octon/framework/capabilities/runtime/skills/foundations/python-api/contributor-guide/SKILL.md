---
name: python-contributor-guide
description: >
  Generate AGENT.md, CONTRIBUTING.md, PR template, and CI workflow from actual
  project state. Reads existing files to produce accurate contributor documentation.
  Invoke after other foundation skills have established the project structure.
skill_sets: [specialist]
capabilities: [phased]
# Write scopes are explicit: workspace scaffolding plus skill log output.
allowed-tools: Read Grep Glob Edit Write(../../../**) Write(/.octon/state/evidence/runs/skills/*) Bash(mkdir)
---

# Contributor Guide

Generate contributor documentation by reading the actual project state:
module layout, tooling config, contracts, and infrastructure.

## Arguments

`$ARGUMENTS` should include:

- **Project name**
- **Team name** or contact (for author attribution)
- **Ticket prefix** (e.g., "ASC", "PROJ") if your team requires ticket IDs
- **Optional**: custom branch naming convention, additional review priorities

Example: `myapp "Platform Team" ASC`

## Pre-flight Checks (Discovery Phase)

This skill is primarily read-driven. Discover project state:

1. Read `pyproject.toml` for project name, Python version, dependencies.
2. Read `justfile` for available targets (especially `check`, `fmt`, `lint`,
   `type`, `test`).
3. List `src/<package>/` to discover module layout.
4. List `docs/` to discover source-of-truth documents.
5. List `docs/contracts/` to discover contract files.
6. Read `docs/contracts/versioning-policy.md` if it exists.
7. Read `.pre-commit-config.yaml` if it exists.
8. Read `src/<package>/config/settings.py` to discover infrastructure dependencies.
9. Read existing `AGENT.md` and `CONTRIBUTING.md` if they exist (to preserve
   custom sections).

## Generation Steps

### Step 1: `AGENT.md`

Use the structure in [references/agent-md-pattern.md](references/agent-md-pattern.md).

Sections:

**Source of Truth**: List all docs files discovered, with relative paths.
Prioritize: architecture spec, implementation blueprint, contract files,
quality gates, testing strategy.

**Module Layout**: For each sub-package in `src/<package>/`, one bullet
describing its purpose. Derive descriptions from `__init__.py` docstrings
or use standard conventions:
- `api/` — "public HTTP contract and FastAPI entrypoints"
- `workflows/` — "orchestration/workflow definitions"
- `models/` — "schema-aligned Pydantic domain models"
- `services/` — "domain/service layer"
- `rendering/` — "rendering and conversion logic"
- `config/` — "typed configuration loading"
- `observability/` — "structured logging and telemetry helpers"

**Coding Conventions**:
1. Python version (from `requires-python`).
2. "Keep models and API payloads strict (`extra=\"forbid\"` for contracts)."
3. "Prefer explicit types and typed return values."
4. "Do not introduce new dependencies without updating `docs/dependency-compatibility-matrix.md`."
5. "Contract changes must include schema/OpenAPI updates and tests in the same PR."

**Testing Expectations**:
1. "Unit tests for business logic and validators."
2. "Contract tests for OpenAPI and JSON schema alignment."
3. "Integration tests under `tests/integration` must be compose-backed and opt-in (`RUN_INTEGRATION_TESTS=1`)."

**Commands Before Commit**: List `just fmt` and `just check` (read from
justfile). If integration tests exist, add the integration command.

**Pull Request Hygiene**: Focused changes, ADR documentation, doc updates.

### Step 2: `CONTRIBUTING.md`

Use the structure in [references/contributing-md-pattern.md](references/contributing-md-pattern.md).

Sections:
- **Scope**: Contract-first approach description.
- **Branch Naming**: `<type>/<ticket-id>-<short-description>` with examples
  using the provided ticket prefix when tickets are required. If no ticket
  is used, omit the ticket segment.
- **Commit Message Format**: Conventional Commits with types.
- **Local Workflow**: Numbered list of `just` commands discovered from justfile.
- **Pull Request Expectations**: One concern per PR, What/Why/How, reference ticket.
- **Code Review Conventions**: Reviewer priorities (correctness > security >
  compat > coverage > operations). Author responsibilities.
- **Definition of Ready to Merge**: CI passes, approvals present, no
  unresolved blocking comments, docs updated.

### Step 3: `.github/PULL_REQUEST_TEMPLATE.md`

Use the template in [references/pr-template-pattern.md](references/pr-template-pattern.md).

Sections: What, Why (with `Refs:` line), How, Tradeoffs, Testing
(with `just check` checkbox), Rollout/Rollback, Checklist.

### Step 4: CI workflow (`ci.yml` in `.github/workflows/`)

Use the template in [references/ci-workflow-pattern.yml](references/ci-workflow-pattern.yml).

- Trigger on pull_request and push to main.
- Single job: `check` with `Lint, Type, and Test` name.
- Steps: checkout, setup-python (version from pyproject.toml), install just,
  install uv, `just sync`, `source .venv/bin/activate && just check`.

## Edge Cases

- If `AGENT.md` or `CONTRIBUTING.md` already exist, read them and regenerate
  with updated project state while preserving any custom sections.
- If no `justfile` exists, list raw commands instead of `just` targets.
- If `.github/` does not exist, create it with required subdirectories.
- If no `docs/` directory exists, omit the Source of Truth section or note
  that docs should be added.

## Cross-references

- **Depends on**: all other skills (reads their outputs)
- **Run last** in the foundation workflow

## When to Use

- Generating contributor-facing docs and CI templates from current Python project state
- Need repeatable scaffolding that follows Octon foundation conventions

## Boundaries

- Does not perform in-place migrations of existing implementations
- Does not install runtime dependencies outside generated project files

## When to Escalate

- Project requires a non-standard directory topology or naming scheme
- Existing code must be migrated or reconciled instead of scaffolded from templates
