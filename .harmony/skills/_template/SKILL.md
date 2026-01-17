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
allowed-tools: Read Glob Grep Write(outputs/*) Write(logs/*)
---

# {{skill_display_name}}

{{skill_one_liner}}

## When to Use

Use this skill when:

- {{trigger_condition_1}}
- {{trigger_condition_2}}
- {{trigger_condition_3}}

## Quick Start

```
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

Outputs are written to `outputs/{{output_category}}/` (results) and `logs/runs/` (execution log).

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

| Archetype | Structure | When to Use |
|-----------|-----------|-------------|
| **Utility** | SKILL.md only | Single-purpose skills with obvious I/O |
| **Workflow** | SKILL.md + references/ | Multi-phase execution with defined steps |
| **Domain** | Workflow + domain files | Specialized domains requiring terminology & auditability |

See [Reference Artifacts](../../../docs/architecture/workspaces/skills/reference-artifacts.md) for the full archetype decision matrix.

**This template includes Workflow archetype references:**

- [I/O contract](references/io-contract.md) - Inputs, outputs, dependencies, command-line usage
- [Safety policies](references/safety.md) - Tool and file policies
- [Examples](references/examples.md) - Full usage examples
- [Behavior phases](references/behaviors.md) - Full phase-by-phase instructions
- [Validation](references/validation.md) - Acceptance criteria

**For Domain archetype, add:**

- `errors.md` - Error codes and recovery procedures
- `glossary.md` - Domain-specific terminology
- `<domain>.md` - Domain-specific reference material (e.g., `finance.md`, `security.md`)
