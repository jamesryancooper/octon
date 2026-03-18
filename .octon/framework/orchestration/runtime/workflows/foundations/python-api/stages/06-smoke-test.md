---
name: smoke-test
title: "Smoke Test"
description: "Run just check to validate the generated project passes linting, typing, and tests."
---

# Step 6: Smoke Test

## Input

- Complete project from steps 2–5
- `justfile` with `check` target (from step 3c)

## Purpose

Validate that the generated project actually works: dependencies install,
linting passes, type checking passes, and tests pass. This catches
integration issues between skills — e.g., a contract model that references
a missing import, or a test fixture with invalid JSON.

## Actions

1. **Check prerequisites:**

   - `justfile` exists with `check` target
   - If no `justfile`, fall back to running commands directly:
     `ruff check . && ruff format --check . && mypy --ignore-missing-imports src tests && pytest -q`

2. **Install dependencies:**

   ```bash
   just sync
   ```

   If `just sync` fails, try `uv sync` directly.

3. **Run the check gate:**

   ```bash
   just check
   ```

   This runs `validate-schemas`, `lint`, `type`, and `test` in sequence.

4. **Record results:**

   ```markdown
   ## Smoke Test Results

   | Check            | Status | Details          |
   | ---------------- | ------ | ---------------- |
   | Dependencies     | PASS   | uv sync complete |
   | Schema validation | PASS  | N schemas valid  |
   | Ruff lint        | PASS   | 0 issues         |
   | Ruff format      | PASS   | 0 reformatted    |
   | Mypy             | PASS   | 0 errors         |
   | Pytest           | PASS   | N passed, 0 failed |
   ```

5. **Handle failures:**

   If any check fails:

   - Record the specific error output
   - Attempt an obvious fix (e.g., missing import, formatting issue)
   - Re-run `just check` after the fix
   - If the fix succeeds, continue
   - If the fix fails or the issue is non-trivial, document the failure
     and proceed to step 7 (do not block the workflow)

## Idempotency

**Check:** Smoke test already passed.

- [ ] Checkpoint file exists with PASSED status

**If Already Complete:**

- Re-run if any files changed since last pass
- Skip if no changes detected

**Marker:** `checkpoints/python-api-foundation/06-smoke-test.complete`

## Error Messages

- No justfile: "SMOKE_NO_JUSTFILE: justfile not found — running checks directly"
- Sync failed: "SMOKE_SYNC_FAILED: Dependency install failed: {details}"
- Check failed: "SMOKE_CHECK_FAILED: {check_name} failed: {details}"

## Output

- Smoke test results table
- List of any failures and attempted fixes

## Proceed When

- [ ] `just check` passes OR failures are documented
- [ ] Results recorded
