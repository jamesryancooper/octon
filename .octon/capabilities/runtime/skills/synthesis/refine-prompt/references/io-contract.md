---
# I/O Contract Documentation
# This file provides extended documentation for human reference.
#
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Parameters: .octon/capabilities/runtime/skills/registry.yml
#   - Output paths: .octon/capabilities/runtime/skills/registry.yml
#
# Current allowed-tools: Read Glob Grep Write(../../scaffolding/practices/prompts/*) Write(_ops/state/logs/*)
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# I/O Contract Reference

Extended input/output documentation for the refine-prompt skill.

> **Authoritative Sources:**
>
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Parameters: `.octon/capabilities/runtime/skills/registry.yml`
> - Output paths: `.octon/capabilities/runtime/skills/registry.yml`

## Context Depth Levels

The `context_depth` parameter controls how deeply the skill analyzes the repository:

| Level | Behavior |
|-------|----------|
| `minimal` | Scan immediate directory, check for README/package.json only |
| `standard` | Scan relevant directories, identify key files, patterns |
| `deep` | Full codebase analysis, dependency graph, cross-module patterns |

## Parameter Summary

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `raw_prompt` | text | Yes | - | Raw prompt text to refine (inline or file path) |
| `execute` | boolean | No | `false` | Execute the refined prompt after generation |
| `context_depth` | text | No | `standard` | Repository analysis depth (`minimal`, `standard`, `deep`) |
| `skip_confirmation` | boolean | No | `false` | Skip the intent confirmation step |

## Output Format

The refined prompt follows this structure:

```markdown
# Refined Prompt

**Original:** {{original_prompt}}
**Refined:** {{timestamp}}
**Context Depth:** {{minimal/standard/deep}}
**Status:** {{confirmed/pending confirmation}}

---

## Execution Persona
{{Role, expertise level, perspective, style}}

## Repository Context
{{Tech stack, relevant modules, files in scope, patterns to follow}}

## Intent
{{Clear statement of what to accomplish}}

## Requirements
{{Explicit numbered requirements}}

## Assumptions Made
{{Listed assumptions with reasoning}}

## Negative Constraints (What NOT To Do)
{{Anti-patterns, forbidden approaches, out of scope items}}

## Sub-Tasks
{{Decomposed tasks with dependencies}}

## Risks & Edge Cases
{{Identified risks and edge cases to handle}}

## Success Criteria
{{Measurable completion criteria}}

## Self-Critique Results
{{Completeness, ambiguity, feasibility, quality checks}}

## Intent Confirmation
{{Summary, key decisions, user response}}

## Refined Prompt
{{The actual refined prompt text, self-contained}}
```

## Dependencies

Tool requirements are defined in SKILL.md `allowed-tools` frontmatter (single source of truth).

No external dependencies required. Works with any codebase structure.

---

## Command-Line Usage

### Basic Invocation

```bash
/refine-prompt "add caching to the api"
```

### With Options

```bash
# Deep context analysis
/refine-prompt "refactor the auth module" --context_depth=deep

# Execute after refinement
/refine-prompt "add caching" --execute

# Skip confirmation step
/refine-prompt "quick fix" --skip_confirmation=true

# Combined options
/refine-prompt "major refactor" --context_depth=deep --execute
```

### From File

```bash
/refine-prompt path/to/rough-prompt.txt
/refine-prompt path/to/prompt.txt --context_depth=standard
```
