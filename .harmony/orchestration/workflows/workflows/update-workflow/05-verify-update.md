---
title: Verify Update
description: Validate updated workflow meets requirements.
---

# Step 5: Verify Update

## Purpose

**MANDATORY GATE:** Confirm all changes were applied correctly and the workflow is in a valid state. Update is NOT complete until this step passes.

## Verification Checklist

### Change Application Verification
- [ ] All changes in manifest are marked complete
- [ ] No failed changes remain
- [ ] Version field updated to new version
- [ ] Version History updated with change entry

### Frontmatter Verification
- [ ] All required fields present:
  - [ ] title
  - [ ] description
  - [ ] access
  - [ ] version (updated)
  - [ ] depends_on
  - [ ] checkpoints
  - [ ] parallel_steps

### Gap Fix Verification
- [ ] Idempotency sections present in all step files
- [ ] Each Idempotency has Check, If Already Complete, Marker
- [ ] Version History section present and current

### Structural Integrity
- [ ] All step files still exist
- [ ] Links in overview still resolve
- [ ] No syntax errors in YAML frontmatter
- [ ] No broken markdown formatting

## Actions

1. **Verify change application:**
   ```text
   For each change in manifest:
     Verify the change is reflected in file
     Log verification result
   ```

2. **Validate frontmatter:**
   ```bash
   # Check YAML parses correctly
   Parse 00-overview.md frontmatter
   Verify all required fields present
   Verify version matches planned new version
   ```

3. **Validate step files:**
   ```text
   For each step file:
     Check ## Idempotency section exists
     Check section has required clauses
   ```

4. **Check structural integrity:**
   ```text
   Verify all files in workflow directory
   Check all links resolve
   Ensure no leftover backup/temp files
   ```

5. **Run lightweight evaluation (optional):**
   ```text
   If requested (--verify-score):
     Run /evaluate-workflow on updated workflow
     Report new score vs baseline
   ```

6. **Document results:**
   ```markdown
   ## Update Verification Results

   | Check | Result | Status |
   |-------|--------|--------|
   | Changes applied | 12/12 | PASS |
   | Version updated | 1.0.0 -> 1.0.1 | PASS |
   | Frontmatter valid | 7/7 fields | PASS |
   | Idempotency added | 7/7 steps | PASS |
   | Version History | Updated | PASS |
   | Links valid | 8/8 | PASS |

   **VERIFICATION:** PASSED
   ```

## If Verification FAILS

If ANY check fails:

1. **Do NOT declare update complete**
2. **Document** the failures:
   ```markdown
   ## Verification Failures

   - Change change-005 not reflected in 03-plan.md
   - Version field still shows 1.0.0 (expected 1.0.1)
   - Broken link in overview: ./missing-step.md
   ```
3. **Return to** Step 4 (Execute) to fix issues
4. **Re-run** this verification step
5. **Repeat** until all checks pass

## Idempotency

**Check:** Was verification already completed successfully?
- [ ] `checkpoints/update-workflow/<workflow-id>/verify.complete` exists
- [ ] Checkpoint shows PASSED status

**If Already Complete:**
- Report cached verification status
- Offer to re-verify with `--force`

**Marker:** `checkpoints/update-workflow/<workflow-id>/verify.complete`

## Cleanup

After successful verification:

1. **Remove backup (optional):**
   ```text
   If backup exists and update successful:
     Ask user: Keep backup? [y/N]
     If no: Remove .workspace/.backup/<workflow-id>-<timestamp>/
   ```

2. **Clean up checkpoints:**
   ```text
   Move checkpoint files to archive:
     .workspace/progress/checkpoints/update-workflow/<workflow-id>/
     -> .workspace/progress/checkpoints/.archive/update-workflow/<workflow-id>-<timestamp>/
   ```

## Output

Either:
- **PASSED:** All checks pass, update complete
- **FAILED:** Failures documented, return to fix

## Update Complete When

- [ ] All verification checks pass
- [ ] Results documented
- [ ] Summary reported to user:
  ```markdown
  ## Workflow Updated Successfully

  **Workflow:** <workflow-title>
  **Location:** <path>
  **Version:** <old-version> -> <new-version>
  **Changes Applied:** <count>

  ### Changes Summary

  - Added `depends_on`, `checkpoints`, `parallel_steps` to frontmatter
  - Added ## Idempotency to <N> step files
  - Added ## Version History section
  - Updated version to <new-version>

  ### Next Steps

  1. Review changes
  2. Test workflow execution
  3. Commit changes to version control
  ```
