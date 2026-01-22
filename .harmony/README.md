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
.workspace/          <- Project-specific (progress, missions, domain context)
```

Local `.workspace/` directories inherit from `.harmony/` and can override where needed.

## Override Priority

When resolving a resource, agents check local first, then shared:

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

## Structure

```
.harmony/
├── README.md           <- You are here
│
├── assistants/         <- Generic specialists (@mention invocation)
│   ├── registry.yml
│   ├── _template/
│   ├── reviewer/
│   ├── refactor/
│   └── docs/
│
├── templates/          <- Workspace scaffolding
│   ├── workspace/
│   ├── workspace-docs/
│   └── workspace-node-ts/
│
├── workflows/          <- Generic multi-step procedures
│   ├── workspace/      <- Workspace management
│   ├── missions/       <- Mission lifecycle
│   └── skills/         <- Skill creation
│
├── commands/           <- Generic atomic operations
│   ├── recover.md
│   ├── refactor.md
│   └── validate-frontmatter.md
│
├── context/            <- Generic reference material
│   ├── tools.md
│   └── compaction.md
│
├── checklists/         <- Generic quality gates
│   ├── complete.md
│   └── session-exit.md
│
├── prompts/            <- Generic task templates
│   ├── bootstrap-session.md
│   └── research/
│
├── skills/             <- Skills framework + generic skills
│   ├── registry.yml
│   ├── _template/
│   ├── synthesize-research/
│   └── scripts/
│
└── examples/           <- Reference patterns
```

## What Lives Here vs. `.workspace/`

### In `.harmony/` (Shared)

- Generic assistants (reviewer, refactor, docs)
- Base templates for workspace creation
- Workspace/mission management workflows
- Generic commands (recover, refactor, validate-frontmatter)
- Tool usage and compaction guides
- Base quality checklists
- Skills framework and generic skills

### In `.workspace/` (Project-Specific)

- `START.md`, `scope.md`, `conventions.md`, `catalog.md`
- `progress/` (session continuity)
- `missions/` instances (time-bounded sub-projects)
- Domain-specific context (decisions, lessons, glossary, constraints)
- Domain-specific workflows (e.g., flowkit)
- Skills outputs and logs (always local)
- `.scratchpad/` (human-led zone with inbox/, archive/, projects/, etc.)

## Skills Registry Pattern

`.harmony/skills/registry.yml` defines skill capabilities without project-specific paths.

`.workspace/skills/registry.yml` extends the harmony registry and adds:
- Project-specific input/output mappings
- Project-specific skills
- Project-specific pipelines

## Harness Integration

### Skills

Harness directories (`.claude/`, `.cursor/`, `.codex/`) symlink to `.harmony/skills/` for shared skills:

```
.claude/skills/synthesize-research -> ../../.harmony/skills/synthesize-research
.cursor/skills/synthesize-research -> ../../.harmony/skills/synthesize-research
.codex/skills/synthesize-research -> ../../.harmony/skills/synthesize-research
```

### Commands

Harness command directories symlink to `.harmony/commands/` for shared commands:

```
.cursor/commands/refactor.md -> ../../.harmony/commands/refactor.md
.claude/commands/refactor.md -> ../../.harmony/commands/refactor.md
```

**Note:** Codex CLI does not support project-level custom commands. Codex users have two options:
1. Manually copy commands from `.harmony/commands/` to `~/.codex/prompts/`
2. Invoke the workflow directly: "Execute `.harmony/workflows/refactor/00-overview.md`"

## Adopting in Other Repos

To use this workspace infrastructure in another repository:

### Quick Start

```bash
# 1. Copy .harmony/ to your repo
cp -r /path/to/harmony/.harmony /path/to/your-repo/

# 2. Create a root workspace from template
cp -r .harmony/templates/workspace .workspace

# 3. Customize .workspace/scope.md and .workspace/conventions.md
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

1. Edit `.workspace/scope.md` to define your repo's boundaries
2. Edit `.workspace/conventions.md` for your style rules
3. Add repo-specific context to `.workspace/context/`
4. Create domain workspaces as needed: `docs/.workspace/`, `packages/foo/.workspace/`

For detailed documentation, see `docs/architecture/workspaces/shared-foundation.md`.

### When to Consider a Package

If you have 5+ repositories using this pattern, frequent updates, or need semantic versioning, consider converting `.harmony/` to a published package. See `docs/architecture/workspaces/shared-foundation.md#when-to-consider-a-package` for guidance.
