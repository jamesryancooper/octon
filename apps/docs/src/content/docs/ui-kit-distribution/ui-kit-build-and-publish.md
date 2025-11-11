---
title: Build, Splitting, and Publishing CSS
description: Tailwind/PostCSS inside the kit, split CSS entrypoints, package exports, and versioning.
---

## Tailwind and PostCSS (inside the kit)

```ts
// packages/ui/tailwind.config.ts
import type { Config } from 'tailwindcss'

export default {
  content: [
    './src/**/*.{ts,tsx}',
    './src/styles/**/*.css',
  ],
  theme: {
    extend: {},
  },
  corePlugins: {
    preflight: false, // assume base styles owned explicitly in @layer base
  },
  plugins: [],
} satisfies Config
```

```js
// packages/ui/postcss.config.mjs
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
```

## CSS entrypoints

Produce a single bundle and split entries:

- `dist/ui.css` (complete bundle)
- `dist/css/base.css` (base + tokens mapping)
- `dist/css/button.css`, `dist/css/card.css`, ...

## Packaging settings

Mark CSS as side effects and export CSS entrypoints for tree-shaking:

```json
{
  "name": "@harmony/ui",
  "sideEffects": ["**/*.css"],
  "exports": {
    "./ui.css": "./dist/ui.css",
    "./css/base.css": "./dist/css/base.css",
    "./css/button.css": "./dist/css/button.css"
  }
}
```

## Versioning and releases

- Use SemVer. Treat visual and spacing changes as breaking unless proven non-impactful.
- Maintain a human-readable changelog with component-level notes and screenshots.
- For large refactors, ship prereleases (e.g., `1.3.0-next.1`) and capture visual diffs.

## Build commands (example)

```json
// packages/ui/package.json (scripts excerpt)
{
  "scripts": {
    "build:css": "postcss src/styles/*.css -o dist/ui.css",
    "build": "rimraf dist && pnpm build:css && node scripts/split-css.js"
  }
}
```

> The split step can emit component-scoped CSS files while ensuring a stable base layer for tokens and resets.


