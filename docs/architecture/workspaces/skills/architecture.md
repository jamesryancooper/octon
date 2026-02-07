---
title: Workspace Skills Architecture
description: Hierarchical workspace model with scoped authority and progressive disclosure.
---

# Workspace Skills Architecture

This document describes the architectural design of the skills system, including the hierarchical workspace model, scope authority, and progressive disclosure.

---

## Workspace Definition

A `.harmony/` directory designates its **parent directory** as a workspace root. Workspaces can be nested at any level, creating a hierarchy.

```markdown
repo/                              ← Root workspace (scope: repo/**)
├── .harmony/
├── src/
├── docs/                          ← Docs workspace (scope: docs/**)
│   ├── .harmony/
│   └── guides/
└── packages/
    └── kits/                      ← Kits workspace (scope: kits/**)
        ├── .harmony/
        ├── shared/
        └── flowkit/               ← FlowKit workspace (scope: flowkit/**)
            ├── .harmony/
            └── src/
```

---

## Hierarchical Scope

Each workspace's scope includes its parent directory and **all descendants**, including directories that contain their own `.harmony/`.

### Scope Authority Rules

| Direction    | Allowed | Description                              |
|--------------|---------|------------------------------------------|
| **DOWN**     | ✓       | Can write into descendant workspaces     |
| **UP**       | ✗       | Cannot write into ancestor workspaces    |
| **SIDEWAYS** | ✗       | Cannot write into sibling workspaces     |

### Write Permission Matrix

| Workspace   | Can Write To                                             |
|-------------|----------------------------------------------------------|
| **repo**    | `repo/**` (includes `docs/**`, `kits/**`, `flowkit/**`)  |
| **docs**    | `docs/**` only                                           |
| **kits**    | `kits/**` (includes `flowkit/**`)                        |
| **flowkit** | `flowkit/**` only                                        |

### Example: Who Can Write `flowkit/src/generated.ts`

| Workspace | Permission | Reason                                |
|-----------|:----------:|---------------------------------------|
| repo      |     ✓      | flowkit is a descendant               |
| kits      |     ✓      | flowkit is a descendant               |
| flowkit   |     ✓      | within own scope                      |
| docs      |     ✗      | flowkit is not a descendant of docs   |

---

## Skill Directory Layout

```markdown
┌─────────────────────────────────────────────────────────────────┐
│  .harmony/capabilities/skills/          Single Location                   │
│  ├── manifest.yml              Tier 1 discovery index           │
│  ├── registry.yml              Extended metadata + I/O mappings │
│  ├── capabilities.yml          Capability schema                │
│  ├── _template/                Scaffolding for new skills       │
│  ├── refine-prompt/            Skill definition                 │
│  │   ├── SKILL.md              Core instructions (<500 lines)   │
│  │   └── references/           Progressive disclosure content   │
│  ├── synthesize-research/                                      │
│  ├── configs/                  Per-skill configuration          │
│  ├── resources/                Per-skill input resources        │
│  ├── runs/                     Execution state (checkpoints)    │
│  └── logs/                     Execution logs with indexes      │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 │ exposed via symlinks
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│  Host Adapters                 Agent Access                     │
│  .claude/skills/   .cursor/skills/   .codex/skills/             │
└─────────────────────────────────────────────────────────────────┘
```

---

## Skill Contents (`.harmony/capabilities/skills/`)

Skill definitions, metadata, and operational artifacts all live in a single location:

| Content                    | Purpose                                                  |
|----------------------------|----------------------------------------------------------|
| `manifest.yml`             | Tier 1 discovery index (id, display_name, summary, triggers) |
| `registry.yml`             | Extended metadata (commands, requires, depends_on)       |
| `_template/`               | Scaffolding for new skills                               |
| `<skill-name>/SKILL.md`    | Core skill instructions (required)                       |
| `<skill-name>/references/` | Detailed documentation (progressive disclosure)          |
| `<skill-name>/scripts/`    | Executable helpers (optional)                            |
| `<skill-name>/assets/`     | Static resources (optional)                              |

---

## Progressive Disclosure

Skills follow a **four-tier disclosure model** for token efficiency, as defined in the [agentskills.io specification](https://agentskills.io/what-are-skills):

| Tier       | Source              | Content                                      | When Loaded                 | Token Budget   |
|------------|---------------------|----------------------------------------------|-----------------------------|----------------|
| **Tier 1** | `manifest.yml`      | `id`, `display_name`, `summary`, `triggers`  | Always (discovery)          | ~50 tokens     |
| **Tier 2** | `registry.yml`      | `commands`, `requires`, `depends_on`         | After skill matched         | ~50 tokens     |
| **Tier 3** | `SKILL.md`          | Full skill instructions                      | When skill activated        | <5000 tokens   |
| **Tier 4** | `references/`, etc. | Detailed docs, scripts, assets               | When specific detail needed | On demand      |

> **Token Budget Note:** The agentskills.io spec recommends ~100 tokens for discovery metadata (name + description in SKILL.md). Harmony's Tier 1 + Tier 2 combined equals ~100 tokens, aligning with spec guidance while enabling finer-grained progressive loading.

### Two-File Discovery

The manifest/registry split optimizes for progressive disclosure:

| File            | Tier   | Purpose                                      | Agent Loads When                |
|-----------------|--------|----------------------------------------------|---------------------------------|
| `manifest.yml`  | Tier 1 | Compact index for routing decisions          | Session start (always)          |
| `registry.yml`  | Tier 2 | Extended metadata for validation/execution   | After matching, before activation |

**manifest.yml** contains only what agents need for initial routing:

```yaml
skills:
  - id: refine-prompt
    display_name: Refine Prompt
    path: refine-prompt/
    summary: "Context-aware prompt refinement with persona assignment."
    status: active
    tags:
      - prompt
      - refinement
    triggers:
      - "refine my prompt"
      - "improve this prompt"
```

**registry.yml** contains extended metadata loaded after a match:

```yaml
skills:
  refine-prompt:
    version: "2.1.1"
    commands:
      - /refine-prompt
    depends_on: []
```

> **Tool Permissions:** Tool permissions are defined in SKILL.md frontmatter via `allowed-tools`, not in registry.yml. See [Specification](./specification.md#tool-permissions-single-source-of-truth) for details.

### Loading Sequence

1. **Discovery** — Agent reads `manifest.yml` for skill index
2. **Matching** — Agent matches user task to skill summaries or triggers
3. **Validation** — Agent reads matched skill's entry from `registry.yml` for commands/requires
4. **Activation** — User confirms or agent proceeds; agent loads full `SKILL.md`
5. **Detail** — Agent loads reference files only when specific information needed

This approach keeps initial context minimal (~50 tokens per skill) while providing full metadata on demand.

---

## Operational Artifacts

All operational categories follow the `{{category}}/{{skill-id}}/` pattern within `.harmony/capabilities/skills/`:

| Content | Purpose |
|---------|---------|
| `configs/{{skill-id}}/` | Per-skill configuration overrides |
| `resources/{{skill-id}}/` | Per-skill input resources (notes, docs, data) |
| `runs/{{skill-id}}/{{run-id}}/` | Execution state (checkpoints, manifests) |
| `logs/index.yml` | Cross-skill chronological index |
| `logs/{{skill-id}}/index.yml` | Skill-level run metadata |
| `logs/{{skill-id}}/{{run-id}}.md` | Execution audit logs |

> **Bounded top-level:** The top level has fixed entries regardless of skill count: `manifest.yml`, `registry.yml`, `capabilities.yml`, `configs/`, `resources/`, `runs/`, `logs/`.

> **Terminology Note:** The `runs/` directory stores **execution state** for session recovery (checkpoints, manifests). This is distinct from **workspace continuity files** (`continuity/log.md`, ADRs, decisions) which preserve project history. See [Design Conventions](./design-conventions.md#continuity-artifact-detection) for continuity file handling.

### Output Paths

Output paths are declared in `registry.yml` under each skill's `io:` section and validated against the workspace's hierarchical scope.

| Path Type | Example | Purpose |
|-----------|---------|---------|
| **Deliverables** | `.harmony/{{category}}/{{file}}` | Final products (prompts, drafts) |
| **Configs** | `configs/{{skill-id}}/` | Per-skill configuration |
| **Resources** | `resources/{{skill-id}}/` | Per-skill input materials |
| **Execution state** | `runs/{{skill-id}}/{{run-id}}/` | Checkpoints, manifests |
| **Logs** | `logs/{{skill-id}}/{{run-id}}.md` | Execution audit |
| **Descendant workspace** | `flowkit/docs/api.md` | Must be declared, scope-validated |

**Scope validation:** Paths are checked to ensure they fall within the workspace's hierarchical scope (can write down, not up or sideways).

---

## Output Permission Tiers

Skills produce two distinct artifact types with different permission models:

### Deliverables (Final Products)

Deliverables go directly to their final destination with tiered permissions:

| Tier | Scope | Example Path | Use Case |
|------|-------|--------------|----------|
| **Tier 1** | `.harmony/{{category}}/` | `.harmony/scaffolding/prompts/refined.md` | Standard deliverables |
| **Tier 2** | `.harmony/**` | `.harmony/output/exports/data.json` | Custom workspace locations |
| **Tier 3** | `<workspace-root>/**` | `src/generated/api-client.ts` | Project source locations |

**Scope validation:** All paths are validated against the workspace's hierarchical scope—skills can write **down** into descendant workspaces but never **up** to ancestors or **sideways** to siblings.

**Permission requirements:** Tier 3 paths (workspace root locations) require explicit declaration in `registry.yml`.

### Operational Artifacts

Operational artifacts use the categorical `{{category}}/{{skill-id}}/` pattern within `.harmony/capabilities/skills/`:

| Category | Path Pattern | Purpose |
|----------|--------------|---------|
| `configs/` | `configs/{{skill-id}}/` | Per-skill configuration overrides |
| `resources/` | `resources/{{skill-id}}/` | Per-skill input materials |
| `runs/` | `runs/{{skill-id}}/{{run-id}}/` | Execution state (checkpoints, manifests) |
| `logs/` | `logs/{{skill-id}}/{{run-id}}.md` | Execution history |

**Correlation pattern:** `logs/{{skill-id}}/{{run-id}}.md` pairs with `runs/{{skill-id}}/{{run-id}}/` for easy correlation.

---

## Path Validation

Output paths declared in the registry are validated at two points:

| Point | Action |
|-------|--------|
| **Registry load** | Validate paths are within hierarchical scope |
| **Execution time** | Re-validate before write; block out-of-scope writes |

### Validation Logic

```markdown
VALIDATE_PATH(declared_path, workspace_root):
  1. Resolve path relative to workspace_root
  2. Normalize to absolute path
  3. Check: resolved_path starts with workspace_root
     - True: ✓ Valid (within scope)
     - False: ✗ Reject (outside hierarchical scope)
```

### Invalid Path Examples

```yaml
# In docs/.harmony/capabilities/skills/registry.yml (scope: docs/**)
skill_mappings:
  generate-guide:
    outputs:
      - path: "../README.md"           # ✗ REJECTED: ancestor (repo)
      - path: "../packages/kits/x.md"  # ✗ REJECTED: sibling path
      - path: "guides/quickstart.md"   # ✓ Valid: within scope
```

---

## Host Adapters (Symlinks)

Symlinks expose shared skills to different agent hosts:

```bash
.claude/skills/refine-prompt -> ../../.harmony/capabilities/skills/refine-prompt
.cursor/skills/refine-prompt -> ../../.harmony/capabilities/skills/refine-prompt
.codex/skills/refine-prompt  -> ../../.harmony/capabilities/skills/refine-prompt
```

**Why symlinks?** Agent products discover skills in their own directories (`.claude/skills/`, `.cursor/skills/`, etc.). Symlinks allow multiple agents to share the same canonical skill definition while maintaining expected directory structures.

### Setup

**Automatic (recommended):**

```bash
# Create symlinks for all skills
.harmony/capabilities/skills/scripts/setup-harness-links.sh

# Create symlinks for a specific skill
.harmony/capabilities/skills/scripts/setup-harness-links.sh refine-prompt
```

**Manual:**

```bash
# Create directories
mkdir -p .claude/skills .cursor/skills .codex/skills

# Link a skill to all harnesses
ln -s ../../.harmony/capabilities/skills/refine-prompt .claude/skills/refine-prompt
ln -s ../../.harmony/capabilities/skills/refine-prompt .cursor/skills/refine-prompt
ln -s ../../.harmony/capabilities/skills/refine-prompt .codex/skills/refine-prompt
```

### Verification

```bash
# Check symlink status
ls -la .claude/skills/
ls -la .cursor/skills/
ls -la .codex/skills/
```

### Troubleshooting

| Issue | Solution |
|-------|----------|
| Symlinks not working on Windows | Enable Developer Mode or run as Administrator |
| Agent can't find skill | Run `setup-harness-links.sh` to recreate links |
| Broken symlinks after moving files | Delete and recreate symlinks |
| Permission errors | Check filesystem permissions on `.harmony/capabilities/skills/` |

---

## Why Capabilities

In AI-native systems, the consumer of skill definitions is an LLM, not a runtime engine. This changes what drives documentation requirements.

### The Core Insight

| System Type | Question | Optimizes For |
|-------------|----------|---------------|
| Traditional | "How to execute this?" | Runtime dispatch |
| AI-Native (Harmony) | "What can this skill do?" | Documentation needs |

Traditional systems categorize by execution type: "Validator," "Transformer," "Pipeline." In Harmony, capabilities describe what a skill can do—and that drives what documentation it needs.

### Benefits

1. **Granular control.** 17 capabilities vs 2 archetypes—declare exactly what you need.

2. **Clear documentation requirements.** Each capability maps to specific reference files.

3. **Flexible composition.** Skill sets bundle common patterns; capabilities allow fine-tuning.

4. **Validation.** System can check that declared capabilities have matching documentation.

5. **Discovery.** Query skills by capability ("find all resumable skills") or skill set.

### Skill Sets vs Capabilities

**Skill sets** are pre-defined capability bundles for common patterns:

```yaml
skill_sets: [executor, guardian]
# Expands to: phased, branching, stateful, self-validating, safety-bounded
```

**Capabilities** allow fine-grained control:

```yaml
capabilities: [resumable]  # Add to skill set capabilities
```

### Semantic Categories as Tags

For discoverability, use `tags` in manifest.yml:

```yaml
- id: validate-schema
  tags: [validator, json]

- id: format-json
  tags: [transformer, json, formatter]
```

Tags enable filtering ("show me all validators") without affecting capabilities. See [Discovery](./discovery.md) for details.

---

## Design Principles

### Hierarchical Authority

- Parent workspaces can orchestrate across descendant workspaces
- Child workspaces remain focused and contained
- Sibling workspaces are independent

### Separation of Concerns

| Layer | Contains | Does NOT Contain |
|-------|----------|------------------|
| Skills (`.harmony/capabilities/skills/`) | Definitions, I/O paths, configs, outputs, logs | Host-specific invocation |
| Host Adapters (`.claude/`, `.cursor/`, etc.) | Symlinks only | Any actual content |

### Portability

Skills in `.harmony/capabilities/skills/` can be:

- Copied to other repositories
- Shared via git submodules
- Published to skill registries

### Auditability

Every skill execution produces:

- Output artifacts (default or custom paths within scope)
- Run logs in `logs/{{skill-id}}/{{run-id}}.md`
- Timestamped entries for traceability

---

## See Also

- [Design Conventions](./design-conventions.md) — Log structure, checkpoints, and operational patterns
- [Discovery](./discovery.md) — Manifest and registry formats
- [Execution](./execution.md) — Run logging and scope enforcement
- [Reference Artifacts](./reference-artifacts.md) — Progressive disclosure content
