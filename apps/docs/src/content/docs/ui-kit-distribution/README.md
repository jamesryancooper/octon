---
title: UI Kit Distribution Model
description: Ship @harmony/ui as precompiled CSS; apps import CSS (no Tailwind) and theme via CSS variables. Works across multiple apps with Turborepo + Next.js (App Router).
---

## Overview

This distribution model confines Tailwind to the design system package `@harmony/ui`, compiles styles to prebuilt CSS (for example, `dist/ui.css` and split CSS entries), and has apps import the compiled CSS directly. Apps do not run Tailwind. They theme at runtime via CSS variables and compose pages using a tiny set of micro-utilities plus CSS Modules.

### Why this model

- Tooling is decoupled from apps: Tailwind/PostCSS upgrades happen once inside the UI Kit.
- Consistency: A single, versioned DS controls spacing, color, typography, states, and a11y.
- Performance discipline: Ship only what components use. Enable CSS entrypoint splitting for tree-shaking.
- Cross-framework reuse: Precompiled CSS + tokens work in Next, Remix, static sites, etc.
- Runtime theming: CSS variables enable light/dark/brand modes without rebuilds.

### Non-goals

- Re-enabling Tailwind in apps (apps remain Tailwind-free).
- Exposing every Tailwind utility to apps. Use micro-utilities + CSS Modules for page layout and specifics.

## High-level architecture

```mermaid
flowchart TD
  subgraph UI_Kit_Package[@harmony/ui]
    A[Tailwind source (RSC-friendly CSS)
      + optional @harmony/tokens] --> B[Tailwind + PostCSS build]
    B --> C[dist/ui.css]
    B --> D[dist/css/* split entries]
    B --> E[package.json exports + sideEffects]
  end

  C --> F[[Next.js App (App Router)]]
  D --> F
  E --> F
  F --> G[Runtime DOM]
  F --> H[App overrides via CSS variables + CSS Modules]
```

## Five-minute quick start (existing Turborepo + Next app)

1) Import the UI Kit CSS and your app overrides in `app/layout.tsx`:

```ts
// app/layout.tsx
import '@harmony/ui/dist/ui.css'
import './styles/app.css'
```

2) Add a tiny tokens + micro-utilities file at `app/styles/app.css`:

```css
/* app/styles/app.css */
:root {
  --brand: #3b82f6;
  --surface: #ffffff;
  --surface-2: #f7f7f8;
  --ink: #111827;
  --muted-ink: #6b7280;
  --space-1: .25rem; --space-2: .5rem; --space-3: .75rem; --space-4: 1rem;
  --space-5: 1.25rem; --space-6: 1.5rem; --space-8: 2rem; --space-10: 2.5rem;
  --fs-0: clamp(.875rem,.8rem+.2vw,1rem);
  --fs-1: clamp(1.125rem,1rem+.5vw,1.25rem);
  --fs-2: clamp(1.25rem,1.1rem+.8vw,1.5rem);
  --fs-3: clamp(1.5rem,1.2rem+1.2vw,2rem);
}
@layer base {}
@layer components {}
@layer utilities {
  .container { width: min(100% - 2rem, 72rem); margin-inline: auto; }
  .stack > * + * { margin-top: var(--space-4); }
  .stack--sm > * + * { margin-top: var(--space-2); }
  .stack--lg > * + * { margin-top: var(--space-6); }
  .cluster { display:flex; flex-wrap:wrap; align-items:center; gap:var(--space-3); }
  .cluster--lg { gap: var(--space-5); }
  .grid { display:grid; gap:var(--space-5); }
  @media (min-width:48rem){ .grid--2{grid-template-columns:repeat(2,1fr)} .grid--3{grid-template-columns:repeat(3,1fr)} }
}
```

3) If the UI Kit ships untranspiled ESM/TS, add package transpilation to Next:

```js
// next.config.js
module.exports = { transpilePackages: ['@harmony/ui'] }
```

4) Ensure the UI Kit builds before the app in your Turborepo pipeline:

```json
// turbo.json (snippet)
{
  "pipeline": {
    "build": { "dependsOn": ["^build"] },
    "dev":   { "dependsOn": ["@harmony/ui#build"] }
  }
}
```

## CSS Layers and overrides

`@harmony/ui` compiles CSS into `@layer base, components, utilities`. Your app-level CSS should come after and can define its own `@layer` blocks. Because layer order is explicit, app rules can override DS defaults without `!important`.

## Where to go next

- Architecture and ownership boundaries → `architecture.md`
- Authoring components in the UI Kit → `ui-authoring.md`
- App integration with Next (no Tailwind) → `app-integration-next.md`
- Tokens and theming strategies → `tokens-and-theming.md`
