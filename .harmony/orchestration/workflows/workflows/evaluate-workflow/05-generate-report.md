---
title: Generate Report
description: Produce final assessment report with grade and recommendations.
---

# Step 5: Generate Report

## Purpose

Compile all assessment results into a comprehensive report with overall grade and actionable recommendations.

## Input

- Structure score from Step 2
- Gap coverage score from Step 3
- Quality scores from Step 4
- All documented issues

## Actions

1. **Calculate total score:**
   ```text
   Total = Structure (25) + Frontmatter (20) + Content (25) + Gap Coverage (20) + Maintainability (10)
   Maximum = 100 points
   ```

2. **Determine grade:**
   ```text
   A: 90-100 points (Exemplary)
   B: 80-89 points (Good)
   C: 70-79 points (Adequate)
   D: 60-69 points (Below Standard)
   F: 0-59 points (Failing)
   ```

3. **Prioritize issues:**
   ```text
   Sort issues by severity:
   1. Critical (blocking, must fix)
   2. Major (significant impact)
   3. Minor (improvement opportunity)
   4. Info (suggestions)
   ```

4. **Generate recommendations:**
   ```text
   For each issue, provide actionable fix:
   - What to change
   - Where to change it
   - Example of correct implementation
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
   | Structure | X | 25 | X% |
   | Frontmatter | X | 20 | X% |
   | Content | X | 25 | X% |
   | Gap Coverage | X | 20 | X% |
   | Maintainability | X | 10 | X% |
   | **Total** | **X** | **100** | **X%** |

   ## Gap Coverage Detail

   | Gap | Status | Notes |
   |-----|--------|-------|
   | Idempotency | Full/Partial/None | X/Y steps |
   | Dependencies | Full/N/A | |
   | Checkpoints | Full/Partial/None | |
   | Versioning | Full/Partial/None | |
   | Parallel | Full/N/A | |

   ## Issues Found

   ### Critical
   - <issue description>

   ### Major
   - <issue description>

   ### Minor
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
   Display report to user
   Optionally save to file: .harmony/continuity/assessments/<workflow-id>.md
   ```

## Idempotency

**Check:** Is report already generated for this run?
- [ ] `checkpoints/evaluate-workflow/<workflow-id>/report.md` exists
- [ ] Report timestamp matches current session

**If Already Complete:**
- Display cached report
- Offer to regenerate with `--force`

**Marker:** `checkpoints/evaluate-workflow/<workflow-id>/05-report.complete`

## Grade Interpretation

| Grade | Meaning | Recommended Action |
|-------|---------|-------------------|
| **A** | Exemplary workflow | None required, maintain quality |
| **B** | Good workflow | Address minor issues when convenient |
| **C** | Adequate workflow | Prioritize gap fixes and quality improvements |
| **D** | Below standard | Run `/update-workflow` to address issues |
| **F** | Failing | Major restructuring needed |

## Report Delivery Options

- **Console:** Display formatted markdown
- **File:** Save to `.harmony/continuity/assessments/<workflow-id>-<date>.md`
- **Both:** Display and save

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
