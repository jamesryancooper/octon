# Turborepo Structure

This guide provides a pragmatic Turborepo structure you can adopt with confidence. It distills patterns from real monorepos and the Vercel/Turbo docs, with file‑level references so you can copy what matters and skip what doesn’t.

What you’ll find:

- Three reference models to mirror (teaching baseline, lean product, security‑conscious growth)
- A recommended v1 layout (`apps/*`, `packages/*`, `infra/*`) and root `turbo.json`
- Caching and previews with Vercel Remote Cache and PR deployments
- CI/CD recipes: quality gates, SBOM/SAST/secrets, and promote‑to‑prod
- Hexagonal boundaries enforcement, contract checks, and shared `packages/contracts`
- Observability starter (OpenTelemetry) and structured logging
- CODEOWNERS guidance and a 90‑day evolution path
- Appendix with ready‑to‑paste scripts and workflow snippets

---

## 1) Comparative recommendation — 3 “models” to copy from

### **Model A — Teaching-quality baseline (great for starting v1)**

**Repo:** `belgattitude/nextjs-monorepo-example`
**Why it fits:** Clear `apps/*` + `packages/*` shape, very explicit `turbo.json`, and healthy CI examples. Ideal to copy structure and conventions without inheriting big‑company complexity.

**Concrete references**:

- Structure roots: `apps/` and `packages/` shown in repo root; includes example Next app and multiple shared libraries. ([GitHub][1])
- Example apps and packages (names we can mirror): `apps/nextjs-app`, `packages/ui-lib`, `packages/db-main-prisma`, `packages/eslint-config-bases`. ([GitHub][2])
- **`turbo.json`** at root (simple, readable pipeline). ([GitHub][3])
- **GitHub Actions** folder with working CI examples under `.github/workflows/`. ([GitHub][4])

**Trade‑offs / what to trim or add**:

- Trim: Its Storybook/Playwright extras if you don’t need them immediately.
- Add for us: `packages/contracts` and `infra/otel/` (OTel isn’t a first‑class concept here). Also bolt on SBOM + Semgrep + CodeQL workflows.

---

### **Model B — Lean, product-grade baseline (fast PR previews)**

**Repos:** `unkeyed/unkey` (clean minimal Turborepo) and `openstatusHQ/openstatus` (compact monorepo with `infra/`)
**Why it fits:** Minimal ceremony with serious production bones: clear `apps/` + `packages/`, a concise root `turbo.json`, and a footprint that feels close to our target. OpenStatus also demonstrates an `infra/` area we can mirror.

**Concrete references**:

- **Unkey** root shows `apps/`, `packages/`, `.github/`, `turbo.json`, `pnpm-workspace.yaml`. ([GitHub][5])

  - `turbo.json` at root. ([GitHub][6])
  - `apps/` and `packages/`. ([GitHub][7])
- **OpenStatus** shows `apps/`, `packages/`, `infra/`, and `turbo.json` in the root—useful for our `infra/` separation. ([GitHub][8])

**Trade‑offs / what to trim or add**:

- Trim: Anything cloud/provider specific you don’t use.
- Add: `packages/contracts` (OpenAPI/JSON Schemas + Pact files), explicit `infra/ci/` with our scans, and OTel config.

---

### **Model C — Security-conscious growth (SAST/quality hygiene baked in)**

**Repos:** `formbricks/formbricks` and `documenso/documenso`
**Why it fits:** You get a mature `turbo.json` and hygiene that scales. Documenso is a monorepo with `apps/` and `packages/` and (notably) `.cursorrules`—handy because you’re using Cursor for agentic/BMAD flows.

**Concrete references**:

- **Formbricks**: `turbo.json` at repo root (good reference for pipelines and cache outputs). ([GitHub][9])
- **Documenso** monorepo shape: `apps/`, `packages/`, and root `turbo.json`. Also `.cursorrules` at the repo root (nice pattern to gate AI‑generated diffs). ([GitHub][10])

**Trade‑offs / what to trim or add**:

- Trim: Documenso’s broader product surface if you just need the monorepo shape.
- Add: Your own `infra/otel/` and explicit contract‑testing (`packages/contracts` + OpenAPI/Pact checks) if you want that enforced centrally.

---

### Why these three?

- They match our **monolith-first in a Turborepo** approach (Next.js + Node) and **Trunk‑Based with Vercel Preview** per PR. ([Turborepo][11])
- Each uses **root `turbo.json`** pipelines we can adapt, with clear `apps/*` and `packages/*`. ([Turborepo][12])
- They keep **cache-effective outputs** and are compatible with **Vercel Remote Cache** for fast CI. ([Vercel][13])

---

## 2) Proposed **baseline for us (v1)**

### Target repo layout (mirrors your starter)

```plaintext
repo/
  apps/
    web/            # Next.js app
    api/            # Node API (or Next API routes if monolith)
  packages/
    domain/         # pure business logic (no framework/IO)
    adapters/       # db/http adapters implementing ports from domain
    contracts/      # OpenAPI/JSON Schemas, Pact files
    ui-kit/         # shared React UI
  infra/
    ci/             # GH Actions workflows (CodeQL/Semgrep/SBOM/etc.)
    otel/           # OpenTelemetry config
  docs/
    specs/          # Spec Kits, ADRs (Spec-first)
  turbo.json
  CODEOWNERS
```

---

### `turbo.json` (v1)

> Covers: `dev`, `build`, `typecheck`, `lint`, `test`, plus `contracts:check`, `deps:scan`, `sbom`, `secrets:scan`, `preview:vercel`.
> Uses Turborepo task-graph conventions with cacheable outputs and per‑task env to split caches where needed. (See Turbo config & package‑level overrides.) ([Turborepo][12])

```json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["pnpm-lock.yaml", "package.json", "tsconfig.base.json"],
  "pipeline": {
    "dev": {
      "cache": false,
      "persistent": true,
      "dependsOn": ["^dev"]
    },
    "build": {
      "dependsOn": ["^build", "typecheck"],
      "outputs": [
        "dist/**",
        "build/**",
        ".next/**",
        ".vercel/output/**",
        "!.next/cache/**"
      ],
      "env": ["NODE_ENV", "NEXT_PUBLIC_*"]
    },
    "typecheck": {
      "dependsOn": ["^typecheck"],
      "outputs": ["tsconfig.tsbuildinfo"]
    },
    "lint": {
      "dependsOn": ["^lint"],
      "outputs": ["reports/eslint-*.json"]
    },
    "test": {
      "dependsOn": ["^test", "build"],
      "outputs": ["coverage/**", "reports/junit-*.xml"]
    },

    "contracts:check": {
      "dependsOn": ["^build"],
      "inputs": ["packages/contracts/**"],
      "outputs": ["packages/contracts/reports/**"],
      "env": ["OPENAPI_BASE_REF", "PACT_BROKER_BASE_URL"]
    },
    "deps:scan": {
      "cache": false
    },
    "sbom": {
      "outputs": ["sbom/**"]
    },
    "secrets:scan": {
      "cache": false
    },

    "preview:vercel": {
      "dependsOn": ["build"],
      "cache": false,
      "env": [
        "VERCEL_ORG_ID",
        "VERCEL_PROJECT_ID",
        "VERCEL_TOKEN",
        "NEXT_PUBLIC_*"
      ]
    }
  }
}
```

> Notes
> • Set **env** on cache‑sensitive tasks so caches don’t bleed across environments/build args (Vercel recommends listing env‑vars for Turbo caching). ([Vercel][14])
> • Outputs include both Node `dist/**` and Next `.next/**`/`.vercel/output/**` for cache hits in CI and local. (Turbo docs on structuring/config.) ([Turborepo][11])

---

### Package‑level overrides (optional)

If `apps/web` needs a different `preview:vercel` command than `apps/api`, add `apps/web/turbo.json` and extend root to override just that task. (Turbo **Package Configurations**.) ([Turborepo][15])

---

### Caching — Vercel Remote Cache

**How to enable (one‑time and CI):**

1. Log in locally and link the repo to your Vercel team/org:

    ```bash
    npx turbo login     # creates credentials
    npx turbo link      # links repo to team for Remote Cache
    ```

2. In CI (GitHub Actions), either rely on the Vercel integration (it injects the Turbo cache automatically during Vercel builds) or export `TURBO_TOKEN`/`TURBO_TEAM` secrets for your self‑hosted actions. ([Vercel][13])

    > Vercel docs: **Remote Caching** + **Turborepo on Vercel**. ([Vercel][16])

---

### CI/CD on GitHub Actions (guardrails + previews + promote)

We’ll keep Actions **small and focused**. Place these in `infra/ci/`. (Formbricks and Belgattitude both illustrate healthy workflows under `.github/workflows/`.) ([GitHub][9])

#### **A) Pull request CI (`infra/ci/pr.yml`)**

- Runs **typecheck/lint/test/build** with Turbo remote cache.
- Performs **contract checks**, **dep review**, **secrets** and **SBOM** generation as PR‑gated checks.
- **Preview Deployments**: prefer Vercel’s GitHub integration to auto‑create a Preview and **auto‑comment URL** on the PR; if you prefer full control, the fallback CLI job below does it explicitly. ([Vercel][17])

```yaml
name: pr
on:
  pull_request:
    branches: [main]

jobs:
  quality:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      security-events: write   # for CodeQL/Semgrep SARIF upload
      pull-requests: write     # to post comments if needed
    env:
      TURBO_TOKEN: ${{ secrets.TURBO_TOKEN }}   # if not relying on Vercel injects
      TURBO_TEAM:  ${{ secrets.TURBO_TEAM }}
    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v4
        with: { version: 10 }

      - uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: 'pnpm'

      - run: pnpm install --frozen-lockfile

      # Turborepo core checks (cache-aware)
      - run: pnpm turbo run typecheck lint test --cache-dir=.turbo

      # Build everything once (CI will hit remote cache heavily on small PRs)
      - run: pnpm turbo run build --filter=...[origin/main]

      # --- Security & Reliability guardrails ---
      # 1) CodeQL (GitHub’s starter workflow for JS/TS)
      - name: Init CodeQL
        uses: github/codeql-action/init@v3
        with: { languages: javascript }
      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v3
      # Ref: starter template. :contentReference[oaicite:21]{index=21}

      # 2) Semgrep SAST
      - name: Semgrep Scan
        uses: returntocorp/semgrep-action@v1
        with:
          config: p/ci
          generateSarif: "1"
      # Samples & docs. :contentReference[oaicite:22]{index=22}

      # 3) Dependency review (GitHub)
      - name: Dependency Review
        uses: actions/dependency-review-action@v4

      # 4) Secrets scanning (TruffleHog)
      - name: TruffleHog
        uses: trufflesecurity/trufflehog@v3
        with:
          scan: git
          extra_args: --since-commit HEAD~50
      # Marketplace + blog usage. :contentReference[oaicite:23]{index=23}

      # 5) SBOM (Syft via Anchore action)
      - name: SBOM (Syft)
        uses: anchore/sbom-action@v0
        with:
          path: .
          format: spdx-json
          output-file: sbom/sbom.spdx.json
      # Anchore sbom-action. :contentReference[oaicite:24]{index=24}

      # 6) Contract tests / breaking-change check for OpenAPI
      - name: OpenAPI breaking-change check (oasdiff)
        uses: oasdiff/oasdiff-action/diff@main
        with:
          base: packages/contracts/openapi-base.yaml
          revision: packages/contracts/openapi.yaml
      # oasdiff action and breaking-change docs. :contentReference[oaicite:25]{index=25}

  # Optional: explicit Preview with CLI (if not using Vercel integration)
  preview:
    if: ${{ github.event.pull_request.head.repo.full_name == github.repository }}
    needs: quality
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v4
        with: { version: 10 }
      - uses: actions/setup-node@v4
        with: { node-version: '22', cache: 'pnpm' }
      - run: pnpm install --frozen-lockfile

      - name: Vercel pull env
        run: npx vercel pull --yes --environment=preview --token=${{ secrets.VERCEL_TOKEN }}

      - name: Build (prebuilt artifacts)
        run: npx vercel build --token=${{ secrets.VERCEL_TOKEN }}

      - name: Deploy preview
        id: deploy
        run: echo "url=$(npx vercel deploy --prebuilt --token=${{ secrets.VERCEL_TOKEN }})" >> $GITHUB_OUTPUT

      - name: Comment Preview URL
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `Vercel Preview: ${{ steps.deploy.outputs.url }}`
            })
```

> Vercel GitHub integration already **auto‑creates a Preview per PR** and comments URLs—prefer that for low ceremony; keep the CLI fallback if you need custom steps. ([Vercel][17])

#### **B) Guarded promote to prod (`infra/ci/promote.yml`)**

- Uses **environment protection** (GitHub “production” env requires approval).
- Promotes a **known-good Preview** instantly (no rebuild), enabling instant rollback by re‑promoting the prior preview. ([Vercel][18])

```yaml
name: promote
on:
  workflow_dispatch:
    inputs:
      previewUrl:
        description: "Vercel preview URL to promote"
        required: true

jobs:
  promote:
    runs-on: ubuntu-latest
    environment: production  # require manual approval in GH env settings
    steps:
      - name: Promote preview to production
        run: npx vercel promote ${{ inputs.previewUrl }} --token=${{ secrets.VERCEL_TOKEN }}
# CLI promote + docs cover no-rebuild promote and instant rollback behavior. :contentReference[oaicite:28]{index=28}
```

> Production releases still follow **Trunk‑Based**: merge to `main` after all required checks. Feature‑flag behind `config/flags.ts` so you can dark‑launch and revert instantly by re‑promoting the previous preview. ([Vercel][17])

---

### Hexagonal boundaries enforcement

**Directory contracts**:

- `packages/domain`: **pure** TS (no `react`, `next`, `pg`, `axios`). Only domain types/ports.
- `packages/adapters`: implements ports (e.g., `DbPort`, `HttpPort`) and may depend on infra libs.
- `apps/api` and `apps/web`: may depend on `domain` and `adapters`, but **never** on each other.

**Automated guardrails**:

- ESLint **boundaries** rule: prevent wrong‑way imports (`web` importing `adapters` internals, or anything importing infra‑only code). ([npm][19])
- (Optional) **dependency-cruiser** fitness function in CI to visualize/enforce “domain ↔ adapters ↔ apps” rules. ([DEV Community][20])

`eslint.config.js` (snippet)

```js
import boundaries from "eslint-plugin-boundaries";
/** @type {import('eslint').Linter.Config[]} */
export default [{
  plugins: { boundaries },
  settings: {
    'boundaries/elements': [
      { type: 'domain', pattern: 'packages/domain/**' },
      { type: 'adapters', pattern: 'packages/adapters/**' },
      { type: 'contracts', pattern: 'packages/contracts/**' },
      { type: 'app', pattern: 'apps/**' }
    ]
  },
  rules: {
    'boundaries/element-types': [ 'error', {
      default: 'disallow',
      rules: [
        { from: 'domain',   allow: [] },
        { from: 'adapters', allow: ['domain','contracts'] },
        { from: 'app',      allow: ['domain','adapters','contracts'] }
      ]
    }]
  }
}];
```

> Alternatives: `eslint-plugin-hexagonal-architecture` (if you prefer opinionated rules) or `@nx/enforce-module-boundaries` if you later move to Nx. ([GitHub][21])

**Contract tests in CI**:

- **OpenAPI breaking-change** gate with `oasdiff-action` (shown in CI above). ([GitHub][22])
- (Optional) **PactJS** for consumer/provider contracts between `apps/web` and `apps/api` (publish Pacts to broker on PR, verify on API). ([GitHub][23])

---

### Observability (OpenTelemetry) baseline

**Files**:

```plaintext
infra/otel/instrumentation.ts
apps/api/src/log.ts
```

**`infra/otel/instrumentation.ts`** — zero/low‑code NodeSDK with OTLP exporters and auto‑instrumentations. Set `OTEL_EXPORTER_OTLP_ENDPOINT` in env. ([OpenTelemetry][24])

```ts
// infra/otel/instrumentation.ts
import { NodeSDK } from '@opentelemetry/sdk-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-proto';
import { OTLPMetricExporter } from '@opentelemetry/exporter-metrics-otlp-proto';
import { PeriodicExportingMetricReader } from '@opentelemetry/sdk-metrics';

const otlpEndpoint = process.env.OTEL_EXPORTER_OTLP_ENDPOINT || 'http://localhost:4318';

const sdk = new NodeSDK({
  traceExporter: new OTLPTraceExporter({ url: `${otlpEndpoint}/v1/traces` }),
  metricReader: new PeriodicExportingMetricReader({
    exporter: new OTLPMetricExporter({ url: `${otlpEndpoint}/v1/metrics` })
  }),
  instrumentations: [getNodeAutoInstrumentations()]
});

sdk.start().catch((err) => {
  console.error('OTel init error', err);
});
```

> Start API with `NODE_OPTIONS="--require ./infra/otel/instrumentation.ts"` or import at app bootstrap. (OpenTelemetry JS getting started.) ([OpenTelemetry][24])

**Structured logs (trace‑context aware)**:

```ts
// apps/api/src/log.ts
import pino from 'pino';
import { context, trace } from '@opentelemetry/api';

export const log = pino({ level: process.env.LOG_LEVEL || 'info' });

export function withTrace(fields: Record<string, unknown> = {}) {
  const span = trace.getSpan(context.active());
  const traceId = span?.spanContext().traceId;
  return log.child(traceId ? { traceId, ...fields } : fields);
}
```

---

### Security & reliability baked in (ASVS + SSDF alignment)

The CI stack maps to **OWASP ASVS** verification areas (e.g., logging, dependency checks, headers) and **NIST SSDF** practices (e.g., threat modeling artifacts and SAST/DAST/SBOM in the pipeline). Your Spec Kit + ADRs live under `docs/specs/` and link to acceptance criteria. ([OWASP Foundation][25])

---

### CODEOWNERS (keep review load tiny)

```plaintext
# apps
/apps/web/      @you @teammate
/apps/api/      @you @teammate

# domain & contracts need both eyes
/packages/domain/    @you @teammate
/packages/contracts/ @you @teammate

# infra & ci
/infra/ci/      @you
/infra/otel/    @teammate
```

---

## 3) 90‑day evolution path (brief)

1. **Weeks 1–2** (this PR):

   - Land the baseline layout + `turbo.json` + CI above.
   - Enable **Vercel Remote Cache** + GitHub integration for **Preview per PR**. ([Vercel][16])
   - Enforce **Hexagonal** with ESLint boundaries + initial **oasdiff** job.

2. **Weeks 3–6**:

   - Expand **contracts**: generate OpenAPI from handlers, add **Pact** for UI↔API flows. ([GitHub][23])
   - Add **SLIs/SLOs** and **error budgets** (burn alerts) from OTel metrics (latency, error rate). (Use `OTLPMetricExporter` to your backend/collector.) ([OpenTelemetry][26])
   - Add **license compliance** job (e.g., `license-checker` JSON -> gate on forbidden licenses).

3. **Weeks 7–12**:

   - Split `adapters` into subpackages as needed (`db`, `http`, `cache`) to keep boundaries clear.
   - Add **per‑package `turbo.json`** overrides (e.g., heavier `test` only for API). ([Turborepo][15])
   - Introduce **feature flags** for safe launches and reinforce **guarded auto‑promote** on green SLOs (promote the exact Preview). ([Vercel][18])
   - If teams grow, adopt CODEOWNERS matrices and optional **dependency-cruiser** reports as PR artifacts. ([DEV Community][20])

---

## Why this baseline matches your methodology

- **Spec‑first** — `docs/specs/` + ADRs backed by CI contract gates (oasdiff + Pact) map to **ASVS** & **SSDF** expectations. ([OWASP Foundation][25])
- **Agentic agile (BMAD) with Cursor** — keep small PRs; Documenso’s `.cursorrules` shows a real project wiring editor guardrails for AI‑assisted diffs/plans. ([GitHub][27])
- **Flow over ceremony** — **Trunk‑Based**, tiny PRs, **Vercel Previews** per PR, and **promote** previous deploy for instant rollback. ([Vercel][28])
- **Reliability** — OTel traces/metrics + structured logs; add burn‑rate alerts later (export to your telemetry backend). ([OpenTelemetry][24])
- **Security by default** — CodeQL, Semgrep, dep review, secret scan, **SBOM**, contract tests all in default PR CI. ([GitHub][29])
- **Turbo & caching** — Clear `outputs`, `env` controls, and **Vercel Remote Cache** for fast CI/PR loops. ([Turborepo][12])

---

## Appendix — small implementation details you’ll want

**Root `package.json` scripts (suggested)**

```json
{
  "scripts": {
    "dev": "turbo run dev --parallel",
    "build": "turbo run build",
    "typecheck": "turbo run typecheck",
    "lint": "turbo run lint",
    "test": "turbo run test",
    "contracts:check": "turbo run contracts:check",
    "deps:scan": "pnpm dlx osv-scanner --recursive --format sarif --output reports/osv.sarif || true",
    "sbom": "pnpm dlx @cyclonedx/cyclonedx-npm --output-file sbom/sbom.spdx.json",
    "secrets:scan": "pnpm dlx trufflehog filesystem --no-update --fail --path .",
    "preview:vercel": "turbo run preview:vercel"
  }
}
```

**Vercel Preview behavior**:

- Previews are created automatically on each PR/branch push and Vercel **comments the URL** on the PR. **Promote** the exact Preview to production to “instant rollback” by re‑promoting the prior one. ([Vercel][28])

**Migration steps for your current code**:

1. Move Next app → `apps/web/` and API → `apps/api/` (or use Next API routes only).
2. Create `packages/domain` and move pure logic; surface **ports** (interfaces).
3. Create `packages/adapters` and move DB/HTTP clients there.
4. Add `packages/contracts` and place `openapi.yaml`, JSON Schemas, and (optional) Pact setup.
5. Drop in the `turbo.json` above and the three Actions workflows; connect Vercel (monorepo project).
6. Enable **Remote Cache** (Turbo link/login; or rely on Vercel’s integration). ([Vercel][13])

---

### Quick reference to the real repos we modeled

- **Belgattitude** (teaching template): `apps/*`, `packages/*`, `turbo.json`, and CI under `.github/workflows/`. ([GitHub][1])
- **Unkey** (minimal, clean): root `turbo.json`, `apps/`, `packages/`. ([GitHub][6])
- **OpenStatus** (compact + `infra/`): `apps/`, `packages/`, `infra/`, `turbo.json`. ([GitHub][8])
- **Formbricks** (healthy pipeline): root `turbo.json`. ([GitHub][9])
- **Documenso** (monorepo + Cursor rules): `apps/`, `packages/`, `turbo.json`, `.cursorrules`. ([GitHub][10])
- **Vercel / Turborepo docs** (Previews, Promote, Remote Cache, Turbo config). ([Vercel][28])
- **OpenTelemetry JS** (Node SDK + OTLP exporters). ([OpenTelemetry][24])

---

If you want, I can turn this into a ready‑to‑merge PR skeleton (folders, baseline files, and the three workflows) so you can plug in your current code with minimal edits.

[1]: https://github.com/belgattitude/nextjs-monorepo-example "GitHub - belgattitude/nextjs-monorepo-example: Collection of monorepo tips & tricks"
[2]: https://github.com/u4078974/nextjs-monorepo-example "GitHub - u4078974/nextjs-monorepo-example"
[3]: https://github.com/belgattitude/nextjs-monorepo-example/blob/main/turbo.json "nextjs-monorepo-example/turbo.json at main · belgattitude/nextjs-monorepo-example · GitHub"
[4]: https://github.com/belgattitude/nextjs-monorepo-example/blob/main/.github/workflows "nextjs-monorepo-example/.github/workflows at main · belgattitude/nextjs-monorepo-example · GitHub"
[5]: https://github.com/unkeyed/unkey "GitHub - unkeyed/unkey: The Developer Platform for Modern APIs"
[6]: https://github.com/unkeyed/unkey/blob/main/turbo.json "unkey/turbo.json at main · unkeyed/unkey · GitHub"
[7]: https://github.com/unkeyed/unkey/tree/main/apps "unkey/apps at main · unkeyed/unkey · GitHub"
[8]: https://github.com/openstatusHQ/openstatus "GitHub - openstatusHQ/openstatus:  Uptime monitoring & API monitoring as code with status page "
[9]: https://github.com/formbricks/formbricks/blob/main/turbo.json "formbricks/turbo.json at main · formbricks/formbricks · GitHub"
[10]: https://github.com/documenso/documenso/tree/main/apps "documenso/apps at main · documenso/documenso · GitHub"
[11]: https://turborepo.com/docs/crafting-your-repository/structuring-a-repository?utm_source=chatgpt.com "Structuring a repository | Turborepo"
[12]: https://turborepo.com/docs/reference/configuration?utm_source=chatgpt.com "Configuring turbo.json | Turborepo"
[13]: https://vercel.com/docs/monorepos/turborepo?utm_source=chatgpt.com "Deploying Turborepo to Vercel"
[14]: https://vercel.com/docs/monorepos/turborepo.md?utm_source=chatgpt.com "vercel.com"
[15]: https://turborepo.com/docs/reference/package-configurations?utm_source=chatgpt.com "Package Configurations - Turborepo"
[16]: https://vercel.com/docs/monorepos/remote-caching?utm_source=chatgpt.com "Remote Caching - Vercel"
[17]: https://vercel.com/docs/git?utm_source=chatgpt.com "Deploying Git Repositories with Vercel"
[18]: https://vercel.com/docs/deployments/promoting-a-deployment?utm_source=chatgpt.com "Promoting Deployments - vercel.com"
[19]: https://www.npmjs.com/package/eslint-plugin-boundaries?utm_source=chatgpt.com "eslint-plugin-boundaries - npm"
[20]: https://dev.to/rubenoostinga/taking-frontend-architecture-serious-with-dependency-cruiser-5fc2?utm_source=chatgpt.com "Taking Frontend Architecture Serious with dependency-cruiser"
[21]: https://github.com/CodelyTV/eslint-plugin-hexagonal-architecture?utm_source=chatgpt.com "CodelyTV/eslint-plugin-hexagonal-architecture - GitHub"
[22]: https://github.com/oasdiff/oasdiff-action?utm_source=chatgpt.com "GitHub - oasdiff/oasdiff-action: GitHub action for comparing and detect ..."
[23]: https://github.com/pact-foundation/pact-js?utm_source=chatgpt.com "GitHub - pact-foundation/pact-js: JS version of Pact. Pact is a ..."
[24]: https://opentelemetry.io/docs/languages/js/getting-started/nodejs/?utm_source=chatgpt.com "Node.js - OpenTelemetry"
[25]: https://owasp.org/www-project-application-security-verification-standard/?utm_source=chatgpt.com "OWASP Application Security Verification Standard (ASVS)"
[26]: https://opentelemetry.io/docs/languages/js/exporters/?utm_source=chatgpt.com "Exporters - OpenTelemetry"
[27]: https://github.com/documenso/documenso "GitHub - documenso/documenso: The Open Source DocuSign Alternative."
[28]: https://vercel.com/docs/deployments/environments?utm_source=chatgpt.com "Environments - Vercel"
[29]: https://github.com/actions/starter-workflows/blob/main/code-scanning/codeql.yml?utm_source=chatgpt.com "starter-workflows/code-scanning/codeql.yml at main - GitHub"
