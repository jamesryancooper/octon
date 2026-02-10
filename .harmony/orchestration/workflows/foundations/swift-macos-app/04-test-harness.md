---
name: test-harness
title: "Test Harness"
description: "Run /test-harness after data-layer and daemon-service are in place."
---

# Step 4: Test Harness

## Input

- Validated input record (from step 1)
- Completed package structure (from step 2)
- Data layer outputs (from step 3a, if run)
- Daemon service outputs (from step 3b, if run)

## Purpose

Generate testing infrastructure that covers all existing source modules:
XCTest suites for core types, database records, daemon actors, and CI
workflow configuration.

## Actions

1. **Check skip list:**

   If `test-harness` is in the skip list:

   - Verify `Tests/{PROJECT_NAME}Tests/` exists with at least one test file
   - If verified, skip to step 5
   - If missing, warn and ask user whether to proceed

2. **Invoke the skill:**

   ```text
   /test-harness {PROJECT_NAME} auto-discover
   ```

   The skill will scan `Sources/` to discover testable modules automatically.

3. **Validate outputs:**

   After the skill completes, confirm these exist:

   - `Tests/{PROJECT_NAME}Tests/Fixtures/TestFixtures.swift`
   - `Tests/{PROJECT_NAME}Tests/Core/TypesTests.swift`
   - `Tests/{PROJECT_NAME}Tests/Database/MigrationTests.swift` (if data-layer ran)
   - `Tests/{PROJECT_NAME}Tests/Database/RecordTests.swift` (if data-layer ran)
   - `Tests/{PROJECT_NAME}Tests/Daemon/IntentQueueTests.swift` (if daemon ran)
   - `.github/workflows/ci.yml`

4. **Record result:**

   Note which test files were generated and what coverage they target.

## Idempotency

**Check:** Test infrastructure already exists.

- [ ] `Tests/{PROJECT_NAME}Tests/` has test files
- [ ] `.github/workflows/ci.yml` exists

**If Already Complete:**

- Skip to step 5
- The skill handles additive generation (only adds missing tests)

**Marker:** `checkpoints/swift-macos-app-foundation/04-test-harness.complete`

## Error Messages

- Skill failed: "TEST_HARNESS_FAILED: /test-harness exited with errors: {details}"
- Missing fixtures: "TEST_FIXTURES_MISSING: Expected TestFixtures.swift but it was not created"

## Output

- XCTest suites covering discovered modules
- Test fixtures with in-memory database helpers
- CI workflow configuration
- List of test files created

## Proceed When

- [ ] `Tests/{PROJECT_NAME}Tests/` has at least one test file
- [ ] Test fixtures file exists
- [ ] CI workflow exists in `.github/workflows/`
