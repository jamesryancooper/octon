---
name: python-contract-first-api
description: >
  Generate a coherent contract set from a domain description: OpenAPI 3.1.0 spec,
  JSON Schema files, Pydantic ContractModel classes, contract tests, and JSON test
  fixtures. Invoke with a domain description and list of _ops/state/resources/endpoints.
skill_sets: [specialist]
capabilities: [phased]
# Write scopes are explicit: workspace scaffolding plus skill log output.
allowed-tools: Read Grep Glob Edit Write(../../../**) Write(_ops/state/logs/*) Bash(mkdir)
---

# Contract-First API

Generate a complete, cross-validated contract set for an API domain: OpenAPI
spec, JSON schemas, Pydantic models, test fixtures, and contract tests.

## Arguments

`$ARGUMENTS` should include:

- **Resource names** and their fields (types, constraints, required vs optional)
- **Endpoint operations** (HTTP verb, path, request/response schemas, status codes)
- **Enum values** or constrained types
- **Versioning**: defaults to `v1` unless specified

Example: `A job management API with: POST /v1/jobs (JobSubmitRequest -> 202 JobResponse), GET /v1/jobs/{job_id} (-> JobResponse | 404 ErrorResponse), GET /v1/jobs/{job_id}/artifact (-> ArtifactLinksResponse | 202 ErrorResponse | 404 ErrorResponse)`

## Pre-flight Checks

1. Read `pyproject.toml` to discover the project name and `src/<package>/` path.
2. Check if `docs/contracts/openapi-v1.yaml` already exists. If yes, this is an
   additive change — extend rather than overwrite. Read the existing spec first.
3. Check if `src/<package>/models/base.py` exists. If not, warn that
   `/scaffold-package` should be run first.
4. Check if `docs/contracts/versioning-policy.md` exists. If yes, read and follow it.
5. Check if `tests/conftest.py` has `load_contract_schema` and `load_contract_fixture`
   fixtures. If not, note that `/test-harness` should be run to get full test coverage.

## Generation Steps

### Step 1: JSON Schema files

For each domain entity described in `$ARGUMENTS`, generate
`docs/contracts/<entity-name>-v1.schema.json`.

Use the skeleton in [references/json-schema-skeleton.json](references/json-schema-skeleton.json).

Rules:
- JSON Schema Draft 2020-12 (`$schema: "https://json-schema.org/draft/2020-12/schema"`).
- Set `$id` to a project-local URI.
- Set `additionalProperties: false` on **all** object types.
- Set `type`, `required`, and property-level constraints (`minLength`, `pattern`,
  `enum`, `minimum`, `maximum`, etc.).
- Include `const` for `schema_version` fields.
- Validate syntax: `python -m json.tool <file> >/dev/null`.

### Step 2: OpenAPI spec

Use the skeleton in [references/openapi-skeleton.yaml](references/openapi-skeleton.yaml).

If creating new, generate `docs/contracts/openapi-v1.yaml`:
- OpenAPI 3.1.0 with `info` (title, version "1.0.0"), `servers`, `security`, `tags`, `paths`.
- Always include `/healthz` and `/readyz` operational endpoints.
- Versioned paths use `/v1/` prefix.
- Use `$ref` for all schema references in `components/schemas`.
- Set `additionalProperties: false` on all component schemas.
- If extending existing: add new paths and schemas additively, never remove.

### Step 3: Pydantic models

Generate or extend `src/<package>/api/contracts.py`.

Use the pattern in [references/contract-model-pattern.py](references/contract-model-pattern.py).

Rules:
- All models inherit from `ContractModel` (from `<package>.models.base`).
- Use `Annotated` types with `StringConstraints` for pattern-validated strings.
- Use `Literal` for enum-like fields.
- Use `Field` with `default`, `ge`, `le`, `min_length`, `max_length` matching
  schema constraints.
- Include `@field_validator` where uniqueness or cross-field constraints apply.
- Define type aliases (e.g., `JobId = Annotated[str, StringConstraints(pattern=...)]`).

### Step 4: Test fixtures

Generate fixtures in `tests/contracts/fixtures/` following the naming convention
in [references/fixture-naming.md](references/fixture-naming.md).

For each contract entity, create at minimum:
- `<entity>.valid-minimal.json` — only required fields, minimal valid values.
- `<entity>.valid-full.json` — all fields populated.
- `<entity>.invalid-<field>.json` — one per constrained field.

### Step 5: Contract tests

Use the patterns in [references/contract-test-patterns.py](references/contract-test-patterns.py).

Generate or extend these test files:

**`tests/contracts/test_contract_schemas.py`**:
- Parameterized tests using `Draft202012Validator` from `jsonschema`.
- Helper functions: `_validator()`, `_subschema_validator()`, `_errors()`.
- Test valid fixtures produce zero errors, invalid fixtures produce expected errors.

**`tests/contracts/test_openapi_contract.py`**:
- Assert all expected endpoints exist in the OpenAPI spec text.
- Assert enum values match between OpenAPI and JSON schemas.
- Assert `/healthz:` and `/readyz:` are present.

**`tests/contracts/test_pydantic_contract_models.py`**:
- Test `model_validate` succeeds on valid fixture payloads.
- Test `model_validate` raises `ValidationError` on invalid fixtures.

### Step 6: Update validate-schemas

If a `justfile` exists, update the `validate-schemas` target to include
`python -m json.tool` validation for each new schema file and `rg -q` checks
for new path segments in the OpenAPI spec.

## Edge Cases

- If contracts already exist, read them first and only add new _ops/state/resources/fields.
- If a schema change would remove or rename a field, warn the user and point to
  the versioning policy.
- If `tests/conftest.py` lacks the required fixtures, note that `/test-harness`
  should be run for full test support, but still generate the test files.

## Cross-references

- **Depends on**: `/scaffold-package` (for `models/base.py` and package structure)
- **Feeds into**: `/test-harness` (for test infrastructure)

## When to Use

- Defining or regenerating OpenAPI, JSON Schema, and contract models from domain requirements
- Need repeatable scaffolding that follows Harmony foundation conventions

## Boundaries

- Does not perform in-place migrations of existing implementations
- Does not install runtime dependencies outside generated project files

## When to Escalate

- Project requires a non-standard directory topology or naming scheme
- Existing code must be migrated or reconciled instead of scaffolded from templates
