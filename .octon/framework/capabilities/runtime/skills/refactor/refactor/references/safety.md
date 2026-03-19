---
title: Safety Reference
description: Safety policies and constraints for the refactor skill.
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Output paths: .octon/framework/capabilities/runtime/skills/registry.yml
#
# Current allowed-tools: Read Glob Grep Edit Write(/.octon/state/control/skills/checkpoints/*) Write(/.octon/state/evidence/runs/skills/*) Bash(mv) Bash(mkdir)
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# Safety Reference

Safety policies and behavioral constraints for the refactor skill.

> **Authoritative Sources:**
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Output paths: `.octon/framework/capabilities/runtime/skills/registry.yml`

## Tool Policy

**Mode:** Deny-by-default

Allowed tools are defined in SKILL.md `allowed-tools` frontmatter (single source of truth).

This skill requires:
- Read access to codebase files
- Glob for pattern matching
- Grep for content search
- Edit for modifying source files during refactor
- Write access to output directories
- Bash (mv) for physical renames/moves
- Bash (mkdir) for directory creation

## File Policy

### Write Scope

The skill may only write to:

- `.octon/state/control/skills/checkpoints/refactor/**` — Execution state (session recovery)
- `.octon/state/evidence/runs/skills/refactor/**` — Execution logs

### Source Code Modifications

The skill modifies source code files during Phase 4 (Execute) to replace references. This is the core function of the refactor skill.

**Safety guarantees:**
- All changes are planned in Phase 3 (Plan) before execution
- Changes are verified in Phase 5 (Verify)
- Checkpoint enables rollback identification
- Suggested commit message enables git reset if needed

### Destructive Actions

**Policy:** Controlled

The skill:
- **Does** rename/move files and directories
- **Does** modify file contents to update references
- **Does NOT** delete files (only rename/move)
- **Does NOT** auto-commit changes (user controls git)

## Harness Continuity File Protection

> **Terminology:** These are **harness continuity files**—historical records that preserve project history. They are distinct from **skill execution state** (checkpoints, manifests in `/.octon/state/control/skills/checkpoints/`) which enables session recovery. Harness continuity files require append-only protection; execution state is freely writable by skills.

Files matching these patterns are **APPEND-ONLY** during refactors:

```yaml
continuity_patterns:
  - "**//.octon/state/continuity/repo/log.md"
  - "**/continuity/*.md"
  - "**/decisions/*.md"
  - "**//.octon/instance/cognition/context/shared/decisions.md"
  - "**/CHANGELOG.md"
  - "**/HISTORY.md"
  - "**/.history/**"
  - "**/ADR-*.md"
  - "**/adr-*.md"
```

### Why Append-Only?

Historical records should reflect what was true at the time. Future readers should see the progression of the project, not a sanitized history.

**Allowed:**
- Add new log entry documenting the refactor
- Add new decision entry
- Create new ADR documenting the change

**Not Allowed:**
- Modify existing log entries to reflect new names
- Update old decision text
- Change paths in historical ADRs

### Detection Algorithm

During Phase 3 (Plan):

1. Check each file against `continuity_patterns`
2. Check against `.octon/instance/cognition/context/shared/continuity.md` if it exists
3. If match found:
   - Mark file as `continuity: true` in manifest
   - Add to "Continuity Artifacts (APPEND ONLY)" section
   - Include specific instructions

4. If uncertain:
   - Flag for user confirmation
   - Ask: "Is `{{file}}` a continuity artifact (append-only)?"

## Scope Signals

These thresholds are **complexity signals, not hard limits**. Use judgment based on:
- Code coupling (40 tightly-coupled files may be harder than 60 simple renames)
- Change risk (config files vs source code)
- Review capacity (how much can be meaningfully reviewed?)

| Metric | Threshold | Signal Strength | Suggested Action |
|--------|-----------|-----------------|------------------|
| Files to modify | >50 | Strong | Consider mission-level coordination |
| Match count | >200 | Strong | Consider mission-level coordination |
| Modules affected | >3 | Moderate | Warn user, offer escalation |
| External dependencies | Any | Strong | Likely needs mission coordination |

### Why These Signals?

These thresholds indicate where single-session execution typically becomes impractical:
- **>50 files:** Review becomes difficult; risk of missed changes increases
- **>200 matches:** Manual verification becomes tedious; higher chance of errors
- **>3 modules:** Cross-cutting changes need broader architectural consideration
- **External deps:** Changes may cascade beyond the codebase

**Override guidance:** If you have high confidence in the scope (e.g., simple mechanical renames across many files), you may proceed with user acknowledgment. Document the rationale in the run log.

## Git Integration

**Policy:** No auto-commit

The skill does NOT run git commands for commits. It:

1. Makes file changes
2. Generates suggested commit message
3. Saves to `/.octon/state/control/skills/checkpoints/refactor/{{id}}/commit-message.txt`
4. Informs user: "Changes are unstaged. Suggested commit saved."

**User responsibilities:**
- Review changes before committing
- Choose commit granularity (one commit or multiple)
- Apply their own commit message conventions
- Decide on branch strategy

## Behavioral Boundaries

- Never skip the verification phase
- Never declare completion if verification fails
- Never modify continuity artifacts (only append)
- Never auto-commit changes
- Always preserve original file backup via checkpoint
- Always verify all 8 search variations
- Always check scope limits before execution
- Stop and escalate if scope exceeds limits

## Escalation Triggers

The skill must escalate to the user when:

| Trigger | Action |
|---------|--------|
| Scope >50 files | Stop, recommend mission |
| Scope >3 modules | Warn, offer escalation option |
| External dependencies | Stop, recommend mission |
| Verification fails 3+ times | Stop, ask for human review |
| Continuity artifact modification detected | Stop, warn, revert |
| Unresolvable conflicts | Stop, ask for guidance |

## Error Recovery

### Partial Execution

If execution is interrupted:

1. Checkpoint.yml contains exact state
2. Phase 4 progress shows completed items
3. Resume continues from last incomplete item
4. No duplicate changes made

### Verification Failure

If verification fails:

1. Remaining references documented
2. Return to Phase 4 automatically
3. Fix remaining items
4. Re-run verification
5. Loop until pass

### Rollback

If full rollback needed:

1. Review `execution-log.md` for all changes made
2. Changes are NOT committed (unless user committed)
3. Use git to reset: `git checkout -- .`
4. Or manually reverse changes using the log
