---
title: "ADR-002: Consolidated .scratchpad/ Human-Led Zone"
description: Consolidate .humans/, .inbox/, and .archive/ into single .scratchpad/ directory.
date: 2026-01-13
status: accepted
mutability: append-only
---

# ADR-002: Consolidated `.scratchpad/` Human-Led Zone

## Status

Accepted

## Context

The workspace architecture previously used multiple dot-prefixed directories for human-led content:

- `.humans/` — Explanatory content, rationale, decision details
- `.inbox/` — Temporary staging for external imports
- `.archive/` — Deprecated content preserved for reference
- `.scratchpad/` — Persistent thinking, research, exploration

This created several problems:

- **Conceptual overhead**: Four separate directories with subtle autonomy distinctions
- **Fragmented content**: Related human content scattered across locations
- **Unnecessary complexity**: `.humans/` duplicated concepts available elsewhere (`docs/`, `.scratchpad/`)
- **Agent confusion**: Multiple autonomy rules (never-access vs human-led) added complexity

Additionally, with an agent-first philosophy, tracking human access via dedicated directories is unnecessary—access can be tracked in YAML frontmatter if needed.

## Decision

Consolidate all human-led content into a **single `.scratchpad/` directory** with subdirectories:

```text
.scratchpad/
├── README.md       # Purpose and rules
├── inbox/          # Temporary staging (was .inbox/)
├── archive/        # Deprecated content (was .archive/)
├── projects/       # Isolated research projects
├── ideas/          # Brainstorming and possibilities
├── daily/          # Date-based notes (YYYY-MM-DD.md)
├── drafts/         # Work-in-progress documents
└── clips/          # Snippets and fragments
```

**Single autonomy rule**: Agents MUST NOT access `.scratchpad/**` autonomously. Human-directed collaboration is allowed when explicitly pointed to specific files.

## Rationale

| Before | After | Benefit |
|--------|-------|---------|
| 4 directories with different rules | 1 directory with one rule | Simpler mental model |
| `.humans/` for explanations | `docs/` or `.scratchpad/` | Clearer purposes |
| Separate `.inbox/`, `.archive/` | Subdirectories of `.scratchpad/` | Unified location |
| Multiple autonomy levels | Single human-led rule | Easier enforcement |

## Migration

1. Move `.inbox/*` → `.scratchpad/inbox/`
2. Move `.archive/*` → `.scratchpad/archive/`
3. Remove `.humans/` (content goes to `docs/` or `.scratchpad/`)
4. Update all documentation and workflows to reference new structure

**Note**: Mission-specific archives (`missions/.archive/`) remain unchanged—these are distinct from workspace-level archives.

## Consequences

### Benefits

- **Simpler model**: One human-led zone with clear purpose
- **Easier navigation**: All human content in predictable location
- **Cleaner autonomy**: Single rule for agent behavior
- **Better organization**: Subdirectories provide structure within human zone

### Tradeoffs

- **Deeper nesting**: `inbox/` and `archive/` are now subdirectories
- **Historical entries**: Progress logs reference old directories (preserved as history)

## Files Changed

### Documentation Updated

- `docs/architecture/workspaces/README.md` — Updated structure diagrams
- `docs/architecture/workspaces/dot-files.md` — Rewritten for single `.scratchpad/`
- `docs/architecture/workspaces/scratchpad.md` — Updated with subdirectory structure
- `docs/architecture/workspaces/context.md` — Updated references
- `docs/architecture/workspaces/missions.md` — Clarified mission-specific archive

### Workspace Updated

- `.octon/START.md` — Updated structure and visibility rules
- `.octon/cognition/context/glossary.md` — Consolidated terminology
- `.octon/cognition/context/constraints.md` — Updated for single human-led zone
- `.octon/cognition/context/lessons.md` — Updated references
- `.octon/cognition/context/decisions.md` — Added D003, D005, D008; superseded D006
- `.octon/conventions.md` — Updated references
- `.octon/catalog.md` — Updated archive reference
- `.octon/orchestration/missions/README.md` — Clarified mission archive path
- `.octon/ideation/scratchpad/README.md` — Updated for consolidated structure

### Shared Foundation Updated

- `.octon/assurance/complete.md` — Updated references
- `.octon/assurance/session-exit.md` — Updated references
- `.octon/orchestration/workflows/promote-from-scratchpad.md` — Updated references
- `.octon/orchestration/workflows/workspace/evaluate-workspace/*` — Updated references
- `.octon/orchestration/workflows/workspace/update-workspace/*` — Updated references
- `.octon/orchestration/workflows/workspace/migrate-workspace/*` — Rewritten for new structure
- `.octon/scaffolding/templates/workspace/conventions.md` — Updated references
- `.octon/scaffolding/templates/workspace/checklists/done.md` — Updated references
- Removed `.octon/scaffolding/templates/workspace-docs/workflows/.humans/` directory

### Physical Structure

- Created `.octon/ideation/scratchpad/inbox/`
- Created `.octon/ideation/scratchpad/archive/`
- Moved content from old directories
- Removed empty `.workspace/.inbox/`, `.workspace/.archive/`, `.workspace/.humans/`

## Naming Choice

The directory is named `.scratchpad/` rather than `.scratch/` for explicitness. While `.scratch/` is shorter, `.scratchpad/` is more self-documenting and immediately clear to newcomers. The 3-character difference is negligible given that:

1. The directory is human-led (humans type/navigate it, not agents)
2. Tab completion handles the extra characters
3. Clarity benefits outweigh brevity

## Related Decisions

- **D003**: Human-led zone — Single `.scratchpad/` directory
- **D005**: Human-led collaboration — `.scratchpad/` only
- **D008**: Consolidated human zones — Subdirectories within `.scratchpad/`
- **D009**: Naming choice — `.scratchpad/` over `.scratch/` for explicitness
- **Supersedes D006**: Scratch vs inbox semantics (now both in `.scratchpad/`)

