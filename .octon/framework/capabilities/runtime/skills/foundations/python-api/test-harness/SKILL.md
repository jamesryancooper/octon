---
name: python-test-harness
description: >
  Generate testing infrastructure aligned with project contracts and package
  structure: conftest fixtures, contract tests, unit test stubs, and integration
  test scaffolding. Invoke with the project name and list of infrastructure dependencies.
skill_sets: [specialist]
capabilities: [phased, external-dependent]
# Write scopes are explicit: workspace scaffolding plus skill log output.
allowed-tools: Read Grep Glob Edit Write(../../../**) Write(/.octon/state/evidence/runs/skills/*) Bash(mkdir) Bash(uv)
---

# Test Harness

Generate a three-tier testing pyramid: `tests/unit/`, `tests/contracts/`,
`tests/integration/` — with shared fixtures, contract validation tests, unit
test stubs, and compose-backed integration scaffolding.

## Arguments

`$ARGUMENTS` should include:

- **Project name** (to discover package paths)
- **Contract names** to test (e.g., "scene-dsl, physics-ir") or `auto-discover`
  to scan `docs/contracts/` for `*.schema.json` files
- **Infrastructure dependencies** (postgres, nats, s3, etc.) for integration fixtures
- **Optional**: specific test scenarios to generate beyond defaults

Example: `myapp auto-discover postgres nats s3`

## Pre-flight Checks

1. Read `pyproject.toml` to discover the project name and verify
   `[tool.pytest.ini_options]` exists.
2. Scan `docs/contracts/` for existing `*.schema.json` and `openapi-*.yaml` files.
3. Scan `src/<package>/api/contracts.py` for existing Pydantic models.
4. Scan `src/<package>/config/settings.py` for Settings fields (needed for
   unit test env variable setup).
5. Check for existing `tests/` directory and test files to avoid overwriting.

## Generation Steps

### Step 1: Directory structure

Create these directories and empty `__init__.py` files if they do not exist:

```
tests/
├── __init__.py
├── conftest.py
├── unit/
│   └── __init__.py
├── contracts/
│   ├── __init__.py
│   └── fixtures/
└── integration/
    ├── __init__.py
    └── conftest.py
```

### Step 2: Root `tests/conftest.py`

Use the pattern in [references/root-conftest-pattern.py](references/root-conftest-pattern.py).

Session-scoped fixtures:
- `repo_root` — `Path(__file__).resolve().parents[1]`
- `contracts_dir` — `repo_root / "docs" / "contracts"`
- `contract_fixtures_dir` — `Path(__file__).resolve().parent / "contracts" / "fixtures"`
- `load_json` — callable `(Path) -> dict` that reads and parses JSON
- `load_contract_schema` — callable `(str) -> dict` loading from `contracts_dir`
- `load_contract_fixture` — callable `(str) -> dict` loading from `contract_fixtures_dir`

### Step 3: Integration `tests/integration/conftest.py`

Use the pattern in [references/integration-conftest-pattern.py](references/integration-conftest-pattern.py).

- `IntegrationEndpoints` frozen dataclass with fields for each declared service.
- `integration_enabled` — reads `RUN_INTEGRATION_TESTS` env var.
- `require_integration` — skips if not enabled.
- `integration_endpoints` — constructs dataclass from env vars with local defaults.
- **postgres**: `db_engine` (session-scoped, SQLAlchemy, pre-ping), `db_connection` (function-scoped).
- **nats**: `nats_url` fixture.
- **s3**: `s3_http_client` fixture using httpx.

### Step 4: Contract tests

Generate contract tests based on discovered schemas and models.

Use the patterns in [references/contract-test-patterns.py](references/contract-test-patterns.py).

**`tests/contracts/test_contract_schemas.py`**:
- For each JSON schema, test valid fixtures pass and invalid fixtures fail.
- Use `Draft202012Validator` from `jsonschema`.
- Include helper functions: `_validator()`, `_subschema_validator()`, `_errors()`.

**`tests/contracts/test_openapi_contract.py`**:
- Assert `/healthz:` and `/readyz:` are present in the OpenAPI spec.
- For each versioned resource path, assert it appears in the spec.
- For shared enums, assert values match between OpenAPI and schemas.

**`tests/contracts/test_pydantic_contract_models.py`**:
- For each Pydantic model in `contracts.py`, test `model_validate` with fixtures.
- Test `ValidationError` on invalid inputs.

### Step 5: Unit tests

Use the patterns in [references/unit-test-patterns.py](references/unit-test-patterns.py).

**`tests/unit/test_settings.py`**:
- Discover all Settings fields from `config/settings.py`.
- Generate `REQUIRED_ENV` dict with local defaults for all aliased fields.
- Test: settings parse required env, reject invalid constrained fields, `get_settings` is cached.

**`tests/unit/test_structured_logging.py`**:
- Test `JsonLogFormatter` emits expected core fields.
- Test correlation ID propagation via `set_correlation_id`.
- Test optional fields appear when set on LogRecord.

**API tests** (if `api/app.py` has routes):
- Generate `tests/unit/test_<resource>_api.py` with `TestClient(create_app())`.
- Test health endpoint returns 200.
- Test resource CRUD endpoints based on discovered routes.

### Step 6: Integration smoke tests

**`tests/integration/test_harness_smoke.py`**:
- All tests marked with `@pytest.mark.integration`.
- For each declared service, generate a connectivity smoke test:
  - **postgres**: `SELECT 1` via `db_connection`.
  - **nats**: assert URL starts with `nats://`.
  - **s3**: assert HTTP client can reach the endpoint.

### Step 7: Missing test fixtures

For each JSON schema without existing fixtures, generate:
- `<schema-name>.valid-minimal.json` — only required fields.
- `<schema-name>.invalid-missing-required.json` — missing one required field.

## Edge Cases

- If `tests/conftest.py` already exists, read it and only add missing fixtures.
- If test files already exist, do not overwrite — only add new test functions.
- If no contracts exist yet, generate only infrastructure (conftest, directories,
  unit tests) and note that contract tests will be added when
  `/contract-first-api` is run.

## Cross-references

- **Depends on**: `/scaffold-package` (package structure), `/contract-first-api` (contracts)
- **Feeds into**: `/dev-toolchain` (pytest config in pyproject.toml)

## When to Use

- Building pytest unit, contract, and integration scaffolding aligned with existing contracts
- Need repeatable scaffolding that follows Octon foundation conventions

## Boundaries

- Does not perform in-place migrations of existing implementations
- Does not install runtime dependencies outside generated project files

## When to Escalate

- Project requires a non-standard directory topology or naming scheme
- Existing code must be migrated or reconciled instead of scaffolded from templates
