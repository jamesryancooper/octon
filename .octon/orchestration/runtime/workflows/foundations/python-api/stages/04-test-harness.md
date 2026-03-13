---
name: test-harness
title: "Test Harness"
description: "Run /test-harness to generate three-tier testing infrastructure."
---

# Step 4: Test Harness

## Input

- Validated input record (from step 1)
- Package structure (from step 2)
- Contracts and fixtures (from step 3a, if available)
- Infrastructure config (from step 3b, if available)
- Pytest config in pyproject.toml (from step 3c, if available)

## Purpose

Generate the testing infrastructure: directory structure, conftest fixtures,
contract tests, unit test stubs, and integration scaffolding. This step
benefits from all three middle-tier skills having run first, but degrades
gracefully if some were skipped or failed.

## Actions

1. **Check skip list:**

   If `test-harness` is in the skip list, skip to step 5.

2. **Assess available inputs:**

   | Input                  | Source           | If missing                                  |
   | ---------------------- | ---------------- | ------------------------------------------- |
   | JSON schemas           | step 3a          | Skip contract tests, note in output         |
   | Pydantic models        | step 3a          | Skip pydantic contract tests                |
   | Infrastructure services | step 3b         | Skip integration fixtures for those services |
   | pytest config          | step 3c          | Skill will generate its own                 |

3. **Invoke:**

   ```text
   /test-harness {PROJECT_NAME} auto-discover {SERVICES...}
   ```

   Use `auto-discover` to let the skill scan `docs/contracts/` for schemas.
   If no contracts exist, it will generate only infrastructure tests.

4. **Validate outputs:**

   - `tests/conftest.py` exists with session-scoped fixtures
   - `tests/unit/` directory exists
   - `tests/contracts/` directory exists (even if empty)
   - `tests/integration/conftest.py` exists (if services were declared)
   - At least one test file exists in `tests/unit/`

## Idempotency

**Check:** Test infrastructure already exists.

- [ ] `tests/conftest.py` exists with `load_contract_schema` fixture
- [ ] `tests/unit/test_settings.py` exists
- [ ] `tests/integration/conftest.py` exists (if services declared)

**If Already Complete:**

- Skip to step 5
- The skill itself handles additive generation (only creates missing files)

**Marker:** `checkpoints/python-api-foundation/04-test-harness.complete`

## Error Messages

- Skill invocation failed: "TEST_HARNESS_FAILED: /test-harness exited with errors: {details}"
- No contracts found: "TEST_HARNESS_NO_CONTRACTS: No schemas in docs/contracts/ — generating infrastructure tests only"

## Output

- `tests/` directory structure with conftest fixtures
- Contract tests (if schemas exist)
- Unit test stubs for settings and logging
- Integration test scaffolding (if services declared)

## Proceed When

- [ ] `tests/conftest.py` exists
- [ ] `tests/unit/` has at least one test file
- [ ] `tests/contracts/` directory exists
