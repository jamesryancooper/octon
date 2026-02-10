---
title: Assess Quality
description: Evaluate content quality and completeness.
---

# Step 4: Assess Quality

## Input

- Parsed workflow model from Step 1
- Structure score from Step 2
- Gap coverage score from Step 3

## Purpose

Evaluate the quality and completeness of workflow content.

## Actions

### 4.1 Check Frontmatter Compliance (20 points)

```text
Overview frontmatter fields:
- title present and non-empty: 4 points
- description present (max 160 chars): 4 points
- access is 'human' or 'agent': 4 points
- version in semantic format: 4 points
- gap fix fields present: 4 points
```

### 4.2 Check Content Quality (25 points)

```text
Prerequisites defined (5 points):
- At least one prerequisite: 5 points
- None: 0 points

Failure conditions defined (5 points):
- At least one STOP condition: 5 points
- None: 0 points

Steps are actionable (5 points):
- All steps have concrete Actions: 5 points
- Most steps: 3 points
- Few steps: 1 point

Verification criteria clear (5 points):
- Checklist items are testable: 5 points
- Vague criteria: 2 points
- No criteria: 0 points

Error messages helpful (5 points):
- Specific, actionable messages: 5 points
- Generic messages: 2 points
- No error handling: 0 points
```

### 4.3 Check Maintainability (10 points)

```text
Steps are focused (3 points):
- Each step does one thing: 3 points
- Steps do multiple things: 1 point

References are valid (3 points):
- All links resolve: 3 points
- Some broken: 1 point

No dead code/steps (2 points):
- All steps reachable: 2 points
- Orphaned steps: 0 points

Consistent formatting (2 points):
- Consistent headings/lists: 2 points
- Inconsistent: 0 points
```

### 4.4 Scan for Issues

```text
Check for:
- Placeholder text remaining: [placeholder]
- Broken internal links
- Missing required sections
- Inconsistent step numbering
- Overly long descriptions (>160 chars)
```

## Idempotency

**Check:** Is quality assessment already done?
- [ ] `checkpoints/evaluate-workflow/<workflow-id>/quality-score.json` exists

**If Already Complete:**
- Load cached quality score
- Skip to next step

**Marker:** `checkpoints/evaluate-workflow/<workflow-id>/04-quality.complete`

## Quality Score Schema

```json
{
  "category": "quality",
  "subcategories": {
    "frontmatter": {
      "max_points": 20,
      "earned_points": 18,
      "checks": [...]
    },
    "content": {
      "max_points": 25,
      "earned_points": 20,
      "checks": [...]
    },
    "maintainability": {
      "max_points": 10,
      "earned_points": 8,
      "checks": [...]
    }
  },
  "total_points": 46,
  "max_points": 55,
  "issues": [
    {"severity": "minor", "message": "Step 03 has vague error messages"},
    {"severity": "warning", "message": "Description exceeds 160 characters"}
  ]
}
```

## Output

- Frontmatter score (0-20 points)
- Content score (0-25 points)
- Maintainability score (0-10 points)
- Combined quality score
- List of quality issues
- Recommendations

## Proceed When

- [ ] All quality checks evaluated
- [ ] Scores calculated
- [ ] Issues documented
