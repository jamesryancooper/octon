---
name: verify
title: Verify Completion
description: Validate the Swift macOS app foundation workflow executed successfully.
---

# Step 8: Verify Completion

## Purpose

**MANDATORY GATE:** Confirm all workflow objectives were achieved. Workflow is NOT complete until this step passes.

## Verification Checklist

### Package Structure (step 2)

- [ ] `Package.swift` exists with correct products and dependencies
- [ ] `Sources/{PROJECT_NAME}/{PROJECT_NAME}.swift` exists (re-exports)
- [ ] `Sources/{PROJECT_NAME}/Core/Types.swift` contains domain types
- [ ] `Sources/{PROJECT_NAME}/Config/Configuration.swift` contains typed config
- [ ] `Sources/{PROJECT_NAME}/Logging/Logger.swift` exists

### Data Layer (step 3a, if not skipped)

- [ ] `Sources/{PROJECT_NAME}/Database/DatabaseManager.swift` has database actor
- [ ] `Sources/{PROJECT_NAME}/Database/Migrations.swift` has schema migrations
- [ ] `Sources/{PROJECT_NAME}/Database/Records/` has at least one record type
- [ ] `Sources/{PROJECT_NAME}/Database/Queries/` has query helpers

### Daemon Service (step 3b, if not skipped)

- [ ] `Sources/{PROJECT_NAME}Daemon/Daemon.swift` has daemon actor
- [ ] `Sources/{PROJECT_NAME}Daemon/IntentQueue.swift` has intent queue
- [ ] `Sources/{PROJECT_NAME}Daemon/FileWatcher.swift` has FSEvents watcher
- [ ] `Resources/com.{author}.{project-slug}d.plist` exists

### Test Harness (step 4, if not skipped)

- [ ] `Tests/{PROJECT_NAME}Tests/` has at least one test file
- [ ] `Tests/{PROJECT_NAME}Tests/Fixtures/TestFixtures.swift` exists
- [ ] `.github/workflows/ci.yml` exists

### CLI Interface (step 5, if not skipped)

- [ ] `Sources/{PROJECT_NAME}CLI/main.swift` has `AsyncParsableCommand`
- [ ] `Sources/{PROJECT_NAME}CLI/Commands/` has subcommand files
- [ ] `Sources/{PROJECT_NAME}CLI/Helpers/` has utility files

### Documentation (step 6, if not skipped)

- [ ] `CLAUDE.md` exists with accurate module layout
- [ ] `CONTRIBUTING.md` exists with accurate workflow
- [ ] `Docs/architecture/overview.md` exists
- [ ] `.github/PULL_REQUEST_TEMPLATE.md` exists
- [ ] `.gitignore` exists

### Smoke Test (step 7)

- [ ] `swift build` passed OR failures documented
- [ ] `swift test` passed OR failures documented

## Actions

1. Check each criterion in the checklist (skipping sections for skipped skills)
2. Document verification results:

   ```markdown
   ## Verification Results

   | Section        | Criteria | Passed | Status |
   | -------------- | -------- | ------ | ------ |
   | Package        | 5/5      | 5/5    | PASS   |
   | Data Layer     | 4/4      | 4/4    | PASS   |
   | Daemon         | 4/4      | 4/4    | PASS   |
   | Test Harness   | 3/3      | 3/3    | PASS   |
   | CLI Interface  | 3/3      | 3/3    | PASS   |
   | Documentation  | 5/5      | 5/5    | PASS   |
   | Smoke Test     | 2/2      | 2/2    | PASS   |

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

**Marker:** `checkpoints/swift-macos-app-foundation/verify.complete`

## Output

Either:

- **PASSED:** All criteria met (workflow complete)
- **FAILED:** Failures documented (return to fix)

## Workflow Complete When

- [ ] All verification criteria pass (adjusted for skipped skills)
- [ ] Results documented
- [ ] Completion declared with summary
