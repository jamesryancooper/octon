# Workspace Skills

Composable capabilities with defined I/O contracts and progressive disclosure.

## Quick Start

**Invoke a skill:**

```text
/use-skill <skill-id> [input-path]
```

**Or use skill-specific commands:**

```text
/synthesize-research sources/topic/
```

**Or explicit call pattern:**

```text
use skill: research-synthesizer
```

**List available skills:**
Check `registry.yml` or the Skills section in `.workspace/catalog.md`.

## Directory Structure

```text
skills/
├── registry.yml           # Skill catalog (read first)
├── _template/
│   ├── SKILL.md           # Template for new skills
│   └── scripts/           # Template for executable helpers
├── <skill-id>/
│   ├── SKILL.md           # Skill definition
│   ├── templates/         # Skill-specific templates (optional)
│   ├── reference/         # Detailed reference material (optional)
│   └── scripts/           # Executable helpers (optional)
├── sources/               # Standard input folder
├── outputs/
│   ├── drafts/            # Initial outputs
│   ├── refined/           # Processed outputs
│   ├── html/              # HTML outputs
│   ├── social/            # Social media outputs
│   └── assets/            # Generated assets
└── logs/
    └── runs/              # Execution logs
```

## Progressive Disclosure

Skills follow a three-tier loading model:

1. **Tier 1 (always):** `registry.yml` - compact catalog for routing
2. **Tier 2 (on demand):** `<skill-id>/SKILL.md` - full instructions
3. **Tier 3 (rare):** `reference/`, `templates/`, `scripts/` - deep resources

**Rule:** Read `registry.yml` first. Load SKILL.md only when needed.

## Skill Schema

Skills use YAML frontmatter with these fields:

```yaml
---
# Identity
id: "skill-id"           # Stable kebab-case identifier
name: "Skill Name"       # Human-readable name
version: "1.0.0"         # Semantic version
summary: "..."           # One-line routing hint
description: "..."       # Longer description with usage context

# Provenance
author:
  name: "Author"
  contact: "email/handle"
created_at: "YYYY-MM-DD"
updated_at: "YYYY-MM-DD"
license: "MIT"

# Invocation
commands: [/command]
explicit_call_patterns: ["use skill: skill-id"]
triggers: ["natural language"]

# I/O Contract
inputs:
  - name: input_name
    type: file|text|folder|glob|json|yaml
    required: true
    path_hint: "sources/..."
outputs:
  - name: output_name
    type: markdown|html|json|images|audio|log
    path: "outputs/..."
    format: "markdown"
    determinism: stable|variable|non-deterministic

# Dependencies
requires:
  tools: [filesystem.read, web.search, shell, http.fetch]
  packages: []
  services: []
depends_on: [other-skill-ids]

# Safety
safety:
  tool_policy:
    mode: deny-by-default
    allowed: [...]
  file_policy:
    write_scope: [".workspace/skills/outputs/**"]
    destructive_actions: never

# Behavior
behavior:
  goals: ["..."]
  steps: ["..."]

# Validation
acceptance_criteria: ["..."]

# Examples
examples:
  - input: "..."
    invocation: "/command args"
    output: "outputs/..."
    description: "..."
---
```

## Creating a Skill

**Via command:**

```text
/create-skill <skill-id>
```

**Manually:**

1. Copy `_template/` to `<skill-id>/`
2. Update `SKILL.md` with definition
3. Add entry to `registry.yml`
4. Update `.workspace/catalog.md` skills table
5. Run `./scripts/setup-harness-links.sh <skill-id>` to create harness symlinks

## Harness Distribution

Skills are distributed to agent harnesses via symlinks:

```text
.workspace/skills/                      # Source of truth
├── research-synthesizer/
│   └── SKILL.md

.claude/skills/                         # Claude Code
└── research-synthesizer -> ../../.workspace/skills/research-synthesizer

.cursor/skills/                         # Cursor
└── research-synthesizer -> ../../.workspace/skills/research-synthesizer

.codex/skills/                          # OpenAI Codex
└── research-synthesizer -> ../../.workspace/skills/research-synthesizer
```

**Setup all links:**

```bash
./scripts/setup-harness-links.sh
```

**Setup single skill:**

```bash
./scripts/setup-harness-links.sh <skill-id>
```

**Why symlinks?**

- Single source of truth (no drift)
- Zero duplication
- Changes propagate automatically
- All harnesses see the same skill definition

**Compatibility:**

- Uses uppercase `SKILL.md` per Agent Skills standard
- Works with Claude Code, Cursor, Codex, and other compliant harnesses

## Skill Pipelines

Skills compose via outputs becoming inputs:

```text
skill-1 (outputs/drafts/) → skill-2 (outputs/refined/) → skill-3 (outputs/html/)
```

Define common pipelines in `registry.yml` for discoverability.

## Run Logging

Every skill execution produces a log at:

```text
logs/runs/<timestamp>-<skill-id>.md
```

Log format:

```yaml
---
run_id: 2025-01-12T10-31-00Z-skill-id
skill_id: skill-id
skill_version: "1.0.0"
status: success  # success | partial | failed
started_at: 2025-01-12T10:31:00Z
ended_at: 2025-01-12T10:44:12Z
inputs: [list of input paths]
outputs: [list of output paths]
tools_used: [list of tools]
external_calls:
  - type: web.search
    purpose: "verify dates"
  - type: http.fetch
    purpose: "retrieve resource"
---

## Summary
- What was done

## Notes
- Any issues or decisions made
```

## Safety

Skills declare safety constraints in frontmatter:

- **tool_policy:** Capabilities the skill may use (deny-by-default)
- **file_policy:** Where the skill may write (scoped to outputs/)

Default: `deny-by-default` with explicit allowlist.

## See Also

- [Skills Documentation](../../docs/architecture/workspaces/skills.md)
- [Taxonomy](../../docs/architecture/workspaces/taxonomy.md)
- [Catalog](./../catalog.md)
