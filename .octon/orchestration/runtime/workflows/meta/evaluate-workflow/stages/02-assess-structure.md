---
title: Assess Structure
description: Check entrypoint, step parity, and format-specific structure conventions.
---

# Step 2: Assess Structure

## Input

- Parsed workflow model from Step 1

## Purpose

Evaluate workflow structure against the unified canonical workflow-unit contract.

## Actions

1. **Check canonical contract and guide exist:**
   ```text
   workflow.yml exists
   README.md exists
   ```

2. **Check declared step/file parity:**
   ```text
   Every declared guide stage file exists
   ```

3. **Check verification is structurally reachable:**
   ```text
   Final stage or guide content reaches verification
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
    {"name": "canonical_contract_and_guide", "status": "PASS"},
    {"name": "declared_step_parity", "status": "PASS"},
    {"name": "verification_reachable", "status": "PARTIAL"},
    {"name": "naming_consistency", "status": "PASS"}
  ],
  "issues": []
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
