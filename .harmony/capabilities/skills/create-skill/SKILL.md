---
name: create-skill
description: >
  Scaffold a new skill from template following the agentskills.io specification.
  Validates skill name format (kebab-case, 1-64 chars), checks uniqueness against
  existing skills, copies template structure, initializes placeholders, and updates
  manifest and registry entries. Creates symlinks in harness folders for multi-agent
  compatibility. Supports checkpoint/resume for interrupted sessions.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Harmony Framework
  created: "2026-01-20"
  updated: "2026-01-23"
skill_sets: [executor]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(.harmony/capabilities/skills/*) Write(runs/*) Write(logs/*) Bash(mkdir) Bash(ln) Bash(cp)
---

# Create Skill

Scaffold a new skill from template with registry entry, following the agentskills.io specification.

## When to Use

Use this skill when:

- Creating a new skill from scratch
- Scaffolding a skill directory structure with progressive disclosure
- Generating boilerplate for a new capability
- Adding a new skill entry to the manifest and registry

## Quick Start

```
/create-skill "analyze-codebase"
```

## Core Workflow

1. **Validate** — Check name format (kebab-case, 1-64 chars), verify uniqueness
2. **Copy Template** — Create directory structure from `_template/`, create symlinks
3. **Initialize** — Replace placeholders with skill name and dates
4. **Update Registry** — Add entries to manifest.yml and registry.yml
5. **Update Catalog** — Add row to catalog.md skills table
6. **Report Success** — Confirm creation and provide next steps

## Parameters

Parameters are defined in `.harmony/capabilities/skills/registry.yml` (single source of truth).

This skill accepts one required parameter (`skill_name`) and optional parameters for description and archetype.

## Output Location

Output paths are defined in `.harmony/capabilities/skills/registry.yml` (single source of truth).

Outputs are written to:
- `.harmony/capabilities/skills/{{skill-name}}/` — The new skill directory (deliverable)
- `runs/create-skill/{{run-id}}/` — Execution state (checkpoint and summary) for session recovery
- `logs/create-skill/` — Execution logs with index

## Naming Convention

**Use action-oriented names** following the verb-noun pattern:

| Pattern | Good Examples | Bad Examples |
|---------|---------------|--------------|
| verb-noun | `refine-prompt`, `generate-report` | `prompt-refiner`, `report-generator` |
| verb-object | `analyze-codebase`, `process-payment` | `codebase-analyzer`, `payment-processor` |

**Common action verbs:**
- `analyze`, `build`, `create`, `deploy`, `extract`
- `generate`, `process`, `refine`, `run`, `validate`
- `transform`, `convert`, `export`, `import`, `sync`

**Validation rules:**
- 1-64 characters
- Lowercase letters, numbers, hyphens only
- Must not start or end with hyphen
- No consecutive hyphens (`--`)
- Pattern: `^[a-z][a-z0-9]*(-[a-z0-9]+)*$`

## Verification Gate

After Phase 5, verify:
- Skill directory exists with all required files
- SKILL.md frontmatter `name` matches directory name
- Manifest entry exists with correct `id`
- Registry entry exists with correct key
- Symlinks exist in harness folders

## Boundaries

- Never overwrite existing skills without explicit confirmation
- Write only to designated paths (`.harmony/capabilities/skills/`, outputs, logs)
- Always validate name format before any file operations
- Always check uniqueness before proceeding

## When to Escalate

- Skill with same name already exists — Ask user for confirmation or new name
- Name format validation fails — Report error with corrective guidance
- Template directory missing — Report error, cannot proceed
- Registry file malformed — Report error, request manual intervention

## References

For detailed documentation:

- [Behavior phases](references/behaviors.md) — Full phase-by-phase instructions
- [I/O contract](references/io-contract.md) — Inputs, outputs, dependencies
- [Safety policies](references/safety.md) — Tool policies, boundaries
- [Validation](references/validation.md) — Acceptance criteria, verification
- [Examples](references/examples.md) — Full creation examples
