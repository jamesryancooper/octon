---
title: ".octon/ Architecture"
description: Capability-organized harness architecture with a single repo-root harness.
---

# `.octon/` Architecture

## Purpose

`.octon/` is the **single root directory** for this repository's harness infrastructure. Octon now treats the repo-root harness as the only supported harness surface.

The structure is organized by **capability category** rather than by reusability layer, eliminating the old separate "shared" and "local" directory model. A root manifest (`octon.yml`) declares which paths are portable to other repositories and which are project-specific state.

The key insight: **organize by what things do, not by where they came from**.

---

## Structure

```text
.octon/
├── octon.yml              # Root manifest: portability + resolution metadata
├── START.md                 # Boot sequence and orientation
├── scope.md                 # Harness boundaries
├── conventions.md           # Style and formatting rules
├── catalog.md               # Available operations and actors
│
├── cognition/               # Memory & knowledge
│   ├── context/             #   Reference material (tools, compaction, primitives)
│   ├── decisions/           #   Recorded decisions and rationale
│   └── analyses/            #   Analytical artifacts
│
├── agency/                  # Actor runtime + governance
│   ├── governance/          #   Cross-agent contracts and precedence overlays
│   ├── actors/              #   Runtime actor artifacts
│   │   ├── agents/          #   Autonomous agents (e.g., software-architect)
│   │   ├── assistants/      #   Focused specialists (@mention invocation)
│   │   └── teams/           #   Multi-agent compositions
│   └── practices/           #   Human-agent operating standards
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
├── assurance/                 # Verification
│   ├── done.md              #   Completion checklist
│   └── session-exit.md      #   End-of-session gate
│
├── scaffolding/             # Reusable patterns
│   ├── templates/           #   Harness scaffolding (base, docs, node-ts variants)
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

The tree above is the canonical superset profile for the repository root harness.

---

## Repo-Root Harness

Octon supports one harness per repository:

| Dimension | Repo-Root Harness |
| --------- | ----------------- |
| Typical path | `/<repo>/.octon/` |
| Purpose | Repo-wide policy, defaults, shared assets, and operational state |
| Scope | Entire repository |
| Subsystems | Canonical full profile, trimmed only by normal repository-specific customization |
| Resolution | Always resolve to the outermost repo-root `.octon/` |

---

## Portability via `octon.yml`

Instead of splitting resources across two directories, `octon.yml` declares which paths are **portable** (safe to copy when bootstrapping a new repository) and which are **project-specific state** (stay with this repo).

### `octon.yml` (excerpt)

```yaml
schema_version: "1.0"

# Portable paths -- copy these to bootstrap a new repo via `octon init`.
# Everything else is project-specific state that stays with this repo.
portable:
  - START.md
  - scope.md
  - conventions.md
  - catalog.md
  - README.md
  - agency/manifest.yml
  - agency/governance/
  - agency/runtime/agents/
  - agency/runtime/assistants/
  - agency/runtime/teams/
  - agency/practices/
  - capabilities/runtime/skills/manifest.yml
  - capabilities/runtime/skills/registry.yml
  - capabilities/runtime/skills/capabilities.yml
  - capabilities/runtime/skills/_scaffold/template/
  - capabilities/runtime/skills/_ops/scripts/
  - capabilities/runtime/skills/**/SKILL.md
  - capabilities/runtime/skills/**/references/
  - capabilities/runtime/commands/
  - orchestration/runtime/workflows/
  - assurance/
  - scaffolding/
  - cognition/runtime/context/primitives.md
  - cognition/runtime/context/tools.md
  - cognition/runtime/context/compaction.md

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
| **Portable paths** | Listed under `portable:` in `octon.yml`. Copied by `octon init` when bootstrapping a new repo. |
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
| **Agency** | `agency/` | Actors, governance, practices | Yes (definitions are portable) |
| **Capabilities** | `capabilities/` | Skills, commands, tools | Yes (definitions are portable; logs and outputs are project-specific) |
| **Orchestration** | `orchestration/` | Workflows, missions | Partially (workflow definitions are portable; missions are project-specific) |
| **Continuity** | `continuity/` | Progress log, tasks, next steps | No (project-specific state) |
| **Quality** | `assurance/` | Completion checklists, session gates | Yes |
| **Scaffolding** | `scaffolding/` | runtime, governance, practices | Yes |
| **Ideation** | `ideation/` | Scratchpad, projects (human-led) | No (project-specific, human-led) |
| **Output** | `output/` | Reports, drafts, artifacts | No (project-specific artifacts) |

### Decision Heuristic

Ask: **"Should this travel to a new repository?"**

- **Yes** -- Add the path to `portable:` in `octon.yml`
- **No** -- Leave it out; it stays as project-specific state

---

## Harness Integration

Harness directories (`.claude/`, `.cursor/`, `.codex/`) integrate with `.octon/` via symlinks:

```
.claude/skills/synthesize-research -> ../../.octon/capabilities/runtime/skills/synthesize-research
.cursor/skills/synthesize-research -> ../../.octon/capabilities/runtime/skills/synthesize-research
.codex/skills/synthesize-research  -> ../../.octon/capabilities/runtime/skills/synthesize-research
```

### Why Symlinks?

| Benefit | Description |
| ------- | ----------- |
| Single source of truth | Skill definition lives in one place |
| Harness portability | Same skill works in Claude Code, Cursor, Codex |
| Easy updates | Change `.octon/`, all harnesses get the update |

### Command Wrappers

Harness commands in `.<harness>/commands/` are thin wrappers that delegate to `.octon/` workflows:

| Command | Delegates To |
| ------- | ------------ |
| `/synthesize-research` | `.octon/capabilities/runtime/skills/synthesize-research/` |

---

## When to Extend `.octon/`

Add to `.octon/` when you have:

| Situation | Action |
| --------- | ------ |
| A new agent or assistant | Add to `.octon/agency/runtime/` |
| A new reusable non-harness template bundle | Add to `.octon/scaffolding/runtime/templates/` |
| A new skill that other projects could use | Add to `.octon/capabilities/runtime/skills/` and mark its definition paths as `portable:` |
| A workflow that applies to any harness | Add to `.octon/orchestration/runtime/workflows/` |
| Project-specific state (progress, missions) | Add under the relevant category; do **not** mark as `portable:` |

---

## Adopting in Other Repositories

Use `octon.yml` portable paths to bootstrap `.octon/` in a new repository.

### Setup Steps

1. **Copy portable paths** using the init script or manually:
   ```bash
   # Preferred: use Octon CLI
   octon harness install --source /path/to/octon-repo --target /path/to/target-repo

   # Alias (same as harness install)
   octon init --source /path/to/octon-repo --target /path/to/target-repo

   # Manual: copy only portable paths
   # (Refer to octon.yml for the authoritative list)
   ```

2. **Create a root `octon.yml`** in the target repo to declare its own portable/state boundaries.

3. **Verify harness structure**:
   ```bash
   cd /path/to/target-repo/.octon
   bash init.sh
   ```

4. **Configure harness entry points** (optional):
   ```bash
   # For Claude Code
   mkdir -p .claude/commands

   # For Cursor
   mkdir -p .cursor/commands
   ```

5. **Set up skill symlinks** (if using skills):
   ```bash
   mkdir -p .cursor/skills
   ln -s ../../.octon/capabilities/runtime/skills/synthesize-research .cursor/skills/synthesize-research
   ```

### What You Get

| Category | Path | Description |
| -------- | ---- | ----------- |
| Agency | `agency/` | Actors, governance, practices |
| Capabilities | `capabilities/` | Skills framework, commands, tools |
| Scaffolding | `scaffolding/` | runtime, governance, practices |
| Quality | `assurance/` | Completion checklists |
| Cognition (partial) | `cognition/runtime/context/` | Reference material (tools, compaction) |

### Customization

After bootstrapping, you can:

- **Add repo-specific agents** to `.octon/agency/runtime/agents/`
- **Create custom templates** in `.octon/scaffolding/runtime/templates/`
- **Add new skills** to `.octon/capabilities/runtime/skills/`
- **Record project decisions** in `.octon/cognition/runtime/decisions/`
- **Track progress** in `.octon/continuity/`

Mark any new reusable content as `portable:` in `octon.yml` so it propagates to future repositories.

### Keeping Up to Date

When the source `.octon/` improves, selectively update portable paths:

```bash
# Compare portable paths
diff -r /path/to/octon/.octon/agency .octon/agency
diff -r /path/to/octon/.octon/scaffolding .octon/scaffolding

# Or run CLI update (preserves project-specific state)
octon harness update --source /path/to/octon-repo --target .
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

**Hybrid approach:** Start with portable paths via `octon init`. When you hit the signals above, extract the stable core into a package while keeping repo-specific content in a local `.octon/` that extends the package.

---

## Related Documentation

- [README.md](./README.md) -- Main harness documentation
- [Skills](../../../capabilities/runtime/skills/README.md) -- Composable capabilities with defined I/O
- [Workflows](../../../orchestration/_meta/architecture/workflows.md) -- Multi-step procedures
- [Taxonomy](./taxonomy.md) -- Harness entry points, commands, workflows relationships
