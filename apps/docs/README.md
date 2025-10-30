# Harmony Docs (Astro Starlight)

Documentation hub for the Harmony monorepo. Built with Astro 5 and the Starlight docs theme so we can author guides in Markdown/MDX, keep navigation opinionated, and ship a lightweight static site.

- **Content source**: Markdown now lives directly inside `apps/docs/src/content/docs`. The legacy root `docs/` folder stays in place for the moment, but prefer editing the app-local files so the build remains self-contained.
- **API reference**: the Scalar component renders `/openapi/openapi.yaml`, which is copied automatically from `packages/contracts/openapi.yaml` during dev and build.
- **Delivery**: Turbo builds the project, and the Vercel preview pipeline serves it alongside the other apps.

---

## Prerequisites

- Node 24.x (see `.nvmrc` in repo root)
- PNPM 10 (`corepack enable`, then `corepack use pnpm@10.20.0`)
- Optional: install `uv` if you plan to work on Python tooling referenced in docs

Install dependencies from the monorepo root:

```bash
pnpm install
```

---

## Local development

```bash
# Run docs in dev mode (Astro dev server)
pnpm --filter @harmony/docs dev

# Build static output into apps/docs/dist
pnpm --filter @harmony/docs build

# Preview the production build on port 4175
pnpm --filter @harmony/docs preview:vercel
```

Dev server defaults to `http://localhost:4321`. The `preview:vercel` script binds to `http://localhost:4175` to mimic the CI preview job.

---

## Repo boundaries & layout

```plaintext
apps/docs/
├─ astro.config.ts          # Astro entry; wires Starlight + OpenAPI copy integration
├─ starlight.config.ts      # Sidebar, metadata, and social links
├─ tsconfig.json            # Extends repo base config, registers Astro + Node types
├─ package.json             # Scripts + dependencies
└─ src/content/docs/        # Markdown sources consumed by Starlight
```

Key files in the shared content folder:

- `src/content/docs/index.mdx` – landing page for the docs site
- `src/content/docs/reference/api.mdx` – Scalar embed of the OpenAPI spec (served from `/openapi/openapi.yaml`)
- `src/content/docs/handbook/**` – structured guides, checklists, and methodology docs

---

## OpenAPI copy integration

The custom integration in `astro.config.ts` keeps the OpenAPI spec published:

- On dev server start and on build, `packages/contracts/openapi.yaml` is copied to `apps/docs/public/openapi/openapi.yaml`.
- In dev mode, a file watcher refreshes the copy whenever the source spec changes.
- The docs content must reference the public path (`/openapi/openapi.yaml`), not the source file path.

If you move the spec or add additional generated assets, update both the constants in `astro.config.ts` and any content links.

---

## Common tasks

- **Add / edit docs**: create or edit `.md`/`.mdx` files in `src/content/docs`. Keep frontmatter concise (`title`, `description`) so pages render cleanly.
- **Adjust sidebar or metadata**: update `starlight.config.ts`, which exports a typed `StarlightUserConfig` consumed by `astro.config.ts`.
- **Wire new assets**: place extra static files in `apps/docs/public`. Use similar copy logic if the source lives outside the app directory.
- **Diagnostics**:
  - `pnpm --filter @harmony/docs typecheck`
  - `pnpm --filter @harmony/docs lint`
  - (Tests are currently placeholders; add Vitest/Playwright coverage as needed.)

---

## Deployment notes

- Turbo’s `build` pipeline outputs to `dist/`, which Vercel serves for previews and production.
- CI preview step runs `pnpm turbo run build --filter=...[origin/main]`, so keep build deterministic.
- If you introduce environment-driven configuration (e.g., Algolia search), document required env vars here and ensure they’re provided by the preview deployment.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Scalar API reference shows 404 | `/openapi/openapi.yaml` missing in the build | Ensure `packages/contracts/openapi.yaml` exists and rerun `astro build`; integration should recopy on build |
| Docs dev server doesn’t show new pages | Added files outside `src/content/docs/` | Place content under `src/content/docs/` so Starlight picks it up |
| Type errors about Node or Astro globals | Missing types | `tsconfig.json` already includes `node` & `astro/client`; verify `pnpm install` installed `@types/node` |
| Starlight integration warnings about Astro version | `@astrojs/starlight` may lag latest Astro | Check release notes; pin a compatible version or update Starlight |

---

## Next steps

- Enable Starlight search (Pagefind or Algolia) once IA stabilizes.
- Theme the site (logo, colors) via `starlight.config.ts` and optional CSS overrides.
- Automate API reference rebuilds if OpenAPI spec is generated.
