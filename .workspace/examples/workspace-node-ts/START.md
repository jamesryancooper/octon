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
6. **Before finishing:** Update `progress/log.md`, verify against `checklists/done.md`

## Key Files

- Entry point: `src/index.ts`
- Components: `src/components/`
- Tests: `__tests__/`
- Stories: `src/**/*.stories.tsx`

## Off-Limits

- `.humans/` — Human documentation
- `.inbox/` — Unprocessed materials
- `.archive/` — Deprecated content

## When Stuck

- Check component patterns in `src/components/Button/`
- Review test examples in `__tests__/`
- See Storybook at `pnpm storybook`
