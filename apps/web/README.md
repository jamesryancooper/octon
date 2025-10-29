# apps/web

Astro frontend surface. Depends on `@domain`, `@adapters`, and `@contracts`. Does not import from `apps/api`.

- Purpose: UI composition, static generation, client hydration where needed.
- Boundaries: no direct DB/infra calls; interact through adapters/HTTP APIs.
- Flags: gate risky features behind configuration flags per DoD.
