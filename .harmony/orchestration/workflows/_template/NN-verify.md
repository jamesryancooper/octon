---
title: Verify Completion
description: Validate workflow executed successfully.
---

# Step N: Verify Completion

## Purpose

**MANDATORY GATE:** Confirm all workflow objectives were achieved. Workflow is NOT complete until this step passes.

## Verification Checklist

- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

## Actions

1. Check each criterion in the checklist
2. Document verification results:
   ```markdown
   ## Verification Results

   | Criterion | Result | Status |
   |-----------|--------|--------|
   | [Criterion 1] | [Result] | PASS/FAIL |
   | [Criterion 2] | [Result] | PASS/FAIL |
   | [Criterion 3] | [Result] | PASS/FAIL |

   **VERIFICATION:** PASSED/FAILED
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

**Marker:** `checkpoints/[workflow-id]/verify.complete`

## Output

Either:
- **PASSED:** All criteria met (workflow complete)
- **FAILED:** Failures documented (return to fix)

## Workflow Complete When

- [ ] All verification criteria pass
- [ ] Results documented
- [ ] Completion declared with summary
