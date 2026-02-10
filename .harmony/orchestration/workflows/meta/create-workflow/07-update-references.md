---
title: Update References
description: Update catalog and index files to include new workflow.
---

# Step 7: Update References

## Input

- Completed workflow from Steps 4-6
- Target path
- Workflow metadata (title, description, access)

## Purpose

Make the new workflow discoverable by updating relevant indexes and catalogs.

## Actions

### 7.1 Update Catalog (if .harmony exists)

If `.harmony/catalog.md` exists:

1. **Find the Workflows section:**
   ```text
   Locate the appropriate workflow table based on domain
   ```

2. **Add entry:**
   ```markdown
   | [<workflow-title>](<relative-path>/00-overview.md) | <access> | <description> |
   ```

3. **Maintain alphabetical order** within the table

### 7.2 Update Domain README (if exists)

If the workflow is in a domain subdirectory:

1. **Check for domain README:**
   ```text
   Look for .harmony/orchestration/workflows/<domain>/README.md
   ```

2. **Add workflow to domain index:**
   ```markdown
   | [<workflow-title>](./<workflow-id>/00-overview.md) | <description> |
   ```

### 7.3 Create Harness Command (if access: human)

If workflow has `access: human`, create command wrappers:

1. **Create command file:**
   ```text
   Location: .harmony/capabilities/commands/<workflow-id>.md
   Or: .harmony/capabilities/commands/<workflow-id>.md (for local workflows)
   ```

2. **Command content:**
   ```markdown
   ---
   title: <Workflow Title>
   description: <description>
   access: human
   argument-hint: <args if any>
   ---

   # <Workflow Title> `/<workflow-id>`

   <One-line description>

   ## Usage

   ```text
   /<workflow-id> <arguments>
   ```

   ## Implementation

   Execute the workflow in `<workflow-path>`.

   ## References

   - **Workflow:** `<workflow-path>`
   ```

### 7.4 Create Harness Command Symlinks (if access: human)

If workflow has `access: human`, create symlinks in all harness command directories so the command is discoverable in each IDE/tool:

1. **Identify harness directories:**
   ```bash
   # Check which harness command directories exist
   ls -d .cursor/commands/ .claude/commands/ .codex/commands/ 2>/dev/null
   ```

2. **Create symlinks in each harness:**
   ```bash
   # For shared workflows (in .harmony/):
   cd .cursor/commands/ && ln -s ../../.harmony/capabilities/commands/<workflow-id>.md <workflow-id>.md
   cd .claude/commands/ && ln -s ../../.harmony/capabilities/commands/<workflow-id>.md <workflow-id>.md

   # For local workflows (in .harmony/):
   cd .cursor/commands/ && ln -s ../../.harmony/capabilities/commands/<workflow-id>.md <workflow-id>.md
   cd .claude/commands/ && ln -s ../../.harmony/capabilities/commands/<workflow-id>.md <workflow-id>.md
   ```

3. **Verify symlinks resolve:**
   ```bash
   # Symlinks should show the target file content
   head -3 .cursor/commands/<workflow-id>.md
   head -3 .claude/commands/<workflow-id>.md
   ```

**Note:** Symlinks are required for `access: human` workflows to be invocable via `/<command>` in each harness. Without symlinks, the command exists but won't be discoverable.

## Idempotency

**Check:** Are references already updated?
- [ ] Catalog entry exists (if catalog exists)
- [ ] Command file exists (if access: human)
- [ ] Domain README updated (if domain has README)
- [ ] Harness symlinks exist (if access: human)

**If Already Complete:**
- Verify entries are correct
- Verify symlinks resolve correctly
- Skip to next step if all correct
- Update if entries are stale or symlinks broken

**Marker:** `checkpoints/create-workflow/<workflow-id>/07-references.complete`

## Reference Checklist

| Reference | Location | Required? | Status |
|-----------|----------|-----------|--------|
| Catalog entry | `.harmony/catalog.md` | If file exists | |
| Command file | `.harmony/capabilities/commands/` | If access: human | |
| Domain README | `.harmony/orchestration/workflows/<domain>/README.md` | If file exists | |
| Harness symlinks | `.cursor/commands/`, `.claude/commands/` | If access: human | |

## Error Messages

- Catalog not found: "No catalog.md found. Skipping catalog update."
- Cannot write command: "Failed to create command file at '<path>'. Check permissions."
- Symlink failed: "Failed to create symlink. Manual creation may be required."

## Output

- Catalog updated (if applicable)
- Command file created (if access: human)
- Domain README updated (if applicable)
- Harness symlinks created in all existing harness directories (if access: human)

## Proceed When

- [ ] All applicable references updated
- [ ] Command file created (if access: human)
- [ ] Harness symlinks created and verified (if access: human)
- [ ] No write errors encountered
