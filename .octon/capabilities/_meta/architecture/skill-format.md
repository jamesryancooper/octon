---
title: Skill Format
description: SKILL.md structure, naming conventions, and frontmatter requirements.
---

# Skill Format

Every skill requires a `SKILL.md` file with YAML frontmatter and Markdown body. This is the only **required** file per the [agentskills.io specification](https://agentskills.io/specification).

---

## Naming Convention

Skills use **action-oriented names** following the verb-noun pattern per the [agentskills.io specification](https://agentskills.io/specification):

| Pattern | Good Examples | Bad Examples |
|---------|---------------|--------------|
| verb-noun | `refine-prompt`, `generate-report` | `prompt-refiner`, `report-generator` |
| verb-object | `analyze-codebase`, `process-payment` | `codebase-analyzer`, `payment-processor` |

### Spec Requirements

| Constraint | Rule |
|------------|------|
| Length | 1-64 characters |
| Characters | Lowercase letters, numbers, and hyphens only |
| Hyphens | Must not start/end with hyphen |
| Consecutive | Must not contain consecutive hyphens (`--`) |
| Directory match | **Must match the manifest `id`; grouped directories are allowed** |

### Valid Examples

```yaml
name: refine-prompt
name: data-analysis
name: code-review
```

### Invalid Examples

```yaml
name: PDF-Processing          # uppercase not allowed
name: -refine-prompt          # cannot start with hyphen
name: refine--prompt          # consecutive hyphens not allowed
```

---

## Required Frontmatter

```yaml
---
name: refine-prompt
description: >
  Transforms rough prompts into clear, actionable instructions
  with codebase context. Use when prompts are vague or need
  grounding in specific files and patterns.
---
```

| Field | Constraints | Purpose |
|-------|-------------|---------|
| `name` | 1-64 chars, lowercase + hyphens, **must match manifest `id`** | Identifies the skill |
| `description` | 1-1024 chars | What it does and when to use it (helps agents match tasks) |

---

## Optional Frontmatter

```yaml
---
name: refine-prompt
description: >
  Transforms rough prompts into clear, actionable instructions...
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2025-01-14"
  updated: "2025-01-15"
allowed-tools: Read Glob Grep Write(../prompts/*) Write(_ops/state/logs/*)
---
```

| Field | Constraints | Purpose |
|-------|-------------|---------|
| `license` | License name or reference | Legal terms for the skill |
| `compatibility` | Max 500 chars | Environment requirements (product, system packages, network) |
| `metadata` | Key-value mapping | Author, dates, custom fields |
| `allowed-tools` | Space-delimited list | Pre-approved tools (experimental) |

> **Note:** The authoritative `version` is defined in `.octon/capabilities/runtime/skills/registry.yml`, not in SKILL.md metadata. This prevents version drift between files. See [Specification](./specification.md#manifest-and-registry-files) for the single source of truth principle.

---

## Body Content

The Markdown body follows the frontmatter and contains skill instructions. Per the spec, keep the body under **500 lines** and move detailed content to `references/` files.

### Recommended Structure

```markdown
# Skill Name

[One sentence describing the skill's value]

## When to Use
- [Trigger condition 1]
- [Trigger condition 2]

## Quick Start
/skill-name "[input]"

## Core Workflow
1. **Phase 1** - [Description]
2. **Phase 2** - [Description]

## Parameters
| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|

## Output Location
- **Deliverables:** `.octon/{{category}}/{{timestamp}}-{{name}}.md`
- **Run logs:** `_ops/state/logs/{{skill-id}}/{{run-id}}.md`

## Boundaries
- [Constraints]

## When to Escalate
- [Conditions]

## References
- `references/phases.md`
- `references/io-contract.md`
- `references/safety.md`
- `references/examples.md`
- `references/validation.md`
```

---

## Directory Structure

A complete skill directory:

```markdown
<skill-name>/
├── SKILL.md              # Required: core instructions (<500 lines)
├── references/           # Optional: progressive disclosure
│   ├── io-contract.md    # Inputs, outputs, dependencies, command-line usage
│   ├── safety.md         # Tool and file policies
│   ├── examples.md       # Full worked examples
│   ├── phases.md         # Phase-by-phase execution
│   └── validation.md     # Acceptance criteria
├── scripts/              # Optional: executable code
└── assets/               # Optional: static resources
```

**Note:** Commands and triggers are defined in `manifest.yml` and `registry.yml` at the skill collection level, not in individual reference files.

---

## See Also

- [Reference Artifacts](./reference-artifacts.md) — Detailed reference file documentation
- [Creation](./creation.md) — Creating new skills
- [agentskills.io/specification](https://agentskills.io/specification) — Official format specification
