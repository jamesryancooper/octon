---
title: Migration Guide (App Tailwind → UI Kit CSS)
description: Step-by-step plan to remove Tailwind from the app, adopt UI Kit CSS, and keep velocity.
---

## Goals

- Remove Tailwind from the app layer while preserving velocity and visual stability.
- Centralize styling inside `@harmony/ui`; compose pages with micro-utilities + CSS Modules.

## Prerequisites

- UI Kit publishes `dist/ui.css` and split entries with `sideEffects` + `exports`.
- Turborepo pipeline ensures `@harmony/ui#build` precedes app `dev/build`.

## Step-by-step plan

1) Wire base CSS
   - Import `@harmony/ui/dist/ui.css` and `./styles/app.css` in `app/layout.tsx`.
   - Commit the micro-utilities and tokens file.

2) Disable Tailwind in the app
   - Remove `@tailwind` imports from global CSS or remove Tailwind from PostCSS.
   - Delete Tailwind config if unused elsewhere.

3) Convert page layout utilities
   - Replace `space-y-*` → wrap with `.stack` (`--sm`/`--lg`).
   - Replace grid/cluster patterns using `.grid.grid--2|--3` and `.cluster`.
   - Replace containers with `.container`.

4) Move local tweaks to CSS Modules
   - Create `*.module.css` for page/component specifics.
   - Keep selectors low-specificity and token-driven.

5) Map remaining utilities to tokens or Modules
   - Use CSS variables for typography/spacing/colors.
   - Only extend micro-utilities if a recurring layout emerges.

6) Verify visually
   - Run Storybook (kit) and app pages to confirm parity.
   - Address focus states and accessible contrast.

## Tailwind → Micro-utilities/tokens mapping

| Tailwind utility                         | Replacement                                      |
|------------------------------------------|--------------------------------------------------|
| `space-y-2` / `space-y-4` / `space-y-6`  | `.stack--sm` / `.stack` / `.stack--lg`           |
| `flex gap-3 items-center flex-wrap`      | `.cluster`                                       |
| `gap-5`                                  | `.cluster--lg` or `.grid { gap: var(--space-5) }` |
| `grid grid-cols-2` / `grid-cols-3`       | `.grid.grid--2` / `.grid.grid--3`                |
| `max-w-7xl mx-auto px-4`                 | `.container`                                     |
| `text-xl/2xl/3xl`                        | `font-size: var(--fs-1/2/3)`                     |

## Rollback strategy

- Keep the old Tailwind branch for a short window.
- If a critical regression surfaces mid-migration, revert app-side Tailwind removal while keeping `ui.css` import intact. Reattempt after addressing gaps.

## FAQ

**Q: Can I still add one-off utilities in markup?**  
Use CSS Modules or extend micro-utilities. Avoid reintroducing Tailwind in app markup.

**Q: How do I override a component style?**  
Prefer component props/slots. For small overrides, append a class via `className` and target it in a Module. Layer ordering lets app styles win without `!important`.

**Q: What about third-party components?**  
Wrap them and style via tokens or Modules. Avoid pulling Tailwind back into the app.


