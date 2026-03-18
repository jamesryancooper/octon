---
title: Generate Report
description: Produce final assessment report from the shared scorer output.
---

# Step 5: Generate Report

## Purpose

Render the shared score data as a readable workflow assessment report.

## Input

- Shared score output
- Shared issue list

## Actions

1. **Read shared scoring output:**
   ```text
   Use the same machine-readable score data used by the Workflow System Audit
   ```

2. **Render category scores:**
   ```text
   Discovery and Routing
   Contract Integrity
   Quality and Gap Coverage
   Execution Safety and Verification
   Maintainability
   Documentation and References
   ```

3. **Prioritize issues by severity:**
   ```text
   high -> medium -> low
   ```

4. **Generate recommendations:**
   ```text
   For each issue, provide:
   - what to change
   - where to change it
   - why it matters for workflow operability
   ```

5. **Format report:**
   ```markdown
   # Workflow Assessment: <Workflow Title>

   **Path:** `<path>`
   **Date:** <date>
   **Grade:** <grade> (<score>/100)

   ## Score Summary

   | Category | Score | Max | Percentage |
   |----------|-------|-----|------------|
   | Discovery and Routing | X | 10 | X% |
   | Contract Integrity | X | 20 | X% |
   | Quality and Gap Coverage | X | 25 | X% |
   | Execution Safety and Verification | X | 20 | X% |
   | Maintainability | X | 10 | X% |
   | Documentation and References | X | 15 | X% |
   | **Total** | **X** | **100** | **X%** |

   ## Issues Found

   ### High
   - <issue description>

   ### Medium
   - <issue description>

   ### Low
   - <issue description>

   ## Recommendations

   1. **<Priority 1>:** <action>
      - Location: <file/line>
      - Fix: <specific change>

   2. **<Priority 2>:** <action>

   ## Summary

   <Overall assessment and suggested next steps>
   ```

6. **Output report:**
   ```text
   Display report to user or save it as a workflow assessment artifact
   ```

## Idempotency

**Check:** Is report already generated for this run?
- [ ] `checkpoints/evaluate-workflow/<workflow-id>/report.md` exists
- [ ] Report timestamp matches current session

**If Already Complete:**
- Display cached report
- Offer to regenerate with `--force`

**Marker:** `checkpoints/evaluate-workflow/<workflow-id>/05-report.complete`

## Output

- Complete assessment report
- Overall grade with interpretation
- Prioritized recommendations
- Next steps guidance

## Workflow Complete When

- [ ] Report generated
- [ ] Grade calculated
- [ ] Recommendations provided
- [ ] Report displayed or saved
