---
title: Read Workflow
description: Load and parse the workflow artifact for shared scoring.
---

# Step 1: Read Workflow

## Input

- `path`: Path to a workflow directory or single-file workflow

## Purpose

Load the workflow artifact in the same way the shared scorer does.

## Actions

1. **Validate path:**
   ```text
   Check path exists
   Check path is readable
   ```

2. **Determine workflow format:**
   ```text
   If directory:
     require WORKFLOW.md
   If file:
     treat as single-file workflow
   ```

3. **Read workflow entrypoint:**
   ```text
   Directory: read <path>/WORKFLOW.md
   Single-file: read <path>
   Parse YAML frontmatter
   Extract sections and local references
   ```

4. **Read declared step files when directory-based:**
   ```text
   For each file declared in WORKFLOW.md frontmatter.steps:
     Read file content
     Parse frontmatter (if present)
     Extract sections (Input, Actions, Idempotency, Output, etc.)
   ```

5. **Build workflow model:**
   ```json
   {
     "path": "<path>",
     "format": "directory|single-file",
     "entrypoint": {...},
     "primary_doc": {...},
     "steps": [...],
     "declared_step_count": N
   }
   ```

## Idempotency

**Check:** Is workflow already loaded?
- [ ] `checkpoints/evaluate-workflow/<workflow-id>/workflow-model.json` exists
- [ ] Model timestamp is recent (within this session)

**If Already Complete:**
- Load cached workflow model
- Skip to next step

**Marker:** `checkpoints/evaluate-workflow/<workflow-id>/01-read.complete`

## Error Messages

- Path not found: "Workflow path '<path>' does not exist."
- Missing entrypoint: "No WORKFLOW.md found in '<path>'. Is this a workflow directory?"
- Invalid file target: "Expected workflow markdown file at '<path>'."
- Parse error: "Failed to parse '<file>': <error>"

## Output

- Parsed workflow model
- File inventory
- Ready for assessment steps

## Proceed When

- [ ] Path exists and is readable
- [ ] Workflow entrypoint exists and parsed
- [ ] Declared step files are parsed when required
- [ ] Workflow model built successfully
