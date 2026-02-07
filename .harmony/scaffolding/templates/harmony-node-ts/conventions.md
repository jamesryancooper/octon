---
title: Conventions
description: Style and formatting rules for Node.js/TypeScript workspaces.
---

# Conventions

## File Naming

- Components: PascalCase (`Button.tsx`, `TextInput.tsx`)
- Component folders: PascalCase (`Button/`, `TextInput/`)
- Utilities: camelCase (`formatClassName.ts`)
- Tests: `ComponentName.test.tsx` or `__tests__/ComponentName.test.tsx`
- Stories: `ComponentName.stories.tsx`
- Styles: `ComponentName.module.css`

## Component Structure

```text
src/components/Button/
├── Button.tsx           # Component implementation
├── Button.test.tsx      # Tests
├── Button.stories.tsx   # Storybook stories (if applicable)
├── Button.module.css    # Styles (if needed)
└── index.ts             # Re-export
```

## Export Pattern

```typescript
// src/components/Button/index.ts
export { Button } from './Button';
export type { ButtonProps } from './Button';
```

## Writing Style

| Do | Don't |
|----|-------|
| Export named components | Use default exports |
| Co-locate tests with components | Put tests in separate tree |
| Use CSS modules for styles | Use global CSS |
| Document props with JSDoc | Skip prop documentation |

## Progress Log Format

```markdown
## YYYY-MM-DD

**Session focus:** [one-line summary]

**Completed:**
- [task 1]

**Next:**
- [priority item]

**Blockers:**
- [if any]
```

