---
title: Verify Workflow Creation
description: Validate the created workflow meets all requirements.
---

# Step 8: Verify Workflow Creation

## Purpose

**MANDATORY GATE:** Confirm the workflow was created correctly and meets all quality standards. Workflow creation is NOT complete until this step passes.

## Verification Checklist

### Structure Verification
- [ ] Workflow directory exists at target path
- [ ] `00-overview.md` exists
- [ ] All planned step files exist
- [ ] Final step is verification/validate step
- [ ] File names follow `NN-name.md` pattern

### Frontmatter Verification
- [ ] `title` field present and non-empty
- [ ] `description` field present (max 160 chars)
- [ ] `access` field is `human` or `agent`
- [ ] `version` field present (semantic format)
- [ ] `depends_on` field present (array)
- [ ] `checkpoints` field present with `enabled` and `storage`
- [ ] `parallel_steps` field present (array)

### Content Verification
- [ ] No `[placeholder]` text remains in any file
- [ ] Prerequisites section has at least one item
- [ ] Failure conditions section has at least one item
- [ ] Steps section links to actual files
- [ ] Version History section present

### Gap Fix Verification
- [ ] Every step file has `## Idempotency` section
- [ ] Idempotency sections have Check, If Already Complete, Marker
- [ ] Parallel steps documented in frontmatter (even if empty)
- [ ] Dependencies documented (even if empty)

### Reference Verification
- [ ] Catalog updated (if applicable)
- [ ] Command file created (if access: human)
- [ ] All internal links resolve

## Actions

1. **Run structure checks:**
   ```bash
   ls <target-path>/
   # Verify all expected files present
   ```

2. **Validate frontmatter:**
   ```text
   Parse 00-overview.md frontmatter
   Check each required field
   ```

3. **Scan for placeholders:**
   ```bash
   grep -r "\[.*\]" <target-path>/*.md
   # Should return empty or only valid markdown links
   ```

4. **Validate step files:**
   ```text
   For each step file:
     Check ## Idempotency section exists
     Check ## Actions section exists
     Check ## Output section exists
   ```

5. **Document results:**
   ```markdown
   ## Verification Results

   | Check | Result | Status |
   |-------|--------|--------|
   | Directory exists | Yes | PASS |
   | Overview exists | Yes | PASS |
   | Step files exist | 8/8 | PASS |
   | Frontmatter complete | 7/7 fields | PASS |
   | No placeholders | 0 found | PASS |
   | Idempotency sections | 8/8 steps | PASS |
   | Gap fixes complete | 6/6 | PASS |

   **VERIFICATION:** PASSED
   ```

## If Verification FAILS

If ANY check fails:

1. **Do NOT declare workflow creation complete**
2. **Document** the failures:
   ```markdown
   ## Verification Failures

   - Frontmatter: Missing 'version' field
   - Step 03: No Idempotency section
   - Overview: Contains [placeholder] text on line 45
   ```
3. **Return to** the appropriate step:
   - Missing content -> Step 5 (Customize)
   - Missing gap fixes -> Step 6 (Integrate Gap Fixes)
   - Missing references -> Step 7 (Update References)
   - Missing structure -> Step 4 (Generate Structure)
4. **Re-run** this verification step
5. **Repeat** until all checks pass

## Idempotency

**Check:** Was verification already completed successfully?
- [ ] `checkpoints/create-workflow/<workflow-id>/verify.complete` exists
- [ ] Checkpoint contains PASSED status

**If Already Complete:**
- Report cached verification status
- Optionally re-verify with `--force` flag

**Marker:** `checkpoints/create-workflow/<workflow-id>/verify.complete`

## Output

Either:
- **PASSED:** All checks pass, workflow creation complete
- **FAILED:** Failures documented, return to fix

## Workflow Creation Complete When

- [ ] All verification checks pass
- [ ] Results documented
- [ ] Summary reported to user:
  ```markdown
  ## Workflow Created Successfully

  **Workflow:** <workflow-title>
  **Location:** <target-path>
  **Steps:** <count> steps including verification
  **Access:** <human|agent>

  ### Next Steps

  1. Review generated files
  2. Test workflow execution
  3. Add to version control

  ### Files Created

  - <target-path>/00-overview.md
  - <target-path>/01-<step>.md
  - ...
  ```
