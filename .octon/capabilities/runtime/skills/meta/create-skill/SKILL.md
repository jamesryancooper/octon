---
name: create-skill
description: >
  Scaffold a new skill from template following the agentskills.io specification.
  Validates skill name format (kebab-case, 1-64 chars), checks uniqueness against
  existing skills, copies template structure, initializes placeholders, and updates
  manifest and registry entries with `skill_class`, strict placeholders, and optional
  composition metadata. Supports checkpoint/resume for interrupted sessions.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-01-20"
  updated: "2026-02-10"
skill_sets: [executor]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/capabilities/runtime/skills/*) Write(_ops/state/runs/*) Write(_ops/state/logs/*) Bash(mkdir) Bash(ln) Bash(cp)
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

1. **Validate** — Check name format, verify uniqueness, resolve target `group`, and run alignment-first gate
2. **Copy Template** — Create directory structure from `_scaffold/template/`
3. **Initialize** — Replace placeholders with skill name and dates
4. **Update Registry** — Add entries to manifest.yml and registry.yml, including `skill_class`
5. **Validate** — Run contract validation and refresh harness links if needed
6. **Report Success** — Confirm creation and provide next steps

## Alignment-First Rule

Before scaffolding or updating registries, record one decision:

- `aligned` — skill can be implemented with existing contracts
- `extension-proposed` — current contracts are insufficient and extension artifacts are prepared

If `extension-proposed`, do not proceed with ad hoc schema changes. Escalate with:

- Deviation note (why existing contracts are insufficient)
- Proposed contract delta
- Required synchronized updates (docs, templates, validation)
- Migration impact (if any)

## Parameters

Parameters are defined in `.octon/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts required `skill_name` and `group` parameters plus optional parameters for description, skill_sets, and capabilities.

## Output Location

Output paths are defined in `.octon/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to:
- `.octon/capabilities/runtime/skills/<group>/{{skill_name}}/` — The new skill directory (deliverable)
- `_ops/state/runs/create-skill/{{run_id}}/` — Execution state (checkpoint and summary) for session recovery
- `_ops/state/logs/create-skill/` — Execution logs with index

## Naming Convention

**Use action-oriented names** following the verb-noun pattern:

| Pattern | Good Examples | Bad Examples |
|---------|---------------|--------------|
| verb-noun | `refine-prompt`, `build-mcp-server` | `prompt-refiner`, `report-generator` |
| verb-object | `audit-migration`, `resolve-pr-comments` | `codebase-analyzer`, `payment-processor` |

**Verb vocabulary:** See [Verb Vocabulary](/.octon/capabilities/practices/design-conventions.md#verb-vocabulary) for the full list with semantic definitions, boundaries, and retired verbs.

**Key distinctions:**
- `create` (scaffold from template) vs `build` (end-to-end construction)
- `audit` (compliance violations) vs `evaluate` (quality scoring)
- `refine` (improve one input) vs `synthesize` (combine many inputs)

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
- `skill_class` is present in manifest and placeholders resolve cleanly

## Boundaries

- Never overwrite existing skills without explicit confirmation
- Write only to designated paths (`.octon/capabilities/runtime/skills/`, outputs, logs)
- Always validate name format before any file operations
- Always check uniqueness before proceeding

## When to Escalate

- Skill with same name already exists — Ask user for confirmation or new name
- Requested `group` is not one of the canonical skill groups — Report error with valid options
- Name format validation fails — Report error with corrective guidance
- Template directory missing — Report error, cannot proceed
- Registry file malformed — Report error, request manual intervention
- Requested behavior does not fit existing contracts — Create extension proposal before implementation

## References

For detailed documentation:

- [Behavior phases](references/phases.md) — Full phase-by-phase instructions
- [I/O contract](references/io-contract.md) — Inputs, outputs, dependencies
- [Safety policies](references/safety.md) — Tool policies, boundaries
- [Validation](references/validation.md) — Acceptance criteria, verification
- [Examples](references/examples.md) — Full creation examples
