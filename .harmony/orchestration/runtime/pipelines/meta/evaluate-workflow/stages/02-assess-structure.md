---
title: Assess Structure
description: Check entrypoint, step parity, and format-specific structure conventions.
---

# Step 2: Assess Structure

## Input

- Parsed workflow model from Step 1

## Purpose

Evaluate workflow structure against the current directory and single-file contracts.

## Actions

1. **Check valid entrypoint exists:**
   ```text
   Directory workflow: WORKFLOW.md exists
   Single-file workflow: target file exists and parses
   ```

2. **Check declared step/file parity:**
   ```text
   Directory workflow: every declared step file exists
   Single-file workflow: N/A, inline flow is valid
   ```

3. **Check verification is structurally reachable:**
   ```text
   Directory: final step or workflow content reaches verification
   Single-file: Required Outcome or equivalent verification section exists
   ```

4. **Check naming consistency:**
   ```text
   Filenames and declared step references follow repo conventions
   ```

5. **Check purpose/usage documentation exists:**
   ```text
   The workflow explains what it does and when to use it
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
  "category": "contract_integrity",
  "max_points": 20,
  "earned_points": 18,
  "checks": [
    {"name": "entrypoint", "status": "PASS"},
    {"name": "declared_step_parity", "status": "PASS"},
    {"name": "verification_reachable", "status": "PARTIAL"},
    {"name": "naming_consistency", "status": "PASS"}
  ],
  "issues": [
    {"severity": "medium", "message": "Single-file workflow lacks explicit Required Outcome"}
  ]
}
```

## Output

- Structure/contract score
- List of structural issues
- Recommendations for improvement

## Proceed When

- [ ] All 5 checks evaluated
- [ ] Score calculated
- [ ] Issues documented
