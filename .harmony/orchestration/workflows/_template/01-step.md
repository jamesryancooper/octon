---
title: "[Step Title]"
description: "[Brief description of this step.]"
---

# Step N: [Step Title]

## Input

- [Input 1 from previous step or user]
- [Input 2]

## Purpose

[Why this step exists and what it accomplishes.]

## Actions

1. [Action 1]
2. [Action 2]
3. [Action 3]

## Idempotency

**Check:** [How to detect if this step already ran]
- [ ] [Condition 1 that indicates completion]
- [ ] [Condition 2 that indicates completion]

**If Already Complete:**
- Skip to next step
- OR: [Cleanup action] before re-running

**Marker:** `checkpoints/[workflow-id]/NN-step.complete`

## Error Messages

- [Error condition 1]: "[Error message to display]"
- [Error condition 2]: "[Error message to display]"

## Output

- [Output 1]
- [Output 2]

## Proceed When

- [ ] [Completion criterion 1]
- [ ] [Completion criterion 2]
