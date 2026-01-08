---
title: Record Edits
description: Record what edits would be applied according to the alignment plan.
step_index: 6
action: edit
---

# Record Edits

## Objective

Record the specific edits that would be applied according to the alignment plan. This is a **read-only assessment**; actual file modifications are handled by downstream agents/tools.

## Inputs

- `state.alignment_plan`: List of `AlignmentDecision` objects

## Process

1. For each decision in the alignment plan:
   - Identify the target file(s)
   - Determine the specific edit operations
   - Record evidence locations for traceability

2. Create `EditRecord` entries documenting:
   - What would change
   - Where the change would occur
   - Why the change is needed (linked to decision)

## Output

Populate `state.edits_applied` with a list of `EditRecord` objects:
- `file_path`: Target file
- `summary`: Description of the edit
- `evidence_locations`: List of source locations supporting the edit

## Constraints

- Do NOT modify files directly
- Ensure all edits are traceable to alignment decisions
- Preserve enough detail for downstream application

