---
title: Harness Skills Architecture
description: Repository-root harness model with repository-scoped authority and progressive disclosure.
---

# Harness Skills Architecture

This document describes the architectural design of the skills system, including the repository-root harness model, scope authority, and progressive disclosure.

---

## Harness Definition

A `.octon/` directory designates its **parent directory** as the repository harness root.

Exactly one `.octon/` directory may exist on a repository ancestor chain. Sibling repositories may each have their own repo-root harness.

```markdown
repo/                              ← Root harness (scope: repo/**)
├── .octon/
├── src/
├── docs/
└── packages/
```

---

## Repository Scope

The root harness scope includes the repository root and all repository descendants.

### Scope Authority Rules

| Direction    | Allowed | Description                              |
|--------------|---------|------------------------------------------|
| **WITHIN REPO** | ✓ | Can write to declared paths within the repository root |
| **OUTSIDE REPO** | ✗ | Cannot write outside the repository root |

### Write Permission Matrix

| Harness | Can Write To |
|---------|--------------|
| **repo** | `repo/**` subject to declared output paths and policy |

## Locality Resolution

Capability routing and agent execution resolve locality from the root-owned
repo-instance scope registry, not from descendant harnesses or nearest-parent
registry fallback.

- authored locality authority: `/.octon/instance/locality/**`
- compiled runtime-facing locality view: `/.octon/generated/effective/locality/**`
- v1 model: one `root_path` per `scope_id`, zero or one active scope per path
- invalid models: descendant `.octon/` roots, hierarchical scope inheritance,
  ancestor-chain composition

### Example: Who Can Write `flowkit/src/generated.ts`

| Harness   | Permission | Reason |
|-----------|:----------:|--------|
| repo      |     ✓      | path stays within repo root and declared outputs |

---

## Skill Directory Layout

```markdown
┌─────────────────────────────────────────────────────────────────┐
│  .octon/framework/capabilities/runtime/skills/          Single Location                   │
│  ├── manifest.yml              Tier 1 discovery index           │
│  ├── registry.yml              Extended metadata + I/O mappings │
│  ├── capabilities.yml          Capability schema                │
│  ├── _scaffold/template/                Scaffolding for new skills       │
│  ├── refine-prompt/            Skill definition                 │
│  │   ├── SKILL.md              Core instructions (<500 lines)   │
│  │   └── references/           Progressive disclosure content   │
│  ├── synthesize-research/                                      │
│  ├── /.octon/instance/capabilities/runtime/skills/configs/                  Per-skill configuration          │
│  ├── /.octon/instance/capabilities/runtime/skills/resources/                Per-skill input resources        │
│  ├── /.octon/state/control/skills/checkpoints/                     Execution state (checkpoints)    │
│  └── /.octon/state/evidence/runs/skills/                     Execution logs with indexes      │
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

## Skill Contents (`.octon/framework/capabilities/runtime/skills/`)

Skill definitions, metadata, and operational artifacts all live in a single location:

| Content                    | Purpose                                                  |
|----------------------------|----------------------------------------------------------|
| `manifest.yml`             | Tier 1 discovery index (id, display_name, summary, triggers) |
| `registry.yml`             | Extended metadata (commands, requires, composition)      |
| `_scaffold/template/`               | Scaffolding for new skills                               |
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
| **Tier 2** | `registry.yml`      | `commands`, `requires`, `composition`        | After skill matched         | ~50 tokens     |
| **Tier 3** | `SKILL.md`          | Full skill instructions                      | When skill activated        | <5000 tokens   |
| **Tier 4** | `references/`, etc. | Detailed docs, scripts, assets               | When specific detail needed | On demand      |

> **Token Budget Note:** The agentskills.io spec recommends ~100 tokens for discovery metadata (name + description in SKILL.md). Octon's Tier 1 + Tier 2 combined equals ~100 tokens, aligning with spec guidance while enabling finer-grained progressive loading.

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
    composition:
      mode: prerequisites
      failure_policy: fail_fast
      steps: []
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

All operational categories follow the `{{category}}/{{skill-id}}/` pattern within `.octon/framework/capabilities/runtime/skills/`:

| Content | Purpose |
|---------|---------|
| `/.octon/instance/capabilities/runtime/skills/configs/{{skill-id}}/` | Per-skill configuration overrides |
| `/.octon/instance/capabilities/runtime/skills/resources/{{skill-id}}/` | Per-skill input resources (notes, docs, data) |
| `/.octon/state/control/skills/checkpoints/{{skill-id}}/{{run-id}}/` | Execution state (checkpoints, manifests) |
| `/.octon/state/evidence/runs/skills/index.yml` | Cross-skill chronological index |
| `/.octon/state/evidence/runs/skills/{{skill-id}}/index.yml` | Skill-level run metadata |
| `/.octon/state/evidence/runs/skills/{{skill-id}}/{{run-id}}.md` | Execution audit logs |

> **Bounded top-level:** The top level has fixed entries regardless of skill count: `manifest.yml`, `registry.yml`, `capabilities.yml`, `/.octon/instance/capabilities/runtime/skills/configs/`, `/.octon/instance/capabilities/runtime/skills/resources/`, `/.octon/state/control/skills/checkpoints/`, `/.octon/state/evidence/runs/skills/`.

> **Terminology Note:** The `/.octon/state/control/skills/checkpoints/` directory stores **execution state** for session recovery (checkpoints, manifests). This is distinct from **harness continuity files** (`/.octon/state/continuity/repo/log.md`, ADRs, decisions) which preserve project history. See [Design Conventions](../../practices/design-conventions.md#continuity-artifact-detection) for continuity file handling.

### Output Paths

Output paths are declared in `registry.yml` under each skill's `io:` section and validated against the repository-root harness scope.

| Path Type | Example | Purpose |
|-----------|---------|---------|
| **Deliverables** | `.octon/{{category}}/{{file}}` | Final products (prompts, drafts) |
| **Configs** | `/.octon/instance/capabilities/runtime/skills/configs/{{skill-id}}/` | Per-skill configuration |
| **Resources** | `/.octon/instance/capabilities/runtime/skills/resources/{{skill-id}}/` | Per-skill input materials |
| **Execution state** | `/.octon/state/control/skills/checkpoints/{{skill-id}}/{{run-id}}/` | Checkpoints, manifests |
| **Logs** | `/.octon/state/evidence/runs/skills/{{skill-id}}/{{run-id}}.md` | Execution audit |
| **Project tree path** | `packages/flowkit/docs/api.md` | Must be declared, scope-validated |

**Scope validation:** Paths are checked to ensure they remain within the repository-root harness scope.

---

## Output Permission Tiers

Skills produce two distinct artifact types with different permission models:

### Deliverables (Final Products)

Deliverables go directly to their final destination with tiered permissions:

| Tier | Scope | Example Path | Use Case |
|------|-------|--------------|----------|
| **Tier 1** | `.octon/{{category}}/` | `.octon/framework/scaffolding/practices/prompts/refined.md` | Standard deliverables |
| **Tier 2** | `.octon/**` | `.octon/generated/exports/data.json` | Custom harness locations |
| **Tier 3** | `<harness-root>/**` | `src/generated/api-client.ts` | Project source locations |

**Scope validation:** All paths are validated against the repository-root harness boundary.

**Permission requirements:** Tier 3 paths (harness root locations) require explicit declaration in `registry.yml`.

### Operational Artifacts

Operational artifacts use the categorical `{{category}}/{{skill-id}}/` pattern within `.octon/framework/capabilities/runtime/skills/`:

| Category | Path Pattern | Purpose |
|----------|--------------|---------|
| `/.octon/instance/capabilities/runtime/skills/configs/` | `/.octon/instance/capabilities/runtime/skills/configs/{{skill-id}}/` | Per-skill configuration overrides |
| `/.octon/instance/capabilities/runtime/skills/resources/` | `/.octon/instance/capabilities/runtime/skills/resources/{{skill-id}}/` | Per-skill input materials |
| `/.octon/state/control/skills/checkpoints/` | `/.octon/state/control/skills/checkpoints/{{skill-id}}/{{run-id}}/` | Execution state (checkpoints, manifests) |
| `/.octon/state/evidence/runs/skills/` | `/.octon/state/evidence/runs/skills/{{skill-id}}/{{run-id}}.md` | Execution history |

**Correlation pattern:** `/.octon/state/evidence/runs/skills/{{skill-id}}/{{run-id}}.md` pairs with `/.octon/state/control/skills/checkpoints/{{skill-id}}/{{run-id}}/` for easy correlation.

---

## Path Validation

Output paths declared in the registry are validated at two points:

| Point | Action |
|-------|--------|
| **Registry load** | Validate paths are within repository scope |
| **Execution time** | Re-validate before write; block out-of-scope writes |

### Validation Logic

```markdown
VALIDATE_PATH(declared_path, harness_root):
  1. Resolve path relative to harness_root
  2. Normalize to absolute path
  3. Check: resolved_path starts with harness_root
     - True: ✓ Valid (within scope)
     - False: ✗ Reject (outside repository scope)
```

### Invalid Path Examples

```yaml
# In repo/.octon/framework/capabilities/runtime/skills/registry.yml
skills:
  generate-guide:
    io:
      outputs:
        - path: "../README.md"           # ✗ REJECTED: escapes repo root
        - path: "../other-repo/x.md"     # ✗ REJECTED: sibling workspace outside repo root
        - path: "/tmp/x.md"              # ✗ REJECTED: outside repo root
        - path: "guides/quickstart.md"   # ✓ Valid: within scope
```

---

## Host Adapters (Symlinks)

Symlinks expose shared skills to different agent hosts:

```bash
.claude/skills/refine-prompt -> ../../.octon/framework/capabilities/runtime/skills/synthesis/refine-prompt
.cursor/skills/refine-prompt -> ../../.octon/framework/capabilities/runtime/skills/synthesis/refine-prompt
.codex/skills/refine-prompt  -> ../../.octon/framework/capabilities/runtime/skills/synthesis/refine-prompt
```

**Why symlinks?** Agent products discover skills in their own directories (`.claude/skills/`, `.cursor/skills/`, etc.). Symlinks allow multiple agents to share the same canonical skill definition while maintaining expected directory structures.

### Setup

**Automatic (recommended):**

```bash
# Create symlinks for all skills
.octon/framework/capabilities/runtime/skills/_ops/scripts/setup-harness-links.sh

# Create symlinks for a specific skill
.octon/framework/capabilities/runtime/skills/_ops/scripts/setup-harness-links.sh refine-prompt
```

**Manual:**

```bash
# Create directories
mkdir -p .claude/skills .cursor/skills .codex/skills

# Link a skill to all harnesses
ln -s ../../.octon/framework/capabilities/runtime/skills/synthesis/refine-prompt .claude/skills/refine-prompt
ln -s ../../.octon/framework/capabilities/runtime/skills/synthesis/refine-prompt .cursor/skills/refine-prompt
ln -s ../../.octon/framework/capabilities/runtime/skills/synthesis/refine-prompt .codex/skills/refine-prompt
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
| Permission errors | Check filesystem permissions on `.octon/framework/capabilities/runtime/skills/` |

---

## Why Capabilities

In AI-native systems, the consumer of skill definitions is an LLM, not a runtime engine. This changes what drives documentation requirements.

### The Core Insight

| System Type | Question | Optimizes For |
|-------------|----------|---------------|
| Traditional | "How to execute this?" | Runtime dispatch |
| AI-Native (Octon) | "What can this skill do?" | Documentation needs |

Traditional systems categorize by execution type: "Validator," "Transformer," "Pipeline." In Octon, capabilities describe what a skill can do—and that drives what documentation it needs.

### Benefits

1. **Granular control.** 20 capabilities vs 2 archetypes—declare exactly what you need.

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

### Repository Authority

- The repo-root harness is the single orchestration authority
- Domain-specific context lives under repo-root harness paths
- Validation and discovery stay deterministic because there is one active harness root

### Separation of Concerns

| Layer | Contains | Does NOT Contain |
|-------|----------|------------------|
| Skills (`.octon/framework/capabilities/runtime/skills/`) | Definitions, I/O paths, configs, outputs, logs | Host-specific invocation |
| Host Adapters (`.claude/`, `.cursor/`, etc.) | Symlinks only | Any actual content |

### Portability

Skills in `.octon/framework/capabilities/runtime/skills/` can be:

- Copied to other repositories
- Shared via git submodules
- Published to skill registries

### Auditability

Every skill execution produces:

- Output artifacts (default or custom paths within scope)
- Run logs in `/.octon/state/evidence/runs/skills/{{skill-id}}/{{run-id}}.md`
- Timestamped entries for traceability

---

## See Also

- [Design Conventions](../../practices/design-conventions.md) — Log structure, checkpoints, and operational patterns
- [Discovery](./discovery.md) — Manifest and registry formats
- [Execution](./execution.md) — Run logging and scope enforcement
- [Reference Artifacts](./reference-artifacts.md) — Progressive disclosure content
