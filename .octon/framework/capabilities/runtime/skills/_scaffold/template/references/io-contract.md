---
# I/O Contract Documentation
# This file provides extended documentation for human reference.
#
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Parameters: .octon/framework/capabilities/runtime/skills/registry.yml
#   - Output paths: .octon/framework/capabilities/runtime/skills/registry.yml
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# I/O Contract Reference

**Required when capability:** `contract-driven`

Input/output specifications for the skill-name skill.

> **Authoritative Sources:**
>
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Parameters: `.octon/framework/capabilities/runtime/skills/registry.yml`
> - Output paths: `.octon/framework/capabilities/runtime/skills/registry.yml`

## Inputs

Parameter definitions are in `registry.yml` (single source of truth). Summary:

| Parameter         | Type | Required | Default     | Description      |
|-------------------|------|----------|-------------|------------------|
| `{{input_name}}`  | text | Yes      | —           | {{Description}}  |
| `{{option_name}}` | text | No       | {{default}} | {{Description}}  |

## Outputs

Output definitions are in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

> **Note:** All `.octon/framework/capabilities/runtime/skills/` categories follow the `{{category}}/{{skill-id}}/` pattern: `/.octon/instance/capabilities/runtime/skills/configs/`, `/.octon/instance/capabilities/runtime/skills/resources/`, `/.octon/state/control/skills/checkpoints/`, `/.octon/state/evidence/runs/skills/`.

Summary:

### {{Primary Output}} (Deliverable)

- **Path:** `.octon/generated/{{category}}/{{timestamp}}-{{name}}.md`
- **Format:** Markdown
- **Content:** {{Description of output content}}

### Run Log

- **Path:** `/.octon/state/evidence/runs/skills/{{skill-id}}/{{run-id}}.md`
- **Format:** YAML frontmatter + Markdown
- **Content:** Execution log with input, context, and output summary

#### Run Log Format

```yaml
---
run_id: "2025-01-15T10-30-00Z-skill-name"
skill_id: skill-name
skill_version: "1.0.0"
status: success  # success | partial | failed
started_at: 2025-01-15T10:30:00Z
ended_at: 2025-01-15T10:32:15Z
inputs:
  - {{input_path_or_value}}
outputs:
  - .octon/generated/{{category}}/{{timestamp}}-{{name}}.md
tools_used:
  - filesystem.read
  - filesystem.glob
  - filesystem.write
---

## Summary

- Processed {{N}} input files
- Generated {{description of output}}

## Notes

- {{Any observations during execution}}
- {{Edge cases encountered}}
```

## Output Structure

The output follows this structure:

```markdown
# {{Output Title}}

{{Description of expected output structure}}

## Section 1
{{Content}}

## Section 2
{{Content}}
```

## Dependencies

### Required Tools

Tool requirements are defined in SKILL.md `allowed-tools` frontmatter (single source of truth). This skill uses:

| Tool              | Purpose       |
|-------------------|---------------|
| `Read`            | {{Purpose}}   |
| `Write(../{{category}}/*)`| Write deliverables to final destination |
| `Write(/.octon/state/evidence/runs/skills/*)`   | Write execution logs |
| `Glob`            | {{Purpose}}   |
| `Grep`            | {{Purpose}}   |

### External Dependencies

{{None required, or list external dependencies}}

---

## Command-Line Usage

### Basic Invocation

```bash
/skill-name "{{input}}"
```

### With Options

```bash
# Option example
/skill-name "{{input}}" --param2={{value}}

# Combined options
/skill-name "{{input}}" --param2={{value}} --param3
```

### From File

```bash
/skill-name path/to/input.txt
```

### Parameter Reference

| Parameter     | Flag         | Values              | Default    |
|---------------|--------------|---------------------|------------|
| `{{param1}}`  | (positional) | text or file path   | required   |
| `{{param2}}`  | `--param2=`  | {{valid values}}    | {{default}}|
