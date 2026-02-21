---
title: "ADR-003: Projects Elevation and Idea Funnel"
description: Elevate projects/ to workspace level and introduce brainstorm/ as filter stage.
date: 2026-01-14
status: accepted
mutability: append-only
---

# ADR-003: Projects Elevation and Idea Funnel

## Status

Accepted

## Context

Projects were previously located in `.scratchpad/projects/`. This created friction:

1. **Promotion overhead**: Projects frequently produce artifacts that feed `context/`, `missions/`, and other workspace areas. Having them in `.scratchpad/` required a separate "promotion" workflow.

2. **Unclear lifecycle**: Projects have significant structure (registry, templates, lifecycle) more like missions than ephemeral scratch content.

3. **Missing filter stage**: Ideas in `ideas/` either stayed there or jumped directly to full projects. There was no intermediate exploration stage to validate ideas before committing.

## Decision

### 1. Elevate `projects/` to Workspace Level

Move `projects/` from `.scratchpad/projects/` to `.harmony/ideation/projects/`:

```text
.workspace/
├── projects/           # Human-led explorations (produces artifacts)
│   ├── README.md
│   ├── registry.md
│   ├── _scaffold/template/
│   └── <project-slug>/
├── missions/           # Agent-accessible execution
└── .scratchpad/        # Ephemeral content and idea funnel
```

Projects are still **human-led** (require explicit direction for agent access), but findings flow directly to `context/` without a separate promotion step.

### 2. Introduce `brainstorm/` as Filter Stage

Add `.scratchpad/brainstorm/` as a lightweight exploration stage between `ideas/` and `projects/`:

```text
.scratchpad/
├── ideas/           # Quick captures (most die here)
├── brainstorm/      # Structured exploration (filter stage)
├── inbox/
├── archive/
└── ...
```

Brainstorms are **single files** (not directories like projects), with a simple lifecycle: `exploring` → `graduated` | `killed` | `parked`.

### 3. Define The Funnel

Establish a clear pipeline from raw ideas to committed work:

```
.scratchpad/ideas/      → Quick captures (most die here)
        ↓
.scratchpad/brainstorm/ → Structured exploration (filter stage)
        ↓
projects/               → Committed research (produces artifacts)
        ↓
missions/               → Committed execution
        ↓
context/                → Permanent knowledge
```

## Rationale

| Before | After | Benefit |
|--------|-------|---------|
| Projects in `.scratchpad/` | Projects at workspace level | Direct artifact flow |
| Separate promotion workflow | Findings publish directly | Less friction |
| Ideas → Projects jump | Ideas → Brainstorm → Projects | Better filtering |
| Unclear graduation path | Explicit funnel stages | Clear lifecycle |

### Why Projects Are Still Human-Led

Projects remain **human-led** (agents don't access autonomously) because:
- They're exploratory/divergent (not convergent execution)
- They benefit from human judgment about direction
- They may contain speculative thinking not ready for agents

The difference from before: projects now **live at workspace level** so findings flow naturally to `context/` without extra steps.

### Why Brainstorm Uses Single Files

Brainstorms are lightweight exploration, not committed research:
- Single file per topic (not a directory structure)
- Simple frontmatter status: `exploring | graduated | killed | parked`
- Most will be killed (that's the filter working)
- Successful ones graduate to full projects

## Consequences

### Benefits

- **Reduced friction**: Project findings flow directly to workspace artifacts
- **Better filtering**: Brainstorm stage catches ideas not worth full projects
- **Clearer model**: Parallel tracks for thinking (projects) vs doing (missions)
- **Explicit lifecycle**: The funnel documents how ideas mature

### Tradeoffs

- **Two human-led directories**: Both `projects/` and `.scratchpad/` require explicit direction
- **Migration needed**: Existing `.scratchpad/projects/` content must move to `projects/`

## Files Changed

### Created

- `.harmony/ideation/projects/README.md` — Projects overview with funnel
- `.harmony/ideation/projects/registry.md` — Project tracking
- `.harmony/ideation/projects/_scaffold/template/*` — Project templates
- `.harmony/ideation/scratchpad/brainstorm/README.md` — Brainstorm template
- `.harmony/orchestration/workflows/projects/create-project.md` — Project creation workflow

### Updated

- `.harmony/START.md` — Added projects, funnel, updated visibility rules
- `.harmony/catalog.md` — Changed workflow reference
- `.harmony/cognition/context/glossary.md` — Added Project, Brainstorm, The Funnel terms
- `.workspace/agent-autonomy-guard.globs` — Added projects pattern
- `.harmony/ideation/scratchpad/README.md` — Removed projects, added brainstorm, added funnel
- `.harmony/ideation/scratchpad/ideas/README.md` — Updated graduation paths
- `.harmony/ideation/scratchpad/inbox/README.md` — Updated destination references
- `.harmony/capabilities/skills/registry.yml` — Updated input paths
- `.harmony/orchestration/workflows/README.md` — Updated workflow references

### Documentation Updated

- `docs/architecture/workspaces/README.md` — Structure, categorization, funnel
- `docs/architecture/workspaces/scratchpad.md` — Full rewrite with funnel
- `docs/architecture/workspaces/projects.md` — Full rewrite for new location
- `docs/architecture/workspaces/dot-files.md` — Added projects, funnel, examples
- `docs/architecture/workspaces/skills.md` — Updated paths
- `docs/architecture/workspaces/workflows.md` — Updated example
- `docs/architecture/workspaces/taxonomy.md` — Updated diagram
- `docs/architecture/workspaces/shared-foundation.md` — Updated paths

### Shared Foundation Updated

- `.harmony/README.md` — Removed promote-from-scratchpad reference
- `.harmony/scaffolding/prompts/research/README.md` — Updated paths
- `.harmony/scaffolding/prompts/research/synthesize-findings.md` — Updated paths
- `.harmony/scaffolding/prompts/research/prepare-promotion.md` — Updated paths
- `.harmony/capabilities/skills/synthesize-research/README.md` — Updated examples
- `.harmony/capabilities/skills/synthesize-research/SKILL.md` — Updated paths
- `.harmony/scaffolding/templates/workspace/progress/next.md` — Updated description
- `.harmony/orchestration/workflows/workspace/migrate-workspace/02-structure-migration.md` — Added migration step

### Commands Updated

- `.cursor/commands/research.md` — Updated paths and added funnel
- `.cursor/commands/use-skill.md` — Updated paths
- `.cursor/commands/synthesize-research.md` — Updated paths

### Removed

- `.harmony/ideation/scratchpad/projects/` — Moved to `.harmony/ideation/projects/`
- `.harmony/orchestration/workflows/scratchpad/` — Replaced with `.harmony/orchestration/workflows/projects/`
- Promote-from-scratchpad workflow concept — Replaced by direct publishing

## Related Decisions

- **D010**: Projects location — Workspace level, not `.scratchpad/`
- **D011**: Brainstorm stage — Single-file exploration before projects
- **D012**: The Funnel — Pipeline from ideas to context
- **Updates D003/D008**: Human-led zones now include `projects/` alongside `.scratchpad/`
