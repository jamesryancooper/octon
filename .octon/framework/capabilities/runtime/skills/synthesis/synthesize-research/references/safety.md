---
title: Safety Reference
description: Safety policies and constraints for the synthesize-research skill.
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Output paths: .octon/framework/capabilities/runtime/skills/registry.yml
#
# Current allowed-tools: Read Glob Write(/.octon/inputs/exploratory/drafts/*) Write(/.octon/state/evidence/runs/skills/*)
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# Safety Reference

Security boundaries and behavioral constraints for the synthesize-research skill.

> **Authoritative Sources:**
>
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Output paths: `.octon/framework/capabilities/runtime/skills/registry.yml`

## Tool Policy

**Mode:** Deny-by-default

Allowed tools are defined in SKILL.md `allowed-tools` frontmatter (single source of truth).

This skill requires only read access to source files and write access to output directories. It does not require glob, grep, network, or shell access.

## File Policy

### Write Scope

The skill may only write to designated output locations:

| Tier | Path | Purpose |
|------|------|---------|
| **Tier 1** | `.octon/inputs/exploratory/drafts/**` | Synthesis documents (deliverables) |
| **Tier 1** | `.octon/state/evidence/runs/skills/**` | Execution logs |

### Scope Authority

| Boundary | Permission | Description |
|----------|------------|-------------|
| **Within repo root** | Allowed | Can write to declared repo-root harness paths |
| **Outside repo root** | Blocked | Cannot write outside the repository boundary |

### Destructive Actions

**Policy:** Never

The skill must never:

- Delete files
- Overwrite source research notes
- Modify files outside designated output paths
- Write outside the repo-root harness boundary

## Behavioral Boundaries

### Must Always

- Cite source files for all findings
- Preserve the nuance of original research
- State assumptions explicitly
- Mark uncertain findings with appropriate confidence level
- Write only to .octon/inputs/exploratory/drafts/ and /.octon/state/evidence/runs/skills/ directories

### Must Never

- Fabricate findings not present in source materials
- Make recommendations beyond what evidence supports
- Overstate confidence in uncertain findings
- Delete or modify source files
- Access external resources or services

## Escalation Triggers

The skill must stop and request user intervention when:

| Condition | Action |
|-----------|--------|
| Input folder is empty | Report error, ask for valid path |
| No `.md` files found | Report error, ask for valid path |
| Research goal is unclear | Ask one clarifying question |
| Major contradictions unresolved | Flag for human review |
| Findings require domain expertise | Note limitations, proceed with caveats |
| Scope exceeds reasonable size (>50 files) | Warn user, suggest narrowing scope |

## Input Validation

Before processing, validate:

- [ ] Input path exists
- [ ] Input path is a directory
- [ ] Directory contains at least one `.md` file
- [ ] Files are readable

If validation fails, report the specific issue and exit gracefully.
