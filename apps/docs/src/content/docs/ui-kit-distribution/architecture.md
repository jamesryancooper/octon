---
title: System Architecture
description: Flow from Tailwind-in-kit sources to compiled CSS and app consumption. Defines ownership and CSS layer ordering.
---

## Component and build flow

```mermaid
flowchart LR
  subgraph Sources
    A[UI Kit components\nReact + CSS files]
    B[UI Kit styles\nTailwind utilities + @apply]
    T[Optional @harmony/tokens\nCSS vars + TS types]
  end

  subgraph Build[@harmony/ui build]
    C[Tailwind] --> D[PostCSS]
  end

  A --> C
  B --> C
  T --> C
  D --> E[dist/ui.css]
  D --> F[dist/css/* per-entry]
  D --> G[package.json exports + sideEffects]

  subgraph App[Next.js (App Router)]
    H[Import @harmony/ui/dist/ui.css]
    I[Import ./styles/app.css\n(tokens + micro-utilities + overrides)]
    J[CSS Modules for page specifics]
  end

  E --> App
  F --> App
  G --> App

  App --> K[Runtime DOM]
```

## Ownership boundaries

- UI Kit owns: component APIs, states, focus rings, motion preferences, visual recipes, Tailwind configuration and compilation.
- App owns: composition and layout (container/stack/cluster/grid), token overrides, local styles via CSS Modules, and theming scope.

## CSS Layers ordering

The UI Kit compiles CSS with layers like:

```css
/* Compiled inside @harmony/ui */
@layer base { /* Normalize, resets, tokens-to-vars mapping (if any) */ }
@layer components { /* Component recipes (e.g., .btn, .card) */ }
@layer utilities { /* Kit-scoped helpers if any */ }
```

Your application CSS is loaded after the kit and may also declare layers:

```css
/* Loaded after the kit in app/styles/app.css */
@layer base {}
@layer components {}
@layer utilities { /* .container, .stack, .cluster, .grid, etc. */ }
```

Because CSS layers define order explicitly, app rules win without `!important`. This keeps overrides safe and predictable across apps.


