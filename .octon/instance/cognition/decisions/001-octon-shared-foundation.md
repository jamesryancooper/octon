---
title: "ADR-001: Shared .octon/ Foundation"
description: Extract generic components from .workspace/ to shared .octon/ directory.
date: 2026-01-13
status: superseded
mutability: append-only
---

# ADR-001: Shared `.octon/` Foundation

## Status

Superseded

## Context

The root `.workspace/` contained both generic, reusable components (assistants, templates, workflows) and project-specific content (progress, missions, domain context). This created risks:

- **Duplication**: Creating new workspaces elsewhere would copy generic components
- **Drift**: Generic components could diverge between workspaces
- **Maintenance burden**: Updates to generic workflows required changes in multiple places

## Decision

This ADR captured the initial migration from `.workspace/` toward `.octon/`. Its original layered override model is superseded.

Current rule:

- Use one repo-root `.octon/` per repository
- Keep domain-specific guidance under repo-root `.octon/` paths
- Do not use additional `.octon/` directories on the same ancestor chain

## Components Moved to `.octon/`

| Component | Contents |
|-----------|----------|
| `assistants/` | reviewer, refactor, docs (generic specialists) |
| `templates/` | octon/ plus reusable template bundles |
| `workflows/` | workspace management, missions, skills, promote-from-scratchpad |
| `commands/` | recover, validate-frontmatter |
| `context/` | tools.md, compaction.md |
| `checklists/` | complete.md, session-exit.md |
| `prompts/` | bootstrap-session, research/ |
| `skills/` | framework, _scaffold/template/, synthesize-research |
| `examples/` | create-workspace-flow.md |

## Components Remaining in `.workspace/`

| Component | Reason |
|-----------|--------|
| `START.md`, `scope.md`, `conventions.md`, `catalog.md` | Workspace definition (always local) |
| `progress/` | Session continuity (always local) |
| `missions/` | Time-bounded sub-projects (always local) |
| `context/decisions.md`, `lessons.md`, `glossary.md`, `constraints.md` | Domain-specific knowledge |
| `workflows/audit/`, `workflows/tasks/` | Domain-specific workflows |
| `skills/outputs/`, `skills//.octon/state/evidence/runs/skills/` | Execution artifacts (always local) |
| Stub READMEs | Override points + discoverability |

## Skills Registry Split

To separate skill definitions from project-specific configuration:

- **`.octon/framework/capabilities/skills/registry.yml`**: Skill definitions (id, name, commands, triggers) without paths
- **`.octon/framework/capabilities/skills/registry.yml`**: Project-specific input/output mappings, extends octon registry

## Harness Integration

Symlinks updated to point to `.octon/framework/capabilities/skills/`:

```
.claude/skills/synthesize-research -> ../../.octon/framework/capabilities/skills/synthesize-research
.codex/skills/synthesize-research -> ../../.octon/framework/capabilities/skills/synthesize-research
.cursor/skills/synthesize-research -> ../../.octon/framework/capabilities/skills/synthesize-research
```

Cursor commands updated to reference `.octon/` for shared workflows:

| Command | Delegates To |
|---------|--------------|
| `/create-workspace` | `.octon/framework/orchestration/workflows/workspace/create-workspace/` |
| `/bootstrap` | `.octon/framework/scaffolding/prompts/bootstrap-session.md` |
| `/synthesize-research` | `.octon/framework/capabilities/skills/synthesize-research/` |

## Consequences

### Benefits

- **Single source of truth**: Generic components maintained in one place
- **No duplication**: New workspaces inherit from `.octon/` without copying
- **Override capability**: Local `.workspace/` can override any shared component
- **Portability**: `.octon/` can be shared across repos or extracted as a package

### Tradeoffs

- **Two locations to check**: Agents must understand inheritance model
- **Stub READMEs**: Empty directories with READMEs for discoverability
- **Split registries**: Skills registry pattern is more complex

## Files Changed

- `CLAUDE.md` - Updated to reference `.octon/framework/capabilities/skills/`
- `.cursor/commands/*.md` (12 files) - Updated paths
- `.cursor/rules/*.md` (3 files) - Updated globs and template paths
- `.octon/instance/bootstrap/START.md` - Added inheritance section
- `docs/architecture/workspaces/README.md` - Added initial migration docs for the old workspace model
- `.octon/framework/capabilities/skills/scripts/setup-harness-links.sh` - Updated to check both locations
