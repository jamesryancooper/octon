---
name: python-scaffold-package
description: >
  Create an architecture-aligned Python package structure with typed config,
  structured logging, health endpoints, and standard sub-packages. Invoke with
  a project name, description, Python version, and infrastructure dependencies.
skill_sets: [specialist]
capabilities: [phased, external-dependent]
# Write scopes are explicit: workspace scaffolding plus skill log output.
allowed-tools: Read Grep Glob Edit Write(../../../**) Write(/.octon/state/evidence/runs/skills/*) Bash(mkdir) Bash(uv)
---

# Scaffold Package

Create the foundational package structure for a Python project following
contract-first, production-grade conventions.

## Arguments

`$ARGUMENTS` should include:

- **Project name** (lowercase, hyphens for PyPI, underscores for Python package)
- **One-line description**
- **Python version** (e.g., `>=3.12,<3.13`)
- **Infrastructure dependencies** to configure in Settings (subset of: postgres, nats, redis, s3/minio, temporal)
- **Optional**: additional sub-packages beyond the standard set

Example: `myapp "Event processing platform" python3.12 postgres redis nats`

## Pre-flight Checks

Before generating anything:

1. Read `pyproject.toml` if it exists — only fill gaps, never overwrite.
2. Check if `src/` directory exists. If not, this is a fresh scaffold.
3. Normalize the project name: hyphens for `pyproject.toml [project].name`,
   underscores for the Python package directory name.

## Generation Steps

### Step 1: `pyproject.toml`

Use the template in [references/pyproject-template.toml](references/pyproject-template.toml).

- Replace `{{PROJECT_NAME}}` with the hyphenated project name.
- Replace `{{PACKAGE_NAME}}` with the underscored package name.
- Replace `{{DESCRIPTION}}` with the user's description.
- Replace `{{PYTHON_VERSION}}` with the version constraint (e.g., `>=3.12,<3.13`).
- Replace `{{TARGET_VERSION}}` with the ruff target (e.g., `py312`).
- Include runtime dependencies matching declared infrastructure:
  - **Always**: fastapi, pydantic, pydantic-settings, httpx, python-dotenv,
    opentelemetry-api, opentelemetry-sdk, prometheus-client
  - **postgres**: sqlalchemy, alembic, `psycopg[binary]`
  - **nats**: nats-py
  - **redis**: redis
  - **temporal**: temporalio
- If `pyproject.toml` already exists, merge additively using the Edit tool.

### Step 2: Source package tree

Create `src/{{PACKAGE_NAME}}/` with these sub-packages:

```
src/{{PACKAGE_NAME}}/
├── __init__.py          # Package root with version
├── py.typed             # PEP 561 marker (empty file)
├── api/
│   ├── __init__.py
│   ├── app.py           # FastAPI factory
│   └── contracts.py     # Pydantic API models (placeholder)
├── models/
│   ├── __init__.py
│   └── base.py          # ContractModel base class
├── services/
│   └── __init__.py
├── workflows/
│   └── __init__.py
├── rendering/
│   └── __init__.py
├── config/
│   ├── __init__.py
│   └── settings.py      # Typed settings
└── observability/
    ├── __init__.py
    └── logging.py        # Structured JSON logging
```

### Step 3: `models/base.py`

```python
"""Shared base model configuration for contract-bound models."""

from pydantic import BaseModel, ConfigDict


class ContractModel(BaseModel):
    """Strict pydantic model used for frozen contract payloads."""

    model_config = ConfigDict(extra="forbid")
```

### Step 4: `api/app.py`

Use the pattern in [references/app-factory-pattern.py](references/app-factory-pattern.py).

- Create a `create_app() -> FastAPI` factory function.
- Register `/healthz` (GET, `HealthResponse`, tags=["ops"]).
- Register `/readyz` (GET, `ReadyResponse`, 503 response, tags=["ops"]).
- Include minimal `HealthResponse` and `ReadyResponse` contract models in
  `contracts.py` or inline if contracts.py is not yet populated.
- Module-level `app = create_app()`.

### Step 5: `config/settings.py`

Use the pattern in [references/settings-pattern.py](references/settings-pattern.py).

- `BaseSettings` subclass with `SettingsConfigDict(env_file=".env.local", extra="ignore")`.
- `app_env: Literal["local", "dev", "staging", "prod"]` with default `"local"`.
- Add fields matching declared infrastructure dependencies:
  - **postgres**: `postgres_dsn: PostgresDsn`
  - **nats**: `nats_url: AnyUrl`
  - **redis**: `redis_url: RedisDsn`
  - **temporal**: `temporal_hostport` with regex pattern constraint
  - **s3/minio**: `s3_endpoint`, `s3_access_key`, `s3_secret_key: SecretStr`, `s3_bucket`
- Use `Field(alias="ENV_VAR_NAME")` for all fields.
- `@lru_cache(maxsize=1)` on `get_settings()`.

### Step 6: `observability/logging.py`

Use the pattern in [references/logging-pattern.py](references/logging-pattern.py).

- `ContextVar("correlation_id", default=None)` for correlation IDs.
- `set_correlation_id()` and `get_correlation_id()` functions.
- `JsonLogFormatter(logging.Formatter)` emitting newline-delimited JSON.
- Core fields: `timestamp`, `level`, `logger`, `message`.
- Optional fields: `correlation_id`, `trace_id`, `span_id`, `job_id`, `component`.
- `configure_structured_logging(level)` configuring root logger.

### Step 7: `__init__.py` files

Follow the conventions in [references/init-exports.md](references/init-exports.md).

- Each `__init__.py` has a module docstring.
- Public symbols are imported and listed in `__all__`.
- `config/__init__.py` exports `Settings` and `get_settings`.
- `observability/__init__.py` exports `JsonLogFormatter`, `set_correlation_id`,
  `get_correlation_id`, `configure_structured_logging`.

## Edge Cases

- If `src/{{PACKAGE_NAME}}/` already exists, only create missing sub-packages and files.
- If `pyproject.toml` exists, read existing dependencies and only add missing ones.
- Do not create `.venv/` — that is the developer's responsibility.

## Cross-references

- **Run first** in the foundation workflow.
- Feeds into: `/contract-first-api`, `/test-harness`, `/dev-toolchain`, `/infra-manifest`, `/contributor-guide`.

## When to Use

- Starting a new Python API package scaffold with typed config and logging conventions
- Need repeatable scaffolding that follows Octon foundation conventions

## Boundaries

- Does not perform in-place migrations of existing implementations
- Does not install runtime dependencies outside generated project files

## When to Escalate

- Project requires a non-standard directory topology or naming scheme
- Existing code must be migrated or reconciled instead of scaffolded from templates
