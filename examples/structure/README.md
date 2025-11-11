---
title: Baseline Turborepo Monorepo
description: Overview of the Harmony reference monorepo structure, guardrails, and CI expectations.
---

This PR adds a ready‑to‑run Turborepo + Vercel baseline with CI/CD guardrails, Hexagonal boundaries, and contract checks.

---

## File tree

```
repo/
  apps/
    web/
      package.json
      tsconfig.json
      next.config.js
      src/app/layout.tsx
      src/app/page.tsx
    api/
      package.json
      tsconfig.json
      src/index.ts
      src/log.ts
  packages/
    domain/
      package.json
      tsconfig.json
      src/index.ts
      src/__tests__/index.test.ts
    adapters/
      package.json
      tsconfig.json
      src/db.ts
    contracts/
      package.json
      tsconfig.json
      openapi.yaml
      openapi-base.yaml
      reports/.gitkeep
    ui/
      package.json
      tsconfig.json
      src/index.tsx
  infra/
    ci/
      pr.yml
      promote.yml
    otel/
      instrumentation.ts
  docs/
    specs/
      ADR-0001-template.md
      spec-kit-template.md
  .github/
    workflows/
      pr.yml
      promote.yml
  turbo.json
  package.json
  pnpm-workspace.yaml
  tsconfig.base.json
  eslint.config.js
  CODEOWNERS
  .cursorrules
  .gitignore
  README.md
```

---

## Key files (excerpts)

### `turbo.json`

```json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["pnpm-lock.yaml", "package.json", "tsconfig.base.json"],
  "pipeline": {
    "dev": { "cache": false, "persistent": true, "dependsOn": ["^dev"] },
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
    "lint": { "dependsOn": ["^lint"], "outputs": ["reports/eslint-*.json"] },
    "test": { "dependsOn": ["^test"], "outputs": ["coverage/**", "reports/junit-*.xml"] },
    "contracts:check": {
      "dependsOn": ["^build"],
      "inputs": ["packages/contracts/**"],
      "outputs": ["packages/contracts/reports/**"],
      "env": ["OPENAPI_BASE_REF", "PACT_BROKER_BASE_URL"]
    },
    "deps:scan": { "cache": false },
    "sbom": { "outputs": ["sbom/**"] },
    "secrets:scan": { "cache": false },
    "preview:vercel": {
      "dependsOn": ["build"],
      "cache": false,
      "env": ["VERCEL_ORG_ID", "VERCEL_PROJECT_ID", "VERCEL_TOKEN", "NEXT_PUBLIC_*"]
    }
  }
}
```

### `infra/ci/pr.yml` (PR checks + Preview)

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
      security-events: write
      pull-requests: write
    env:
      TURBO_TOKEN: ${{ secrets.TURBO_TOKEN }}
      TURBO_TEAM:  ${{ secrets.TURBO_TEAM }}
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v3
        with: { version: 9 }
      - uses: actions/setup-node@v4
        with:
          node-version: '24'
          cache: 'pnpm'
      - run: pnpm install --frozen-lockfile
      - run: pnpm turbo run typecheck lint test --cache-dir=.turbo
      - run: pnpm turbo run build --filter=...[origin/main]
      - name: Init CodeQL
        uses: github/codeql-action/init@v3
        with: { languages: javascript }
      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v3
      - name: Semgrep Scan
        uses: returntocorp/semgrep-action@v1
        with:
          config: p/ci
          generateSarif: "1"
      - name: Dependency Review
        uses: actions/dependency-review-action@v4
      - name: TruffleHog
        uses: trufflesecurity/trufflehog@v3
        with:
          scan: git
          extra_args: --since-commit HEAD~50
      - name: SBOM
        uses: anchore/sbom-action@v0
        with:
          path: .
          format: spdx-json
          output-file: sbom/sbom.spdx.json
      - name: OpenAPI diff
        uses: oasdiff/oasdiff-action/diff@main
        with:
          base: packages/contracts/openapi-base.yaml
          revision: packages/contracts/openapi.yaml

  preview:
    if: ${{ github.event.pull_request.head.repo.full_name == github.repository }}
    needs: quality
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v3
        with: { version: 9 }
      - uses: actions/setup-node@v4
        with: { node-version: '24', cache: 'pnpm' }
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

### `infra/ci/promote.yml` (promote preview → prod)

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
    environment: production
    steps:
      - name: Promote preview to production
        run: npx vercel promote ${{ inputs.previewUrl }} --token=${{ secrets.VERCEL_TOKEN }}
```

### `infra/otel/instrumentation.ts` (OTel SDK)

```ts
import { NodeSDK } from '@opentelemetry/sdk-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-proto';
import { OTLPMetricExporter } from '@opentelemetry/exporter-metrics-otlp-proto';
import { PeriodicExportingMetricReader } from '@opentelemetry/sdk-metrics';

const otlpEndpoint = process.env.OTEL_EXPORTER_OTLP_ENDPOINT || 'http://localhost:4318';

export const sdk = new NodeSDK({
  traceExporter: new OTLPTraceExporter({ url: `${otlpEndpoint}/v1/traces` }),
  metricReader: new PeriodicExportingMetricReader({
    exporter: new OTLPMetricExporter({ url: `${otlpEndpoint}/v1/metrics` })
  }),
  instrumentations: [getNodeAutoInstrumentations()]
});

sdk.start().catch((err) => console.error('OTel init error', err));
```

### `eslint.config.js` (Hexagonal boundaries)

```js
import boundaries from "eslint-plugin-boundaries";
export default [{
  ignores: ["node_modules","dist","build",".turbo",".next"],
  plugins: { boundaries },
  settings: {
    'boundaries/elements': [
      { type: 'domain',   pattern: 'packages/domain/**' },
      { type: 'adapters', pattern: 'packages/adapters/**' },
      { type: 'contracts',pattern: 'packages/contracts/**' },
      { type: 'ui',       pattern: 'packages/ui/**' },
      { type: 'app',      pattern: 'apps/**' }
    ]
  },
  rules: {
    'boundaries/element-types': [ 'error', {
      default: 'disallow',
      rules: [
        { from: 'domain',   allow: [] },
        { from: 'adapters', allow: ['domain','contracts'] },
        { from: 'ui',       allow: [] },
        { from: 'app',      allow: ['domain','adapters','contracts','ui'] }
      ]
    }]
  }
}];
```

### `apps/api/src/index.ts` (Fastify + structured logs)

```ts
import Fastify from 'fastify';
import { withTrace } from './log.js';
import { hello } from '@domain/index.js';

const app = Fastify({ logger: false });

app.get('/health', async () => ({ ok: true }));
app.get('/hello', async (req, reply) => {
  const msg = hello('world');
  withTrace().info({ route: '/hello' }, 'hello invoked');
  return reply.send({ message: msg });
});

const port = Number(process.env.PORT || 3001);
app.listen({ port, host: '0.0.0.0' }).then(() => {
  withTrace().info({ port }, `api listening`);
}).catch((err) => {
  withTrace().error({ err }, 'api failed to start');
  process.exit(1);
});
```

### `packages/contracts/openapi.yaml` (starter)

```yaml
openapi: 3.1.0
info:
  title: COE API
  version: 0.1.0
paths:
  /hello:
    get:
      summary: hello endpoint
      responses:
        "200":
          description: OK
          content:
            application/json:
              schema:
                type: object
                properties:
                  message:
                    type: string
```

---

## How to use

1. **Install & develop:**

   ```bash
   pnpm i
   pnpm dev
   ```
2. **Connect Turbo Remote Cache (one-time):**

   ```bash
   npx turbo login
   npx turbo link
   ```
3. **Wire Vercel:** connect repo in Vercel, add `VERCEL_TOKEN`, `TURBO_TEAM`, `TURBO_TOKEN` GitHub secrets.
4. **Open a PR:** CI will run checks and post a Preview URL. Use **Promote** workflow to ship.
