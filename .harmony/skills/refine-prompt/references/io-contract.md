---
inputs:
  - name: raw_prompt
    type: text
    required: true
    path_hint: "inline text or file path"
    schema: null
    description: "The raw prompt text to refine (inline or from file)"
  - name: execute
    type: boolean
    required: false
    path_hint: "flag"
    schema: null
    description: "Execute the refined prompt after saving (default: false)"
  - name: context_depth
    type: text
    required: false
    path_hint: "minimal/standard/deep"
    schema: null
    description: "How deep to analyze repository context (default: standard)"
  - name: skip_confirmation
    type: text
    required: false
    path_hint: "true/false"
    schema: null
    description: "Skip intent confirmation step (default: false)"

outputs:
  - name: refined_prompt
    type: markdown
    path: "outputs/prompts/<timestamp>-refined.md"
    format: "markdown"
    determinism: "stable"
    description: "The refined, improved prompt ready for execution"
  - name: run_log
    type: log
    path: "logs/runs/<timestamp>-refine-prompt.md"
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

Input/output specifications and dependencies for the refine-prompt skill.

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `raw_prompt` | text | Yes | The raw prompt text to refine (inline or file path) |
| `execute` | boolean | No | Execute the refined prompt after saving (default: false) |
| `context_depth` | text | No | Analysis depth: minimal/standard/deep (default: standard) |
| `skip_confirmation` | text | No | Skip intent confirmation step (default: false) |

## Outputs

### Refined Prompt
- **Path:** `outputs/prompts/<timestamp>-refined.md`
- **Format:** Markdown
- **Content:** The refined, improved prompt ready for execution

### Run Log
- **Path:** `logs/runs/<timestamp>-refine-prompt.md`
- **Format:** YAML frontmatter + Markdown
- **Content:** Execution log with input, context analyzed, and output summary

## Output Structure

The refined prompt follows this structure:

```markdown
# Refined Prompt

**Original:** [quoted original prompt]
**Refined:** [timestamp]
**Context Depth:** [minimal/standard/deep]
**Status:** [confirmed/pending confirmation]

---

## Execution Persona
[Role, expertise level, perspective, style]

## Repository Context
[Tech stack, relevant modules, files in scope, patterns to follow]

## Intent
[Clear statement of what to accomplish]

## Requirements
[Explicit numbered requirements]

## Assumptions Made
[Listed assumptions with reasoning]

## Negative Constraints (What NOT To Do)
[Anti-patterns, forbidden approaches, out of scope items]

## Sub-Tasks
[Decomposed tasks with dependencies]

## Risks & Edge Cases
[Identified risks and edge cases to handle]

## Success Criteria
[Measurable completion criteria]

## Self-Critique Results
[Completeness, ambiguity, feasibility, quality checks]

## Intent Confirmation
[Summary, key decisions, user response]

## Refined Prompt
[The actual refined prompt text, self-contained]
```

## Dependencies

### Required Tools
- `filesystem.read` - Read codebase files for context
- `filesystem.write.outputs` - Write refined prompts and logs
- `filesystem.glob` - Find relevant files
- `filesystem.grep` - Search for patterns

### External Dependencies
None required. Works with any codebase structure.
