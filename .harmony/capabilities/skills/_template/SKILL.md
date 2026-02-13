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
  # Note: version is defined in .harmony/capabilities/skills/registry.yml, not here
# Capability Model
# Skills declare skill_sets (bundles) and individual capabilities.
# Resolved capabilities determine which reference files are needed.
#
# Skill Sets (choose applicable bundles):
#   executor     - Multi-step work (→ phased, branching, stateful)
#   coordinator  - Manages external tasks (→ task-coordinating, parallel)
#   delegator    - Delegates to sub-agents (→ agent-delegating)
#   collaborator - Works with humans (→ human-collaborative, stateful)
#   integrator   - Pipeline building block (→ composable, contract-driven)
#   specialist   - Requires domain expertise (→ domain-specialized)
#   guardian     - Enforces quality/safety (→ self-validating, safety-bounded)
#
# Additional Capabilities (beyond skill set bundles):
#   resumable, error-resilient, idempotent, cancellable, external-dependent,
#   long-running, scheduled, external-output
#
# Alignment-First Rule:
#   Prefer existing skill_sets/capabilities and reference contracts.
#   If a requested behavior does not fit, create a spec extension proposal
#   before adding new contract fields, capability names, or reference types.
#
# See: .harmony/capabilities/architecture/capabilities.md
skill_sets: []
capabilities: []
# Tool Permissions (Single Source of Truth)
# Format: Space-delimited list. Add (path/glob) to scope writes.
# Example: Read Glob Grep Write(../prompts/*) Write(_state/logs/*)
#          └─ Read-only ─┘     └─ Scoped writes ────────┘
# Pack reference example: pack:read-only Write(_state/logs/*)
# See: .harmony/capabilities/architecture/specification.md#tool-permissions-single-source-of-truth
# Tool reference: Read, Glob, Grep, Write(path/*), WebFetch, Shell, Task
#
# Output Types:
#   - Deliverables: Write(../{{category}}/*) - e.g., Write(../prompts/*), Write(../drafts/*)
#   - Continuity Artifacts: Write(_state/runs/*) - for stateful/resumable skills
allowed-tools: Read Glob Grep Write(../{{category}}/*) Write(_state/logs/*)
# Allowed service IDs (optional, space-delimited):
# Example: guard cost
allowed-services:
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

Parameters are defined in `.harmony/capabilities/skills/registry.yml` (single source of truth).

This skill accepts {{parameters_summary}}.

## Output Location

Output paths are defined in `.harmony/capabilities/skills/registry.yml` (single source of truth).

All operational categories in `.harmony/capabilities/skills/` follow the `{{category}}/{{skill-id}}/` pattern:

- **Deliverables:** `.harmony/output/{{category}}/` (e.g., `.harmony/scaffolding/prompts/`, `.harmony/output/drafts/`)
- **Configs:** `.harmony/capabilities/skills/_state/configs/{{skill-id}}/` (per-skill configuration overrides)
- **Resources:** `.harmony/capabilities/skills/_state/resources/{{skill-id}}/` (per-skill input materials)
- **Continuity Artifacts:** `.harmony/capabilities/skills/_state/runs/{{skill-id}}/{{run-id}}/` (for stateful/resumable skills)
- **Execution Logs:** `.harmony/capabilities/skills/_state/logs/{{skill-id}}/{{run-id}}.md`

## Boundaries

- {{constraint_must_not}}
- {{constraint_must_do}}
- Write only to designated output paths
- {{additional_constraint}}

## When to Escalate

- {{escalation_condition_1}}
- {{escalation_condition_2}}
- {{escalation_condition_3}}

## References

Reference files are included based on your declared **capabilities**. Each capability maps to specific reference files:

| Capability | Reference File | When Needed |
|------------|----------------|-------------|
| `phased` | [phases.md](references/phases.md) | Skill has distinct execution phases |
| `branching` | [decisions.md](references/decisions.md) | Skill has conditional execution paths |
| `stateful` / `resumable` | [checkpoints.md](references/checkpoints.md) | State persists across phases |
| `human-collaborative` | [interaction.md](references/interaction.md) | Human decisions required |
| `agent-delegating` | [agents.md](references/agents.md) | Spawns sub-agents |
| `task-coordinating` / `parallel` | [orchestration.md](references/orchestration.md) | Manages external tasks |
| `composable` | [composition.md](references/composition.md) | Designed for chaining |
| `contract-driven` | [io-contract.md](references/io-contract.md) | Formal I/O specification |
| `self-validating` | [validation.md](references/validation.md) | Formal acceptance criteria |
| `safety-bounded` | [safety.md](references/safety.md) | Explicit constraints |
| `domain-specialized` | [glossary.md](references/glossary.md) | Domain terminology |
| `error-resilient` | [errors.md](references/errors.md) | Recovery procedures |
| `idempotent` | [idempotency.md](references/idempotency.md) | Safe retry semantics |
| `cancellable` | [cancellation.md](references/cancellation.md) | Mid-execution stopping |
| `external-dependent` | [dependencies.md](references/dependencies.md) | External service requirements |
| `long-running` | [execution-model.md](references/execution-model.md) | Extended runtime behavior |
| `scheduled` | [schedule.md](references/schedule.md) | Timer/cron-based triggering |
| `external-output` | [external-outputs.md](references/external-outputs.md) | URL/API/deployment outputs |

### Capability Selection Guide

**Choose skill sets first** (bundles of related capabilities):

```yaml
# Simple multi-phase skill
skill_sets: [executor]
capabilities: []

# Multi-phase with human checkpoints
skill_sets: [executor, collaborator]
capabilities: []

# Multi-phase with quality gates
skill_sets: [executor, guardian]
capabilities: []

# Pipeline component
skill_sets: [integrator]
capabilities: []

# Minimal skill (no references needed)
skill_sets: []
capabilities: []
```

**Add individual capabilities** for specific needs beyond skill set bundles:

```yaml
# Executor that can resume after interruption
skill_sets: [executor]
capabilities: [resumable]

# Integrator with retry safety
skill_sets: [integrator]
capabilities: [idempotent]
```

**To use this template:**

1. Set `skill_sets` and `capabilities` in frontmatter above
2. Delete reference files you don't need (based on resolved capabilities)
3. Update remaining reference files with skill-specific content

See [Reference Artifacts](/.harmony/capabilities/architecture/reference-artifacts.md) for the complete capability-to-reference mapping.
