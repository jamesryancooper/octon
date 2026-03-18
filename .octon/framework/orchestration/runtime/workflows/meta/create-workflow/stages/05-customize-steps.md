---
title: Customize Steps
description: Fill in step-specific content from requirements.
---

# Step 5: Customize Steps

## Input

- Generated files from Step 4
- Requirements from Step 2
- Step details (name, purpose, actions)

## Purpose

Replace template placeholders with actual workflow content.

## Actions

1. **Customize 00-overview.md:**
   ```text
   Replace:
   - [Workflow Title] -> requirements.title
   - [Brief summary...] -> requirements.description
   - access: human -> requirements.access
   - [Prerequisites] -> requirements.prerequisites
   - [Failure Conditions] -> requirements.failure_conditions
   - Steps section -> generated from step list
   - References -> appropriate paths
   ```

2. **Customize each step file:**
   ```text
   For each step in requirements.steps:
     Open <NN>-<step-name>.md
     Replace:
     - [Step Title] -> step.purpose (title case)
     - Step N -> Step <step.number>
     - [Input] -> derived from previous step or user
     - [Purpose] -> step.purpose
     - [Actions] -> step.actions (numbered list)
     - [Output] -> derived from step purpose
     - [Proceed When] -> completion criteria
   ```

3. **Update step links in overview:**
   ```text
   Generate steps section:
   1. [Step Name](./01-step-name.md) - Brief description
   2. [Step Name](./02-step-name.md) - Brief description
   ...
   N. [Verify](./NN-verify.md) - Validate workflow executed successfully
   ```

4. **Customize verification step:**
   ```text
   Replace:
   - Verification checklist -> derived from workflow goals
   - Criteria -> specific, testable items
   - Results table -> actual criterion names
   ```

5. **Add workflow-specific error messages:**
   ```text
   For each step:
     Identify potential errors
     Write specific, actionable error messages
   ```

## Idempotency

**Check:** Are step files already customized?
- [ ] `00-overview.md` contains actual title (not placeholder)
- [ ] Step files contain actual content (not placeholders)
- [ ] No `[placeholder]` text remains

**If Already Complete:**
- Check for remaining placeholders
- If none, skip to next step
- If some remain, resume customization

**Marker:** `checkpoints/create-workflow/<workflow-id>/05-customize.complete`

## Placeholder Inventory

Track placeholders to replace:

| Placeholder | Location | Replacement |
|-------------|----------|-------------|
| `[Workflow Title]` | 00-overview.md | requirements.title |
| `[Brief summary...]` | 00-overview.md | requirements.description |
| `[Step Title]` | NN-*.md | step.purpose |
| `[Input]` | NN-*.md | derived |
| `[Actions]` | NN-*.md | step.actions |
| `[Output]` | NN-*.md | derived |
| `[Proceed When]` | NN-*.md | criteria |
| `[workflow-id]` | NN-*.md | workflow ID |
| `YYYY-MM-DD` | 00-overview.md | today's date |

## Output

- All files customized with actual content
- No placeholder text remaining
- Links between files are valid

## Proceed When

- [ ] No `[placeholder]` text in any file
- [ ] All step links in overview resolve to actual files
- [ ] Title and description are present and specific
