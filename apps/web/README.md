# apps/web

Next.js app. Depends on `@domain`, `@adapters`, and `@contracts`. Does not import from `apps/api`.

- Purpose: UI, routing, SSR/SSG, client interactions.
- Boundaries: no direct DB/infra calls; use adapters/HTTP.
- Flags: use feature flags for risky features.

