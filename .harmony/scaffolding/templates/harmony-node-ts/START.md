---
title: Start Here
description: Boot sequence and orientation for Node.js/TypeScript harnesses.
---

# .harmony: Start Here

## Prerequisites

```bash
pnpm install
```

## Boot Sequence

1. **Read `scope.md`** → Know boundaries
2. **Read `conventions.md`** → Know style rules
3. **Read `continuity/log.md`** → Know what's been done
4. **Read `continuity/tasks.json`** → Know current priorities
5. **Begin** highest-priority unblocked task
6. **Before finishing:** Update `continuity/log.md`, verify against `assurance/practices/complete.md`

## Key Files

- Entry point: `src/index.ts`
- Components: `src/components/`
- Tests: `__tests__/` or `*.test.ts`
- Stories: `src/**/*.stories.tsx` (if applicable)

## Visibility & Autonomy Rules

| Directory | Autonomy | Description |
|-----------|----------|-------------|
| `ideation/scratchpad/` | **Human-led only** | Human-led zone (thinking, staging, archives) |

Subdirectories: `inbox/` (staging), `archive/` (deprecated), `projects/` (research).

**Human-led:** Access ONLY when human explicitly directs to specific files.

## When Stuck

- Check component patterns in `src/components/`
- Review test examples in `__tests__/`
- Run `pnpm test` to verify changes
- See Storybook at `pnpm storybook` (if applicable)

