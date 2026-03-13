---
title: Analyze Requirements
description: Gather workflow purpose, steps, and characteristics.
---

# Step 2: Analyze Requirements

## Input

- Validated workflow ID from Step 1
- User's description of what the workflow should accomplish

## Purpose

Understand what the workflow needs to do so we can generate appropriate steps and structure.

## Actions

1. **Gather purpose:**
   ```text
   Ask: "What should this workflow accomplish?"
   Record: One-line description (max 160 chars for frontmatter)
   Record: Expanded description for the generated operator guidance
   ```

2. **Identify steps:**
   ```text
   Ask: "What are the main steps or phases?"
   For each step, record:
   - Step name (kebab-case for filename)
   - Step purpose (one line)
   - Key actions
   ```

3. **Identify prerequisites:**
   ```text
   Ask: "What must be true before this workflow can run?"
   Record: List of prerequisites
   ```

4. **Identify failure conditions:**
   ```text
   Ask: "What conditions should stop the workflow?"
   Record: List of STOP conditions with recovery actions
   ```

5. **Determine workflow boundary:**
   ```text
   Ask: "Why is this a workflow instead of a skill, command, or simpler surface?"
   Record: workflow_boundary_reason
   Ask: "Is this orchestrating a broader portfolio concern or one bounded runtime surface?"
   Record: boundary_class = portfolio | surface
   ```

6. **Determine entry and execution shape:**
   ```text
   Ask: "Will humans, agents, or both trigger this workflow?"
   Record: entry_mode = human | agent | hybrid
   Ask: "Is the workflow read-only, mutating, or destructive?"
   Record: side_effect_class = none | read_only | mutating | destructive
   Ask: "Can cancellation safely stop work without leaving partial state?"
   Record: cancel_safe = true | false
   Ask: "What should define the coordination identity for concurrent runs?"
   Record: coordination_key_strategy draft
   ```

7. **Define verification and recovery posture:**
   ```text
   Ask: "What proves the workflow completed correctly?"
   Record: verification_strategy
   If side_effect_class is mutating or destructive:
   Ask: "How does an operator resume or recover from partial execution?"
   Record: recovery_posture
   ```

8. **Check for dependencies:**
   ```text
   Ask: "Does this workflow require other workflows to complete first?"
   Record: depends_on list (if any)
   ```

## Idempotency

**Check:** Are requirements already captured?
- [ ] `checkpoints/create-workflow/<workflow-id>/requirements.json` exists
- [ ] File contains non-empty purpose, steps, prerequisites

**If Already Complete:**
- Load requirements from checkpoint file
- Ask user if they want to modify or proceed
- Skip to next step if no changes

**Marker:** `checkpoints/create-workflow/<workflow-id>/02-analyze.complete`

## Requirements Schema

```json
{
  "workflow_id": "example-workflow",
  "title": "Example Workflow",
  "description": "Brief description for frontmatter.",
  "purpose": "Expanded description of what workflow accomplishes.",
  "workflow_boundary_reason": "Requires explicit multi-stage orchestration and verification.",
  "boundary_class": "surface",
  "entry_mode": "human",
  "side_effect_class": "read_only",
  "cancel_safe": true,
  "coordination_key_strategy": {
    "kind": "none"
  },
  "verification_strategy": "Final verification stage confirms the generated artifacts and metadata are aligned.",
  "recovery_posture": "N/A for read-only workflows.",
  "steps": [
    {
      "number": 1,
      "name": "validate-input",
      "filename": "01-validate-input.md",
      "purpose": "Ensure input meets requirements",
      "actions": ["Check format", "Validate values"]
    }
  ],
  "prerequisites": [
    "Prerequisite 1",
    "Prerequisite 2"
  ],
  "failure_conditions": [
    {"condition": "Invalid input", "action": "STOP, report error"}
  ],
  "depends_on": []
}
```

## Output

- Complete requirements document
- Saved to `checkpoints/create-workflow/<workflow-id>/requirements.json`
- Step count determined
- Entry and execution shape determined

## Proceed When

- [ ] Purpose is defined (non-empty)
- [ ] At least 2 steps identified (including verify)
- [ ] At least one prerequisite listed
- [ ] At least one failure condition listed
- [ ] Workflow boundary is justified
- [ ] Entry mode and side-effect class are determined
- [ ] Verification strategy is defined
