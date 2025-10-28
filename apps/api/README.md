# apps/api

API application (Node/Next API routes). Depends on `@domain`, `@adapters`, and `@contracts`. Never import from `apps/web`.

- Purpose: HTTP API handlers, business orchestration, auth.
- Boundaries: no UI code, no direct domain internals from other apps.
- Observability: see `infra/otel/instrumentation.ts` and `src/log.ts`.

