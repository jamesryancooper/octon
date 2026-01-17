---
title: Workspace Skills Architecture
description: Hierarchical workspace model with scoped authority and progressive disclosure.
---

# Workspace Skills Architecture

This document describes the architectural design of the skills system, including the hierarchical workspace model, scope authority, and progressive disclosure.

---

## Workspace Definition

A `.workspace/` directory designates its **parent directory** as a workspace root. Workspaces can be nested at any level, creating a hierarchy.

```markdown
repo/                              ← Root workspace (scope: repo/**)
├── .workspace/
├── src/
├── docs/                          ← Docs workspace (scope: docs/**)
│   ├── .workspace/
│   └── guides/
└── packages/
    └── kits/                      ← Kits workspace (scope: kits/**)
        ├── .workspace/
        ├── shared/
        └── flowkit/               ← FlowKit workspace (scope: flowkit/**)
            ├── .workspace/
            └── src/
```

---

## Hierarchical Scope

Each workspace's scope includes its parent directory and **all descendants**, including directories that contain their own `.workspace/`.

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

## Skill Definition Tiers

```markdown
┌─────────────────────────────────────────────────────────────────┐
│  .harmony/skills/              Shared Foundation                │
│  ├── manifest.yml              Tier 1 discovery index           │
│  ├── registry.yml              Extended metadata for routing    │
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
│  .workspace/skills/            Workspace I/O                    │
│  ├── registry.yml              I/O mappings (scope-validated)   │
│  ├── outputs/                  Default output location (Tier 1) │
│  ├── logs/runs/                Execution audit logs             │
│  └── sources/                  Input files                      │
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

## Shared Foundation (`.harmony/skills/`)

Portable skill definitions that work across workspaces:

| Content                    | Purpose                                                  |
|----------------------------|----------------------------------------------------------|
| `manifest.yml`             | Tier 1 discovery index (id, name, summary, triggers)     |
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
| **Tier 1** | `manifest.yml`      | `id`, `name`, `summary`, `triggers`          | Always (discovery)          | ~50 tokens     |
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
    requires:
      context:
        - type: directory_exists
          path: ".workspace/"
    depends_on: []
```

> **Tool Permissions:** Tool permissions are defined in SKILL.md frontmatter via `allowed-tools`, not in registry.yml. See [Specification](./specification.md#tool-permissions-single-source-of-truth) for details.

### Loading Sequence

1. **Discovery** — Agent reads `manifest.yml` (shared, then workspace) for skill index
2. **Matching** — Agent matches user task to skill summaries or triggers
3. **Validation** — Agent reads matched skill's entry from `registry.yml` for commands/requires
4. **Activation** — User confirms or agent proceeds; agent loads full `SKILL.md`
5. **Detail** — Agent loads reference files only when specific information needed

This approach keeps initial context minimal (~50 tokens per skill) while providing full metadata on demand.

---

## Workspace I/O (`.workspace/skills/`)

Workspace-specific configuration and outputs:

| Content | Purpose |
|---------|---------|
| `registry.yml` | Extends shared registry, adds I/O path mappings |
| `outputs/` | Default output location (Tier 1, always allowed) |
| `logs/runs/` | Execution audit logs |
| `sources/` | Input files for skills |

### Output Paths

Output paths are declared in `registry.yml` and validated against the workspace's hierarchical scope.

| Path Type | Example | Validation |
|-----------|---------|------------|
| **Default (Tier 1)** | `outputs/{{category}}/{{file}}` | Always allowed |
| **Workspace internal (Tier 2)** | `.workspace/projects/{{project}}/{{file}}` | Must be declared |
| **Workspace root (Tier 3)** | `src/generated/{{file}}` | Must be declared, scope-validated |
| **Descendant workspace** | `flowkit/docs/api.md` | Must be declared, scope-validated |

**Scope validation:** Paths are checked to ensure they fall within the workspace's hierarchical scope (can write down, not up or sideways).

---

## Output Permission Tiers

Within each workspace, output locations follow a tiered permission model:

| Tier | Location | Declaration Required |
|------|----------|---------------------|
| **Tier 1** | `.workspace/skills/outputs/**` | None (always allowed) |
| **Tier 2** | `.workspace/**` | Registry declaration |
| **Tier 3** | `<workspace-root>/**` | Registry declaration |

**Default behavior:** Without explicit declaration, skills write to Tier 1:

```markdown
.workspace/skills/outputs/{{category}}/{{timestamp}}-{{name}}.md
```

Custom paths (Tier 2 and 3) require registry declaration and are validated against the workspace's hierarchical scope.

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
# In docs/.workspace/skills/registry.yml (scope: docs/**)
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
.claude/skills/refine-prompt -> ../../.harmony/skills/refine-prompt
.cursor/skills/refine-prompt -> ../../.harmony/skills/refine-prompt
.codex/skills/refine-prompt  -> ../../.harmony/skills/refine-prompt
```

**Why symlinks?** Agent products discover skills in their own directories (`.claude/skills/`, `.cursor/skills/`, etc.). Symlinks allow multiple agents to share the same canonical skill definition while maintaining expected directory structures.

### Setup

**Automatic (recommended):**

```bash
# Create symlinks for all skills
.harmony/skills/scripts/setup-harness-links.sh

# Create symlinks for a specific skill
.harmony/skills/scripts/setup-harness-links.sh refine-prompt
```

**Manual:**

```bash
# Create directories
mkdir -p .claude/skills .cursor/skills .codex/skills

# Link a skill to all harnesses
ln -s ../../.harmony/skills/refine-prompt .claude/skills/refine-prompt
ln -s ../../.harmony/skills/refine-prompt .cursor/skills/refine-prompt
ln -s ../../.harmony/skills/refine-prompt .codex/skills/refine-prompt
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
| Permission errors | Check filesystem permissions on `.harmony/skills/` |

---

## Design Principles

### Hierarchical Authority

- Parent workspaces can orchestrate across descendant workspaces
- Child workspaces remain focused and contained
- Sibling workspaces are independent

### Separation of Concerns

| Layer | Contains | Does NOT Contain |
|-------|----------|------------------|
| Shared (`.harmony/`) | Skill logic, behaviors, constraints | Workspace paths, local config |
| Workspace (`.workspace/`) | I/O paths, outputs, logs | Skill logic |
| Host Adapters | Symlinks only | Any actual content |

### Portability

Skills in `.harmony/skills/` can be:

- Copied to other repositories
- Shared via git submodules
- Published to skill registries

### Auditability

Every skill execution produces:

- Output artifacts (default or custom paths within scope)
- Run logs in `logs/runs/`
- Timestamped entries for traceability

---

## See Also

- [Discovery](./discovery.md) — Manifest and registry formats
- [Execution](./execution.md) — Run logging and scope enforcement
- [Reference Artifacts](./reference-artifacts.md) — Progressive disclosure content
