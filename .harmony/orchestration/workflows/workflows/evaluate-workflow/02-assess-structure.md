---
title: Assess Structure
description: Check file organization and naming conventions.
---

# Step 2: Assess Structure

## Input

- Parsed workflow model from Step 1

## Purpose

Evaluate the workflow's file structure against conventions.

## Actions

1. **Check overview exists (5 points):**
   ```text
   Does 00-overview.md exist?
   - Yes: +5 points
   - No: 0 points, CRITICAL issue
   ```

2. **Check step file numbering (5 points):**
   ```text
   Do all step files follow NN-name.md pattern?
   - All match: +5 points
   - Some match: +2 points
   - None match: 0 points
   ```

3. **Check final step is verification (5 points):**
   ```text
   Does the last numbered step contain "verify" or "validate"?
   - Yes: +5 points
   - No: 0 points, MAJOR issue
   ```

4. **Check file naming consistency (5 points):**
   ```text
   Are all files kebab-case?
   - All kebab-case: +5 points
   - Mixed: +2 points
   - Other: 0 points
   ```

5. **Check for documentation (5 points):**
   ```text
   Is purpose documented in overview or README?
   - Clear purpose: +5 points
   - Partial: +2 points
   - Missing: 0 points
   ```

## Idempotency

**Check:** Is structure assessment already done?
- [ ] `checkpoints/evaluate-workflow/<workflow-id>/structure-score.json` exists

**If Already Complete:**
- Load cached structure score
- Skip to next step

**Marker:** `checkpoints/evaluate-workflow/<workflow-id>/02-structure.complete`

## Structure Score Schema

```json
{
  "category": "structure",
  "max_points": 25,
  "earned_points": 22,
  "checks": [
    {"name": "overview_exists", "points": 5, "max": 5, "status": "PASS"},
    {"name": "step_numbering", "points": 5, "max": 5, "status": "PASS"},
    {"name": "final_is_verify", "points": 5, "max": 5, "status": "PASS"},
    {"name": "naming_consistency", "points": 5, "max": 5, "status": "PASS"},
    {"name": "documentation", "points": 2, "max": 5, "status": "PARTIAL", "note": "Missing README"}
  ],
  "issues": [
    {"severity": "minor", "message": "Consider adding README.md to workflow directory"}
  ]
}
```

## Scoring Criteria

| Check | Full Points | Partial | None |
|-------|-------------|---------|------|
| Overview exists | 5 | - | 0 |
| Step numbering | 5 | 2 | 0 |
| Final is verify | 5 | - | 0 |
| Naming consistency | 5 | 2 | 0 |
| Documentation | 5 | 2 | 0 |

## Output

- Structure score (0-25 points)
- List of structural issues
- Recommendations for improvement

## Proceed When

- [ ] All 5 checks evaluated
- [ ] Score calculated
- [ ] Issues documented
