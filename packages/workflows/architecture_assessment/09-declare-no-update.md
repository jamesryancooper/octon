---
title: Declare No Update
description: Emit the canonical no-update declaration when appropriate.
step_index: 9
action: declare_no_update
---

# Declare No Update

## Objective

Evaluate whether the architecture documentation is sufficiently aligned and, if so, emit the canonical "No updates required" declaration.

## Inputs

- `state.alignment_report`: The compiled alignment report
- `state.issue_register`: All detected issues
- `state.thresholds.min_alignment_score_for_no_update`: Minimum score (default: 90)

## Process

1. **Check Alignment Criteria**:
   - Alignment score ≥ threshold (default 90)
   - No high-severity issues remaining

2. **If Criteria Met**:
   - Update the alignment report's executive summary to:
     > "No updates required. The Harmony architecture documentation is internally aligned and consistent."

3. **If Criteria Not Met**:
   - Leave the alignment report unchanged
   - The full report with recommendations will be the output

## Output

Potentially updated `state.alignment_report` with the no-update declaration if criteria are met.

## Stop Instruction

This is the terminal step. The flow completes after this step regardless of outcome.

## Constraints

- Only declare no-update if BOTH criteria are satisfied
- Preserve the full alignment report data for traceability

