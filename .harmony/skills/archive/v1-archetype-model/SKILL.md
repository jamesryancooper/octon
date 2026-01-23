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
#   - Continuity Artifacts: Write(runs/*) - for complex skills with checkpoints
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
- **Continuity Artifacts:** `.workspace/skills/runs/{{skill-id}}/{{run-id}}/` (for complex skills)
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

| Archetype                   | Structure                          | When to Use                                 |
|-----------------------------|------------------------------------|---------------------------------------------|
| **Atomic**                  | SKILL.md only                      | Single-purpose, stateless, obvious I/O      |
| **Atomic (with examples)**  | SKILL.md + examples.md             | Single-purpose, output needs demonstration  |
| **Complex** (minimal)       | SKILL.md + 1-2 pattern refs        | Simple multi-phase or coordinated skill     |
| **Complex** (typical)       | SKILL.md + 3-5 pattern refs        | Standard for most multi-phase skills        |

See [Reference Artifacts](../../../../docs/architecture/workspaces/skills/reference-artifacts.md) for the full archetype decision matrix.

### Atomic Archetype ("The Specialist")

For single-purpose skills, you may delete the `references/` folder entirely—or keep individual files as needed. An Atomic skill is appropriate when the skill does one discrete action without internal state.

**Atomic can include individual reference files:**

- Add `examples.md` if you'd write >3 example cases
- Add `errors.md` if error handling exceeds 30 lines
- Add `glossary.md` if >5 domain terms need definitions

**To convert to minimal Atomic:** Delete `references/` directory. Everything needed fits in this SKILL.md file.

**To convert to Atomic with selective refs:** Delete unneeded reference files, keep only what adds value.

### Atomic (with examples) Archetype

For single-purpose skills where worked examples clarify expected behavior:

- The skill has a single, obvious purpose
- Output format isn't immediately obvious from the description
- Users would benefit from seeing concrete input→output examples

**To convert to Atomic (with examples) archetype:** Delete all files in `references/` except `examples.md`. Keep SKILL.md + `references/examples.md` only.

### Complex Archetype ("The Strategist")

This template includes Complex archetype references. Complex skills must have **at least one** pattern-triggered reference file. Add files based on which patterns your skill exhibits:

**Pattern-triggered files (add based on exhibited patterns):**

| Pattern | File | When to Add |
|---------|------|-------------|
| Non-trivial I/O | [io-contract.md](references/io-contract.md) | >2 inputs OR structured output |
| Distinct phases | [behaviors.md](references/behaviors.md) | ≥2 phases with transitions |
| Tool/file policies | [safety.md](references/safety.md) | Restricted operations need documentation |
| Output demonstration | [examples.md](references/examples.md) | Output format needs worked examples |
| Quality gates | [validation.md](references/validation.md) | Formal acceptance criteria exist |
| Stateful | `checkpoints.md` | State persists across phases |
| Orchestrated | `orchestration.md` | Coordinates sub-tasks |
| Phased | `decisions.md` | Branching logic exists |
| Interactive | `interaction.md` | Human-in-the-loop required |
| Agentic | `agents.md` | Spawns sub-agents |
| Composable | `composition.md` | Designed for pipelines |
| Complex errors | `errors.md` | Recovery procedures needed |
| Domain-specific | `glossary.md` | >5 domain terms |
| Specialized knowledge | `<domain>.md` | Domain expertise needed |

**To convert to minimal Complex:** Keep only the 1-2 files matching your skill's patterns.

**To convert to typical Complex:** Keep files for all exhibited patterns (usually 3-5 files).

### Validation Expectations

Choose validation approach based on archetype:

- **Atomic:** Add a "Success Criteria" section to this SKILL.md with 2-3 bullet points
- **Atomic (with examples):** Examples in `examples.md` serve as test cases—output should match demonstrated patterns
- **Complex (minimal):** Include inline success criteria in SKILL.md or behaviors.md
- **Complex (with validation.md):** Use `references/validation.md` for formal acceptance criteria and quality gates
