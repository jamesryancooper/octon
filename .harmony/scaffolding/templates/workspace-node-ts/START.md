---
title: Start Here
description: Boot sequence and orientation for Node.js/TypeScript workspaces.
---

# .workspace: Start Here

## Prerequisites

```bash
pnpm install
```

## Boot Sequence

1. **Read `scope.md`** → Know boundaries
2. **Read `conventions.md`** → Know style rules
3. **Read `progress/log.md`** → Know what's been done
4. **Read `progress/tasks.json`** → Know current priorities
5. **Begin** highest-priority unblocked task
6. **Before finishing:** Update `progress/log.md`, verify against `checklists/complete.md`

## Key Files

- Entry point: `src/index.ts`
- Components: `src/components/`
- Tests: `__tests__/` or `*.test.ts`
- Stories: `src/**/*.stories.tsx` (if applicable)

## Visibility & Autonomy Rules

| Directory | Autonomy | Description |
|-----------|----------|-------------|
| `.scratchpad/` | **Human-led only** | Human-led zone (thinking, staging, archives) |

Subdirectories: `inbox/` (staging), `archive/` (deprecated), `projects/` (research).

**Human-led:** Access ONLY when human explicitly directs to specific files.

## When Stuck

- Check component patterns in `src/components/`
- Review test examples in `__tests__/`
- Run `pnpm test` to verify changes
- See Storybook at `pnpm storybook` (if applicable)

