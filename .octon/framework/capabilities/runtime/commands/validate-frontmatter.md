---
title: Validate Frontmatter
description: Validate YAML frontmatter in markdown files.
access: agent
---

# Validate Frontmatter

Validate YAML frontmatter in all markdown files in the target directory.

## Input

- **Target directory:** Path to scan for markdown files (provided via Cursor command `@` reference)

## Action

1. Find all `*.md` files in the target directory (recursive)
2. For each file, check that frontmatter exists and contains required fields
3. Report any files with missing or invalid frontmatter

## Required Fields

### All Markdown Files

- `title` — Document title
- `description` — Brief summary (max 160 characters)

### Harness Commands and Workflow Overviews

Files in `.octon/framework/capabilities/runtime/commands/` and `.octon/framework/orchestration/runtime/workflows/**/00-overview.md` also require:

- `access` — Must be `human` (has Cursor command wrapper) or `agent` (agent-only)

## Output

List of files with validation status:
- ✅ Valid
- ❌ Missing frontmatter
- ⚠️ Missing required field: `<field>`
- ⚠️ Description exceeds 160 characters
- ⚠️ Invalid `access` value (must be `human` or `agent`)

## References

- **Canonical:** `.octon/framework/capabilities/_meta/architecture/commands.md`

