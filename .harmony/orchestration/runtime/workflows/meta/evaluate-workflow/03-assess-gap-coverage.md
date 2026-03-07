---
title: Assess Gap Coverage
description: Check workflow for explicit gap controls and operational safety guidance.
---

# Step 3: Assess Gap Coverage

## Input

- Parsed workflow model from Step 1

## Purpose

Evaluate the workflow's implementation of explicit gap controls.

## Actions

### 3.1 Check Idempotency

```text
Directory workflow:
  Prefer per-step Idempotency guidance
Single-file workflow:
  Require rerun/resume guidance in the main flow if interruption matters
```

### 3.2 Check Dependencies

```text
Check depends_on for directory workflows and explicit upstream assumptions for single-file workflows
```

### 3.3 Check Checkpoints and Resumption

```text
Checkpoints config for directory workflows
Resume guidance for single-file workflows where interruption matters
```

### 3.4 Check Versioning

```text
Check version metadata and Version History where the workflow is actively maintained
```

### 3.5 Check Branching and Parallelism

```text
Directory workflows should declare parallel_steps or explicit N/A
Single-file workflows should state when the flow is strictly sequential
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
  "max_points": 25,
  "earned_points": 18,
  "checks": [
    {
      "name": "idempotency",
      "status": "PASS",
      "detail": "Flow includes rerun guidance"
    },
    {
      "name": "dependencies",
      "status": "PASS",
      "detail": "Explicit dependency assumptions present"
    },
    {
      "name": "checkpoints_resumption",
      "status": "PARTIAL",
      "detail": "No explicit resume guidance"
    },
    {
      "name": "versioning",
      "status": "PARTIAL",
      "detail": "Version present, history missing"
    },
    {
      "name": "branching_parallelism",
      "status": "PARTIAL",
      "detail": "Sequential assumption is implicit"
    }
  ],
  "issues": [
    {"severity": "medium", "message": "Document interruption-safe resume behavior"},
    {"severity": "low", "message": "Add Version History section"}
  ]
}
```

## Output

- Gap coverage score
- Per-gap status
- List of gap-related issues
- Recommendations for improvement

## Proceed When

- [ ] All 5 gap areas assessed
- [ ] Score calculated
- [ ] Issues documented
