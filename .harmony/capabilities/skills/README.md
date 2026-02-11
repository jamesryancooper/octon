# Harness Skills

Complex capabilities with defined I/O contracts and progressive disclosure.

For full documentation, see [docs/architecture/harness/skills/](../../../docs/architecture/harness/skills/README.md).

---

## Quick Create Checklist

Creating a new skill requires updating **4 files** across **2 locations**. Use this checklist to avoid missing steps.

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│  SKILL CREATION CHECKLIST                                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. SKILL DEFINITION (.harmony/capabilities/skills/<skill-id>/)                          │
│     □ Copy _template/ to <skill-id>/                                        │
│     □ Edit SKILL.md:                                                        │
│       - Set `name:` to match directory name (kebab-case)                    │
│       - Write `description:` (1-1024 chars, include keywords)               │
│       - Set `allowed-tools:` (single source of truth for permissions)       │
│       - Replace all {{placeholders}} with actual content                    │
│     □ Set `skill_sets:` and `capabilities:` (determines ref files)          │
│                                                                             │
│  2. SHARED MANIFEST (.harmony/capabilities/skills/manifest.yml)                          │
│     □ Add skill entry under `skills:`:                                      │
│       - id: <skill-id>           # Must match directory and SKILL.md name   │
│       - display_name: <Title Case>  # e.g., "Synthesize Research"           │
│       - path: <group>/<skill-id>/                                           │
│       - summary: "<one-line description>"                                   │
│       - status: experimental | active | deprecated                          │
│       - tags: [<tag1>, <tag2>]                                              │
│       - triggers: ["<trigger phrase 1>", "<trigger phrase 2>"]              │
│       - skill_sets: [executor, guardian]  # Capability bundles              │
│       - capabilities: [resumable]         # Additional capabilities         │
│                                                                             │
│  3. REGISTRY (.harmony/capabilities/skills/registry.yml)                                 │
│     □ Add skill entry under `skills:`:                                      │
│       - version: "1.0.0"                                                    │
│       - commands: [/<skill-id>]                                             │
│       - parameters: [{name, type, required, description}]                   │
│       - requires.context: [{type, path, description}]                       │
│       - depends_on: []                                                      │
│                                                                             │
│  4. REGISTRY I/O (.harmony/capabilities/skills/registry.yml)                             │
│     □ Add skill I/O under `skills.<skill-id>.io`:                           │
│       - inputs: [{path, kind, required, description}]                       │
│       - outputs: [{name, path, kind, format, determinism, description}]     │
│                                                                             │
│  5. VALIDATE                                                                │
│     □ Run: ./_scripts/validate-skills.sh <skill-id>                          │
│     □ Fix any errors or warnings                                            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

Before implementing any new skill, apply the alignment-first gate in
`docs/architecture/harness/skills/alignment-policy.md`.

**Skill Sets** (choose capability bundles):

| Skill Set | Bundled Capabilities | When to Use |
|:----------|:---------------------|:------------|
| `executor` | phased, branching, stateful | Multi-step workflow |
| `coordinator` | task-coordinating, parallel | Manages external tasks |
| `delegator` | agent-delegating | Spawns sub-agents |
| `collaborator` | human-collaborative, stateful | Requires human input |
| `integrator` | composable, contract-driven | Pipeline building block |
| `specialist` | domain-specialized | Requires domain expertise |
| `guardian` | self-validating, safety-bounded | Has quality gates |

> **Design Note:** Capabilities determine documentation needs. Each capability maps to specific reference files. See [capabilities.md](../../../docs/architecture/harness/skills/capabilities.md) for the full mapping.

**Capability Selection Guide:**

| Question | Yes → Add |
|----------|-----------|
| Does the skill have multiple phases? | `executor` skill set |
| Does the skill need human approval? | `collaborator` skill set |
| Does the skill have quality gates? | `guardian` skill set |
| Can the skill resume after interruption? | `resumable` capability |
| Is the skill a pipeline component? | `integrator` skill set |
| Does the skill need domain terminology? | `specialist` skill set |

**Declaration Examples:**

```yaml
# Minimal skill (no capabilities)
skill_sets: []
capabilities: []

# Standard multi-phase workflow
skill_sets: [executor]
capabilities: []

# Multi-phase with quality gates
skill_sets: [executor, guardian]
capabilities: []

# Multi-phase with resume support
skill_sets: [executor]
capabilities: [resumable]
```

The template includes guidance for choosing capabilities. See [reference-artifacts.md](../../../docs/architecture/harness/skills/reference-artifacts.md) for the complete capability-to-reference mapping.

**Quick command to scaffold and validate:**

```bash
# Copy template
cp -r .harmony/capabilities/skills/_template .harmony/capabilities/skills/<skill-id>

# Edit files (use your editor)
# Then validate
.harmony/capabilities/skills/_scripts/validate-skills.sh <skill-id>

# Use --fix to see scaffolding suggestions for missing entries
.harmony/capabilities/skills/_scripts/validate-skills.sh <skill-id> --fix
```

---

## Quick Start

**Invoke a skill:**

```text
/synthesize-research _state/resources/synthesize-research/topic/
```

**Or explicit call pattern:**

```text
use skill: synthesize-research
```

**List available skills:** Check `manifest.yml` for the skill index.

## Directory Structure

```text
.harmony/capabilities/skills/
├── manifest.yml                    # Tier 1 discovery index
├── capabilities.yml                # Capability schema & skill set definitions
├── registry.yml                    # Extended metadata and I/O paths (single source of truth)
├── _template/                      # Scaffolding for new skills
├── <group>/<skill-id>/SKILL.md     # Core instructions (<500 lines)
├── _state/runs/                           # Execution state (checkpoints) for session recovery
├── _state/configs/                        # Per-skill configuration overrides
├── _state/resources/                      # Per-skill input materials
├── _state/logs/                           # Execution logs
└── _scripts/                       # Validation and maintenance scripts

.harmony/output/                    # Deliverables (final products)
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
│   │  TIER 1: SHARED FOUNDATION (.harmony/capabilities/skills/)                       │   │
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
│   │  TIER 2: HARNESS CONFIG (.harmony/capabilities/skills/)                        │   │
│   │  ─────────────────────────────────────────────────────────────────  │   │
│   │  Harness-specific I/O — paths, outputs, logs                        │   │
│   │                                                                     │   │
│   │  registry.yml ──────▶ I/O mappings (inputs, outputs)                │   │
│   │       │                                                             │   │
│   │       ├──▶ _state/runs/       Execution state (session recovery)            │   │
│   │       └──▶ _state/logs/       Execution audit logs                         │   │
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
│   │                   Symlinks to .harmony/capabilities/skills/                      │   │
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
  Execute skill ─────────────▶ Write deliverables + _state/runs/, log to _state/logs/
```

## Single Source of Truth

| Metadata                                         | Source                                   |
|--------------------------------------------------|------------------------------------------|
| `name`, `description`                            | SKILL.md frontmatter                     |
| `skill_sets`, `capabilities`                     | SKILL.md frontmatter + manifest.yml      |
| `allowed-tools` (tool permissions)               | SKILL.md frontmatter (**authoritative**) |
| `summary`, `triggers`, `tags`                    | `.harmony/capabilities/skills/manifest.yml`           |
| `version`, `commands`, `parameters`, `depends_on`| `.harmony/capabilities/skills/registry.yml`           |
| Input/output paths                               | `.harmony/capabilities/skills/registry.yml`         |

**Tool Permissions:** `allowed-tools` in SKILL.md is the single source of truth. The internal format is derived via the mapping function in `validate-skills.sh`. See [specification.md](../../../docs/architecture/harness/skills/specification.md) for details.

**Validation:** Run `./_scripts/validate-skills.sh` to verify skill consistency.

**Token Validation:** For accurate token budget validation, install tiktoken:

```bash
pip install tiktoken
```

Without tiktoken, word count approximation is used (±20% variance). CI environments should install tiktoken for consistent validation.

## Creating a Skill

1. Copy `_template/` to `{{group}}/{{skill_id}}/`
2. Update `SKILL.md` frontmatter (`name` must match directory, set `allowed-tools`)
3. Replace all `{{placeholder}}` values with actual content
4. Add entry to `manifest.yml` (id, display_name, path, summary, triggers)
5. Add entry to `.harmony/capabilities/skills/registry.yml` under `skills.<id>` (version, commands, parameters)
6. Add I/O mapping to `.harmony/capabilities/skills/registry.yml` under `skills.<id>.io` (inputs, outputs)
7. Run `./_scripts/validate-skills.sh {{skill_id}}` to verify consistency

**Validation Options:**

```bash
./_scripts/validate-skills.sh              # Validate all skills
./_scripts/validate-skills.sh my-skill     # Validate specific skill
./_scripts/validate-skills.sh --fix        # Scaffold missing entries
./_scripts/validate-skills.sh --strict     # Treat trigger duplicates as errors
```

## Skill Classes

Section requirements depend on skill class:

| Class | Required Sections | Example |
|-------|-------------------|---------|
| **Invocable** (has `commands` in registry) | When to Use, Quick Start, Core Workflow, Boundaries, When to Escalate, References | `synthesize-research`, `refactor` |
| **Foundation context** (`user-invocable: false`) | Stack Assumptions, Child Skills, When Not to Suggest | `python-api`, `swift-macos-app` |
| **Specialist ruleset** (best-practices, patterns) | Categories, Rules/Patterns, Boundaries | `react-best-practices`, `postgres-best-practices` |

## Host Adapter Symlinks

Skills are exposed to different AI agents (Claude, Cursor, Codex) via symlinks from their respective skills directories to the shared `.harmony/capabilities/skills/` definitions. This allows multiple agents to share the same canonical skill definitions.

### Why Symlinks

Agent products discover skills in their own directories:

- `.claude/skills/` — Claude Code
- `.cursor/skills/` — Cursor
- `.codex/skills/` — Codex

Symlinks allow all agents to share the same skill definition without duplication.

### Setup

**Automatic setup (recommended):**

```bash
./_scripts/setup-harness-links.sh
```

This creates symlinks for all skills in `.harmony/capabilities/skills/` to each agent's skills directory.

**Manual setup:**

```bash
# Create directories
mkdir -p .claude/skills .cursor/skills .codex/skills

# Link a specific skill
ln -s ../../.harmony/capabilities/skills/refine-prompt .claude/skills/refine-prompt
ln -s ../../.harmony/capabilities/skills/refine-prompt .cursor/skills/refine-prompt
ln -s ../../.harmony/capabilities/skills/refine-prompt .codex/skills/refine-prompt
```

**Link a single skill:**

```bash
./_scripts/setup-harness-links.sh refine-prompt
```

### Troubleshooting

| Issue                 | Solution                                                         |
|-----------------------|------------------------------------------------------------------|
| Symlinks not working  | Ensure your filesystem supports symlinks (Windows may need admin)|
| Agent can't find skill| Run `setup-harness-links.sh` to recreate links                   |
| Wrong skill version   | Delete the symlink and recreate it                               |
| Permission denied     | Check file permissions on `.harmony/capabilities/skills/`                     |

### Verification

Check current symlinks:

```bash
ls -la .claude/skills/
ls -la .cursor/skills/
ls -la .codex/skills/
```

## Harmony Extensions

Harmony extends the [agentskills.io specification](https://agentskills.io/specification) with additional fields for discovery, routing, and lifecycle management. The base spec requires only `name` and `description` in SKILL.md frontmatter.

### Manifest Extensions (`.harmony/capabilities/skills/manifest.yml`)

| Field | Purpose | Example |
|-------|---------|---------|
| `display_name` | Human-readable title (Title Case) | `"Synthesize Research"` |
| `status` | Lifecycle state | `active`, `experimental`, `deprecated` |
| `tags` | Filtering and grouping labels | `[research, synthesis]` |
| `triggers` | Natural language phrases for intent matching | `["synthesize my research"]` |

### Registry Extensions (`.harmony/capabilities/skills/registry.yml`)

| Field | Purpose | Example |
|-------|---------|---------|
| `version` | Semantic version string | `"1.0.0"` |
| `commands` | Slash commands that invoke the skill | `[/synthesize-research]` |
| `parameters` | Input parameters with types and defaults | See schema below |
| `requires.context` | Context conditions for activation | `[{type: directory_exists, path: ".harmony/"}]` |
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
allowed-tools: Read Glob Grep Write(../prompts/*) Write(_state/logs/*)
#              │    │    │    │                    │
#              │    │    │    │                    └─ Scoped write (logs only)
#              │    │    │    └─ Scoped write (deliverables destination)
#              │    │    └─ Read-only tool
#              │    └─ Read-only tool
#              └─ Read-only tool
```

**Format:** Space-delimited list of tool names. Add `(path/glob)` suffix to scope write permissions.

**Important:** Tool permissions are defined ONLY in SKILL.md. Do not duplicate in registry.yml or reference files.

## Capability Patterns

### Live Ruleset (`external-dependent`)

**Decision:** [D040](../../cognition/context/decisions.md)
**Canonical example:** [`audit-ui`](quality-gate/audit-ui/SKILL.md)

Some skills fetch their rule sets from external URLs at runtime rather than
embedding static rules. This keeps audits current without requiring harness
updates, at the cost of requiring network access.

**When to use `external-dependent`:**

- The rules are maintained by an external party and updated independently
- Freshness matters more than offline availability
- The skill's value depends on staying current with evolving standards

**When NOT to use it (embed static rules instead):**

- The rules are stable and rarely change
- Offline operation is required
- You control the rules and update them as part of harness maintenance

**Implementation requirements:**

| Requirement | Detail |
|-------------|--------|
| `capabilities` | Add `external-dependent` to SKILL.md frontmatter and manifest.yml |
| `allowed-tools` | Include `WebFetch` in SKILL.md frontmatter |
| `references/dependencies.md` | Required by `capability_refs` mapping — document the external URL, failure modes, and offline strategy |
| Failure handling | Skill must stop and report error if the URL is unreachable — no silent degradation |
| Content validation | Verify fetched content is parseable before proceeding; flag suspected prompt injection |

**Template for `dependencies.md`:**

The `_template/references/dependencies.md` provides the scaffold. Key sections:

1. **Dependencies table** — service, URL, purpose, required (yes/no)
2. **Configuration** — how to override the default URL via parameters
3. **Health checks** — verify URL accessibility before proceeding
4. **Failure modes** — what happens when the service is unavailable
5. **Offline mode** — whether a cached fallback exists (default: no)

**Example flow:**

```text
Skill activated
    │
    ▼
WebFetch ruleset URL
    │
    ├── Success → Parse rules → Scan files → Report
    │
    └── Failure → Stop execution → Report error to user
                  (no offline fallback)
```

---

## See Also

- [Full Documentation](../../../docs/architecture/harness/skills/README.md) — Complete architecture and reference
- [agentskills.io Specification](https://agentskills.io/specification) — Official spec
