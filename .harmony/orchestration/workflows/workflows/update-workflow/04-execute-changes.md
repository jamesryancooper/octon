---
title: Execute Changes
description: Apply modifications to workflow files.
---

# Step 4: Execute Changes

## Input

- Confirmed change manifest from Step 3
- Workflow files

## Purpose

Apply all planned changes systematically, tracking progress for resumability.

## Actions

1. **Create backup (optional but recommended):**
   ```text
   If backup enabled:
     Copy workflow directory to .workspace/.backup/<workflow-id>-<timestamp>/
   ```

2. **Process changes in order:**
   ```text
   For each change in manifest (ordered):
     1. Read target file
     2. Apply change
     3. Write file
     4. Mark change complete in manifest
     5. Update checkpoint
   ```

3. **Frontmatter changes:**
   ```text
   For add_field / update_field actions:
     Parse YAML frontmatter
     Add or update field
     Serialize back to YAML
     Write file preserving body
   ```

4. **Section additions:**
   ```text
   For add_section actions:
     Find insertion point (before ## Output or at end)
     Insert section template
     Customize with workflow-specific values
     Write file
   ```

5. **Idempotency section template:**
   ```markdown
   ## Idempotency

   **Check:** [Describe how to detect if step completed]
   - [ ] [Specific condition]

   **If Already Complete:**
   - Skip to next step

   **Marker:** `checkpoints/<workflow-id>/<step>.complete`
   ```

6. **Version History entry:**
   ```markdown
   | <new-version> | <today's date> | Updated via /update-workflow: <summary> |
   ```

7. **Track progress:**
   ```json
   {
     "executed": ["change-001", "change-002"],
     "pending": ["change-003", ...],
     "failed": []
   }
   ```

## Idempotency

**Check:** Are changes already applied (partially or fully)?
- [ ] `checkpoints/update-workflow/<workflow-id>/execution.json` exists
- [ ] Execution log shows progress

**If Partially Complete:**
- Load execution state
- Resume from last pending change
- Skip already-applied changes

**If Fully Complete:**
- Skip to verification step

**Marker:** `checkpoints/update-workflow/<workflow-id>/04-execute.complete`

## Execution State Schema

```json
{
  "workflow_id": "refactor",
  "started_at": "2025-01-14T10:00:00Z",
  "changes": {
    "change-001": {"status": "complete", "applied_at": "..."},
    "change-002": {"status": "complete", "applied_at": "..."},
    "change-003": {"status": "pending"},
    "change-004": {"status": "failed", "error": "..."}
  },
  "progress": {
    "total": 12,
    "complete": 2,
    "pending": 9,
    "failed": 1
  }
}
```

## Error Handling

If a change fails:

1. **Log the error:**
   ```json
   {
     "change_id": "change-003",
     "error": "File not found: 01-step.md",
     "attempted_at": "..."
   }
   ```

2. **Decide recovery:**
   ```text
   If error is recoverable:
     Fix issue and retry
   If error is blocking:
     Stop execution
     Report to user
     Allow manual fix and resume
   ```

3. **Never leave workflow in broken state:**
   ```text
   If critical error:
     Restore from backup (if available)
     Report failure
   ```

## Change Templates

### Add Idempotency Section

Insert before `## Output` or at end of file:

```markdown
## Idempotency

**Check:** [Step-specific detection]
- [ ] [Condition based on step purpose]

**If Already Complete:**
- Skip to next step

**Marker:** `checkpoints/<workflow-id>/<NN>-<step-name>.complete`
```

### Add Version History Section

Insert before `## References`:

```markdown
## Version History

| Version | Date | Changes |
|---------|------|---------|
| <version> | <date> | <summary of gap fixes applied> |
```

### Update Harness Command Symlinks (if access: human)

If workflow has `access: human` and command file exists, ensure harness symlinks are present:

1. **Check for existing command file:**
   ```bash
   ls .harmony/commands/<workflow-id>.md 2>/dev/null || ls .workspace/commands/<workflow-id>.md 2>/dev/null
   ```

2. **Check for existing symlinks:**
   ```bash
   ls -la .cursor/commands/<workflow-id>.md 2>/dev/null
   ls -la .claude/commands/<workflow-id>.md 2>/dev/null
   ```

3. **Create missing symlinks:**
   ```bash
   # For shared workflows (in .harmony/):
   cd .cursor/commands/ && ln -s ../../.harmony/commands/<workflow-id>.md <workflow-id>.md
   cd .claude/commands/ && ln -s ../../.harmony/commands/<workflow-id>.md <workflow-id>.md

   # For local workflows (in .workspace/):
   cd .cursor/commands/ && ln -s ../../.workspace/commands/<workflow-id>.md <workflow-id>.md
   cd .claude/commands/ && ln -s ../../.workspace/commands/<workflow-id>.md <workflow-id>.md
   ```

4. **If access changed from agent to human:**
   - Create command file (see create-workflow/07-update-references.md)
   - Create harness symlinks as above

## Output

- All changes applied
- Execution log complete
- Files modified and saved
- Ready for verification

## Proceed When

- [ ] All changes marked complete (or intentionally skipped)
- [ ] No failed changes blocking progress
- [ ] Files saved successfully
