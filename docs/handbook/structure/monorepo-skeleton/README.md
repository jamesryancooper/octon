# COE Monorepo (Turborepo + Vercel)

What’s inside:

* Full repo tree (`apps/`, `packages/`, `infra/ci/`, `infra/otel/`, `docs/specs/`) with code and configs.
* Root `turbo.json` wired with `dev`, `build`, `typecheck`, `lint`, `test`, `contracts:check`, `deps:scan`, `sbom`, `secrets:scan`, `preview:vercel`.
* GitHub Actions: `pr.yml` (quality gates + Preview) and `promote.yml` (instant promote/rollback).
* ESLint boundaries to enforce Hexagonal layering.
* OpenTelemetry bootstrap + structured logging for `apps/api`.
* Spec Kit + ADR templates in `docs/specs/`.
* Mirrored workflows under `.github/workflows/` so Actions run automatically.

Quick start:

1. `pnpm i`
2. `pnpm dev` (Next.js web + Fastify API)
3. Connect Turbo Remote Cache once: `npx turbo login && npx turbo link`
4. In GitHub, add secrets: `VERCEL_TOKEN`, `TURBO_TEAM`, `TURBO_TOKEN` (and connect the repo to Vercel)
5. Open a PR → CI runs gates and posts a Vercel Preview URL. Use **Promote** workflow with that URL to ship; re-promote a previous Preview to roll back instantly.

Want me to open a follow-up PR checklist (issues + milestones) or tweak anything (e.g., switch API to Next.js routes, add Pact boilerplate, or pin semver)?

**Quickstart**

```bash
pnpm i
pnpm dev  # runs dev in apps concurrently
```

**CI expectations**
- PRs run typecheck/lint/test/build, SAST (CodeQL/Semgrep), dep review, secret scan, SBOM, and contracts check.
- Vercel Preview is created per PR (via integration or CLI fallback). Use the `promote` workflow to ship.
- Instant rollback = re-promote a prior Preview URL.
