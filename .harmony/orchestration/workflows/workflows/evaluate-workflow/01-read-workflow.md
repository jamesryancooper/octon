---
title: Read Workflow
description: Load and parse workflow files for assessment.
---

# Step 1: Read Workflow

## Input

- `path`: Path to workflow directory

## Purpose

Load all workflow files and parse their structure for subsequent assessment steps.

## Actions

1. **Validate path:**
   ```text
   Check path exists
   Check path is a directory
   Check directory is readable
   ```

2. **List workflow files:**
   ```bash
   ls <path>/*.md
   # Expect: 00-overview.md and numbered step files
   ```

3. **Read overview file:**
   ```text
   Read <path>/00-overview.md
   Parse YAML frontmatter
   Extract sections (Prerequisites, Failure Conditions, Steps, etc.)
   ```

4. **Read step files:**
   ```text
   For each file matching NN-*.md:
     Read file content
     Parse frontmatter (if present)
     Extract sections (Input, Actions, Idempotency, Output, etc.)
   ```

5. **Build workflow model:**
   ```json
   {
     "path": "<path>",
     "overview": {
       "frontmatter": {...},
       "sections": {...}
     },
     "steps": [
       {
         "filename": "01-step.md",
         "number": 1,
         "frontmatter": {...},
         "sections": {...}
       }
     ],
     "file_count": N
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

## Parsed Workflow Schema

```json
{
  "path": ".harmony/workflows/refactor/",
  "workflow_id": "refactor",
  "overview": {
    "frontmatter": {
      "title": "Refactor",
      "description": "...",
      "access": "human",
      "version": "1.0.0",
      "depends_on": [],
      "checkpoints": {...},
      "parallel_steps": []
    },
    "sections": {
      "prerequisites": ["..."],
      "failure_conditions": ["..."],
      "steps": [
        {"number": 1, "name": "Define scope", "link": "./01-define-scope.md"}
      ],
      "version_history": [...]
    }
  },
  "steps": [
    {
      "filename": "01-define-scope.md",
      "number": 1,
      "frontmatter": {"title": "...", "description": "..."},
      "sections": {
        "input": ["..."],
        "actions": ["..."],
        "idempotency": {...},
        "output": ["..."]
      },
      "has_idempotency": true
    }
  ],
  "file_count": 7,
  "read_at": "2025-01-14T10:00:00Z"
}
```

## Error Messages

- Path not found: "Workflow path '<path>' does not exist."
- Not a directory: "Expected directory at '<path>', found file."
- No overview: "No 00-overview.md found in '<path>'. Is this a workflow directory?"
- Parse error: "Failed to parse '<file>': <error>"

## Output

- Parsed workflow model
- File inventory
- Ready for assessment steps

## Proceed When

- [ ] Path exists and is readable
- [ ] `00-overview.md` exists and parsed
- [ ] At least one step file exists and parsed
- [ ] Workflow model built successfully
