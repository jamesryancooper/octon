---
title: Contracts Registry
description: Canonical contracts/ layout and workflows for OpenAPI/JSON Schema and generated TypeScript/Python clients in the Harmony polyglot monorepo.
---

# Contracts Registry (`contracts/`)

Related docs: [monorepo polyglot (normative)](./monorepo-polyglot.md), [overview](./overview.md), [repository blueprint](./repository-blueprint.md), [monorepo layout](./monorepo-layout.md), [tooling integration](./tooling-integration.md), [knowledge plane](../knowledge-plane/knowledge-plane.md)

The `contracts/` directory is the **canonical contracts registry** for Harmony’s polyglot monorepo. It is the single source of truth for cross-slice and cross-language interfaces, powering generated clients for both TypeScript (control plane and apps) and Python (agents and runtimes).

All architecture documents that reference “contracts” SHOULD conceptually map to this registry.

## Structure

The registry has four main areas:

```text
contracts/
├─ openapi/        # Authoritative OpenAPI specs per slice/surface
├─ schemas/        # Shared JSON Schemas (DTOs/events)
├─ ts/             # Generated TypeScript types/clients
└─ py/             # Generated Python clients (uv workspace package)
```

- `contracts/openapi/*.yaml`:
  - Design-first OpenAPI specs for HTTP APIs (e.g., `inventory.yaml`, `billing.yaml`).
  - Owned by the relevant feature slice (e.g., `packages/inventory`) and curated in coordination with control-plane kits that use them.
- `contracts/schemas/*.json`:
  - JSON Schemas for shared DTOs and events.
  - Used for validation, documentation, and property-based testing.
- `contracts/ts/*`:
  - Generated TypeScript types/clients from `openapi-typescript` (or similar).
  - Consumed by `apps/*`, `packages/*`, and `packages/kits/*` via workspace aliases (for example, `@contracts/ts/inventory`).
- `contracts/py/*`:
  - Generated Python clients from `openapi-python-client`, installed into the uv workspace.
  - Consumed by `agents/*` and platform runtime services under `platform/runtimes/*` (for example, `platform/runtimes/flow-runtime/**`) via normal Python imports.

## Responsibilities

- **Interface source of truth** for cross-slice and cross-language interactions.
- **Client generation** for TypeScript and Python from a single declarative spec set.
- **Contract testing anchor** for Pact and Schemathesis in CI.
- **Knowledge Plane integration** as the authoritative contract catalog.

Feature slices remain the owners of their domain and adapter implementations under `packages/<feature>`, but they publish and evolve their external interfaces through the `contracts/` registry.

## Generation Workflow (`gen:contracts`)

The root `gen:contracts` task (see `monorepo-polyglot.md` and `tooling-integration.md`) keeps the TS/Py clients in sync with OpenAPI/JSON Schema definitions:

- **Inputs**:
  - `contracts/openapi/**/*.yaml`
  - `contracts/schemas/**/*.json`
- **Outputs**:
  - `contracts/ts/**/*`
  - `contracts/py/**/*`

Typical implementation (illustrative):

```json
{
  "scripts": {
    "gen": "pnpm run gen:ts && pnpm run gen:py",
    "gen:ts": "openapi-typescript ./openapi/inventory.yaml -o ./ts/inventory.d.ts",
    "gen:py": "uv run -m openapi_python_client generate --path ./openapi/inventory.yaml --output ./py/inventory_client --install-project"
  }
}
```

In the Turborepo task graph:

- `gen:contracts` is a top-level pipeline task with cached outputs (`contracts/ts/**/*`, `contracts/py/**/*`).
- All `ts:build` / `ts:test` / `py:test` tasks depend on `gen:contracts`, ensuring no consumer runs against stale contracts.

See `monorepo-polyglot.md` for a concrete `turbo.json`, root `package.json`, and `pnpm-workspace.yaml` excerpts.

## Consumption Patterns

### TypeScript Consumers

- Import generated types/clients from `contracts/ts` via workspace aliases (for example, `@contracts/ts/inventory`).
- Use a thin, typed fetch wrapper (for example, `openapi-fetch`) or generated client functions to call APIs.
- Treat generated files as read-only artifacts; API changes are made in `contracts/openapi` and regenerated.

Example (conceptual):

```ts
import type { paths } from "@contracts/ts/inventory";

type Item =
  paths["/items/{id}"]["get"]["responses"]["200"]["content"]["application/json"];
```

### Python Consumers

- Import generated Python clients from `contracts/py/<client>` as standard uv workspace packages.
- Use the generated client methods for typed HTTP interactions; do not hand-roll duplicative clients.

Example (illustrative):

```python
from inventory_client import Client, api

client = Client(base_url="http://localhost:3000")
resp = api.items.get_item.sync(client=client, id="123")
item = resp.parsed
```

## CI Gates and Contracts-First Posture

CI uses the contracts registry as the anchor for contract-first gates (see `tooling-integration.md` and `governance-model.md`):

- `gen:contracts` must succeed before TypeScript or Python build/test tasks.
- Pact consumer/provider tests validate compatibility between producers and consumers against the defined OpenAPI/JSON Schemas.
- Schemathesis (or equivalent) performs fuzz/negative testing of HTTP APIs based on `contracts/openapi`.
- Contract diff checks (e.g., `oasdiff`) compare proposed changes to the canonical specs under `contracts/` and annotate PRs with changes.

Contract test failures or unreviewed breaking diffs block merges unless explicitly waived under the Governance Model.

## Ownership and Versioning

- **Ownership**:
  - Each OpenAPI spec file is owned by the corresponding feature slice and recorded in CODEOWNERS.
  - Shared schemas and DTOs have clearly documented owners (usually platform or a designated slice).
- **Versioning**:
  - Backwards-compatible changes are additive (new fields, endpoints) with tests updated accordingly.
  - Breaking changes require either:
    - A new versioned contract file (for example, `billing.v2.yaml`), or
    - Clear, documented migration steps and updated consumers in the same change set.
  - Semver-like conventions may be used per API surface.

The Knowledge Plane should track contract versions, affected consumers, and test coverage for each contract surface.

## Relationship to Feature Slices and Kits

- Feature slices under `packages/<feature>`:
  - Own domain rules and adapters.
  - Publish their external HTTP contracts in `contracts/openapi` and `contracts/schemas`.
- Kits under `packages/kits/*`:
  - Use generated TS types/clients from `contracts/ts` to talk to HTTP APIs or the shared LangGraph runtime.
  - May define additional in-process contracts, but cross-language/contracts that leave the process SHOULD be represented in `contracts/`.
- Python agents and flows under `agents/*`:
  - Use generated clients from `contracts/py` to call TS-hosted HTTP APIs, keeping cross-language behavior consistent and testable.

## Guidance for Other Docs

When other architecture documents refer to:

- “Contracts & Types” as a layer → treat `contracts/` as the canonical location.
- “OpenAPI/JSON Schema” → assume they live under `contracts/openapi` and `contracts/schemas`.
- “Generated TS/Python clients” → assume they live under `contracts/ts` and `contracts/py`, produced via `gen:contracts`.

Legacy references to `packages/contracts` are superseded by this registry and SHOULD be updated accordingly.
