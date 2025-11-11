---
title: Authoring Components in @harmony/ui
description: Tailwind usage rules inside the kit, file layout, Button example, and accessibility/state conventions.
---

## Goals

- Keep Tailwind usage confined to the UI Kit.
- Produce stable, precompiled CSS with explicit `@layer` ordering.
- Expose theming via CSS variables; avoid leaking Tailwind to consumers.

## File layout (suggested)

```
packages/ui/
  src/
    components/
      Button.tsx
      Card.tsx
      ...
    styles/
      base.css
      button.css
      card.css
      ...
  postcss.config.mjs
  tailwind.config.ts
```

## Tailwind usage rules inside the kit

- Prefer `@apply` to compose common Tailwind utilities into semantic classes under `@layer components`.
- Keep component selectors low-specificity and token-driven (CSS variables), enabling app-side overrides.
- Scope any kit-level helpers under `@layer utilities` sparingly; prefer shipping recipes instead.
- Avoid deep descendant selectors and `!important` – rely on layer order instead.
- Export split CSS entries per component where beneficial for tree-shaking.

## Example: Button built with Tailwind + @apply

```css
/* @harmony/ui/src/styles/button.css */
@layer components {
  .btn { @apply inline-flex items-center justify-center font-semibold rounded-xl px-4 py-2; }
  .btn--primary { @apply bg-[var(--brand)] text-white hover:opacity-90; }
  .btn--ghost { @apply bg-transparent text-[var(--brand)] ring-1 ring-[color-mix(in srgb,var(--brand) 50%,transparent)]; }
}
```

```tsx
// @harmony/ui/src/components/Button.tsx
import clsx from 'clsx'

export function Button({ variant='primary', className, ...props }: { variant?: 'primary' | 'ghost' } & React.ButtonHTMLAttributes<HTMLButtonElement>) {
  return <button className={clsx('btn', `btn--${variant}`, className)} {...props} />
}
```

### Accessibility and state conventions

- Provide visible focus styles that meet contrast ratios; prefer outline/ring styles that align with tokens.
- Respect `prefers-reduced-motion`; avoid large transitions on critical interactions.
- Ensure disabled states are non-interactive and communicated via `aria-disabled` where appropriate.
- Provide keyboard-accessible targets with sufficient hit areas and semantics.


