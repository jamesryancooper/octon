# Monorepo Architecture - Polyglot (TS + Python) – Harmony Methodology

Below is a concrete, Harmony‑aligned blueprint for a **polyglot (TypeScript + Python) modular‑monolith monorepo** using **Turborepo** (task runner & cache), **pnpm** (TS/Node workspaces), and **uv** (Python workspaces). It maps vertical slices + hexagonal boundaries to Harmony’s *kits/control‑plane vs. runtimes* model, and wires TypeScript + Python into a single deterministic task graph.

> **Why these choices**
> *Turborepo* discovers tasks from `package.json` and orchestrates them via `turbo.json` with caching on declared inputs/outputs—this is how we unify TS + Python tasks in one graph. ([Turborepo][1])
> *pnpm* workspaces are defined by `pnpm-workspace.yaml` and drive the package graph for Node/TS. ([pnpm][2])
> *uv* supplies **Python workspaces** with one lockfile and `uv run --package <member>` execution; define members via `[tool.uv.workspace]` with shared lock + sources. ([Astral Docs][3])

Harmony specifics—**kits as control plane** (`packages/kits/*`), a **platform flow runtime service** whose LangGraph-based implementation lives under `platform/runtimes/flow-runtime/**`, and strict module boundaries—come straight from the Harmony blueprint and AI‑Toolkit docs. See also [`runtime-architecture.md`](./runtime-architecture.md) for the canonical runtime model.  

---

## 1) High‑level repo layout (slices ↑, layers →)

```text
.
├─ apps/                            # Thin deployables (UI/BFF/API) — TS
│  ├─ web/                          # Next.js/SSR UI (calls kits)
│  ├─ api/                          # HTTP API, spec-first controllers
│  └─ ai-console/                   # Observability/agent console
│
├─ packages/                        # Feature modules & kits (Hexagonal)
│  ├─ inventory/                    # Example vertical slice — TS
│  │  ├─ domain/                    # Pure domain/use-cases (no IO)
│  │  ├─ adapters/                  # DB/external ports
│  │  ├─ api/                       # OpenAPI/JSON Schema for this slice
│  │  └─ tests/
│  ├─ common/                       # Carefully-curated shared primitives
│  └─ kits/                         # Harmony control-plane kits (TS)
│     ├─ flowkit/                   # Orchestration contracts + client
│     ├─ agentkit/
│     ├─ speckit/, plankit/, evalkit/, policykit/, testkit/, …
│     └─ prompts/                   # PromptOps templates (design-time)
│
├─ agents/                          # Python agent & flow hosts (control-plane agents)
│  ├─ architect/assessment/         # Thin host using AgentKit+FlowKit
│  ├─ planner/                      # Planner agent runtime
│  ├─ builder/                      # Builder agent runtime
│  ├─ verifier/                     # Verifier agent runtime
│  └─ orchestrator/                 # Orchestration/gateway agent
│
├─ kaizen/                          # Kaizen/Autopilot layer (policies, evaluators, codemods, agents, reports)
│
├─ platform/
│  ├─ knowledge-plane/              # Specs, SBOM, policies, traces
│  ├─ observability/                # OTel wiring
│  └─ runtimes/                     # Platform runtime services and their control-plane configuration (see `runtime-architecture.md`)
│     ├─ config/                    # Control-plane configuration for platform runtimes (flags, rollout descriptors, runtime policy bundles, queue/worker profiles, risk tiers, env mappings)
│     └─ flow-runtime/              # LangGraph-based implementation of the platform flow runtime service
│        ├─ assessment/…            # Graphs per flow
│        ├─ server.py               # Internal HTTP/engine surface for the execution tier (runtime API front door exposes `/flows/run`, `/flows/start`, etc.)
│        └─ langgraph.json          # Studio entrypoints
│
├─ contracts/                       # Central contracts registry
│  ├─ openapi/                      # OpenAPI sources per slice
│  ├─ schemas/                      # JSON Schemas (DTOs/events)
│  ├─ ts/                           # Generated TS types/clients
│  └─ py/                           # Generated Python clients (uv pkg)
│
├─ infra/                           # IaC, deployment scaffolds
├─ ci-pipeline/                     # CI workflows & gates as code
│  ├─ workflows/
│  └─ gates/
├─ docs/                            # ADRs, specs, handbooks
└─ turbo.json, pnpm-workspace.yaml, pyproject.toml (uv workspace root), …
```

**Harmony mapping.** *Kits live in `packages/kits/*` (control plane); “flows” execute in a shared **platform flow runtime service** whose current LangGraph-based implementation lives under `platform/runtimes/flow-runtime/**`; apps and agents are thin hosts over kits that **call the runtime via contracts and generated clients**, not by importing its internals. See `runtime-architecture.md` for runtime tiers and contracts.*
**Vertical slices** live in `packages/<feature>` using hexagonal boundaries (domain→adapters→api) with specs/contracts co‑located and re‑exported via `contracts/`.

---

## 2) How TS & Python workspaces communicate (contracts-first)

**Contract flow.**

- **Source of truth:** `contracts/openapi/*.yaml` and `contracts/schemas/*.json`
- **TypeScript consumers:** generate types/clients via **openapi‑typescript** (types) and a light fetch wrapper (e.g., `openapi-fetch`) or Orval if you want auto-clients. ([OpenAPI TypeScript][4])
- **Python consumers:** generate a modern client via **openapi‑python‑client** (Pydantic v2 models). ([PyPI][5])
- **Gates:** Pact consumer/provider tests for in‑process ports; Schemathesis property‑based fuzzing for external HTTP APIs before promotion. ([Pact Docs][6])

Harmony requires **published interfaces only** with consumer‑driven contracts and CI gates—exactly what this does.

---

## 3) Turborepo configuration (one task graph for TS + Python)

### `turbo.json` (sample)

```jsonc
{
  "$schema": "https://turbo.build/schema.json",
  "globalEnv": ["CI", "TURBO_TOKEN", "TURBO_TEAM"],
  "pipeline": {
    // Contracts must be up-to-date before anyone builds or tests.
    "gen:contracts": {
      "cache": true,
      "outputs": ["contracts/ts/**/*", "contracts/py/**/*"],
      "persistent": false
    },

    // TypeScript
    "ts:build": {
      "dependsOn": ["gen:contracts", "^ts:build"],
      "outputs": ["dist/**", "tsconfig.tsbuildinfo"],
      "inputs": ["src/**", "package.json", "tsconfig.json", "tsconfig.base.json"]
    },
    "ts:typecheck": { "dependsOn": ["^ts:typecheck"] },
    "ts:lint":      { "dependsOn": ["^ts:lint"] },
    "ts:test":      { "dependsOn": ["^ts:test"], "outputs": ["coverage/**", "junit/**"] },

    // Python (run via uv)
    "py:lint": {
      "dependsOn": ["^py:lint"],
      "inputs": ["pyproject.toml", "uv.lock", "src/**", "tests/**"]
    },
    "py:typecheck": { "dependsOn": ["^py:typecheck"] },
    "py:test": {
      "dependsOn": ["^py:test"],
      "outputs": ["**/.pytest_cache/**", "coverage.py/**", "junit/**"],
      "inputs": ["pyproject.toml", "uv.lock", "src/**", "tests/**"]
    },

    // Aggregates
    "build": { "dependsOn": ["ts:build"], "cache": true },
    "test":  { "dependsOn": ["ts:test", "py:test"], "cache": false },
    "lint":  { "dependsOn": ["ts:lint", "py:lint"], "cache": true },
    "typecheck": { "dependsOn": ["ts:typecheck", "py:typecheck"], "cache": true }
  }
}
```

**Notes.** Turborepo discovers tasks by matching pipeline keys to workspace `package.json#scripts` and applies caching based on declared `inputs`/`outputs`. That’s why each Python workspace also has a tiny `package.json` shim to expose `py:*` scripts that call `uv`. ([Turborepo][1])

### Root `package.json`

```json
{
  "name": "@harmony/monorepo",
  "private": true,
  "packageManager": "pnpm@9",
  "devDependencies": {
    "turbo": "^2.2.0",
    "openapi-typescript": "^7.10.1",
    "openapi-fetch": "^0.8.4"
  },
  "scripts": {
    "turbo": "turbo",
    "gen:contracts": "pnpm -w --filter ./contracts run gen",
    "build": "turbo run build --parallel",
    "test": "turbo run test",
    "lint": "turbo run lint",
    "typecheck": "turbo run typecheck"
  }
}
```

### `pnpm-workspace.yaml`

```yaml
packages:
  - "apps/*"
  - "packages/*"
  - "packages/kits/*"
  - "agents/*"          # shimmed with package.json to expose uv tasks
  - "contracts"         # contains gen scripts for TS/Py clients
```

*pnpm* uses this file to define the workspace graph. ([pnpm][2])

### Python (uv) — workspace root `pyproject.toml` (excerpt)

```toml
[project]
name = "harmony-workspace-root"
version = "0.0.0"
requires-python = ">=3.12"
dependencies = []                    # workspace-shared (rare)

[tool.uv.workspace]
members = ["agents/*", "contracts/py", "platform/*"]

[tool.uv.sources]
# Example: make a local agent lib available as a dependency
runtime-common = { workspace = true }

# Dev toolchain used by Python workspaces
[dependency-groups.dev]
pytest = "^8.3"
mypy = "^1.10"
ruff = "^0.4"
schemathesis = "^3.32"
```

**Why this shape.** uv workspaces share one lockfile and let you `uv run --package <member>` to run commands in a member from anywhere—perfect for orchestrating via Turborepo. Define membership via `[tool.uv.workspace]`, and use `[tool.uv.sources]` for in‑repo deps. ([Astral Docs][3])

### Wiring Python workspaces into Turbo

Each Python member gets a minimal shim `package.json` so Turbo can see tasks:

```json
{
  "name": "@py/agents-runner",
  "private": true,
  "scripts": {
    "py:lint": "uv run ruff check .",
    "py:typecheck": "uv run mypy src",
    "py:test": "uv run -m pytest -q"
  }
}
```

Ruff (linter/formatter) and pytest are fast, monorepo‑friendly defaults. ([Astral Docs][7])

---

## 4) Slices + Hexagonal boundaries → Harmony mapping

- **Vertical slices** (`packages/<feature>`) own their schema + contracts and expose *ports* to adapters. The **domain** never depends on adapters; adapters depend inward.
- **Control plane (kits)** lives under `packages/kits/*` (FlowKit, AgentKit, PlanKit, …). Apps/agents *call kits*; kits never call apps.
- **Runtimes** split into:
  - **Control-plane runtimes** under `agents/**` that host Planner/Builder/Verifier/Orchestrator agents and other orchestration loops.
  - **Control-plane configuration for platform runtimes** under `platform/runtimes/config/` (for example, policy bundles, queue/worker profiles, default risk tiers, environment mappings) that shape how runtime services operate but are not runtime processes themselves.
  - **Platform runtime services** under `platform/runtimes/*-runtime/` (for example, the **platform flow runtime service** at `platform/runtimes/flow-runtime/**`) that execute flows/graphs on behalf of callers.
  - Agents, apps, and Kaizen **call the platform flow runtime service** behind contract-first APIs such as `/flows/run` and `/flows/start` via generated clients and contracts from `contracts/`; they do not import the runtime’s LangGraph engine internals directly. Conceptually, this runtime is a shared, multi-tenant execution substrate across apps, agents, and Kaizen (see `runtime-architecture.md`).
- **Comms & artifacts:** prefer **typed sync calls** in process and **artifact URIs** for large payloads; use **CloudEvents** for fan‑out.

This clean split supports Harmony’s “speed with safety, determinism, and guided autonomy.”

---

## 5) CI/CD & developer experience (DX)

**Core loop.** `pnpm install` → `pnpm turbo run gen:contracts lint typecheck test build`

- **Turborepo cache.** Local & remote cache (Vercel Remote Cache) via `TURBO_TOKEN` + `TURBO_TEAM`. ([Turborepo][8])
- **pnpm** caches Node deps via `actions/setup-node` with `cache: 'pnpm'`. ([Turborepo][8])
- **uv in CI.** Use official `astral-sh/setup-uv` to install uv and persist cache; `uv sync --locked` (or `uv run` which automatically locks/syncs) to guarantee reproducibility. ([Astral Docs][9])
- **TypeScript builds.** Use **project references** (`composite: true`; `tsc -b`) for incremental builds and strict boundaries. ([TypeScript][10])
- **Python checks.** `ruff check`, `ruff format`, `mypy`, `pytest` executed with `uv run` to leverage the workspace lockfile & env. ([Astral Docs][7])
- **Contract gates.** Pact (consumer/provider) and Schemathesis fuzzing of OpenAPI surfaces run in CI before promotion. ([Pact Docs][6])

---

## 6) Numbered implementation plan (12 steps)

1. **Initialize monorepo scaffolding**

   - `pnpm init -y` at repo root; add `turbo`, create `turbo.json`.
   - Add `pnpm-workspace.yaml` with globs for `apps/*`, `packages/*`, `agents/*`, `contracts/`. ([pnpm][2])

2. **Set up uv workspace**

   - `uv init` at the root → create `pyproject.toml`; add `[tool.uv.workspace]` with members (`agents/*`, `contracts/py`).
   - Commit the `uv.lock`. ([Astral Docs][3])

3. **Lay down directories** as in the tree above; add `.gitkeep` where needed.

4. **Create base TS config**

   - `tsconfig.base.json` with strict mode and path aliases; top‑level `tsconfig.json` with **references** to each TS workspace. ([TypeScript][10])

5. **Create example slice** `packages/inventory`

   - `domain/` (pure functions), `adapters/` (DB impl and outbound ports), `api/` (OpenAPI + DTO schemas), `tests/`. Tie exports via `index.ts`.

6. **Add Harmony kits** under `packages/kits/*` (e.g., FlowKit, AgentKit) as TS libraries; they export contracts only (no runtime).

7. **Add the platform flow runtime implementation** under `platform/runtimes/flow-runtime/**` with a thin HTTP server exposing `/flows/run` to FlowKit, following the platform runtime model in `runtime-architecture.md`.

8. **Contracts registry** (`contracts/`)

   - Put OpenAPI specs & JSON Schemas under `contracts/openapi` and `contracts/schemas`.
   - Create `contracts/package.json` scripts to generate TS and Python clients (next section). ([OpenAPI TypeScript][4])

9. **Wire Turbo tasks**

   - Add `gen:contracts`, `ts:*`, `py:*` tasks in `turbo.json`. Ensure each TS & Python workspace exposes scripts matching those pipeline keys. ([Turborepo][1])

10. **CI skeleton** with remote cache & uv

    - Use `astral-sh/setup-uv` and `actions/setup-node`; configure `TURBO_TOKEN`/`TURBO_TEAM`. ([Turborepo][8])

11. **Lint/type/test defaults**

    - TS: `eslint`, `tsc -b`, `vitest`/`jest`.
    - Py: `ruff`, `mypy`, `pytest` via `uv run`. ([Astral Docs][7])

12. **Add gates**

    - Pact & Schemathesis in CI; block merges on contract diffs/failures. ([Pact Docs][6])

---

## 7) Concrete configuration snippets

### Base TypeScript configs

**`tsconfig.base.json`**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022", "DOM"],
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "jsx": "react-jsx",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noFallthroughCasesInSwitch": true,
    "outDir": "dist",
    "declaration": true,
    "composite": true,
    "incremental": true,
    "tsBuildInfoFile": "tsconfig.tsbuildinfo",
    "baseUrl": ".",
    "paths": {
      "@kits/*": ["packages/kits/*/src"],
      "@slices/*": ["packages/*/src"],
      "@contracts/*": ["contracts/ts/*"]
    }
  }
}
```

**Per package** `packages/inventory/tsconfig.json`

```json
{
  "extends": "../../tsconfig.base.json",
  "include": ["src", "tests"],
  "compilerOptions": { "rootDir": "src" },
  "references": []
}
```

Use **project references** across apps/packages to speed builds and enforce graph order. ([TypeScript][10])

### Contracts: generation scripts (`contracts/package.json`)

```json
{
  "name": "@harmony/contracts",
  "private": true,
  "scripts": {
    "gen": "pnpm run gen:ts && pnpm run gen:py",
    "gen:ts": "openapi-typescript ./openapi/sample.yaml -o ./ts/sample.d.ts",
    "gen:py": "uv run -m openapi_python_client generate --path ./openapi/sample.yaml --output ./py/sample_client --install-project"
  },
  "devDependencies": { "openapi-typescript": "^7.10.1" }
}
```

- `openapi-typescript` generates TS types for consumers. ([OpenAPI TypeScript][4])
- `openapi-python-client` generates a modern Python client package (installed into the uv workspace with `--install-project`). ([PyPI][5])

### Example Python member (`platform/runtimes/flow-runtime/pyproject.toml`)

```toml
[project]
name = "agents-runner"
version = "0.1.0"
requires-python = ">=3.12"
dependencies = [
  "fastapi>=0.115,<1",
  "langgraph>=0.2",
  "pydantic>=2.7,<3"
]

[tool.uv]
# nothing special; inherited workspace lock

[tool.ruff]
line-length = 100
src = ["src"]

[tool.mypy]
python_version = "3.12"
packages = ["src"]
strict = true
```

---

## 8) End‑to‑end contract example

**Minimal OpenAPI (`contracts/openapi/sample.yaml`)**

```yaml
openapi: 3.0.3
info: { title: Inventory API, version: "1.0.0" }
paths:
  /items/{id}:
    get:
      summary: Get an inventory item
      parameters:
        - in: path
          name: id
          required: true
          schema: { type: string }
      responses:
        "200":
          description: OK
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/Item"
components:
  schemas:
    Item:
      type: object
      required: [id, sku, qty]
      properties:
        id: { type: string }
        sku: { type: string }
        qty: { type: integer, minimum: 0 }
```

**Generate clients:**

```bash
pnpm --filter @harmony/contracts run gen   # TS types + Python client
```

**TS consumer (`apps/api/src/usecases/getItem.ts`)**

```ts
import type { paths } from "@contracts/ts/sample";
type Item = paths["/items/{id}"]["get"]["responses"]["200"]["content"]["application/json"];
// call via your fetch wrapper; openapi-fetch works well with these types
```

**Python consumer (agent run step):**

```python
from sample_client import Client, api
client = Client(base_url="http://localhost:3000")
resp = api.items.get_item.sync(client=client, id="123")
item = resp.parsed
```

---

## 9) Workspace catalog (starter set)

| name                          | language | type    | role (Harmony)                   | slice/layer       |
| ----------------------------- | -------- | ------- | -------------------------------- | ----------------- |
| `apps/web`                    | TS       | app     | UI adapter over kits             | app layer         |
| `apps/api`                    | TS       | app     | HTTP adapter over kits           | app layer         |
| `packages/inventory`          | TS       | package | domain slice                     | domain + adapters |
| `packages/kits/flowkit`       | TS       | kit     | **control plane** (flows client) | control plane     |
| `packages/kits/agentkit`      | TS       | kit     | **control plane** (agents)       | control plane     |
| `platform/runtimes/flow-runtime` | Py    | runtime | **platform flow runtime (LangGraph-based)** | runtime layer     |
| `agents/architect/assessment` | Py       | agent   | thin host using AgentKit         | runtime host      |
| `contracts`                   | TS/Py    | package | contracts registry               | control plane     |
| `platform/observability`      | TS       | package | OTel integration                 | platform          |

*Kits are libraries in `packages/kits/*`; the platform flow runtime service is shared at `platform/runtimes/flow-runtime/**` and is called via contracts and generated clients, not imported directly.*

---

## 10) Minimal CI pipeline (GitHub Actions)

```yaml
name: ci
on:
  pull_request:
  push: { branches: ["main"] }

env:
  TURBO_TOKEN: ${{ secrets.TURBO_TOKEN }}
  TURBO_TEAM:  ${{ vars.TURBO_TEAM }}

jobs:
  build-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 2 }

      # Node + pnpm for TS tasks
      - uses: pnpm/action-setup@v3
        with: { version: 9 }
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'
      - run: pnpm install

      # uv for Python tasks (installs uv, can persist caches)
      - name: Setup uv
        uses: astral-sh/setup-uv@v7
      - name: Sync Python deps (locked)
        run: uv sync --locked

      # Generate contracts first (cached by Turborepo)
      - run: pnpm turbo run gen:contracts

      # Lint, typecheck, test across both languages via Turbo graph
      - run: pnpm turbo run lint typecheck test --summarize

      # Example: Schemathesis contract fuzz (OpenAPI) against preview
      - name: Contract fuzz
        run: |
          uv run schemathesis run $API_URL/openapi.json --checks all --junitxml=junit/schemathesis.xml
```

- Turborepo CI + Remote Cache: set `TURBO_TOKEN` & `TURBO_TEAM`. ([Turborepo][8])
- `astral-sh/setup-uv` is the recommended GitHub Action for uv and can persist cache. ([Astral Docs][9])

---

## 11) Playbooks

### A) Add a new **TypeScript app**

1. Create `apps/<name>/` with `package.json`, `src/`, `tsconfig.json` (extends base).
2. Register it in `pnpm-workspace.yaml`. ([pnpm][2])
3. Import contracts via `@contracts/*` (generated types).
4. Expose scripts: `"ts:build"`, `"ts:lint"`, `"ts:typecheck"`, `"ts:test"`.
5. Optional: add **Pact** tests for the app’s client → provider. ([Pact Docs][11])
6. Add to root `tsconfig.json#references` if you use solution builds. ([TypeScript][10])

### B) Add a new **Python agent/tool** (uv)

1. `agents/<agent-name>/` with `pyproject.toml` (member of the uv workspace) and `src/`.
2. Add a tiny `package.json` shim exposing `py:*` scripts (see above).
3. Declare dev tools in workspace root `[dependency-groups.dev]` (pytest, mypy, ruff).
4. Consume contracts from `contracts/py/<client>` by adding it as a dependency (`tool.uv.sources` if local). ([Astral Docs][3])
5. If calling flows, go through **FlowKit** (TS) → `/flows/run` on the shared runtime. Keep agent logic thin.

---

## 12) Anti‑patterns & guardrails

**Don’t do this:**

- Ad‑hoc cross‑workspace imports (e.g., `../../../other-slice`)—breaks encapsulation.
- Mixing `npm`/`yarn` with **pnpm**.
- Duplicating contracts/types across packages.
- Bypassing Turbo (running scripts directly) for CI‑relevant tasks.
- Building multiple Python virtualenvs outside uv workspace.

**Guardrails:**

- **ESLint boundaries**: enforce module boundaries and prevent cross‑slice imports. ([GitHub][12])
- **TS project references**: require `composite: true` and build with `tsc -b`. ([TypeScript][10])
- **CI gates**: Pact + Schemathesis must pass; OpenAPI diff checks. ([Pact Docs][6])
- **CODEOWNERS** by slice/kit; require review for contract changes.
- **uv discipline**: commit `uv.lock`; use `uv sync --locked` in CI to avoid silent lock drift. ([Astral Docs][13])
- **Remote cache**: enforce Turbo via CI so all tasks run in graph order with caching. ([Turborepo][8])

---

## 13) Trade‑offs & gotchas (with mitigations)

- **Python workspace isolation.** uv workspaces share one env/lock; imports aren’t fully isolated between members. Keep boundaries social/disciplinary (lint rules, tests) and add explicit `tool.uv.sources` for in‑repo deps to make intent clear. ([Astral Docs][3])
- **Cross‑language versioning.** Pin TS & Py client generators (openapi‑typescript / openapi‑python‑client) and regenerate in `gen:contracts` task to avoid drift. ([OpenAPI TypeScript][4])
- **Cache determinism.** Turbo assumes tasks are deterministic; declare all inputs/outputs (incl. `uv.lock`, `pyproject.toml`, `tsconfig*`). ([Turborepo][14])
- **Task visibility.** Turbo only runs tasks that exist as `scripts` in a workspace; ensure each Python member has the `package.json` shim. ([Turborepo][1])

Harmony alignment: *monolith‑first, hexagonal boundaries, control plane in kits, one shared runtime, contract‑first gates, OTel everywhere*.  

---

## 14) Appendices — concrete files

### A) `apps/api/package.json`

```json
{
  "name": "@apps/api",
  "private": true,
  "type": "module",
  "scripts": {
    "ts:build": "tsc -b",
    "ts:typecheck": "tsc -p tsconfig.json --noEmit",
    "ts:lint": "eslint .",
    "ts:test": "vitest run"
  },
  "dependencies": {
    "@contracts/ts": "workspace:*",
    "@kits/flowkit": "workspace:*"
  }
}
```

### B) `platform/runtimes/flow-runtime/package.json` (shim)

```json
{
  "name": "@py/platform-flow-runtime",
  "private": true,
  "scripts": {
    "py:lint": "uv run ruff check . && uv run ruff format --check .",
    "py:typecheck": "uv run mypy src",
    "py:test": "uv run -m pytest -q"
  }
}
```

### C) `contracts/README` (generation contract)

- **TS**: `openapi-typescript openapi/sample.yaml -o ts/sample.d.ts` ([OpenAPI TypeScript][4])
- **Python**: `uv run -m openapi_python_client generate --path openapi/sample.yaml --output py/sample_client --install-project` ([PyPI][5])

---

## 15) Validation checklist (Harmony‑aligned)

**Structure:**

- [ ] Slices in `packages/<feature>` with domain→adapters→api; apps & agents are *thin*.
- [ ] Kits in `packages/kits/*`; flows/agents call the shared platform flow runtime service at `platform/runtimes/flow-runtime/**` via generated clients and contracts.

**Contracts:**

- [ ] OpenAPI/JSON‑Schema are the source of truth in `contracts/`; TS/Py clients are generated. ([OpenAPI TypeScript][4])
- [ ] Pact + Schemathesis gates pass in CI before promotion. ([Pact Docs][6])

**Tooling integration:**

- [ ] Turborepo task graph spans TS + Py; `gen:contracts` precedes builds/tests. ([Turborepo][1])
- [ ] pnpm drives TS workspaces; uv drives Python workspaces with a shared lockfile. ([pnpm][2])

**CI/CD & DX:**

- [ ] Remote cache enabled (`TURBO_TOKEN`, `TURBO_TEAM`). ([Turborepo][8])
- [ ] `uv sync --locked` (or `uv run` with locked workflow) ensures reproducibility. ([Astral Docs][13])
- [ ] Lint/type/test across languages: ESLint/tsc + Ruff/mypy/pytest. ([Astral Docs][7])

**Governance & safety:**

- [ ] CODEOWNERS per slice/kit; boundary lint rules enabled. ([GitHub][12])
- [ ] Observability hooks present (OTel spans/ids in changed flows) per Harmony practice.

---

### Closing notes

- If you later need stricter Python isolation, split into **multiple uv workspaces** or use `tool.uv.sources` with per‑member venvs; uv documents when *not* to use workspaces and the limits around import isolation. ([Astral Docs][3])
- For TS, lean on **project references** and keep `composite: true` to preserve incremental builds and clear boundaries. ([TypeScript][10])

This design follows the Harmony repository blueprint (slices, kits, control plane, platform runtime service) and its agent/flow responsibilities—so the **control plane stays in TypeScript**, **flows/agents execute via the shared platform flow runtime service**, and **contracts** keep everything deterministic and testable.

[1]: https://turborepo.com/docs/reference/configuration?utm_source=chatgpt.com "Configuring turbo.json | Turborepo"
[2]: https://pnpm.io/pnpm-workspace_yaml?utm_source=chatgpt.com "pnpm-workspace.yaml"
[3]: https://docs.astral.sh/uv/concepts/projects/workspaces/ "Using workspaces | uv"
[4]: https://openapi-ts.dev/?utm_source=chatgpt.com "OpenAPI TypeScript"
[5]: https://pypi.org/project/openapi-python-client/?utm_source=chatgpt.com "openapi-python-client · PyPI"
[6]: https://docs.pact.io/?utm_source=chatgpt.com "Introduction | Pact Docs"
[7]: https://docs.astral.sh/ruff/?utm_source=chatgpt.com "Ruff - Astral"
[8]: https://turborepo.com/docs/guides/ci-vendors/github-actions?utm_source=chatgpt.com "GitHub Actions | Turborepo"
[9]: https://docs.astral.sh/uv/guides/integration/github/?utm_source=chatgpt.com "Using uv in GitHub Actions | uv - Astral"
[10]: https://www.typescriptlang.org/docs/handbook/project-references.html?utm_source=chatgpt.com "Documentation - Project References - TypeScript"
[11]: https://docs.pact.io/implementation_guides/javascript/docs/consumer?utm_source=chatgpt.com "Consumer Tests | Pact Docs"
[12]: https://github.com/javierbrea/eslint-plugin-boundaries?utm_source=chatgpt.com "javierbrea/eslint-plugin-boundaries - GitHub"
[13]: https://docs.astral.sh/uv/concepts/projects/sync/?utm_source=chatgpt.com "Locking and syncing | uv - docs.astral.sh"
[14]: https://turborepo.com/docs/crafting-your-repository/caching?utm_source=chatgpt.com "Caching | Turborepo"
