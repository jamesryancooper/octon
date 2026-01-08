---
title: Create Alignment Plan
description: Create an alignment plan from detected issues and maps.
step_index: 5
action: align
---

# Create Alignment Plan

## Objective

Convert detected issues into actionable alignment decisions with planned changes.

## Inputs

- `state.issue_register`: List of detected issues
- `state.terminology_map`: Normalized terminology
- `state.decision_map`: Normalized decisions

## Process

1. **Prioritize Issues**:
   - Focus on high and medium severity issues
   - Group related issues that can be addressed together

2. **Design Resolutions**:
   For each addressable issue, create an `AlignmentDecision`:
   - Determine the appropriate fix strategy
   - Identify affected files
   - Plan specific changes needed
   - Flag any open questions requiring human input

3. **Validate Feasibility**:
   - Ensure proposed changes don't introduce new conflicts
   - Check that changes respect existing structure

## Output

Populate `state.alignment_plan` with a list of `AlignmentDecision` objects:
- `id`: Decision identifier (linked to issue)
- `description`: What the decision addresses
- `files`: List of files that would be modified
- `planned_changes`: Specific changes to make
- `open_question_id`: Optional link to unresolved question

## Constraints

- Only address issues that can be resolved without guessing intent
- Flag ambiguous cases as open questions
- Preserve architectural intent

