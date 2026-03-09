---
title: Assess Quality
description: Evaluate execution safety, maintainability, and documentation quality.
---

# Step 4: Assess Quality

## Input

- Parsed workflow model from Step 1
- Structure score from Step 2
- Gap coverage score from Step 3

## Purpose

Render the remaining shared score categories and quality issues from the parsed workflow model.

## Actions

### 4.1 Check Execution Safety and Verification

```text
Check verification gate, target/output description, and execution-profile honesty
```

### 4.2 Check Maintainability

```text
Check naming consistency, focused structure, and step/file coherence
```

### 4.3 Check Documentation and References

```text
Check local links, usage/target guidance, and description quality
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
    "execution_safety_verification": {
      "max_points": 20,
      "earned_points": 16,
      "checks": [...]
    },
    "maintainability": {
      "max_points": 10,
      "earned_points": 8,
      "checks": [...]
    },
    "documentation_references": {
      "max_points": 15,
      "earned_points": 12,
      "checks": [...]
    }
  },
  "total_points": 36,
  "max_points": 45,
  "issues": [
    {"severity": "medium", "message": "Verification gate is implied rather than explicit"},
    {"severity": "low", "message": "One local reference does not resolve"}
  ]
}
```

## Output

- Execution safety score
- Maintainability score
- Documentation/reference score
- List of quality issues
- Recommendations

## Proceed When

- [ ] All quality checks evaluated
- [ ] Scores calculated
- [ ] Issues documented
