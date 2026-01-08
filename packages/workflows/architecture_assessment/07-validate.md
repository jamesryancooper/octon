---
title: Validate Alignment
description: Confirm that the alignment plan addresses issues without introducing regressions.
step_index: 7
action: validate
---

# Validate Alignment

## Objective

Validate that the proposed edits would resolve the detected issues and would not introduce new problems.

## Inputs

- `state.issue_register`: Original list of detected issues
- `state.alignment_plan`: Proposed alignment decisions
- `state.edits_applied`: Recorded edits

## Process

1. **Check Issue Resolution**:
   - For each high/medium severity issue, verify it's addressed by the plan
   - Track which issues are resolved vs. remaining

2. **Check for Regressions**:
   - Ensure proposed changes don't conflict with each other
   - Verify no new issues would be introduced

3. **Identify Residual Issues**:
   - List any issues that couldn't be addressed
   - Note reasons (ambiguity, scope, requires human input)

## Output

Populate `state.validation_summary` with a `ValidationSummary`:
- `resolved_issue_ids`: List of issue IDs that were addressed
- `residual_issue_ids`: List of high-severity issues still remaining
- `notes`: Any observations about the validation

## Constraints

- Be conservative: flag potential regressions
- High-severity residual issues should be clearly highlighted

