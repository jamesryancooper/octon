---
name: verify
title: Verify Completion
description: Validate workflow executed successfully.
---

# Step 6: Verify Completion

## Purpose

**MANDATORY GATE:** Confirm all workflow objectives were achieved. Workflow is NOT complete until this step passes.

## Verification Checklist

- [ ] At least one audit skill completed successfully (health audit at minimum)
- [ ] Consolidated report exists at `.harmony/output/reports/YYYY-MM-DD-pre-release-audit.md`
- [ ] Report contains go/no-go recommendation with rationale
- [ ] Report contains findings from all completed audit skills
- [ ] Findings are deduplicated (no duplicate file:line entries)
- [ ] Coverage summary accounts for all audit dimensions
- [ ] Individual audit reports are linked and accessible
- [ ] If migration manifest was provided: migration audit ran (or failure documented)
- [ ] If docs were provided: doc-to-source alignment was checked

## Actions

1. Check each criterion in the checklist
2. Document verification results:
   ```markdown
   ## Verification Results

   | Criterion | Result | Status |
   |-----------|--------|--------|
   | Health audit completed | {{result}} | PASS/FAIL |
   | Consolidated report exists | {{result}} | PASS/FAIL |
   | Go/no-go stated | {{result}} | PASS/FAIL |
   | Findings merged | {{result}} | PASS/FAIL |
   | Deduplicated | {{result}} | PASS/FAIL |
   | Coverage proof | {{result}} | PASS/FAIL |
   | Individual reports linked | {{result}} | PASS/FAIL |
   | Migration audit (if applicable) | {{result}} | PASS/FAIL/N-A |
   | Doc alignment (if applicable) | {{result}} | PASS/FAIL/N-A |

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

**Marker:** `checkpoints/pre-release-audit/verify.complete`

## Output

Either:
- **PASSED:** All criteria met (workflow complete)
- **FAILED:** Failures documented (return to fix)

## Workflow Complete When

- [ ] All verification criteria pass
- [ ] Results documented
- [ ] Completion declared with summary
