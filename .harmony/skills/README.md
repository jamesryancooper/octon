# Workspace Skills

Composable capabilities with defined I/O contracts and progressive disclosure.

For full documentation, see [docs/architecture/workspaces/skills/](../../docs/architecture/workspaces/skills/README.md).

---

## Quick Create Checklist

Creating a new skill requires updating **4 files** across **2 locations**. Use this checklist to avoid missing steps.

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│  SKILL CREATION CHECKLIST                                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. SKILL DEFINITION (.harmony/skills/<skill-id>/)                          │
│     □ Copy _template/ to <skill-id>/                                        │
│     □ Edit SKILL.md:                                                        │
│       - Set `name:` to match directory name (kebab-case)                    │
│       - Write `description:` (1-1024 chars, include keywords)               │
│       - Set `allowed-tools:` (single source of truth for permissions)       │
│       - Replace all {{placeholders}} with actual content                    │
│     □ Choose archetype: Utility (no refs) / Workflow (5+ refs)              │
│                                                                             │
│  2. SHARED MANIFEST (.harmony/skills/manifest.yml)                          │
│     □ Add skill entry under `skills:`:                                      │
│       - id: <skill-id>           # Must match directory and SKILL.md name   │
│       - display_name: <Title Case>  # e.g., "Synthesize Research"           │
│       - path: <skill-id>/                                                   │
│       - summary: "<one-line description>"                                   │
│       - status: experimental | active | deprecated                          │
│       - tags: [<tag1>, <tag2>]                                              │
│       - triggers: ["<trigger phrase 1>", "<trigger phrase 2>"]              │
│                                                                             │
│  3. SHARED REGISTRY (.harmony/skills/registry.yml)                          │
│     □ Add skill entry under `skills:`:                                      │
│       - version: "1.0.0"                                                    │
│       - commands: [/<skill-id>]                                             │
│       - parameters: [{name, type, required, description}]                   │
│       - requires.context: [{type, path, description}]                       │
│       - depends_on: []                                                      │
│                                                                             │
│  4. WORKSPACE REGISTRY (.workspace/skills/registry.yml)                     │
│     □ Add I/O mapping under `skill_mappings:`:                              │
│       - inputs: [{path, kind, required, description}]                       │
│       - outputs: [{name, path, kind, format, determinism, description}]     │
│                                                                             │
│  5. VALIDATE                                                                │
│     □ Run: ./scripts/validate-skills.sh <skill-id>                          │
│     □ Fix any errors or warnings                                            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Skill Archetypes** (choose based on complexity):

| Archetype                    | Reference Files                                            | When to Use                              |
|:-----------------------------|:-----------------------------------------------------------|:-----------------------------------------|
| **Utility**                  | None                                                       | Single-purpose, obvious I/O              |
| **Utility (with examples)**  | `examples.md` only                                         | Single-purpose, output needs demo        |
| **Workflow**                 | Core: io-contract, safety, examples, behaviors, validation | Multi-phase execution                    |
|                              | Optional: errors, glossary, `<domain>.md`                  | (add for specialized domains)            |

> **Design Note:** Archetypes are based on **documentation needs**, not execution type. Semantic categories like `validator`, `transformer`, or `generator` should use `tags` in manifest.yml for discovery and filtering. See [architecture.md](../../docs/architecture/workspaces/skills/architecture.md#why-documentation-based-archetypes) for the full rationale.

**Archetype Selection Matrix:**

| Question | Yes → | No → |
|----------|-------|------|
| Can you explain the skill in one sentence? | Consider Utility | Continue ↓ |
| Is the output format non-obvious or would examples help? | Utility (with examples) | Utility |
| Do phases need documentation for correct execution? | Workflow | Utility or Utility (with examples) |
| Are there safety boundaries or escalation rules? | Workflow | Utility or Utility (with examples) |
| Does the skill require domain-specific terminology? | Workflow + `glossary.md` | Workflow |
| Are there complex error recovery procedures? | Workflow + `errors.md` | Workflow |

**Decision Examples:**

- **Format JSON** → Utility (single-purpose, no phases, obvious I/O)
- **Summarize Text** → Utility (with examples) (single-purpose, but output format benefits from demonstration)
- **Refine Prompt** → Workflow (10 phases, context analysis, safety boundaries)
- **Financial Audit** → Workflow + optional files (terminology glossary, compliance rules, audit trail requirements)

The template includes **Workflow** archetype files. See [reference-artifacts.md](../../docs/architecture/workspaces/skills/reference-artifacts.md) for details.

**Quick command to scaffold and validate:**

```bash
# Copy template
cp -r .harmony/skills/_template .harmony/skills/<skill-id>

# Edit files (use your editor)
# Then validate
.harmony/skills/scripts/validate-skills.sh <skill-id>

# Use --fix to see scaffolding suggestions for missing entries
.harmony/skills/scripts/validate-skills.sh <skill-id> --fix
```

---

## Quick Start

**Invoke a skill:**

```text
/synthesize-research resources/synthesize-research/topic/
```

**Or explicit call pattern:**

```text
use skill: synthesize-research
```

**List available skills:** Check `manifest.yml` for the skill index.

## Directory Structure

```text
.harmony/skills/                    # Shared skill definitions
├── manifest.yml                    # Tier 1 discovery index
├── registry.yml                    # Extended metadata (version, commands, parameters)
├── _template/                      # Scaffolding for new skills
└── <skill-id>/SKILL.md             # Core instructions (<500 lines)

.workspace/skills/                  # Workspace-specific configuration
├── manifest.yml                    # Workspace-specific skills (extends shared)
├── registry.yml                    # I/O paths (single source of truth)
├── runs/                           # Execution state (checkpoints, manifests) for session recovery
└── logs/                           # Execution logs

.workspace/                          # Deliverables (final products)
├── prompts/                        # Refined prompts
├── drafts/                         # Synthesis documents
└── reports/                        # Analysis reports
```

## Architecture Diagram

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SKILLS ARCHITECTURE                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │  TIER 1: SHARED FOUNDATION (.harmony/skills/)                       │   │
│   │  ─────────────────────────────────────────────────────────────────  │   │
│   │  Portable skill definitions — logic, behaviors, instructions        │   │
│   │                                                                     │   │
│   │  manifest.yml ──────▶ Discovery index (id, summary, triggers)       │   │
│   │       │                      ~50 tokens/skill                       │   │
│   │       ▼                                                             │   │
│   │  registry.yml ──────▶ Extended metadata (commands, parameters)      │   │
│   │       │                      ~50 tokens/skill                       │   │
│   │       ▼                                                             │   │
│   │  {{skill}}/SKILL.md ──▶ Full instructions + allowed-tools           │   │
│   │       │                      <5000 tokens                           │   │
│   │       ▼                                                             │   │
│   │  {{skill}}/references/ ▶ Detailed docs, examples, scripts           │   │
│   │                              On demand                              │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    │ I/O paths defined in                   │
│                                    ▼                                        │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │  TIER 2: WORKSPACE CONFIG (.workspace/skills/)                      │   │
│   │  ─────────────────────────────────────────────────────────────────  │   │
│   │  Workspace-specific I/O — paths, outputs, logs                      │   │
│   │                                                                     │   │
│   │  registry.yml ──────▶ I/O mappings (inputs, outputs)                │   │
│   │       │                                                             │   │
│   │       ├──▶ runs/       Execution state (session recovery)            │   │
│   │       └──▶ logs/       Execution audit logs                         │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    │ exposed via symlinks                   │
│                                    ▼                                        │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │  HOST ADAPTERS (Agent Access Points)                                │   │
│   │  ─────────────────────────────────────────────────────────────────  │   │
│   │  .claude/skills/  .cursor/skills/  .codex/skills/                   │   │
│   │       ▲                ▲                 ▲                          │   │
│   │       └────────────────┴─────────────────┘                          │   │
│   │                   Symlinks to .harmony/skills/                      │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

DATA FLOW:
  Agent receives task
         │
         ▼
  Read manifest.yml ────────▶ Match skill by triggers/commands
         │
         ▼
  Read registry.yml ─────────▶ Get commands, parameters, context requirements
         │
         ▼
  Read SKILL.md ─────────────▶ Load full instructions + tool permissions
         │
         ▼
  Execute skill ─────────────▶ Write deliverables + runs/, log to logs/
```

## Single Source of Truth

| Metadata                                         | Source                                   |
|--------------------------------------------------|------------------------------------------|
| `name`, `description`                            | SKILL.md frontmatter                     |
| `allowed-tools` (tool permissions)               | SKILL.md frontmatter (**authoritative**) |
| `summary`, `triggers`, `tags`                    | `.harmony/skills/manifest.yml`           |
| `version`, `commands`, `parameters`, `depends_on`| `.harmony/skills/registry.yml`           |
| Input/output paths                               | `.workspace/skills/registry.yml`         |

**Tool Permissions:** `allowed-tools` in SKILL.md is the single source of truth. The internal format is derived via the mapping function in `validate-skills.sh`. See [specification.md](../../docs/architecture/workspaces/skills/specification.md) for details.

**Validation:** Run `./scripts/validate-skills.sh` to verify skill consistency.

**Token Validation:** For accurate token budget validation, install tiktoken:

```bash
pip install tiktoken
```

Without tiktoken, word count approximation is used (±20% variance). CI environments should install tiktoken for consistent validation.

## Creating a Skill

1. Copy `_template/` to `{{skill_id}}/`
2. Update `SKILL.md` frontmatter (`name` must match directory, set `allowed-tools`)
3. Replace all `{{placeholder}}` values with actual content
4. Add entry to `manifest.yml` (id, display_name, path, summary, triggers)
5. Add entry to `.harmony/skills/registry.yml` (version, commands, parameters)
6. Add entry to `.workspace/skills/registry.yml` (inputs, outputs)
7. Run `./scripts/validate-skills.sh {{skill_id}}` to verify consistency

**Validation Options:**

```bash
./scripts/validate-skills.sh              # Validate all skills
./scripts/validate-skills.sh my-skill     # Validate specific skill
./scripts/validate-skills.sh --fix        # Scaffold missing entries
./scripts/validate-skills.sh --strict     # Treat trigger duplicates as errors
```

## Host Adapter Symlinks

Skills are exposed to different AI agents (Claude, Cursor, Codex) via symlinks from their respective skills directories to the shared `.harmony/skills/` definitions. This allows multiple agents to share the same canonical skill definitions.

### Why Symlinks

Agent products discover skills in their own directories:

- `.claude/skills/` — Claude Code
- `.cursor/skills/` — Cursor
- `.codex/skills/` — Codex

Symlinks allow all agents to share the same skill definition without duplication.

### Setup

**Automatic setup (recommended):**

```bash
./scripts/setup-harness-links.sh
```

This creates symlinks for all skills in `.harmony/skills/` to each agent's skills directory.

**Manual setup:**

```bash
# Create directories
mkdir -p .claude/skills .cursor/skills .codex/skills

# Link a specific skill
ln -s ../../.harmony/skills/refine-prompt .claude/skills/refine-prompt
ln -s ../../.harmony/skills/refine-prompt .cursor/skills/refine-prompt
ln -s ../../.harmony/skills/refine-prompt .codex/skills/refine-prompt
```

**Link a single skill:**

```bash
./scripts/setup-harness-links.sh refine-prompt
```

### Troubleshooting

| Issue                 | Solution                                                         |
|-----------------------|------------------------------------------------------------------|
| Symlinks not working  | Ensure your filesystem supports symlinks (Windows may need admin)|
| Agent can't find skill| Run `setup-harness-links.sh` to recreate links                   |
| Wrong skill version   | Delete the symlink and recreate it                               |
| Permission denied     | Check file permissions on `.harmony/skills/`                     |

### Verification

Check current symlinks:

```bash
ls -la .claude/skills/
ls -la .cursor/skills/
ls -la .codex/skills/
```

## Harmony Extensions

Harmony extends the [agentskills.io specification](https://agentskills.io/specification) with additional fields for discovery, routing, and lifecycle management. The base spec requires only `name` and `description` in SKILL.md frontmatter.

### Manifest Extensions (`.harmony/skills/manifest.yml`)

| Field | Purpose | Example |
|-------|---------|---------|
| `display_name` | Human-readable title (Title Case) | `"Synthesize Research"` |
| `status` | Lifecycle state | `active`, `experimental`, `deprecated` |
| `tags` | Filtering and grouping labels | `[research, synthesis]` |
| `triggers` | Natural language phrases for intent matching | `["synthesize my research"]` |

### Registry Extensions (`.harmony/skills/registry.yml`)

| Field | Purpose | Example |
|-------|---------|---------|
| `version` | Semantic version string | `"1.0.0"` |
| `commands` | Slash commands that invoke the skill | `[/synthesize-research]` |
| `parameters` | Input parameters with types and defaults | See schema below |
| `requires.context` | Context conditions for activation | `[{type: directory_exists, path: ".workspace/"}]` |
| `depends_on` | Other skills this skill requires | `[]` |

**Parameter Schema:**

```yaml
parameters:
  - name: param_name        # Identifier
    type: text              # text | boolean | file | folder
    required: true          # true | false
    default: "value"        # Default (if not required)
    description: "..."      # Human-readable description
```

### Tool Permissions (SKILL.md `allowed-tools`)

The `allowed-tools` field in SKILL.md frontmatter is the **single source of truth** for tool permissions. Harmony extends the agentskills.io format with path scoping:

```yaml
allowed-tools: Read Glob Grep Write(../prompts/*) Write(logs/*)
#              │    │    │    │                    │
#              │    │    │    │                    └─ Scoped write (logs only)
#              │    │    │    └─ Scoped write (deliverables destination)
#              │    │    └─ Read-only tool
#              │    └─ Read-only tool
#              └─ Read-only tool
```

**Format:** Space-delimited list of tool names. Add `(path/glob)` suffix to scope write permissions.

**Important:** Tool permissions are defined ONLY in SKILL.md. Do not duplicate in registry.yml or reference files.

## See Also

- [Full Documentation](../../docs/architecture/workspaces/skills/README.md) — Complete architecture and reference
- [agentskills.io Specification](https://agentskills.io/specification) — Official spec
