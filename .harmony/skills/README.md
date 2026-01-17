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
│     □ Choose archetype: Utility (no refs) / Workflow (5 refs) / Domain      │
│                                                                             │
│  2. SHARED MANIFEST (.harmony/skills/manifest.yml)                          │
│     □ Add skill entry under `skills:`:                                      │
│       - id: <skill-id>           # Must match directory and SKILL.md name   │
│       - display_name: <Title Case>  # e.g., "Research Synthesizer"          │
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

| Archetype | Reference Files | When to Use |
|-----------|-----------------|-------------|
| **Utility** | None | Single-purpose, obvious I/O |
| **Workflow** | io-contract, safety, examples, behaviors, validation | Multi-phase execution |
| **Domain** | Workflow + errors, glossary, `<domain>.md` | Specialized domains |

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
/synthesize-research sources/topic/
```

**Or explicit call pattern:**

```text
use skill: research-synthesizer
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
├── outputs/                        # Skill outputs
└── logs/runs/                      # Execution logs
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
│   │  <skill>/SKILL.md ──▶ Full instructions + allowed-tools             │   │
│   │       │                      <5000 tokens                           │   │
│   │       ▼                                                             │   │
│   │  <skill>/references/ ▶ Detailed docs, examples, scripts             │   │
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
│   │       ├──▶ outputs/    Skill-generated files                        │   │
│   │       └──▶ logs/runs/  Execution audit logs                         │   │
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
  Execute skill ─────────────▶ Write to outputs/, log to logs/runs/
```

## Single Source of Truth

| Metadata | Source |
|----------|--------|
| `name`, `description` | SKILL.md frontmatter |
| `allowed-tools` (tool permissions) | SKILL.md frontmatter (**authoritative**) |
| `summary`, `triggers`, `tags` | `.harmony/skills/manifest.yml` |
| `version`, `commands`, `parameters`, `depends_on` | `.harmony/skills/registry.yml` |
| Input/output paths | `.workspace/skills/registry.yml` |

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

### Why Symlinks?

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

| Issue | Solution |
|-------|----------|
| Symlinks not working | Ensure your filesystem supports symlinks (Windows may need admin) |
| Agent can't find skill | Run `setup-harness-links.sh` to recreate links |
| Wrong skill version | Delete the symlink and recreate it |
| Permission denied | Check file permissions on `.harmony/skills/` |

### Verification

Check current symlinks:

```bash
ls -la .claude/skills/
ls -la .cursor/skills/
ls -la .codex/skills/
```

## See Also

- [Full Documentation](../../docs/architecture/workspaces/skills/README.md) — Complete architecture and reference
- [agentskills.io Specification](https://agentskills.io/specification) — Official spec
