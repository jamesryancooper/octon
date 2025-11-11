---
title: Performance Strategy
description: Keep CSS lean with split entrypoints and tree-shaking. Balance critical vs async CSS and set budgets.
---

## Split CSS entrypoints

Ship a lean base and split component CSS entries from the UI Kit:

- `@harmony/ui/dist/ui.css` — all-in-one (useful for quick starts and SSR stability).
- `@harmony/ui/dist/css/base.css` — base+tokens only.
- `@harmony/ui/dist/css/*.css` — per-component entries.

With `"sideEffects": ["**/*.css"]` and explicit `exports`, bundlers can tree-shake unused CSS entries when components don’t import them.

## Import model

- Components in the UI Kit import their own CSS (side-effect imports). Apps that don’t render a component won’t include its CSS.
- Alternatively, apps can explicitly import only the entries they need in `app/layout.tsx` for strict control.

## Critical CSS vs async chunks

- The all-in-one `ui.css` is simplest and safe for SSR; it frontloads styles (good for LCP stability).
- For large apps, prefer split entries so only used components pull their CSS into initial chunks.
- HTTP/2 reduces the cost of multiple small CSS files. Keep the base small and cacheable.

## Measuring and budgets

- Track: total CSS bytes, LCP, CLS, and long tasks in lab (Lighthouse) and field (RUM).
- Set budgets (example):
  - Base CSS (tokens + resets): ≤ 20KB gz
  - Route baseline CSS: ≤ 70KB gz
  - New component CSS per route: ≤ 10KB gz
- Monitor regressions via CI (e.g., bundle-size checks, Lighthouse CI) and visual diffing.

## Practical tips

- Prefer token-driven styles over ad-hoc utilities in app code.
- Remove dead variants and legacy recipes during minor/major releases.
- Use modern CSS features (cascade layers, `color-mix`, logical properties) to reduce duplication.


