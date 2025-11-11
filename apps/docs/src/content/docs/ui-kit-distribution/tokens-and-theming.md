---
title: Tokens and Theming
description: Map design tokens to CSS variables. Support light/dark/brand themes at runtime with or without @harmony/tokens.
---

## Options

- With `@harmony/tokens` (recommended): publish a package that exports CSS variables and TS types. The UI Kit consumes tokens; apps override via variables.
- Without `@harmony/tokens`: define CSS variables directly in the app’s `app/styles/app.css` and in kit CSS.

## With @harmony/tokens

Package exposes:

- CSS: `:root { --brand: ..., --surface: ..., --fs-1: ... }`
- TS: `BrandColor`, `SpacingScale`, `TypeScale` types for compile-time safety.

UI Kit consumes variables in recipes:

```css
/* packages/ui/src/styles/button.css (excerpt) */
@layer components {
  .btn--primary { @apply bg-[var(--brand)] text-white; }
}
```

App overrides with brand/theme vars:

```css
/* app/styles/app.css (excerpt) */
:root { --brand: #3b82f6; }
```

## Without @harmony/tokens

Define variables locally and use them in micro-utilities and overrides:

```css
/* app/styles/app.css (tokens + utilities) */
:root {
  --brand: #3b82f6;
  --surface: #ffffff;
  --ink: #111827;
  --fs-0: clamp(.875rem,.8rem+.2vw,1rem);
  --fs-1: clamp(1.125rem,1rem+.5vw,1.25rem);
}
```

## Runtime theming patterns

Toggle themes at runtime by switching CSS variables. Prefer data attributes to avoid specificity issues:

```tsx
// app/components/ThemeToggle.tsx
'use client'

export function ThemeToggle() {
  return (
    <button
      className="button button--ghost"
      onClick={() => {
        const el = document.documentElement
        const next = el.dataset.theme === 'dark' ? 'light' : 'dark'
        el.dataset.theme = next
      }}
    >
      Toggle theme
    </button>
  )
}
```

```css
/* app/styles/app.css (append dark mode overrides) */
:root[data-theme="dark"] {
  --surface: #0b1220;
  --surface-2: #121a2b;
  --ink: #e5e7eb;
  --muted-ink: #9ca3af;
}
```

### Scope

- Global theme: set variables on `:root`.
- Per-container theme: set variables on a container (e.g., `.marketing`) and scope styles under that container.

### SSR hydration notes

- To avoid flash, render the initial theme attribute server-side (e.g., `data-theme="dark"` on `<html>`), 
  or inline a small script in `<head>` that reads persisted preference and sets the attribute before CSS loads.
- Keep variables stable across server and client renders to prevent hydration warnings.


