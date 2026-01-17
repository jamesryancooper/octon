---
# I/O Contract Documentation
# This file provides extended documentation for human reference.
#
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Parameters: .harmony/skills/registry.yml
#   - Output paths: .workspace/skills/registry.yml
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# I/O Contract Reference

Input/output specifications for the skill-name skill.

> **Authoritative Sources:**
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Parameters: `.harmony/skills/registry.yml`
> - Output paths: `.workspace/skills/registry.yml`

## Inputs

Parameter definitions are in `registry.yml` (single source of truth). Summary:

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `[input_name]` | text | Yes | — | [Description] |
| `[option_name]` | text | No | [default] | [Description] |

## Outputs

Output definitions are in `.workspace/skills/registry.yml` (single source of truth). Summary:

### [Primary Output]
- **Path:** `outputs/[category]/{{timestamp}}-[name].md`
- **Format:** Markdown
- **Content:** [Description of output content]

### Run Log
- **Path:** `logs/runs/{{timestamp}}-skill-name.md`
- **Format:** YAML frontmatter + Markdown
- **Content:** Execution log with input, context, and output summary

## Output Structure

The output follows this structure:

```markdown
# [Output Title]

[Description of expected output structure]

## Section 1
[Content]

## Section 2
[Content]
```

## Dependencies

### Required Tools

Tool requirements are defined in SKILL.md `allowed-tools` frontmatter (single source of truth). This skill uses:

| Tool | Purpose |
|------|---------|
| `Read` | [Purpose] |
| `Write(outputs/*)` | [Purpose] |
| `Glob` | [Purpose] |
| `Grep` | [Purpose] |

### External Dependencies

[None required, or list external dependencies]

---

## Command-Line Usage

### Basic Invocation

```bash
/skill-name "[input]"
```

### With Options

```bash
# Option example
/skill-name "[input]" --param2=[value]

# Combined options
/skill-name "[input]" --param2=[value] --param3
```

### From File

```bash
/skill-name path/to/input.txt
```

### Parameter Reference

| Parameter | Flag | Values | Default |
|-----------|------|--------|---------|
| `[param1]` | (positional) | text or file path | required |
| `[param2]` | `--param2=` | [valid values] | [default] |
