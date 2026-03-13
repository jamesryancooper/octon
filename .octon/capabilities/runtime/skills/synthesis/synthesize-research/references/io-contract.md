---
# I/O Contract Documentation
# This file provides extended documentation for human reference.
#
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Parameters: .octon/capabilities/runtime/skills/registry.yml
#   - Output paths: .octon/capabilities/runtime/skills/registry.yml
#
# Current allowed-tools: Read Glob Write(../../output/drafts/*) Write(_ops/state/logs/*)
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# I/O Contract Reference

Extended input/output documentation for the synthesize-research skill.

> **Authoritative Sources:**
>
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Parameters: `.octon/capabilities/runtime/skills/registry.yml`
> - Output paths: `.octon/capabilities/runtime/skills/registry.yml`

## Input Folder Structure

The skill expects a folder containing markdown files with research notes:

```markdown
_ops/state/resources/synthesize-research/topic/
├── findings.md       # Research findings
├── notes.md          # Raw notes
├── log.md            # Research log (optional)
└── project.md        # Project context (optional)
```

> **Note:** All `.octon/capabilities/runtime/skills/` categories follow the `{{category}}/{{skill-id}}/` pattern.

### Special Files

If present, these files receive priority treatment:

| File | Purpose |
|------|---------|
| `project.md` | Project context and research goals — read first to understand scope |
| `log.md` | Chronological research log — useful for understanding evolution |
| `findings.md` | Explicit findings and conclusions — highest weight in synthesis |

## Output Format

### Synthesis Document Format

```markdown
# Research Synthesis: {{topic}}

**Generated:** {{timestamp}}
**Source:** {{input folder path}}

## Executive Summary

{{3-5 sentence overview of key findings}}

## Key Themes

### Theme 1: {{Name}}

**Insight:** {{Clear statement}}

**Evidence:**
- {{Supporting point 1}}
- {{Supporting point 2}}

**Confidence:** {{High/Medium/Low}}

### Theme 2: {{Name}}
...

## Contradictions & Resolutions

| Finding A | Finding B | Resolution |
|-----------|-----------|------------|
| {{Claim}} | {{Conflicting claim}} | {{How resolved or "Unresolved"}} |

## Open Questions

1. {{Question that remains unanswered}}
2. {{Gap in research coverage}}

## Sources Reviewed

- {{File 1}}
- {{File 2}}
```

### Run Log Format

```yaml
---
run_id: 2025-01-12T10-31-00Z-synthesize-research
skill_id: synthesize-research
skill_version: "1.0.0"
status: success  # success | partial | failed
started_at: 2025-01-12T10:31:00Z
ended_at: 2025-01-12T10:44:12Z
inputs:
  - _ops/state/resources/synthesize-research/api-design/
outputs:
  - .octon/output/drafts/api-design-synthesis.md
tools_used:
  - filesystem.read
  - filesystem.write
---

## Summary
- Processed 5 source files
- Identified 4 themes
- Found 1 unresolved contradiction

## Notes
- Research goal was clearly stated in project.md
- One source file was empty (skipped)
```

## Dependencies

Tool requirements are defined in SKILL.md `allowed-tools` frontmatter (single source of truth).

No external dependencies required. Works with any folder containing markdown files.

---

## Command-Line Usage

### Basic Invocation

```bash
/synthesize-research _ops/state/resources/synthesize-research/topic/
```

### With Project Folder

```bash
/synthesize-research _ops/state/resources/synthesize-research/projects/auth-patterns/
```

### Examples

```bash
# Synthesize API design research
/synthesize-research _ops/state/resources/synthesize-research/api-design/

# Synthesize project research
/synthesize-research _ops/state/resources/synthesize-research/projects/caching-strategy/

# Using explicit skill call
use skill: synthesize-research
```

### Parameter Reference

| Parameter | Position | Values | Required |
|-----------|----------|--------|----------|
| `research_folder` | 1 (positional) | folder path | Yes |
