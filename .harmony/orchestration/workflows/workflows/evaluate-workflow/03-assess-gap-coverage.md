---
title: Assess Gap Coverage
description: Check workflow for gap remediation features.
---

# Step 3: Assess Gap Coverage

## Input

- Parsed workflow model from Step 1

## Purpose

Evaluate the workflow's implementation of gap remediation features.

## Actions

### 3.1 Check Idempotency (4 points)

```text
For each step file:
  Does it have ## Idempotency section?
  Does section include Check, If Already Complete, Marker?

Scoring:
- All steps have complete idempotency: 4 points
- Most steps (>75%): 3 points
- Some steps (>50%): 2 points
- Few steps (<50%): 1 point
- None: 0 points
```

### 3.2 Check Dependencies (4 points)

```text
Does overview frontmatter have depends_on field?
- Present and valid array: 4 points
- Present but empty when deps likely needed: 2 points
- Missing: 0 points
- N/A (workflow has no logical dependencies): 4 points
```

### 3.3 Check Checkpoints (4 points)

```text
Does overview frontmatter have checkpoints field?
- Present with enabled:true and storage path: 4 points
- Present but incomplete: 2 points
- Missing: 0 points
```

### 3.4 Check Versioning (4 points)

```text
Does overview have version field?
- Present in semantic format: 2 points
- Invalid format: 0 points

Does overview have Version History section?
- Present with at least one entry: 2 points
- Missing: 0 points
```

### 3.5 Check Parallel Steps (4 points)

```text
Does overview frontmatter have parallel_steps field?
- Present (even if empty): 2 points
- Missing: 0 points

If parallel opportunities exist, are they documented?
- Yes: 2 points
- No opportunities: 2 points (N/A)
- Opportunities missed: 0 points
```

## Idempotency

**Check:** Is gap assessment already done?
- [ ] `checkpoints/evaluate-workflow/<workflow-id>/gap-score.json` exists

**If Already Complete:**
- Load cached gap score
- Skip to next step

**Marker:** `checkpoints/evaluate-workflow/<workflow-id>/03-gaps.complete`

## Gap Coverage Score Schema

```json
{
  "category": "gap_coverage",
  "max_points": 20,
  "earned_points": 14,
  "checks": [
    {
      "name": "idempotency",
      "points": 4,
      "max": 4,
      "status": "PASS",
      "detail": "8/8 steps have idempotency"
    },
    {
      "name": "dependencies",
      "points": 4,
      "max": 4,
      "status": "PASS",
      "detail": "depends_on field present"
    },
    {
      "name": "checkpoints",
      "points": 2,
      "max": 4,
      "status": "PARTIAL",
      "detail": "Missing storage path"
    },
    {
      "name": "versioning",
      "points": 2,
      "max": 4,
      "status": "PARTIAL",
      "detail": "Version present, history missing"
    },
    {
      "name": "parallel_steps",
      "points": 2,
      "max": 4,
      "status": "PARTIAL",
      "detail": "Field present but opportunities not analyzed"
    }
  ],
  "issues": [
    {"severity": "minor", "message": "Add storage path to checkpoints config"},
    {"severity": "minor", "message": "Add Version History section"}
  ]
}
```

## Gap Coverage Summary Table

| Gap | Status | Points | Notes |
|-----|--------|--------|-------|
| Idempotency | Full/Partial/None | X/4 | |
| Dependencies | Full/Partial/None/N/A | X/4 | |
| Checkpoints | Full/Partial/None | X/4 | |
| Versioning | Full/Partial/None | X/4 | |
| Parallel | Full/Partial/None/N/A | X/4 | |

## Output

- Gap coverage score (0-20 points)
- Per-gap status
- List of gap-related issues
- Recommendations for improvement

## Proceed When

- [ ] All 5 gap areas assessed
- [ ] Score calculated
- [ ] Issues documented
