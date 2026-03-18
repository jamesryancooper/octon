---
name: smoke-test
title: "Smoke Test"
description: "Run swift build && swift test to validate the generated project."
---

# Step 7: Smoke Test

## Input

- Complete project scaffold (from steps 2–6)

## Purpose

Validate that the generated project compiles and tests pass. This is a
mechanical check — it does not verify correctness of generated code
beyond compilation and basic test execution.

## Actions

1. **Build the project:**

   ```bash
   swift build 2>&1
   ```

   Capture and record all output including warnings.

2. **Run tests:**

   ```bash
   swift test 2>&1
   ```

   Capture test results.

3. **Run schema validation (if applicable):**

   If `requirements-dev.txt` and `tests/test_spec_conformance.py` exist:

   ```bash
   pip install -r requirements-dev.txt && pytest tests/test_spec_conformance.py
   ```

4. **Record results:**

   ```markdown
   ## Smoke Test Results

   | Check          | Result | Details          |
   | -------------- | ------ | ---------------- |
   | swift build    | PASS   | 0 warnings       |
   | swift test     | PASS   | 12/12 tests pass |
   | Schema tests   | PASS   | 4/4 specs valid  |
   ```

5. **If build fails:**

   - Read compiler errors
   - Attempt targeted fixes (missing imports, type mismatches)
   - Re-run build
   - If still failing after one fix attempt, document failures and proceed

6. **If tests fail:**

   - Read test output for specific failures
   - Document which tests failed and why
   - Do NOT block contributor-guide — test failures are informational

## Idempotency

**Check:** Smoke test already passed.

- [ ] Checkpoint file exists with PASSED status

**If Already Complete:**

- Skip to step 8
- Re-run if any source files changed since last smoke test

**Marker:** `checkpoints/swift-macos-app-foundation/07-smoke-test.complete`

## Error Messages

- Build failed: "BUILD_FAILED: swift build exited with errors — see details above"
- Tests failed: "TESTS_FAILED: {N} test(s) failed — see details above"
- Schema validation failed: "SCHEMA_FAILED: pytest reported failures — see details above"

## Output

- Build success/failure with details
- Test results with pass/fail counts
- Schema validation results (if applicable)

## Proceed When

- [ ] `swift build` completed (pass or documented failures)
- [ ] `swift test` completed (pass or documented failures)
- [ ] Results are recorded
