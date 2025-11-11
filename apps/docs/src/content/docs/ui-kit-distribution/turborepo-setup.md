---
title: Turborepo Setup
description: Ensure the UI Kit builds before apps. Recommended task graph, caching, and artifacts.
---

## Pipeline dependencies

Make the app `dev` and `build` depend on `@harmony/ui#build` to guarantee CSS is ready:

```json
// turbo.json (snippet)
{
  "pipeline": {
    "build": { "dependsOn": ["^build"] },
    "dev":   { "dependsOn": ["@harmony/ui#build"] }
  }
}
```

## Recommended task graph

- `@harmony/ui#build` → builds CSS (`dist/ui.css`, `dist/css/*`).
- `@harmony/web|api#dev` → depends on the kit build when needed.
- `typecheck`, `lint`, `test` run per-package with cache keys including lockfile and source hashes.

## Caching and artifacts

- Cache `dist/**` outputs of the UI Kit to avoid redundant CSS rebuilds.
- Include ESLint/Stylelint reports in `reports/**` if your CI collects them.
- Persist Storybook artifacts for visual diffing (if used) in CI.


