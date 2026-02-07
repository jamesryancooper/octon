---
title: Safety Reference
description: Safety policies and behavioral constraints for the create-skill skill.
---

# Safety Reference

Safety policies and behavioral constraints for the create-skill skill.

> **Authoritative Sources:**
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Output paths: `.harmony/capabilities/skills/registry.yml`

## Tool Policy

**Mode:** Deny-by-default

Allowed tools defined in SKILL.md `allowed-tools`:
- `Read` — Read template and registry files
- `Glob` — Pattern matching for file discovery
- `Grep` — Content search for uniqueness checks
- `Write(.harmony/capabilities/skills/*)` — Create new skill directory and files
- `Write(runs/*)` — Write execution state (checkpoint and summary) for session recovery
- `Write(logs/*)` — Write execution logs
- `Bash(mkdir)` — Create directories
- `Bash(ln)` — Create symlinks
- `Bash(cp)` — Copy template files

## File Policy

### Write Scope

The skill may write to:

| Path | Operations | Purpose |
|------|------------|---------|
| `.harmony/capabilities/skills/{{new-skill}}/` | Create files | New skill directory |
| `.harmony/capabilities/skills/manifest.yml` | Append entry | Register skill |
| `.harmony/capabilities/skills/registry.yml` | Append entry | Add metadata |
| `.harmony/catalog.md` | Append row | Add to catalog table |
| `.harmony/capabilities/skills/runs/create-skill/` | Create files | Execution state (session recovery) |
| `.harmony/capabilities/skills/logs/create-skill/` | Create/update files | Run logs and indexes |
| `.harmony/capabilities/skills/logs/index.yml` | Update | Top-level log index |

### Protected Paths

The skill must NOT:

- Modify existing skill directories (only create new ones)
- Overwrite existing skills without explicit user confirmation
- Modify or delete the `_template/` directory
- Write outside designated paths
- Modify registry entries for other skills

## Uniqueness Protection

**Critical:** Before creating any files, verify:

1. No entry in `manifest.yml` with matching `id`
2. No directory `.harmony/capabilities/skills/{{skill-name}}/` exists
3. If either exists, STOP and ask user

### Conflict Resolution

If skill exists:

```
Skill "analyze-codebase" already exists.

Options:
1. Choose a different name
2. Overwrite existing skill (requires explicit confirmation)
3. Cancel

What would you like to do?
```

## Behavioral Boundaries

| Boundary | Description |
|----------|-------------|
| Validate before write | Always validate name format before any file operations |
| Check uniqueness | Always check manifest.yml before creating files |
| No silent overwrite | Never overwrite existing skills without explicit confirmation |
| Complete registry | Never skip registry updates (manifest and registry must stay in sync) |
| All harnesses | Always create symlinks in all harness folders |
| Always log | Always write execution log and update indexes |

## Escalation Triggers

| Trigger | Action |
|---------|--------|
| Skill name exists | Stop, ask for new name or confirmation |
| Invalid name format | Stop, explain format requirements |
| Template missing | Stop, report error: "Template directory not found" |
| Registry malformed | Stop, request manual intervention |
| Permission denied | Stop, report error with path |
| Harness folder missing | Warn, continue with available harnesses |

## Error Recovery

### Partial Execution

If interrupted mid-execution:
- Checkpoint captures exact state in `checkpoint.yml`
- Resume continues from last incomplete phase
- No duplicate file creation (idempotent)

### Cleanup on Failure

If skill creation fails after partial progress:
- Directory may exist with incomplete files
- Checkpoint shows failed state with error details
- User options:
  - Retry (will resume from checkpoint)
  - Manual cleanup (delete partial directory)
  - Start fresh (delete checkpoint, then retry)

### Rollback Guidance

If rollback needed after completion:

1. Delete skill directory:
   ```bash
   rm -rf .harmony/capabilities/skills/{{skill-name}}/
   ```

2. Remove manifest entry:
   - Edit `.harmony/capabilities/skills/manifest.yml`
   - Remove entry with `id: {{skill-name}}`

3. Remove registry entry:
   - Edit `.harmony/capabilities/skills/registry.yml`
   - Remove entry with key `{{skill-name}}`

4. Remove catalog entry:
   - Edit `.harmony/catalog.md`
   - Remove row for skill

5. Delete symlinks:
   ```bash
   rm .claude/skills/{{skill-name}}
   rm .cursor/skills/{{skill-name}}
   rm .codex/skills/{{skill-name}}
   ```

6. (Optional) Delete execution state and logs:
   ```bash
   rm -rf .harmony/capabilities/skills/runs/create-skill/{{run-id}}/
   rm .harmony/capabilities/skills/logs/create-skill/{{run-id}}.md
   ```

## Input Validation

### Name Format Rules

| Rule | Regex/Check | Error Message |
|------|-------------|---------------|
| Pattern | `^[a-z][a-z0-9]*(-[a-z0-9]+)*$` | "Must be lowercase with hyphens" |
| Length | 1-64 characters | "Must be 1-64 characters" |
| No leading hyphen | Cannot start with `-` | "Cannot start with hyphen" |
| No trailing hyphen | Cannot end with `-` | "Cannot end with hyphen" |
| No consecutive hyphens | Cannot contain `--` | "Cannot contain consecutive hyphens" |

### Archetype Validation

| Value | Description |
|-------|-------------|
| `atomic` | Simple, single-purpose (SKILL.md only) |
| `complex` | Multi-phase with references/ (default, includes optional domain files) |
