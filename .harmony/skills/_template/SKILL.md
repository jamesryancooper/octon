---
name: {{skill_name}}
description: >
  {{skill_description}}
  Include specific keywords to help agents identify relevant tasks.
  Describe the value proposition and typical use cases.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: "{{author_name}}"
  created: "{{created_date}}"
  updated: "{{updated_date}}"
  # Note: version is defined in .harmony/skills/registry.yml, not here
# Tool Permissions (Single Source of Truth)
# Format: Space-delimited list. Add (path/glob) to scope writes.
# Example: Read Glob Grep Write(../prompts/*) Write(logs/*)
#          └─ Read-only ─┘     └─ Scoped writes ────────┘
# See: docs/architecture/workspaces/skills/specification.md#tool-permissions-single-source-of-truth
# Tool reference: Read, Glob, Grep, Write(path/*), WebFetch, Shell, Task
#
# Output Types:
#   - Deliverables: Write(../{{category}}/*) - e.g., Write(../prompts/*), Write(../drafts/*)
#   - Continuity Artifacts: Write(runs/*) - for workflow skills with checkpoints
allowed-tools: Read Glob Grep Write(../{{category}}/*) Write(logs/*)
---

# {{skill_display_name}}

{{skill_one_liner}}

## When to Use

Use this skill when:

- {{trigger_condition_1}}
- {{trigger_condition_2}}
- {{trigger_condition_3}}

## Quick Start

```markdown
/{{skill_name}} "{{example_input}}"
```

## Core Workflow

1. **{{phase_1_name}}** - {{phase_1_description}}
2. **{{phase_2_name}}** - {{phase_2_description}}
3. **{{phase_3_name}}** - {{phase_3_description}}
4. **Output** - Save results and execution log

## Parameters

Parameters are defined in `.harmony/skills/registry.yml` (single source of truth).

This skill accepts {{parameters_summary}}.

## Output Location

Output paths are defined in `.workspace/skills/registry.yml` (single source of truth).

All operational categories in `.workspace/skills/` follow the `{{category}}/{{skill-id}}/` pattern:

- **Deliverables:** `.workspace/{{category}}/` (e.g., `.workspace/prompts/`, `.workspace/drafts/`)
- **Configs:** `.workspace/skills/configs/{{skill-id}}/` (per-skill configuration overrides)
- **Resources:** `.workspace/skills/resources/{{skill-id}}/` (per-skill input materials)
- **Continuity Artifacts:** `.workspace/skills/runs/{{skill-id}}/{{run-id}}/` (for workflow skills)
- **Execution Logs:** `.workspace/skills/logs/{{skill-id}}/{{run-id}}.md`

## Boundaries

- {{constraint_must_not}}
- {{constraint_must_do}}
- Write only to designated output paths
- {{additional_constraint}}

## When to Escalate

- {{escalation_condition_1}}
- {{escalation_condition_2}}
- {{escalation_condition_3}}

## References (Optional)

Reference files are **optional**. Choose the archetype that matches your skill's complexity:

| Archetype                   | Structure                      | When to Use                                 |
|-----------------------------|--------------------------------|---------------------------------------------|
| **Utility**                 | SKILL.md only                  | Single-purpose skills with obvious I/O      |
| **Utility (with examples)** | SKILL.md + examples.md         | Single-purpose, output needs demonstration  |
| **Workflow**                | SKILL.md + references/         | Multi-phase execution with defined steps    |

See [Reference Artifacts](../../../../docs/architecture/workspaces/skills/reference-artifacts.md) for the full archetype decision matrix.

### Utility Archetype (Simplest)

For simple skills, delete the `references/` folder entirely and keep only SKILL.md. A Utility skill is appropriate when:

- The skill has a single, obvious purpose
- Input/output formats are self-explanatory
- No complex multi-phase workflow

**To convert to Utility archetype:** Delete `references/` directory. Everything needed fits in this SKILL.md file.

### Utility (with examples) Archetype

For single-purpose skills where worked examples clarify expected behavior:

- The skill has a single, obvious purpose
- Output format isn't immediately obvious from the description
- Users would benefit from seeing concrete input→output examples

**To convert to Utility (with examples) archetype:** Delete all files in `references/` except `examples.md`. Keep SKILL.md + `references/examples.md` only.

### Workflow Archetype (This Template)

This template includes Workflow archetype core references:

- [I/O contract](references/io-contract.md) - Inputs, outputs, dependencies, command-line usage
- [Safety policies](references/safety.md) - Tool and file policies
- [Examples](references/examples.md) - Full usage examples
- [Behavior phases](references/behaviors.md) - Full phase-by-phase instructions
- [Validation](references/validation.md) - Acceptance criteria

**Optional files for domain-oriented skills:**

- `errors.md` - Error codes and recovery procedures (add for complex error handling)
- `glossary.md` - Domain-specific terminology (add for specialized domains)
- `<domain>.md` - Domain-specific reference material (e.g., `finance.md`, `security.md`)

### Validation Expectations

Choose validation approach based on archetype:

- **Utility:** Add a "Success Criteria" section to this SKILL.md with 2-3 bullet points
- **Utility (with examples):** Examples in `examples.md` serve as test cases—output should match demonstrated patterns
- **Workflow:** Use `references/validation.md` for formal acceptance criteria
