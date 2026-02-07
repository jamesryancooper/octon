---
title: Validate Workflow ID
description: Check workflow ID format and uniqueness.
---

# Step 1: Validate Workflow ID

## Input

- `workflow-id`: The proposed workflow identifier
- `target-location`: `.harmony/workflows/<domain>/` or `.workspace/workflows/` (with `--local`)
- `domain`: Optional subdirectory under `.harmony/workflows/`

## Purpose

Ensure the workflow ID is valid and doesn't conflict with existing workflows before proceeding with creation.

## Actions

1. **Validate format:**
   ```text
   Check workflow-id matches pattern: ^[a-z][a-z0-9-]*$
   - Must be lowercase
   - Must use hyphens (not underscores or spaces)
   - Must start with a letter
   ```

2. **Determine target path:**
   ```text
   If --local flag:
     target = .workspace/workflows/<workflow-id>/
   Else if --domain specified:
     target = .harmony/workflows/<domain>/<workflow-id>/
   Else:
     Prompt user for domain or use "general"
   ```

3. **Check uniqueness:**
   ```text
   List directories in target location
   Check for existing <workflow-id>/ directory
   Also check alternate location (if checking .harmony, also check .workspace)
   ```

4. **Report result:**
   ```text
   If invalid format: STOP with format error
   If already exists: STOP with exists error
   If valid and unique: Proceed to Step 2
   ```

## Idempotency

**Check:** Does checkpoint state exist for this workflow creation?
- [ ] `.workspace/progress/checkpoints/create-workflow/<workflow-id>/state.json` exists
- [ ] State shows step 1 completed

**If Already Complete:**
- Read stored validation result from checkpoint
- Skip to next step

**Marker:** `checkpoints/create-workflow/<workflow-id>/01-validate.complete`

## Error Messages

- Invalid format: "Workflow ID must be lowercase with hyphens (e.g., 'code-review'). Received: '<id>'"
- Already exists: "Workflow '<id>' already exists at '<path>'. Use /update-workflow to modify, or choose a different ID."
- Reserved name: "Workflow ID '<id>' is reserved. Choose a different name."

## Output

- Validated workflow ID
- Confirmed target path: `<target>/<workflow-id>/`
- Domain (if applicable)

## Proceed When

- [ ] ID format is valid (matches `^[a-z][a-z0-9-]*$`)
- [ ] No existing workflow with same ID in target location
- [ ] Target path is writable
