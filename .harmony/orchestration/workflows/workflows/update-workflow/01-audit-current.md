---
title: Audit Current Workflow
description: Read and parse existing workflow for update planning.
---

# Step 1: Audit Current Workflow

## Input

- `path`: Path to workflow directory
- Optional: `--from-report <assessment-path>` to use existing evaluation

## Purpose

Understand the current state of the workflow before planning modifications.

## Actions

1. **Load existing assessment (if available):**
   ```text
   If --from-report provided:
     Load assessment from file
     Extract scores and issues
     Skip redundant analysis
   ```

2. **Read workflow files:**
   ```text
   Read 00-overview.md
   Parse frontmatter
   Identify existing fields and sections
   ```

3. **Inventory step files:**
   ```text
   List all NN-*.md files
   For each, check:
     - Has frontmatter?
     - Has Idempotency section?
     - Has all required sections?
   ```

4. **Document current state:**
   ```json
   {
     "workflow_id": "...",
     "path": "...",
     "current_version": "1.0.0",
     "frontmatter_fields": {
       "title": true,
       "description": true,
       "access": true,
       "version": true,
       "depends_on": false,
       "checkpoints": false,
       "parallel_steps": false
     },
     "step_count": 7,
     "steps_with_idempotency": 2,
     "has_version_history": false,
     "has_verification_step": true
   }
   ```

5. **Identify quick wins:**
   ```text
   List changes that can be made with minimal risk:
   - Adding missing frontmatter fields
   - Adding Idempotency sections
   - Adding Version History section
   ```

## Idempotency

**Check:** Is audit already complete for this update session?
- [ ] `checkpoints/update-workflow/<workflow-id>/audit.json` exists
- [ ] Audit timestamp is from current session

**If Already Complete:**
- Load cached audit results
- Skip to next step

**Marker:** `checkpoints/update-workflow/<workflow-id>/01-audit.complete`

## Audit Report Schema

```json
{
  "workflow_id": "refactor",
  "path": ".harmony/workflows/refactor/",
  "audited_at": "2025-01-14T10:00:00Z",
  "current_version": "1.0.0",
  "structure": {
    "has_overview": true,
    "step_count": 7,
    "has_verify_step": true,
    "naming_consistent": true
  },
  "frontmatter": {
    "present": ["title", "description", "access"],
    "missing": ["version", "depends_on", "checkpoints", "parallel_steps"]
  },
  "gap_coverage": {
    "idempotency": {"total": 7, "covered": 0},
    "dependencies": "missing",
    "checkpoints": "missing",
    "versioning": "partial",
    "parallel": "missing"
  },
  "quick_wins": [
    "Add version field to frontmatter",
    "Add depends_on field to frontmatter",
    "Add checkpoints config to frontmatter",
    "Add parallel_steps field to frontmatter",
    "Add Version History section"
  ]
}
```

## Output

- Complete audit of current workflow state
- List of missing/incomplete elements
- Quick wins identified
- Ready for gap identification

## Proceed When

- [ ] Workflow files successfully read
- [ ] Current state documented
- [ ] Missing elements identified
