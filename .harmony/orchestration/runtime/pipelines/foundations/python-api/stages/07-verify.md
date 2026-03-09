---
name: verify
title: Verify Completion
description: Validate the Python API foundation workflow executed successfully.
---

# Step 7: Verify Completion

## Purpose

**MANDATORY GATE:** Confirm all workflow objectives were achieved. Workflow is NOT complete until this step passes.

## Verification Checklist

### Package Structure (step 2)

- [ ] `pyproject.toml` exists with correct project name and dependencies
- [ ] `src/{PACKAGE_NAME}/__init__.py` exists
- [ ] `src/{PACKAGE_NAME}/models/base.py` contains `ContractModel`
- [ ] `src/{PACKAGE_NAME}/config/settings.py` contains typed `Settings`
- [ ] `src/{PACKAGE_NAME}/api/app.py` contains `create_app()`
- [ ] `src/{PACKAGE_NAME}/observability/logging.py` exists

### Contracts (step 3a, if not skipped)

- [ ] `docs/contracts/openapi-v1.yaml` exists
- [ ] At least one `docs/contracts/*.schema.json` exists
- [ ] `src/{PACKAGE_NAME}/api/contracts.py` has Pydantic models
- [ ] `tests/contracts/fixtures/` has at least one valid fixture

### Infrastructure (step 3b, if services declared)

- [ ] `docker-compose.local.yml` exists with declared services
- [ ] `alembic.ini` exists (if postgres declared)
- [ ] `alembic/env.py` exists (if postgres declared)

### Toolchain (step 3c, if not skipped)

- [ ] `justfile` exists with `sync`, `lint`, `fmt`, `type`, `test`, `check` targets
- [ ] `.pre-commit-config.yaml` exists
- [ ] `.gitignore` exists
- [ ] `.env.local.example` exists

### Testing (step 4, if not skipped)

- [ ] `tests/conftest.py` exists with shared fixtures
- [ ] `tests/unit/` has at least one test file
- [ ] `tests/contracts/` directory exists
- [ ] `tests/integration/conftest.py` exists (if services declared)

### Documentation (step 5, if not skipped)

- [ ] `AGENT.md` exists with accurate module layout
- [ ] `CONTRIBUTING.md` exists with accurate workflow
- [ ] `.github/PULL_REQUEST_TEMPLATE.md` exists
- [ ] `.github/workflows/ci.yml` exists

### Smoke Test (step 6)

- [ ] `just check` passed OR failures documented

## Actions

1. Check each criterion in the checklist (skipping sections for skipped skills)
2. Document verification results:

   ```markdown
   ## Verification Results

   | Section       | Criteria | Passed | Status |
   | ------------- | -------- | ------ | ------ |
   | Package       | 6/6      | 6/6    | PASS   |
   | Contracts     | 4/4      | 4/4    | PASS   |
   | Infrastructure | 3/3     | 3/3    | PASS   |
   | Toolchain     | 4/4      | 4/4    | PASS   |
   | Testing       | 4/4      | 4/4    | PASS   |
   | Documentation | 4/4      | 4/4    | PASS   |
   | Smoke Test    | 1/1      | 1/1    | PASS   |

   **VERIFICATION:** PASSED
   ```

3. If all pass, declare workflow complete
4. If any fail, document and return to appropriate step

## If Verification FAILS

If ANY criterion fails:

1. **Do NOT declare workflow complete**
2. **Document** the failure:

   ```markdown
   ## Verification Failures

   - [Criterion]: [What failed and why]
   - [Recommended action]: Return to step N
   ```

3. **Return to** relevant step to address the failure
4. **Re-run** this verification step
5. **Repeat** until verification passes

## Idempotency

**Check:** Was verification already completed?

- [ ] Checkpoint file exists with PASSED status

**If Already Complete:**

- Report cached verification status
- Skip re-verification unless `--force` flag

**Marker:** `checkpoints/python-api-foundation/verify.complete`

## Output

Either:

- **PASSED:** All criteria met (workflow complete)
- **FAILED:** Failures documented (return to fix)

## Workflow Complete When

- [ ] All verification criteria pass (adjusted for skipped skills)
- [ ] Results documented
- [ ] Completion declared with summary
