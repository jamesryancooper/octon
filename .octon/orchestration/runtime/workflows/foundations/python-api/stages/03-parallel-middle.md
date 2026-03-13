---
name: parallel-middle
title: "Parallel Middle Tier"
description: "Run /contract-first-api, /infra-manifest, and /dev-toolchain — independent of each other."
---

# Step 3: Parallel Middle Tier

## Input

- Validated input record (from step 1)
- Completed package structure (from step 2)

## Purpose

Run the three middle-tier skills that depend only on `/scaffold-package`
and are independent of each other. These can execute in any order or
concurrently.

## Actions

### 3a: Contract-First API

**Skip if** `contract-first-api` is in the skip list or no domain
resources were described in the arguments.

1. **Check prerequisites:**

   - `src/{PACKAGE_NAME}/models/base.py` exists with `ContractModel`

2. **Invoke:**

   ```text
   /contract-first-api {DOMAIN_DESCRIPTION}
   ```

   The domain description comes from `$ARGUMENTS`. If the user provided
   resource/endpoint definitions, pass them through. If not, ask the user
   for the API resource definitions before invoking.

3. **Validate outputs:**

   - `docs/contracts/openapi-v1.yaml` exists
   - At least one `docs/contracts/*.schema.json` file exists
   - `src/{PACKAGE_NAME}/api/contracts.py` has Pydantic models
   - `tests/contracts/fixtures/` has at least one valid fixture

### 3b: Infrastructure Manifest

**Skip if** `infra-manifest` is in the skip list or no infrastructure
services were declared.

1. **Invoke:**

   ```text
   /infra-manifest {PROJECT_NAME} {SERVICES...}
   ```

2. **Validate outputs:**

   - `docker-compose.local.yml` exists with declared services
   - If `postgres` declared: `alembic.ini` and `alembic/env.py` exist
   - Named volumes section present in compose file

### 3c: Dev Toolchain

**Skip if** `dev-toolchain` is in the skip list.

1. **Invoke:**

   ```text
   /dev-toolchain {PROJECT_NAME} {PYTHON_VERSION} {SERVICES...}
   ```

2. **Validate outputs:**

   - `justfile` exists with `sync`, `lint`, `fmt`, `type`, `test`, `check` targets
   - `.pre-commit-config.yaml` exists
   - `.gitignore` exists
   - `.env.local.example` exists with fields matching `config/settings.py`

## Handling Failures

Each sub-step is independent. If one fails:

- Record the failure with details
- Continue with the remaining sub-steps
- Failed skills are noted for the verify step

If `contract-first-api` fails, `/test-harness` (step 4) will still run
but produce only infrastructure tests (no contract tests).

## Idempotency

**Check:** Outputs from each sub-step already exist.

- [ ] 3a: `docs/contracts/openapi-v1.yaml` exists (or skipped)
- [ ] 3b: `docker-compose.local.yml` exists (or skipped)
- [ ] 3c: `justfile` exists (or skipped)

**If Already Complete:**

- Skip completed sub-steps, run only those with missing outputs
- Each child skill handles additive generation internally

**Marker:** `checkpoints/python-api-foundation/03-parallel-middle.complete`

## Error Messages

- Contract skill failed: "CONTRACT_FAILED: /contract-first-api exited with errors — test-harness will run without contract tests"
- Infra skill failed: "INFRA_FAILED: /infra-manifest exited with errors — integration tests will lack service fixtures"
- Toolchain skill failed: "TOOLCHAIN_FAILED: /dev-toolchain exited with errors — justfile and linting config must be created manually"
- No domain description: "CONTRACT_NO_DOMAIN: /contract-first-api requires resource/endpoint definitions — provide them or skip this skill"

## Output

- OpenAPI spec, JSON schemas, Pydantic models, fixtures (3a)
- Docker Compose file, Alembic setup (3b)
- justfile, pre-commit, .gitignore, .env.local.example (3c)
- Record of which sub-steps succeeded/failed/skipped

## Proceed When

- [ ] All non-skipped sub-steps either succeeded or have documented failures
- [ ] At least one sub-step succeeded (workflow can continue)
