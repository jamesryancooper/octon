---
title: Workspace Skills
description: Two-tier skills architecture following the agentskills.io specification.
---

# Workspace Skills

Skills are **composable capability units** following the [agentskills.io](https://agentskills.io) specification. This workspace implements a **two-tier architecture** that separates shared skill definitions (`.harmony/skills/`) from project-specific I/O configuration (`.workspace/skills/`).

---

## What is a Skill

Per the [agentskills.io specification](https://agentskills.io/what-are-skills), a skill is a folder containing a `SKILL.md` file with metadata and instructions that tell agents how to perform specific tasks. Skills provide:

- **Procedural knowledge** — Step-by-step instructions for complex tasks
- **Defined I/O contracts** — Clear inputs, outputs, and dependencies
- **Progressive disclosure** — Metadata for routing, full instructions on demand
- **Auditable execution** — Run logs for every invocation
- **Portability** — Skills are just files, easy to edit, version, and share

---

## Two-Tier Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  .harmony/skills/              TIER 1: Shared Foundation        │
│  ├── registry.yml              Skill catalog for routing        │
│  ├── _template/                Scaffolding for new skills       │
│  ├── refine-prompt/            Shared skill definition          │
│  │   ├── SKILL.md              Core instructions (<500 lines)   │
│  │   └── references/           Progressive disclosure content   │
│  └── research-synthesizer/                                      │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 │ I/O paths defined in
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│  .workspace/skills/            TIER 2: Project I/O              │
│  ├── registry.yml              I/O mappings, local skills       │
│  ├── outputs/                  Skill-generated files            │
│  │   ├── prompts/                                               │
│  │   ├── drafts/                                                │
│  │   └── ...                                                    │
│  ├── logs/runs/                Execution audit logs             │
│  └── sources/                  Input files                      │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 │ exposed via symlinks
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│  Host Adapters                 TIER 3: Agent Access             │
│  .claude/skills/   .cursor/skills/   .codex/skills/             │
└─────────────────────────────────────────────────────────────────┘
```

### Tier 1: Shared Foundation (`.harmony/skills/`)

Portable skill definitions that work across projects:

| Content | Purpose |
|---------|---------|
| `registry.yml` | Skill metadata for routing (no project-specific paths) |
| `_template/` | Scaffolding for new skills |
| `<skill-name>/SKILL.md` | Core skill instructions (required) |
| `<skill-name>/references/` | Detailed documentation (progressive disclosure) |
| `<skill-name>/scripts/` | Executable helpers (optional) |
| `<skill-name>/assets/` | Static resources (optional) |

### Tier 2: Project I/O (`.workspace/skills/`)

Project-specific configuration and outputs:

| Content | Purpose |
|---------|---------|
| `registry.yml` | Extends shared registry, adds I/O path mappings |
| `outputs/` | Skill-generated files |
| `logs/runs/` | Execution audit logs |
| `sources/` | Input files for skills |

### Tier 3: Host Adapters (Symlinks)

Symlinks expose shared skills to different agent hosts:

```bash
.claude/skills/refine-prompt -> ../../.harmony/skills/refine-prompt
.cursor/skills/refine-prompt -> ../../.harmony/skills/refine-prompt
.codex/skills/refine-prompt  -> ../../.harmony/skills/refine-prompt
```

**Setup:** Run `.harmony/skills/scripts/setup-harness-links.sh` to create symlinks, or create them manually:

```bash
# Manual symlink creation
mkdir -p .claude/skills .cursor/skills .codex/skills

# Link a skill to all harnesses
ln -s ../../.harmony/skills/refine-prompt .claude/skills/refine-prompt
ln -s ../../.harmony/skills/refine-prompt .cursor/skills/refine-prompt
ln -s ../../.harmony/skills/refine-prompt .codex/skills/refine-prompt
```

**Why symlinks?** Agent products discover skills in their own directories (`.claude/skills/`, `.cursor/skills/`, etc.). Symlinks allow multiple agents to share the same canonical skill definition while maintaining expected directory structures.

---

## Naming Convention

Skills use **action-oriented names** following the verb-noun pattern per the [agentskills.io specification](https://agentskills.io/specification):

| Pattern | Good Examples | Bad Examples |
|---------|---------------|--------------|
| verb-noun | `refine-prompt`, `generate-report` | `prompt-refiner`, `report-generator` |
| verb-object | `analyze-codebase`, `process-payment` | `codebase-analyzer`, `payment-processor` |

**Spec Requirements:**

| Constraint | Rule |
|------------|------|
| Length | 1-64 characters |
| Characters | Lowercase letters, numbers, and hyphens only |
| Hyphens | Must not start/end with hyphen |
| Consecutive | Must not contain consecutive hyphens (`--`) |
| Directory match | **Must match the parent directory name exactly** |

**Valid:**

```yaml
name: refine-prompt
name: data-analysis
name: code-review
```

**Invalid:**

```yaml
name: PDF-Processing          # uppercase not allowed
name: -refine-prompt          # cannot start with hyphen
name: refine--prompt          # consecutive hyphens not allowed
```

---

## SKILL.md Format

Every skill requires a `SKILL.md` file with YAML frontmatter and Markdown body. This is the only **required** file per the [agentskills.io specification](https://agentskills.io/specification).

### Required Frontmatter

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
| `name` | 1-64 chars, lowercase + hyphens, **must match directory name** | Identifies the skill |
| `description` | 1-1024 chars | What it does and when to use it (helps agents match tasks) |

### Optional Frontmatter

```yaml
---
name: refine-prompt
description: >
  Transforms rough prompts into clear, actionable instructions...
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Harmony Framework
  version: "2.1.1"
  created: "2025-01-14"
  updated: "2025-01-15"
allowed-tools: Read Glob Grep Write(outputs/*) Write(logs/*)
---
```

| Field | Constraints | Purpose |
|-------|-------------|---------|
| `license` | License name or reference | Legal terms for the skill |
| `compatibility` | Max 500 chars | Environment requirements (product, system packages, network) |
| `metadata` | Key-value mapping | Author, version, dates, custom fields |
| `allowed-tools` | Space-delimited list | Pre-approved tools (experimental) |

### Body Content

The Markdown body follows the frontmatter and contains skill instructions. Per the spec, keep the body under **500 lines** and move detailed content to `references/` files.

**Recommended structure:**

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
- **Results:** `outputs/[category]/<timestamp>-[name].md`
- **Run logs:** `logs/runs/<timestamp>-skill-name.md`

## Boundaries
- [Constraints]

## When to Escalate
- [Conditions]

## References
- [Behavior phases](references/behaviors.md)
- [Invocation patterns](references/triggers.md)
- [I/O contract](references/io-contract.md)
- [Safety policies](references/safety.md)
- [Examples](references/examples.md)
- [Validation](references/validation.md)
```

---

## Reference Artifacts

Reference files in the `references/` directory provide **progressive disclosure** — detailed content loaded only when needed. Each reference file has **YAML frontmatter** for machine parsing and a **Markdown body** for human reading.

### Directory Structure

```
<skill-name>/
├── SKILL.md              # Required: core instructions
├── references/           # Optional: progressive disclosure
│   ├── behaviors.md      # Detailed phase-by-phase behavior
│   ├── triggers.md       # Commands, triggers, invocation patterns
│   ├── io-contract.md    # Inputs, outputs, dependencies
│   ├── safety.md         # Tool and file policies
│   ├── examples.md       # Full worked examples
│   └── validation.md     # Acceptance criteria
├── scripts/              # Optional: executable code
└── assets/               # Optional: static resources
```

### Reference File Format

Each reference file follows this pattern:

```markdown
---
# YAML frontmatter for machine parsing
field: value
nested:
  - item1
  - item2
---

# Human-Readable Title

Prose explanation of the content.

## Section 1
...
```

The YAML frontmatter provides structured data that agents can parse programmatically, while the Markdown body provides human-readable documentation.

### Reference File Schemas

#### `triggers.md`

Defines how the skill can be invoked:

```yaml
---
commands:
  - /refine-prompt

explicit_call_patterns:
  - "use skill: refine-prompt"

triggers:
  - "refine my prompt"
  - "improve this prompt"
  - "expand this prompt"
---

# Invocation Reference

How to invoke the refine-prompt skill.

## Commands
- `/refine-prompt` - Primary command invocation

## Natural Language Triggers
The skill activates on phrases like:
- "refine my prompt"
- "improve this prompt"
```

#### `io-contract.md`

Defines inputs, outputs, and dependencies:

```yaml
---
inputs:
  - name: raw_prompt
    type: text
    required: true
    path_hint: "inline text or file path"
    description: "The raw prompt text to refine"

outputs:
  - name: refined_prompt
    type: markdown
    path: "outputs/prompts/<timestamp>-refined.md"
    format: "markdown"
    determinism: "stable"

requires:
  tools:
    - filesystem.read
    - filesystem.write.outputs
  packages: []
  services: []

depends_on: []
---

# I/O Contract Reference

## Inputs
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `raw_prompt` | text | Yes | The raw prompt to refine |
```

#### `safety.md`

Defines tool and file policies:

```yaml
---
safety:
  tool_policy:
    mode: deny-by-default
    allowed:
      - filesystem.read
      - filesystem.write.outputs
  file_policy:
    write_scope:
      - ".workspace/skills/outputs/**"
      - ".workspace/skills/logs/**"
    destructive_actions: never
---

# Safety Reference

## Tool Policy
**Mode:** Deny-by-default

Only the following tools are permitted:
| Tool | Purpose |
|------|---------|
| `filesystem.read` | Read codebase files for context |
| `filesystem.write.outputs` | Write to output directories |
```

#### `behaviors.md`

Defines phase-by-phase execution:

```yaml
---
behavior:
  phases:
    - name: "Context Analysis"
      steps:
        - "Analyze repository structure"
        - "Find relevant files"
    - name: "Output"
      steps:
        - "Save to outputs/"
        - "Log to logs/runs/"
  goals:
    - "Primary goal"
    - "Secondary goal"
---

# Behavior Reference

## Phase 1: Context Analysis
...
```

#### `validation.md`

Defines acceptance criteria:

```yaml
---
acceptance_criteria:
  - "Output exists in outputs/"
  - "All required sections present"
  - "Run log captures execution"
---

# Validation Reference

## Acceptance Criteria
- [ ] Output file created in `outputs/`
- [ ] All required sections present
```

#### `examples.md`

Provides full worked examples:

```yaml
---
examples:
  - input: "add caching to the api"
    invocation: "/refine-prompt 'add caching to the api'"
    output: "outputs/prompts/20250115-refined.md"
    description: "Basic prompt refinement"
---

# Examples Reference

## Example 1: API Caching

### Input
/refine-prompt "add caching to the api"

### Output
[Full example output...]
```

---

## Progressive Disclosure

Skills follow a **three-tier disclosure model** for token efficiency, as defined in the [agentskills.io specification](https://agentskills.io/what-are-skills):

| Tier | Content | When Loaded | Token Budget |
|------|---------|-------------|--------------|
| **Tier 1** | `name` + `description` (from registry or frontmatter) | Always (routing/discovery) | ~100 tokens |
| **Tier 2** | Full `SKILL.md` body | When skill activated | <5000 tokens |
| **Tier 3** | `references/`, `scripts/`, `assets/` | When specific detail needed | On demand |

### Loading Sequence

1. **Discovery** — Agent scans skill directories, parses frontmatter only
2. **Matching** — Agent matches user task to skill descriptions
3. **Activation** — User invokes skill (explicit or trigger), agent loads full `SKILL.md`
4. **Detail** — Agent loads reference files only when specific information needed

This approach keeps agents fast while giving them access to more context on demand.

---

## Registry Format

### Shared Registry (`.harmony/skills/registry.yml`)

Contains skill metadata for routing **without** project-specific I/O paths:

```yaml
# Skills Registry (Shared Foundation)
schema_version: "1.1"
default: null

routing:
  explicit_command_required: false
  ambiguity_resolution: "ask"  # ask | first_match | most_specific

skills:
  - id: refine-prompt
    name: Refine Prompt
    path: refine-prompt/
    version: "2.1.1"
    summary: "Transform rough prompts into clear, actionable instructions."
    commands:
      - /refine-prompt
    explicit_call_patterns:
      - "use skill: refine-prompt"
    triggers:
      - "refine my prompt"
      - "improve this prompt"
    requires:
      tools:
        - filesystem.read
        - filesystem.write.outputs
    depends_on: []
```

### Project Registry (`.workspace/skills/registry.yml`)

Extends the shared registry with project-specific I/O mappings:

```yaml
# Skills Registry (Project-Specific)
schema_version: "1.1"
extends: "../../.harmony/skills/registry.yml"
default: null

# Project-specific I/O mappings for inherited skills
skill_mappings:
  research-synthesizer:
    inputs:
      - path: "projects/<project>/"
        type: folder
    outputs:
      - path: "outputs/drafts/<topic>-synthesis.md"
        type: markdown
        determinism: stable

# Project-specific skills (not in .harmony/)
skills: []

# Project-specific pipelines
pipelines:
  - id: research-synthesis
    name: Research Synthesis Pipeline
    steps:
      - research-synthesizer
```

---

## Creating a Skill

Use the `/create-skill` workflow (`.harmony/workflows/skills/create-skill/`):

```text
/create-skill <skill-name>
```

### Workflow Steps

The workflow is defined in `.harmony/workflows/skills/create-skill/` and consists of:

| Step | File | Purpose |
|------|------|---------|
| 1 | `01-validate-name.md` | Check format, action-oriented naming, uniqueness |
| 2 | `02-copy-template.md` | Copy `_template/` to `skills/<skill-name>/` |
| 3 | `03-initialize-skill.md` | Update placeholders with skill name |
| 4 | `04-update-registry.md` | Add entry to `registry.yml` |
| 5 | `05-update-catalog.md` | Add to skills table in documentation |
| 6 | `06-report-success.md` | Confirm and show next steps |

### Output Structure

A new skill directory following the agentskills.io spec:

```text
.harmony/skills/<skill-name>/
├── SKILL.md              # Core definition (<500 lines)
├── references/           # Progressive disclosure
│   ├── behaviors.md
│   ├── triggers.md
│   ├── io-contract.md
│   ├── safety.md
│   ├── examples.md
│   └── validation.md
├── scripts/              # Executable code (optional)
└── assets/               # Static resources (optional)

# Plus symlinks in harness folders:
.claude/skills/<skill-name> -> ../../.harmony/skills/<skill-name>
.cursor/skills/<skill-name> -> ../../.harmony/skills/<skill-name>
.codex/skills/<skill-name> -> ../../.harmony/skills/<skill-name>
```

### Post-Creation Steps

1. **Edit `SKILL.md`** — Add description, workflow, parameters
2. **Edit reference files** — Add YAML frontmatter and detailed content
3. **Update shared registry** — Add triggers for routing in `.harmony/skills/registry.yml`
4. **Add project mappings** — Define I/O paths in `.workspace/skills/registry.yml`
5. **Create symlinks** — Run setup script or manually create host adapter symlinks
6. **Test** — Run `/<skill-name> [input]`

---

## Invocation

### Explicit Commands (Recommended)

```text
/refine-prompt "add caching to the api"
```

### Explicit Pattern

```text
use skill: refine-prompt
```

### Trigger Matching

```text
"refine my prompt"
→ Matches trigger in registry
→ Routes to refine-prompt skill
```

### Routing Rules

1. Read `.harmony/skills/registry.yml` for shared skills
2. Read `.workspace/skills/registry.yml` for project mappings
3. If explicit command (`/skill-name`), route directly
4. If `use skill: <name>` pattern, route directly
5. Otherwise, match against triggers
6. If ambiguous, use `ambiguity_resolution` setting (default: ask one clarifying question)

---

## Run Logging

Every skill execution produces a log at `.workspace/skills/logs/runs/`:

```markdown
---
run_id: 2025-01-15T10-31-00Z-refine-prompt
skill_id: refine-prompt
skill_version: "2.1.1"
status: success  # success | partial | failed
started_at: 2025-01-15T10:31:00Z
ended_at: 2025-01-15T10:44:12Z

inputs:
  - "add caching to the api"
outputs:
  - .workspace/skills/outputs/prompts/20250115-refined.md
tools_used:
  - filesystem.read
  - filesystem.write.outputs
---

## Summary
- Refined prompt with codebase context
- Assigned Senior Backend Engineer persona

## Notes
- Flagged 2 ambiguities for user review
```

---

## Safety Policies

Skills follow a **deny-by-default** tool policy:

### Tool Policy

| Level | Tools Allowed |
|-------|---------------|
| Read-only | `filesystem.read`, `filesystem.glob`, `filesystem.grep` |
| Write (scoped) | `filesystem.write.outputs`, `filesystem.write.logs` |
| Never | `filesystem.delete`, `filesystem.write.*` (arbitrary paths) |

### File Policy

Skills may only write to designated paths:

| Path | Purpose |
|------|---------|
| `.workspace/skills/outputs/**` | Skill-generated artifacts |
| `.workspace/skills/logs/**` | Execution logs |

**Destructive actions:** Never permitted. Skills must not delete files or overwrite source code.

---

## Skills vs Other Artifact Types

| Aspect | Skill | Assistant | Workflow | Prompt |
|--------|-------|-----------|----------|--------|
| **Purpose** | Composable capability | Focused specialist | Multi-step procedure | Task template |
| **I/O contract** | Yes (typed paths) | No | No | No |
| **Composable** | Yes (pipelines) | No | Loosely | No |
| **Logging** | Required | No | No | No |
| **Invocation** | `/command` or explicit | `@mention` | Reference | Reference |

**Decision heuristic:**

- Need **composable operations** with defined I/O? → Skill
- Need a **focused specialist** for scoped tasks? → Assistant
- Need a **multi-step procedure** to follow? → Workflow
- Need a **judgment-based template**? → Prompt

---

## Spec Compliance

This implementation follows [agentskills.io/specification](https://agentskills.io/specification):

| Spec Requirement | Implementation |
|------------------|----------------|
| Required frontmatter: `name`, `description` | ✓ In `SKILL.md` |
| Optional: `license`, `compatibility`, `metadata`, `allowed-tools` | ✓ In `SKILL.md` |
| Directory structure: `references/`, `scripts/`, `assets/` | ✓ Per spec |
| `SKILL.md` < 500 lines | ✓ Details in `references/` |
| Name matches directory | ✓ Enforced by `create-skill` workflow |
| Progressive disclosure | ✓ Three-tier model |

### Extensions Beyond Spec

This implementation extends the base specification with:

| Extension | Purpose |
|-----------|---------|
| Two-tier architecture | Separate shared skills from project I/O |
| Registry files | Centralized routing metadata for multiple skills |
| Reference file schemas | Standardized YAML frontmatter for machine parsing |
| Host adapter symlinks | Multi-agent discovery from single source |
| Pipelines | Compose multiple skills in sequence |
| Run logging | Auditable execution history |

---

## Validation

Use the [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) reference library to validate skills:

```bash
# Validate a skill directory
skills-ref validate ./path/to/skill

# Generate XML for agent prompts
skills-ref to-prompt ./path/to/skill
```

---

## See Also

- [agentskills.io](https://agentskills.io) — Official specification
- [agentskills.io/specification](https://agentskills.io/specification) — Full format specification
- [agentskills.io/integrate-skills](https://agentskills.io/integrate-skills) — Agent integration guide
- `.harmony/skills/refine-prompt/` — Example skill implementation
- `.harmony/skills/_template/` — Skill template
- `.harmony/workflows/skills/create-skill/` — Skill creation workflow
- `.harmony/skills/registry.yml` — Shared skill registry
- `.workspace/skills/registry.yml` — Project I/O mappings
- [Assistants](./assistants.md) — Focused specialists
- [Workflows](./workflows.md) — Multi-step procedures
- [Taxonomy](./taxonomy.md) — Artifact type classification
