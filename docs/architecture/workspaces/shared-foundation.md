---
title: Shared Foundation (.harmony)
description: The reusable infrastructure layer that workspaces inherit from.
---

# Shared Foundation: `.harmony/`

## Purpose

`.harmony/` provides **domain-agnostic infrastructure** that all `.workspace/` directories inherit from. It contains generic assistants, workflows, skills, and templates that can be reused across any project without modification.

The key insight: **separate what's reusable from what's project-specific**.

---

## Structure

```text
.harmony/
├── README.md           <- Overview and inheritance rules
│
├── assistants/         <- Generic specialists (@mention invocation)
│   ├── registry.yml
│   ├── _template/
│   ├── reviewer/
│   ├── refactor/
│   └── docs/
│
├── templates/          <- Workspace scaffolding
│   ├── workspace/          <- Base template (all workspaces inherit)
│   ├── workspace-docs/     <- Documentation area variant
│   └── workspace-node-ts/  <- Node.js/TypeScript variant
│
├── workflows/          <- Generic multi-step procedures
│   ├── workspace/          <- Workspace management (create, update, evaluate, migrate)
│   ├── missions/           <- Mission lifecycle (create, complete)
│   ├── skills/             <- Skill creation
│
├── skills/             <- Skills framework + generic skills
│   ├── registry.yml        <- Skill catalog (progressive disclosure)
│   ├── _template/
│   ├── research-synthesizer/
│   └── scripts/
│
├── commands/           <- Generic atomic operations
│   ├── recover.md
│   └── validate-frontmatter.md
│
├── prompts/            <- Generic task templates
│   ├── bootstrap-session.md
│   └── research/
│
├── checklists/         <- Generic quality gates
│   ├── complete.md
│   └── session-exit.md
│
├── context/            <- Generic reference material
│   ├── tools.md
│   └── compaction.md
│
└── examples/           <- Reference patterns
```

---

## Inheritance & Resolution

Workspaces follow a **two-layer inheritance model**:

```
.harmony/            <- Shared foundation (generic, domain-agnostic)
    |
    v inherits
.workspace/          <- Project-specific (progress, missions, domain context)
```

### Resolution Rule

**Local overrides shared.** Agents check `.workspace/` first, then fall back to `.harmony/`.

| Resource | Search Order |
|----------|--------------|
| Assistants | `.workspace/assistants/` → `.harmony/assistants/` |
| Templates | `.workspace/templates/` → `.harmony/templates/` |
| Workflows | `.workspace/workflows/` → `.harmony/workflows/` |
| Skills | `.workspace/skills/` → `.harmony/skills/` |
| Commands | `.workspace/commands/` → `.harmony/commands/` |
| Prompts | `.workspace/prompts/` → `.harmony/prompts/` |
| Checklists | `.workspace/checklists/` → `.harmony/checklists/` |
| Context | `.workspace/context/` → `.harmony/context/` |

---

## What Lives Where

### In `.harmony/` (Shared)

| Content | Example | Reason |
|---------|---------|--------|
| Generic assistants | `reviewer/`, `refactor/`, `docs/` | Reusable across any project |
| Base templates | `workspace/`, `workspace-docs/` | Scaffolding is domain-agnostic |
| Management workflows | `create-workspace`, `migrate-workspace` | Workspace operations are generic |
| Skill definitions | `research-synthesizer/SKILL.md` | Capability logic is reusable |
| Generic commands | `recover.md`, `validate-frontmatter.md` | Fixed procedures, no project context |
| Tool/compaction guides | `context/tools.md` | Reference material applies everywhere |

### In `.workspace/` (Project-Specific)

| Content | Example | Reason |
|---------|---------|--------|
| Boot files | `START.md`, `scope.md`, `conventions.md` | Define this workspace's identity |
| Progress tracking | `progress/log.md`, `tasks.json` | State is project-specific |
| Missions | `missions/<slug>/` | Time-bounded sub-projects are local |
| Domain context | `context/decisions.md`, `glossary.md` | Domain knowledge varies |
| Skill I/O mappings | `skills/registry.yml` | Paths are project-specific |
| Skill outputs/logs | `skills/outputs/`, `skills/logs/` | Artifacts stay local |
| Human zones | `.scratchpad/` (includes `inbox/`, `archive/`) | Project-specific thinking/staging |

### Decision Heuristic

Ask: **"Would this be useful in a different project without modification?"**

- **Yes** → Put it in `.harmony/`
- **No** → Put it in `.workspace/`

---

## Skills: Split Definition Pattern

Skills use a split pattern where **capability** lives in `.harmony/` but **configuration** lives in `.workspace/`.

### Shared (`.harmony/skills/registry.yml`)

```yaml
skills:
  - id: research-synthesizer
    name: Research Synthesizer
    path: research-synthesizer/
    summary: "Synthesize scattered research notes into coherent findings."
    commands:
      - /synthesize-research
    # No paths here - those are project-specific
```

### Local (`.workspace/skills/registry.yml`)

```yaml
extends: "../../.harmony/skills/registry.yml"

skill_mappings:
  research-synthesizer:
    inputs:
      - path: "projects/<project>/"
    outputs:
      - path: "outputs/drafts/<topic>-synthesis.md"
```

This separation means the skill logic is reusable, but each project defines where inputs come from and outputs go.

---

## Harness Integration

Harness directories (`.claude/`, `.cursor/`, `.codex/`) integrate with `.harmony/` via symlinks:

```
.claude/skills/research-synthesizer -> ../../.harmony/skills/research-synthesizer
.cursor/skills/research-synthesizer -> ../../.harmony/skills/research-synthesizer
.codex/skills/research-synthesizer  -> ../../.harmony/skills/research-synthesizer
```

### Why Symlinks?

| Benefit | Description |
|---------|-------------|
| Single source of truth | Skill definition lives in one place |
| Harness portability | Same skill works in Claude Code, Cursor, Codex |
| Easy updates | Change `.harmony/`, all harnesses get the update |

### Command Wrappers

Harness commands in `.<harness>/commands/` are thin wrappers that delegate to `.harmony/` or `.workspace/` workflows:

| Command | Delegates To |
|---------|--------------|
| `/create-workspace` | `.harmony/workflows/workspace/create-workspace/` |
| `/synthesize-research` | `.harmony/skills/research-synthesizer/` |

---

## When to Extend `.harmony/`

Add to `.harmony/` when you have:

| Situation | Action |
|-----------|--------|
| A new generic assistant | Add to `.harmony/assistants/` |
| A new workspace template variant | Add to `.harmony/templates/` |
| A new skill that's project-agnostic | Add to `.harmony/skills/` |
| A workflow that applies to any workspace | Add to `.harmony/workflows/` |

**Do not add project-specific content to `.harmony/`.** That defeats the purpose of the shared layer.

---

## Adopting in Other Repositories

The `.harmony/` directory is designed to be **copied to other repositories** to provide workspace infrastructure.

### Setup Steps

1. **Copy `.harmony/`** to the target repository root:
   ```bash
   cp -r /path/to/harmony/.harmony /path/to/target-repo/
   ```

2. **Create a root `.workspace/`** for repo-wide operations:
   ```bash
   # Use the create-workspace workflow or copy from template
   cp -r .harmony/templates/workspace .workspace
   ```

3. **Configure harness entry points** (optional):
   ```bash
   # For Cursor
   mkdir -p .cursor/commands
   # Copy relevant command wrappers

   # For Claude Code
   mkdir -p .claude/commands
   # Copy relevant command wrappers
   ```

4. **Set up skill symlinks** (if using skills):
   ```bash
   # Example for research-synthesizer
   mkdir -p .cursor/skills
   ln -s ../../.harmony/skills/research-synthesizer .cursor/skills/research-synthesizer
   ```

### What You Get

| Component | Description |
|-----------|-------------|
| `templates/` | Scaffolding for new workspaces (`/create-workspace`) |
| `assistants/` | Generic specialists (reviewer, refactor, docs) |
| `workflows/` | Workspace management (create, update, evaluate, migrate) |
| `skills/` | Composable capabilities (research-synthesizer) |
| `commands/` | Atomic operations (recover, validate-frontmatter) |
| `checklists/` | Quality gates (complete, session-exit) |

### Customization

After copying, you can:

- **Add repo-specific assistants** to `.harmony/assistants/`
- **Create custom templates** in `.harmony/templates/`
- **Add new skills** to `.harmony/skills/`
- **Override in `.workspace/`** — local always wins over shared

### Keeping Up to Date

When the source `.harmony/` improves, manually copy updates:

```bash
# Compare and selectively update
diff -r /path/to/harmony/.harmony .harmony

# Or replace entirely (careful: loses customizations)
rm -rf .harmony && cp -r /path/to/harmony/.harmony .
```

**Tip:** Track your customizations in a separate branch or document them in `.harmony/README.md` so you know what to preserve during updates.

### When to Consider a Package

The copyable directory approach works well for most cases. However, consider converting `.harmony/` to a **published package** when:

| Signal | Why It Matters |
|--------|----------------|
| **5+ repositories** using the pattern | Manual syncing becomes burdensome |
| **Frequent foundation updates** | Changes need to propagate quickly across repos |
| **Incompatible drift** | Repos have diverged in ways that cause problems |
| **Team growth** | New team members need a stable, versioned foundation |
| **Breaking changes** | You need semantic versioning to communicate impact |

**Package benefits:**
- `npm update @your-org/harmony` propagates changes
- Semantic versioning (`^1.0.0`) controls breaking change exposure
- Single source of truth for all consumers
- Clear upgrade path with changelogs

**Package costs:**
- Registry infrastructure (npm, private registry, or monorepo publishing)
- Less flexibility for per-repo customization
- Dependency management overhead
- More complex inheritance (node_modules paths)

**Hybrid approach:** Start with copyable directory. When you hit the signals above, extract the stable core into a package while keeping repo-specific customizations in a local `.harmony/` that extends the package.

---

## Related Documentation

- [README.md](./README.md) — Main workspace documentation with Two-Layer Architecture overview
- [Skills](./skills.md) — Composable capabilities with defined I/O
- [Workflows](./workflows.md) — Multi-step procedures
- [Taxonomy](./taxonomy.md) — Harness entry points, commands, workflows relationships
