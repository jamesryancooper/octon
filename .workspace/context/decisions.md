---
title: Decisions
description: Agent-readable summary of key decisions affecting this workspace.
mutability: append-only
---

# Decisions

Key decisions that constrain or guide work in this workspace. For full rationale, see `.workspace/decisions/`.

**ADRs:**
- [ADR-001](../decisions/001-harmony-shared-foundation.md) — Shared `.harmony/` foundation (D007)
- [ADR-002](../decisions/002-consolidated-scratchpad-zone.md) — Consolidated `.scratchpad/` zone (D003, D005, D008, D009)
- [ADR-003](../decisions/003-projects-elevation-and-funnel.md) — Projects elevation and idea funnel (D010, D011, D012)
- [ADR-004](../decisions/004-refactor-workflow.md) — Refactor workflow and universal commands (D013, D014, D015, D016)

## Active Decisions

| ID | Decision | Choice | Constraint | Date |
|----|----------|--------|------------|------|
| D001 | State format | JSON over YAML | Must parse without external dependencies | 2025-12-10 |
| D002 | Token budget | ~2,000 target, ~5,000 max | Leave context window for actual work | 2025-12-10 |
| D003 | Human-led zones | `.scratchpad/` and `projects/` directories | Human-led content in designated zones; agents MUST NOT access autonomously | 2026-01-14 |
| D004 | Boot sequence | 7-step process | Ensures consistent orientation | 2025-12-18 |
| D005 | Human-led collaboration | `.scratchpad/` and `projects/` | Human-led collaboration allowed when explicitly directed; autonomous access forbidden | 2026-01-14 |
| D007 | Shared foundation | `.harmony/` for generic, `.workspace/` for local | Generic components shared; local overrides shared; check local first | 2026-01-13 |
| D008 | Consolidated scratchpad | `.scratchpad/` with subdirectories | `inbox/`, `archive/`, `ideas/`, `brainstorm/` are subdirectories of `.scratchpad/` | 2026-01-14 |
| D009 | Human-led zone naming | `.scratchpad/` over `.scratch/` | Explicit, self-documenting name preferred over shorter abbreviation | 2026-01-13 |
| D010 | Projects location | Workspace level (`projects/`) | Projects live at workspace level, not in `.scratchpad/`; direct artifact flow to `context/` | 2026-01-14 |
| D011 | Brainstorm stage | Single-file exploration in `.scratchpad/brainstorm/` | Filter stage between ideas and projects; most ideas die here | 2026-01-14 |
| D012 | The Funnel | ideas → brainstorm → projects → missions → context | Clear pipeline from raw ideas to permanent knowledge | 2026-01-14 |
| D013 | Refactor verification | Mandatory verification gate | Refactors cannot be declared complete until all audit searches return zero | 2026-01-14 |
| D014 | Continuity artifact immutability | Append-only during refactors | Historical records (`progress/log.md`, `decisions/*.md`) must not be modified, only appended | 2026-01-14 |
| D015 | Universal commands | Symlink from harness to `.harmony/commands/` | Commands defined once in `.harmony/`, symlinked to `.cursor/`, `.claude/` | 2026-01-14 |
| D016 | Mutability frontmatter | `mutability: append-only` property | Files with this property must not have existing content modified; check before editing | 2026-01-14 |

## Decision Format

When adding decisions:

```markdown
| ID | Decision | Choice | Constraint | Date |
|----|----------|--------|------------|------|
| DXXX | What was decided | What we chose | Why it matters to agents | YYYY-MM-DD |
```

- **ID**: Sequential identifier (D001, D002, ...)
- **Decision**: Brief name of what was decided
- **Choice**: The option selected
- **Constraint**: How this affects agent behavior
- **Date**: When decided

## Superseded Decisions

Move here when a decision is replaced. Include reference to replacement.

| ID | Decision | Superseded By | Date |
|----|----------|---------------|------|
| D006 | Scratch vs inbox semantics | D008 | 2026-01-13 |

