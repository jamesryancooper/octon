# .harmony: Shared Workspace Foundation

## Purpose

`.harmony/` provides **reusable infrastructure** for workspace harnesses across the repository:

- Generic assistants, workflows, commands, prompts
- Workspace templates for scaffolding
- Skills framework and base skills
- Quality checklists and context references

**Portability:** This directory is designed to be copied to other repositories. See [Adopting in Other Repos](#adopting-in-other-repos) below.

## Inheritance Model

```
.harmony/            <- Shared foundation (generic, domain-agnostic)
    |
    v inherits
.harmony/            <- Single root (all content organized by cognitive function)
```

All content now lives under `.harmony/`, organized by cognitive function.

## Override Priority

When resolving a resource, agents check local first, then shared:

| Resource | Search Order |
|----------|--------------|
| Assistants | `.harmony/agency/assistants/` |
| Templates | `.harmony/scaffolding/templates/` |
| Workflows | `.harmony/orchestration/workflows/` |
| Skills | `.harmony/capabilities/skills/` |
| Commands | `.harmony/capabilities/commands/` |
| Prompts | `.harmony/scaffolding/prompts/` |
| Checklists | `.harmony/quality/` |
| Context | `.harmony/cognition/context/` |

## Structure

```
.harmony/
├── README.md           <- You are here
│
├── agency/
│   └── assistants/     <- Generic specialists (@mention invocation)
│
├── capabilities/
│   ├── skills/         <- Skills framework + generic skills
│   └── commands/       <- Generic atomic operations
│
├── cognition/
│   └── context/        <- Generic reference material (tools, compaction)
│
├── continuity/         <- Session log, tasks, entities
│
├── orchestration/
│   ├── workflows/      <- Multi-step procedures (workspace, missions, skills)
│   └── missions/       <- Time-bounded sub-projects
│
├── scaffolding/
│   ├── templates/      <- Workspace scaffolding (harmony/, harmony-docs/, harmony-node-ts/)
│   ├── prompts/        <- Task templates
│   └── examples/       <- Reference patterns
│
├── quality/            <- Quality gates (done.md, session-exit.md)
│
├── ideation/           <- Human-led zone (scratchpad/, projects/)
│
└── output/             <- Reports, drafts, artifacts
```

## What Lives Here

### In `.harmony/` (Shared)

- Generic assistants (reviewer, refactor, docs)
- Base templates for workspace creation
- Workspace/mission management workflows
- Generic commands (recover, refactor, validate-frontmatter)
- Tool usage and compaction guides
- Base quality checklists
- Skills framework and generic skills

### Project-Specific Content

- `START.md`, `scope.md`, `conventions.md`, `catalog.md`
- `continuity/` (session log, tasks, entities)
- `orchestration/missions/` instances (time-bounded sub-projects)
- Domain-specific context (`cognition/context/` — decisions, lessons, glossary, constraints)
- Domain-specific workflows (e.g., flowkit)
- Skills outputs and logs (always local)
- `ideation/scratchpad/` (human-led zone with inbox/, archive/, etc.)

## Skills Registry Pattern

`.harmony/capabilities/skills/registry.yml` defines skill capabilities without project-specific paths.

`.harmony/capabilities/skills/registry.yml` defines skill capabilities and adds:
- Project-specific input/output mappings
- Project-specific skills
- Project-specific pipelines

## Harness Integration

### Skills

Harness directories (`.claude/`, `.cursor/`, `.codex/`) symlink to `.harmony/capabilities/skills/` for shared skills:

```
.claude/skills/synthesize-research -> ../../.harmony/capabilities/skills/synthesize-research
.cursor/skills/synthesize-research -> ../../.harmony/capabilities/skills/synthesize-research
.codex/skills/synthesize-research -> ../../.harmony/capabilities/skills/synthesize-research
```

### Commands

Harness command directories symlink to `.harmony/capabilities/commands/` for shared commands:

```
.cursor/commands/refactor.md -> ../../.harmony/capabilities/commands/refactor.md
.claude/commands/refactor.md -> ../../.harmony/capabilities/commands/refactor.md
```

**Note:** Codex CLI does not support project-level custom commands. Codex users have two options:
1. Manually copy commands from `.harmony/capabilities/commands/` to `~/.codex/prompts/`
2. Invoke the workflow directly: "Execute `.harmony/orchestration/workflows/refactor/00-overview.md`"

## Adopting in Other Repos

To use this workspace infrastructure in another repository:

### Quick Start

```bash
# 1. Copy .harmony/ to your repo
cp -r /path/to/harmony/.harmony /path/to/your-repo/

# 2. Create a root workspace from template
cp -r .harmony/scaffolding/templates/harmony .harmony

# 3. Customize .harmony/scope.md and .harmony/conventions.md
```

### What's Included

| Directory | Purpose |
|-----------|---------|
| `templates/` | Workspace scaffolding (base + variants) |
| `assistants/` | Generic specialists (reviewer, refactor, docs) |
| `workflows/` | Workspace management + mission lifecycle |
| `skills/` | Composable capabilities with defined I/O |
| `commands/` | Atomic operations |
| `prompts/` | Task templates |
| `checklists/` | Quality gates |
| `context/` | Tool usage, compaction guides |

### Next Steps

1. Edit `.harmony/scope.md` to define your repo's boundaries
2. Edit `.harmony/conventions.md` for your style rules
3. Add repo-specific context to `.harmony/cognition/context/`
4. Create domain workspaces as needed: `docs/.harmony/`, `packages/foo/.harmony/`

For detailed documentation, see `docs/architecture/workspaces/shared-foundation.md`.

### When to Consider a Package

If you have 5+ repositories using this pattern, frequent updates, or need semantic versioning, consider converting `.harmony/` to a published package. See `docs/architecture/workspaces/shared-foundation.md#when-to-consider-a-package` for guidance.
