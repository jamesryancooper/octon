---
name: verify
title: Verify Completion
description: Validate workflow executed successfully.
---

# Step 8: Verify Completion

## Purpose

**MANDATORY GATE:** Confirm all workflow objectives were achieved. Workflow is NOT complete until this step passes.

## Verification Checklist

- [ ] Health audit completed (or failure documented)
- [ ] If migration manifest was provided: migration audit ran (or failure documented)
- [ ] If `run_cross_subsystem=true`: cross-subsystem audit ran (or failure documented)
- [ ] If `run_freshness=true`: freshness audit ran (or failure documented)
- [ ] Consolidated report exists at `.harmony/output/reports/YYYY-MM-DD-pre-release-audit.md`
- [ ] Report contains go/no-go recommendation with rationale
- [ ] Report contains findings from all completed audit stages
- [ ] Findings are deduplicated (no duplicate file:line entries)
- [ ] Coverage summary accounts for all completed audit dimensions
- [ ] Individual audit reports are linked and accessible
- [ ] Alignment validator passes:
  - `bash .harmony/assurance/_ops/scripts/validate-audit-subsystem-health-alignment.sh`

## Actions

1. Check each criterion in the checklist
2. Run alignment validator:

   ```bash
   bash .harmony/assurance/_ops/scripts/validate-audit-subsystem-health-alignment.sh
   ```

3. Document verification results:

   ```markdown
   ## Verification Results

   | Criterion | Result | Status |
   |-----------|--------|--------|
   | Health audit | {{result}} | PASS/FAIL |
   | Migration audit (if applicable) | {{result}} | PASS/FAIL/N-A |
   | Cross-subsystem audit (if enabled) | {{result}} | PASS/FAIL/N-A |
   | Freshness audit (if enabled) | {{result}} | PASS/FAIL/N-A |
   | Consolidated report exists | {{result}} | PASS/FAIL |
   | Go/no-go stated | {{result}} | PASS/FAIL |
   | Findings merged | {{result}} | PASS/FAIL |
   | Deduplicated | {{result}} | PASS/FAIL |
   | Coverage proof | {{result}} | PASS/FAIL |
   | Individual reports linked | {{result}} | PASS/FAIL |
   | Alignment validator | {{result}} | PASS/FAIL |

   **VERIFICATION:** PASSED/FAILED
   ```

4. If all pass, declare workflow complete
5. If any fail, document and return to the relevant step

## If Verification FAILS

If ANY criterion fails:

1. **Do NOT declare workflow complete**
2. **Document** failures:

   ```markdown
   ## Verification Failures

   - [Criterion]: [What failed and why]
   ```

3. Return to the relevant step
4. Re-run verification

## Idempotency

**Check:** Verification checkpoint exists with PASSED status.

**If Already Complete:**

- Reuse cached verification unless `--force`

**Marker:** `checkpoints/pre-release-audit/08-verify.complete`

## Output

Either:
- **PASSED:** All criteria met (workflow complete)
- **FAILED:** Failures documented (return to fix)

## Workflow Complete When

- [ ] All verification criteria pass
- [ ] Results documented
- [ ] Completion declared with summary
