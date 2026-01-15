---
inputs:
  - name: "[input_name]"
    type: text
    required: true
    path_hint: "inline text or file path"
    schema: null
    description: "[Description of the input]"
  - name: "[option_name]"
    type: text
    required: false
    path_hint: "[hint]"
    schema: null
    description: "[Description of the option] (default: [default])"

outputs:
  - name: "[output_name]"
    type: markdown
    path: "outputs/[category]/<timestamp>-[name].md"
    format: "markdown"
    determinism: "stable"
    description: "[Description of the output]"
  - name: run_log
    type: log
    path: "logs/runs/<timestamp>-skill-name.md"
    format: "yaml-frontmatter-markdown"
    determinism: "stable"

requires:
  tools:
    - filesystem.read
    - filesystem.write.outputs
    - filesystem.glob
    - filesystem.grep
  packages: []
  services: []

depends_on: []
---

# I/O Contract Reference

Input/output specifications and dependencies for the skill-name skill.

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `[input_name]` | text | Yes | [Description] |
| `[option_name]` | text | No | [Description] (default: [default]) |

## Outputs

### [Primary Output]
- **Path:** `outputs/[category]/<timestamp>-[name].md`
- **Format:** Markdown
- **Content:** [Description of output content]

### Run Log
- **Path:** `logs/runs/<timestamp>-skill-name.md`
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
- `filesystem.read` - [Purpose]
- `filesystem.write.outputs` - [Purpose]
- `filesystem.glob` - [Purpose]
- `filesystem.grep` - [Purpose]

### External Dependencies
[None required, or list external dependencies]
