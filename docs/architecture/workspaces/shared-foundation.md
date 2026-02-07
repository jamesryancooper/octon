---
title: ".harmony/ Architecture"
description: The single-root, capability-organized workspace that drives all Harmony projects.
---

# `.harmony/` Architecture

## Purpose

`.harmony/` is the **single root directory** for all workspace infrastructure. It organizes resources by **capability category** rather than by reusability layer, eliminating the need for separate "shared" and "local" directories. A root manifest (`harmony.yml`) declares which paths are portable to other repositories and which are project-specific state.

The key insight: **organize by what things do, not by where they came from**.

---

## Structure

```text
.harmony/
├── harmony.yml              # Root manifest: portability + resolution metadata
├── START.md                 # Boot sequence and orientation
├── scope.md                 # Workspace boundaries
├── conventions.md           # Style and formatting rules
├── catalog.md               # Available operations and actors
│
├── cognition/               # Memory & knowledge
│   ├── context/             #   Reference material (tools, compaction, primitives)
│   ├── decisions/           #   Recorded decisions and rationale
│   └── analyses/            #   Analytical artifacts
│
├── agency/                  # Actors & identity
│   ├── agents/              #   Autonomous agents (e.g., software-architect)
│   ├── assistants/          #   Focused specialists (@mention invocation)
│   ├── subagents/           #   Delegated sub-agents
│   └── teams/               #   Multi-agent compositions
│
├── capabilities/            # What can be done
│   ├── skills/              #   Composable capabilities with manifest + registry
│   ├── commands/            #   Atomic operations (recover, validate-frontmatter)
│   └── tools/               #   Tool definitions and references
│
├── orchestration/           # How work flows
│   ├── workflows/           #   Multi-step procedures
│   └── missions/            #   Time-bounded sub-projects
│
├── continuity/              # State & progress
│   ├── log.md               #   Session-level progress log
│   ├── tasks.json           #   Current task priorities
│   └── next.md              #   Planned next steps
│
├── quality/                 # Verification
│   ├── done.md              #   Completion checklist
│   └── session-exit.md      #   End-of-session gate
│
├── scaffolding/             # Reusable patterns
│   ├── templates/           #   Workspace scaffolding (base, docs, node-ts variants)
│   ├── prompts/             #   Task templates
│   └── examples/            #   Reference patterns
│
├── ideation/                # Human-led zones (agents: hands off)
│   ├── scratchpad/          #   Ephemeral staging and idea funnel
│   └── projects/            #   Committed explorations
│
└── output/                  # Artifacts
    ├── reports/             #   Finished reports
    ├── drafts/              #   Work-in-progress documents
    └── artifacts/           #   Other generated outputs
```

---

## Portability via `harmony.yml`

Instead of splitting resources across two directories, `harmony.yml` declares which paths are **portable** (safe to copy when bootstrapping a new repository) and which are **project-specific state** (stay with this repo).

### `harmony.yml` (excerpt)

```yaml
schema_version: "1.0"

# Portable paths -- copy these to bootstrap a new repo via `harmony init`.
# Everything else is project-specific state that stays with this repo.
portable:
  - agency/agents/
  - agency/assistants/
  - agency/subagents/
  - capabilities/skills/manifest.yml
  - capabilities/skills/registry.yml
  - capabilities/skills/capabilities.yml
  - capabilities/skills/_template/
  - capabilities/skills/scripts/
  - capabilities/skills/*/SKILL.md
  - capabilities/skills/*/references/
  - capabilities/commands/
  - quality/
  - scaffolding/
  - cognition/context/primitives.md
  - cognition/context/tools.md
  - cognition/context/compaction.md
  - README.md

# Agent-excluded zones.
human_led:
  - ideation/**

# Resolution rules for capabilities that span framework and project concerns.
resolution:
  agency: "Framework definitions loaded; project overrides merged on top"
  capabilities: "Single manifest and registry; no extends pattern"
  orchestration: "Framework workflows and project workflows coexist"
```

### How It Works

| Concept | Mechanism |
| ------- | --------- |
| **Portable paths** | Listed under `portable:` in `harmony.yml`. Copied by `harmony init` when bootstrapping a new repo. |
| **Project-specific state** | Everything *not* listed under `portable:`. Stays with the current repository (continuity, missions, decisions, outputs). |
| **Resolution** | Single directory tree -- no layered lookup. The `resolution:` block documents how framework and project content coexist within each category. |
| **Human-led zones** | Listed under `human_led:`. Agents must not access autonomously. |

---

## What Lives Where

Resources are organized by **capability category**. Each category groups related concerns regardless of whether the content is reusable or project-specific.

### Capability Categories

| Category | Path | Contains | Portable? |
| -------- | ---- | -------- | --------- |
| **Cognition** | `cognition/` | Context references, decisions, analyses | Partially (reference docs are portable; decisions are project-specific) |
| **Agency** | `agency/` | Agents, assistants, subagents, teams | Yes (definitions are portable) |
| **Capabilities** | `capabilities/` | Skills, commands, tools | Yes (definitions are portable; logs and outputs are project-specific) |
| **Orchestration** | `orchestration/` | Workflows, missions | Partially (workflow definitions are portable; missions are project-specific) |
| **Continuity** | `continuity/` | Progress log, tasks, next steps | No (project-specific state) |
| **Quality** | `quality/` | Completion checklists, session gates | Yes |
| **Scaffolding** | `scaffolding/` | Templates, prompts, examples | Yes |
| **Ideation** | `ideation/` | Scratchpad, projects (human-led) | No (project-specific, human-led) |
| **Output** | `output/` | Reports, drafts, artifacts | No (project-specific artifacts) |

### Decision Heuristic

Ask: **"Should this travel to a new repository?"**

- **Yes** -- Add the path to `portable:` in `harmony.yml`
- **No** -- Leave it out; it stays as project-specific state

---

## Harness Integration

Harness directories (`.claude/`, `.cursor/`, `.codex/`) integrate with `.harmony/` via symlinks:

```
.claude/skills/synthesize-research -> ../../.harmony/capabilities/skills/synthesize-research
.cursor/skills/synthesize-research -> ../../.harmony/capabilities/skills/synthesize-research
.codex/skills/synthesize-research  -> ../../.harmony/capabilities/skills/synthesize-research
```

### Why Symlinks?

| Benefit | Description |
| ------- | ----------- |
| Single source of truth | Skill definition lives in one place |
| Harness portability | Same skill works in Claude Code, Cursor, Codex |
| Easy updates | Change `.harmony/`, all harnesses get the update |

### Command Wrappers

Harness commands in `.<harness>/commands/` are thin wrappers that delegate to `.harmony/` workflows:

| Command | Delegates To |
| ------- | ------------ |
| `/create-workspace` | `.harmony/orchestration/workflows/workspace/create-workspace/` |
| `/synthesize-research` | `.harmony/capabilities/skills/synthesize-research/` |

---

## When to Extend `.harmony/`

Add to `.harmony/` when you have:

| Situation | Action |
| --------- | ------ |
| A new agent or assistant | Add to `.harmony/agency/` |
| A new workspace template variant | Add to `.harmony/scaffolding/templates/` |
| A new skill that other projects could use | Add to `.harmony/capabilities/skills/` and mark its definition paths as `portable:` |
| A workflow that applies to any workspace | Add to `.harmony/orchestration/workflows/` |
| Project-specific state (progress, missions) | Add under the relevant category; do **not** mark as `portable:` |

---

## Adopting in Other Repositories

Use `harmony.yml` portable paths to bootstrap `.harmony/` in a new repository.

### Setup Steps

1. **Copy portable paths** using the init script or manually:
   ```bash
   # Preferred: use the init script
   bash /path/to/harmony/.harmony/init.sh /path/to/target-repo

   # Manual: copy only portable paths
   # (Refer to harmony.yml for the authoritative list)
   ```

2. **Create a root `harmony.yml`** in the target repo to declare its own portable/state boundaries.

3. **Configure harness entry points** (optional):
   ```bash
   # For Claude Code
   mkdir -p .claude/commands

   # For Cursor
   mkdir -p .cursor/commands
   ```

4. **Set up skill symlinks** (if using skills):
   ```bash
   mkdir -p .cursor/skills
   ln -s ../../.harmony/capabilities/skills/synthesize-research .cursor/skills/synthesize-research
   ```

### What You Get

| Category | Path | Description |
| -------- | ---- | ----------- |
| Agency | `agency/` | Agents, assistants, subagents |
| Capabilities | `capabilities/` | Skills framework, commands, tools |
| Scaffolding | `scaffolding/` | Templates, prompts, examples |
| Quality | `quality/` | Completion checklists |
| Cognition (partial) | `cognition/context/` | Reference material (tools, compaction) |

### Customization

After bootstrapping, you can:

- **Add repo-specific agents** to `.harmony/agency/agents/`
- **Create custom templates** in `.harmony/scaffolding/templates/`
- **Add new skills** to `.harmony/capabilities/skills/`
- **Record project decisions** in `.harmony/cognition/decisions/`
- **Track progress** in `.harmony/continuity/`

Mark any new reusable content as `portable:` in `harmony.yml` so it propagates to future repositories.

### Keeping Up to Date

When the source `.harmony/` improves, selectively update portable paths:

```bash
# Compare portable paths
diff -r /path/to/harmony/.harmony/agency .harmony/agency
diff -r /path/to/harmony/.harmony/scaffolding .harmony/scaffolding

# Or re-run init (preserves project-specific state)
bash /path/to/harmony/.harmony/init.sh .
```

### When to Consider a Package

The portable-paths approach works well for most cases. Consider converting to a **published package** when:

| Signal | Why It Matters |
| ------ | -------------- |
| **5+ repositories** using the pattern | Manual syncing becomes burdensome |
| **Frequent foundation updates** | Changes need to propagate quickly across repos |
| **Incompatible drift** | Repos have diverged in ways that cause problems |
| **Team growth** | New team members need a stable, versioned foundation |
| **Breaking changes** | You need semantic versioning to communicate impact |

**Hybrid approach:** Start with portable paths via `harmony init`. When you hit the signals above, extract the stable core into a package while keeping repo-specific content in a local `.harmony/` that extends the package.

---

## Related Documentation

- [README.md](./README.md) -- Main workspace documentation
- [Skills](./skills.md) -- Composable capabilities with defined I/O
- [Workflows](./workflows.md) -- Multi-step procedures
- [Taxonomy](./taxonomy.md) -- Harness entry points, commands, workflows relationships
