---
title: Safety Reference
description: Security boundaries and behavioral constraints for the synthesize-research skill.
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Output paths: .harmony/capabilities/skills/registry.yml
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# Safety Reference

Security boundaries and behavioral constraints for the synthesize-research skill.

> **Authoritative Sources:**
>
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Output paths: `.harmony/capabilities/skills/registry.yml`

## Tool Policy

**Mode:** Deny-by-default

Allowed tools are defined in SKILL.md `allowed-tools` frontmatter (single source of truth).

This skill requires only read access to source files and write access to output directories. It does not require glob, grep, network, or shell access.

## File Policy

### Write Scope

The skill may only write to designated output locations:

| Tier | Path | Purpose |
|------|------|---------|
| **Tier 1** | `.harmony/output/drafts/**` | Synthesis documents (deliverables) |
| **Tier 1** | `.harmony/capabilities/skills/logs/**` | Execution logs |

### Scope Authority

| Direction | Permission | Description |
|-----------|------------|-------------|
| **Down** | Allowed | Can write into descendant harnesses |
| **Up** | Blocked | Cannot write into ancestor harnesses |
| **Sideways** | Blocked | Cannot write into sibling harnesses |

### Destructive Actions

**Policy:** Never

The skill must never:

- Delete files
- Overwrite source research notes
- Modify files outside designated output paths
- Write to ancestor or sibling harness paths

## Behavioral Boundaries

### Must Always

- Cite source files for all findings
- Preserve the nuance of original research
- State assumptions explicitly
- Mark uncertain findings with appropriate confidence level
- Write only to .harmony/output/drafts/ and logs/ directories

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
