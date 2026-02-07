---
title: Generate Structure
description: Create workflow directory and copy template files.
---

# Step 4: Generate Structure

## Input

- Target path from Step 1
- Template selection from Step 3
- File list from Step 3

## Purpose

Create the workflow directory structure and populate with template files.

## Actions

1. **Create workflow directory:**
   ```bash
   mkdir -p <target-path>
   # e.g., mkdir -p .harmony/workflows/ci-cd/deploy-staging/
   ```

2. **Copy template files:**
   ```text
   For each file in template:
     Copy .harmony/workflows/_template/<file> to <target-path>/<file>
   ```

3. **Rename step files:**
   ```text
   For each step in requirements:
     Rename 01-step.md to <NN>-<step-name>.md
     e.g., 01-step.md -> 01-validate-input.md
   ```

4. **Create additional step files:**
   ```text
   If more steps than template provides:
     Copy 01-step.md template for each additional step
     Rename according to step list
   ```

5. **Create branch files (if needed):**
   ```text
   If branching planned:
     Copy step template for each branch variant
     Name as NNa-*, NNb-*, etc.
   ```

6. **Rename verify file:**
   ```text
   Rename NN-verify.md to actual final step number
   e.g., NN-verify.md -> 08-verify.md
   ```

## Idempotency

**Check:** Does workflow directory already exist with files?
- [ ] Target directory exists
- [ ] `00-overview.md` exists in target
- [ ] Step files exist

**If Already Complete:**
- Check if files match expected list
- If mismatch, ask user: recreate or skip?
- If match, skip to next step

**Marker:** `checkpoints/create-workflow/<workflow-id>/04-structure.complete`

## Expected Output Structure

```text
<target-path>/
├── 00-overview.md
├── 01-<step-1-name>.md
├── 02-<step-2-name>.md
├── 03-<step-3-name>.md
...
└── NN-verify.md
```

## Error Messages

- Cannot create directory: "Failed to create directory '<path>'. Check permissions."
- Template not found: "Template file '<file>' not found in .harmony/workflows/_template/"
- Write failed: "Failed to write '<file>'. Check disk space and permissions."

## Output

- Workflow directory created
- All template files copied and renamed
- File list for customization in next step

## Proceed When

- [ ] Target directory exists
- [ ] All planned files are present
- [ ] Files are readable/writable
