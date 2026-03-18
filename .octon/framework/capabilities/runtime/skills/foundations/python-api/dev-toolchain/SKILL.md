---
name: python-dev-toolchain
description: >
  Configure project development tooling: justfile task runner, pre-commit hooks,
  ruff/mypy settings in pyproject.toml, .gitignore, and .env.local.example.
  Invoke with the project name and infrastructure dependencies.
skill_sets: [specialist]
capabilities: [phased, external-dependent]
# Write scopes are explicit: workspace scaffolding plus skill log output.
allowed-tools: Read Grep Glob Edit Write(../../../**) Write(_ops/state/logs/*) Bash(mkdir) Bash(just) Bash(pre-commit)
---

# Dev Toolchain

Configure the development tooling layer for a Python project: task runner,
linters, type checker, pre-commit hooks, gitignore, and environment example.

## Arguments

`$ARGUMENTS` should include:

- **Project name**
- **Python version** (e.g., `3.12`) for ruff target-version and uv venv
- **Infrastructure dependencies** (for `.env.local.example` generation)
- **Optional**: additional justfile targets, custom ruff rules

Example: `myapp python3.12 postgres redis nats s3 temporal`

## Pre-flight Checks

1. Read `pyproject.toml` if it exists to discover existing tool config sections.
2. Read `src/<package>/config/settings.py` if it exists to discover all Settings
   fields for `.env.local.example`.
3. Check which files already exist: `justfile`, `.pre-commit-config.yaml`,
   `.gitignore`, `.env.local.example`.

## Generation Steps

### Step 1: pyproject.toml tool sections

If `[tool.ruff]` is missing from `pyproject.toml`:

```toml
[tool.ruff]
line-length = 100
target-version = "py312"  # Match requires-python
```

If `[tool.pytest.ini_options]` is missing:

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-q"
markers = [
  "integration: tests that require docker-compose dependencies",
]
```

If sections already exist, leave them unless a specific gap is identified.

### Step 2: justfile

Use the template in [references/justfile-template](references/justfile-template).

Standard targets:
- `sync` — install venv + dependencies via uv
- `dev` — boot docker-compose services
- `docker-up`, `docker-down`, `docker-ps`, `docker-logs` — compose management
- `validate-schemas` — validate JSON schemas and OpenAPI spec
- `lint` — `ruff check .` and `ruff format --check .`
- `fmt` — `ruff check --fix .` and `ruff format .`
- `type` — `mypy --ignore-missing-imports src tests`
- `test` — `pytest -q`
- `check` — runs `validate-schemas lint type test` (the CI gate)
- `precommit-install` — `pre-commit install`

Adapt `validate-schemas` by scanning `docs/contracts/` for schema files. If
no schemas exist yet, add a placeholder comment.

### Step 3: `.pre-commit-config.yaml`

Use the template in [references/pre-commit-config-template.yaml](references/pre-commit-config-template.yaml).

Three local hooks:
- `ruff-check` — `ruff check`, system language, Python files
- `ruff-format-check` — `ruff format --check`, system language, Python files
- `mypy` — `mypy --ignore-missing-imports src tests`, no filenames

### Step 4: `.gitignore`

Use the template in [references/gitignore-python.txt](references/gitignore-python.txt).

Covers: Python bytecode, venvs, tooling caches, packaging artifacts, local
env files (with `!.env.local.example` exception), service data, editor files.

### Step 5: `.env.local.example`

Read `config/settings.py` to discover all `Field(alias="...")` declarations.
Generate one line per field with a sensible local default.

Standard defaults for common infrastructure:
- `APP_ENV=local`
- `POSTGRES_DSN=postgresql://postgres:postgres@localhost:5432/<dbname>`
- `NATS_URL=nats://localhost:4222`
- `REDIS_URL=redis://localhost:6379/0`
- `TEMPORAL_HOSTPORT=localhost:7233`
- `S3_ENDPOINT=http://localhost:9000`
- `S3_ACCESS_KEY=minioadmin`
- `S3_SECRET_KEY=minioadmin`
- `S3_BUCKET=<project>-artifacts`

See [references/env-local-example.md](references/env-local-example.md) for the convention.

## Edge Cases

- If `justfile` already exists, read it and only add missing targets.
- If `.pre-commit-config.yaml` already exists, add missing hooks only.
- If no `docs/contracts/` schemas exist yet, generate `validate-schemas` with
  a placeholder comment.
- If no `config/settings.py` exists, generate `.env.local.example` with just
  `APP_ENV=local`.

## Cross-references

- **Depends on**: `/scaffold-package` (pyproject.toml, settings)
- **Complements**: `/test-harness` (pytest config), `/contract-first-api`
  (validate-schemas targets)

## When to Use

- Bootstrapping local developer tooling (just, linting, type checks, pre-commit) for a Python API
- Need repeatable scaffolding that follows Octon foundation conventions

## Boundaries

- Does not perform in-place migrations of existing implementations
- Does not install runtime dependencies outside generated project files

## When to Escalate

- Project requires a non-standard directory topology or naming scheme
- Existing code must be migrated or reconciled instead of scaffolded from templates
