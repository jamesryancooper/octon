---
title: Decisions
description: Agent-readable summary of key decisions affecting this workspace
---

# Decisions

Key decisions that constrain or guide work in this workspace. For full rationale, see `.humans/decisions/`.

## Active Decisions

| ID | Decision | Choice | Constraint | Date |
|----|----------|--------|------------|------|
| D001 | State format | JSON over YAML | Must parse without external dependencies | 2025-12-10 |
| D002 | Token budget | ~2,000 target, ~5,000 max | Leave context window for actual work | 2025-12-10 |
| D003 | Agent-ignored prefix | Dot (`.`) prefix | `.humans/`, `.scratch/`, `.inbox/`, `.archive/` off-limits to autonomous agents | 2025-12-10 |
| D004 | Boot sequence | 7-step process | Ensures consistent orientation | 2025-12-18 |
| D005 | Human-led directories | `.scratch/` and `.inbox/` | Human-led collaboration allowed when explicitly directed; autonomous access forbidden | 2025-01-04 |
| D006 | Scratch vs inbox semantics | Scratch=persistent, inbox=temporary | `.scratch/` for ongoing research; `.inbox/` for imports that move out | 2025-01-04 |

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
| — | — | — | — |

