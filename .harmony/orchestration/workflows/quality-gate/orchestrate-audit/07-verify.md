---
name: verify
title: Verify Completion
description: Validate orchestrated audit executed successfully.
---

# Step 7: Verify Completion

## Purpose

**MANDATORY GATE:** Confirm all workflow objectives were achieved. Workflow is NOT complete until this step passes.

## Verification Checklist

- [ ] All partition reports exist at expected paths
- [ ] Consolidated report exists at `.harmony/output/reports/YYYY-MM-DD-migration-audit-consolidated.md`
- [ ] Consolidated report includes findings from all successful partitions
- [ ] Global self-challenge completed with all 5 checks documented
- [ ] Deduplication applied (no duplicate file:line entries across partitions)
- [ ] Coverage proof accounts for all files in full scope
- [ ] Any failed partitions documented with impact assessment
- [ ] Fix batches are actionable
- [ ] Idempotency metadata recorded (manifest hash, partition plan hash, file count)
- [ ] Execution log written

## Actions

1. Check each criterion in the checklist
2. Document verification results:

   ```markdown
   ## Verification Results

   | Criterion | Result | Status |
   | --------- | ------ | ------ |
   | Partition reports exist | K/K present | PASS |
   | Consolidated report exists | Yes | PASS |
   | Findings from all partitions | K/K included | PASS |
   | Global self-challenge | 5/5 checks | PASS |
   | Deduplication | 0 duplicates | PASS |
   | Coverage proof | N/N files | PASS |
   | Failed partitions documented | 0 failures | PASS |
   | Fix batches actionable | Yes | PASS |
   | Idempotency metadata | Present | PASS |
   | Execution log | Written | PASS |

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

**Marker:** `checkpoints/orchestrate-audit/verify.complete`

## Output

Either:

- **PASSED:** All criteria met (workflow complete)
- **FAILED:** Failures documented (return to fix)

## Workflow Complete When

- [ ] All verification criteria pass
- [ ] Results documented
- [ ] Completion declared with summary
