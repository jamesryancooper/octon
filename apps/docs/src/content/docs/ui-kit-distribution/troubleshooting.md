---
title: Troubleshooting
description: Common issues and fixes when consuming @harmony/ui as precompiled CSS in Next apps.
---

## Styles don’t apply

- Ensure `@harmony/ui/dist/ui.css` is imported before `./styles/app.css`.
- Verify the UI Kit build ran and outputs exist (`dist/ui.css`, `dist/css/*`).
- Confirm Turborepo dependency: app `dev/build` depends on `@harmony/ui#build`.

## Overrides not winning

- Use CSS Modules or `@layer` blocks in app CSS; avoid `!important`.
- Check that the app CSS is loaded after the kit. Cascade layers give app styles higher priority.

## Turbopack quirks (dev)

- Keep Tailwind disabled in the app to avoid cross-tooling pipeline issues.
- If component CSS source maps aren’t visible, enable source maps in the kit’s PostCSS pipeline.

## Production vs dev discrepancy

- Confirm identical import order in prod and dev.
- Verify that split CSS entries are present in the final bundle for components actually rendered.
- Check that the UI Kit package version is pinned and built in CI before app build.

## Theming issues (dark/brand)

- Ensure theme attribute (e.g., `data-theme="dark"`) is set before paint to avoid flashes.
- Keep tokens consistent across server and client to prevent hydration warnings.


