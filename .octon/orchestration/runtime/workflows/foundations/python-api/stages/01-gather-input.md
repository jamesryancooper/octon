---
name: gather-input
title: "Gather Input"
description: "Collect and validate project name, description, Python version, and infrastructure dependencies."
---

# Step 1: Gather Input

## Input

- User-provided arguments (project name, description, Python version, services)
- Optional: `--skip` flag listing skills to skip

## Purpose

Normalize and validate all inputs before any skill runs. Every downstream
skill needs the same core arguments — collecting them once prevents
repeated prompting and ensures consistency.

## Actions

1. **Parse arguments:**

   Extract from `$ARGUMENTS`:

   - `PROJECT_NAME` — lowercase, hyphens (e.g., `my-app`)
   - `PACKAGE_NAME` — underscored form (e.g., `my_app`)
   - `DESCRIPTION` — quoted one-liner
   - `PYTHON_VERSION` — e.g., `python3.12` → constraint `>=3.12,<3.13`, ruff target `py312`
   - `SERVICES` — subset of: `postgres`, `nats`, `redis`, `s3`, `minio`, `temporal`

2. **Validate:**

   - Project name must be non-empty and match `^[a-z][a-z0-9-]*$`
   - Python version must be 3.12+
   - Services must be from the recognized set (warn on unrecognized, don't fail)

3. **Check for existing project:**

   - If `pyproject.toml` exists, read `[project].name` and confirm it matches
   - If `src/` exists, note this is an incremental run
   - If neither exists, this is a fresh scaffold

4. **Determine skip list:**

   If `--skip` is provided, parse the comma-separated skill names. Validate
   dependency constraints:

   - Cannot skip `scaffold-package` unless `pyproject.toml` and `src/<pkg>/` already exist
   - Cannot skip `contract-first-api` if `test-harness` is not also skipped
     (unless contracts already exist in `docs/contracts/`)

5. **Record input summary:**

   ```markdown
   ## Foundation Input

   | Field          | Value                        |
   | -------------- | ---------------------------- |
   | Project name   | my-app                       |
   | Package name   | my_app                       |
   | Description    | Event processing API         |
   | Python version | >=3.12,<3.13 (target: py312) |
   | Services       | postgres, nats, redis        |
   | Skills to run  | all (or list of active)      |
   | Mode           | fresh / incremental          |
   ```

## Idempotency

**Check:** Input summary already recorded.

- [ ] Checkpoint file exists at `checkpoints/python-api-foundation/01-gather-input.complete`

**If Already Complete:**

- Skip to step 2
- Re-run if arguments have changed

**Marker:** `checkpoints/python-api-foundation/01-gather-input.complete`

## Error Messages

- Missing project name: "PROJECT_NAME_REQUIRED: Provide a project name as the first argument"
- Invalid project name: "PROJECT_NAME_INVALID: Must match ^[a-z][a-z0-9-]*$ (got '{name}')"
- Conflicting name: "PROJECT_NAME_CONFLICT: pyproject.toml has name '{existing}', argument is '{provided}'"
- Invalid skip: "SKIP_INVALID: Cannot skip scaffold-package without existing package structure"

## Output

- Validated input record (PROJECT_NAME, PACKAGE_NAME, DESCRIPTION, PYTHON_VERSION, SERVICES, SKIP_LIST, MODE)
- Input summary for downstream steps

## Proceed When

- [ ] All required fields are populated
- [ ] Project name is valid
- [ ] No unresolvable conflicts with existing project state
- [ ] Skip list (if any) respects dependency constraints
