---
title: Select Template
description: Choose the appropriate template variant for the workflow.
---

# Step 3: Select Template

## Input

- Requirements from Step 2
- Step count and complexity

## Purpose

Select the appropriate template variant based on workflow characteristics.

## Actions

1. **Assess complexity:**
   ```text
   Simple: 2-4 steps, linear execution, no branching
   Standard: 5-8 steps, linear or single branch
   Complex: 9+ steps, multiple branches, parallel opportunities
   ```

2. **Check for special patterns:**
   ```text
   - CRUD workflow? (create/read/update/delete pattern)
   - Assessment workflow? (read-only, produces report)
   - Transformation workflow? (input -> process -> output)
   - Validation workflow? (check conditions, pass/fail)
   ```

3. **Select template:**
   ```text
   All workflows use base template: .harmony/workflows/_template/

   Customize based on pattern:
   - Assessment: Emphasize read-only, report generation
   - Transformation: Emphasize input/output contracts
   - Validation: Emphasize pass/fail criteria
   - General: Use standard template as-is
   ```

4. **Identify parallel opportunities:**
   ```text
   Review step list from requirements
   For each pair of adjacent steps:
     Q: Does step N+1 require output from step N?
     If NO: Mark as potential parallel pair
   ```

5. **Plan branching (if needed):**
   ```text
   If requirements include conditional paths:
     Identify branch points
     Name branch files (03a-*, 03b-*, etc.)
     Identify merge points
   ```

## Idempotency

**Check:** Is template selection already made?
- [ ] `checkpoints/create-workflow/<workflow-id>/template.json` exists
- [ ] File contains template path and customizations

**If Already Complete:**
- Load template selection from checkpoint
- Skip to next step

**Marker:** `checkpoints/create-workflow/<workflow-id>/03-template.complete`

## Template Selection Schema

```json
{
  "base_template": ".harmony/workflows/_template/",
  "complexity": "standard",
  "pattern": "transformation",
  "parallel_groups": [
    {
      "group": "validation",
      "steps": ["02-validate-x", "03-validate-y"],
      "join_at": "04-process"
    }
  ],
  "branches": [],
  "step_files": [
    "00-overview.md",
    "01-step-one.md",
    "02-step-two.md",
    "NN-verify.md"
  ]
}
```

## Output

- Template path confirmed
- Complexity classification
- Parallel step groups identified (if any)
- Branch structure planned (if any)
- Complete list of files to generate

## Proceed When

- [ ] Base template exists and is readable
- [ ] Complexity classified
- [ ] File list generated
- [ ] Parallel opportunities identified (even if none)
