# Harmony AI Console

Internal Next.js app for testing AI completions and embeddings via the Python AI Gateway.

## Scripts

- pnpm --filter @harmony/ai-console dev  (http://localhost:3001)
- pnpm --filter @harmony/ai-console build
- pnpm --filter @harmony/ai-console start (http://localhost:3001)

## Environment

- AI_SERVICE_URL (required): Base URL to the AI Gateway (e.g., http://localhost:8000).
- AI_DEFAULT_MODEL (optional): Default LLM model for completions.
- HARMONY_FLAG_* (optional): Feature flags consumed via @harmony/config (e.g., HARMONY_FLAG_ENABLENEWNAV=true).

## Pages

- /  (Home)
- /completions  (Prompt playground)
- /embeddings  (Embedding playground)
- /status  (Feature flags snapshot)

## Notes

- The dev server listens on port 3001 to avoid conflict with @harmony/api.
- OpenTelemetry is initialized through instrumentation.ts.
- Styling imports the precompiled `@harmony/ui/dist/ui.css` bundle. Tailwind is intentionally
  disabled in this app while we mitigate the Turbopack + Tailwind v4 (lightningcss) build issue.

## Styling guidance (Tailwind mitigation)

- UI kit components remain styled because the kit compiles Tailwind v4 at build time and ships
  `dist/ui.css`. The app simply imports that CSS (see `app/layout.tsx`).
- To customize appearance without Tailwind in the app:
  - **Option A — Tailwind inside the UI kit**: Continue authoring components with Tailwind utilities in
    `packages/ui`, compile them there, and ship the CSS bundle. The app keeps importing the bundle.
  - **Option B — Theme via CSS variables**: Override the tokens exposed by the UI kit using plain CSS
    in the app (e.g., set `--harmony-brand` in a local stylesheet).
- If a feature truly needs ad-hoc Tailwind utilities in the app, prefer CSS Modules or standard CSS for
  the interim. Re-enable Tailwind only after the Turbopack/Tailwind v4 integration stabilizes.
