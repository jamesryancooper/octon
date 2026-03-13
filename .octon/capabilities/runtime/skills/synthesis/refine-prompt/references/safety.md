---
title: Safety Reference
description: Safety policies and constraints for the refine-prompt skill.
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Output paths: .octon/capabilities/runtime/skills/registry.yml
#
# Current allowed-tools: Read Glob Grep Write(../../scaffolding/practices/prompts/*) Write(_ops/state/logs/*)
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# Safety Reference

Safety policies and behavioral constraints for the refine-prompt skill.

> **Authoritative Sources:**
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Output paths: `.octon/capabilities/runtime/skills/registry.yml`

## Tool Policy

**Mode:** Deny-by-default

Allowed tools are defined in SKILL.md `allowed-tools` frontmatter (single source of truth).

This skill requires read access to codebase files, glob for pattern matching, grep for content search, and write access to output directories.

## File Policy

### Write Scope

The skill may only write to:

- `.octon/scaffolding/practices/prompts/**` — Refined prompts (deliverables)
- `.octon/capabilities/runtime/skills/_ops/state/logs/**` — Execution logs

### Destructive Actions

**Policy:** Never

The skill must never:
- Delete files
- Overwrite source code
- Modify files outside designated output paths

## Behavioral Boundaries

- Never change the core intent of the original prompt
- Always preserve the user's explicit preferences
- State all assumptions - never silently assume
- Reference only files that actually exist
- Do not execute unless explicitly requested
- Write only to designated output paths
- If contradictions cannot be resolved, ask before proceeding
- Limit context analysis to reasonable scope (don't scan entire monorepo)
- Always perform self-critique before finalizing
- Always confirm intent unless explicitly skipped

## Escalation Triggers

The skill must escalate to the user when:

- The prompt has unresolvable contradictions
- The intent is completely unclear
- Referenced files don't exist
- The request conflicts with project constraints
- The scope is too large (>20 files)
- Domain expertise is needed to fill gaps accurately
- Self-critique reveals major issues
- User rejects intent confirmation
