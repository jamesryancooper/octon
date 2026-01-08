---
title: Python Runtime Workspace and Platform Flow Runtime
description: Canonical uv workspace, agents/* layout, and LangGraph-based platform flow runtime design for Harmony’s polyglot monorepo.
---

# Python Runtime Workspace and Platform Flow Runtime

Related docs: [monorepo polyglot (normative)](./monorepo-polyglot.md), [overview](./overview.md), [monorepo layout](./monorepo-layout.md), [repository blueprint](./repository-blueprint.md), [tooling integration](./tooling-integration.md), [contracts registry](./contracts-registry.md), [agent roles](./agent-roles.md)

This document specifies the canonical Python runtime workspace for Harmony’s polyglot monorepo: how uv workspaces, `agents/*`, and the shared LangGraph-based **platform flow runtime service** under `platform/runtimes/flow-runtime/**` fit together under the contracts-first, Turborepo+pnpm+uv model.

It is a **canonical reference** for Python runtime structure; stack-specific details (for example, exact FastAPI routes) remain implementation choices.

## Workspace Overview

At the repo root, `pyproject.toml` defines a uv workspace:

```toml
[project]
name = "harmony-workspace-root"
version = "0.0.0"
requires-python = ">=3.12"
dependencies = []

[tool.uv.workspace]
members = ["agents/*", "contracts/py", "platform/*"]
```

- One **uv workspace** with a shared lockfile (`uv.lock`) manages Python dependencies for:
  - `agents/*`: Python agent hosts (Planner/Builder/Verifier/Orchestrator and Kaizen/governance agents).
  - `contracts/py`: generated Python clients for HTTP APIs, produced by `gen:contracts`.
  - `platform/*`: platform-level Python tools and platform runtime services (including `platform/runtimes/flow-runtime/**`).
- uv enables running commands in any member via `uv run --package <member> ...`, which Turborepo uses to orchestrate Python tasks.

## Agents Layout (`agents/*`)

Agents are **runtime hosts**, not libraries:

```text
agents/
├─ planner/           # Planner agent runtime
├─ builder/           # Builder agent runtime
├─ verifier/          # Verifier agent runtime
└─ orchestrator/      # Orchestration/gateway agent
```

- `agents/planner`, `agents/builder`, `agents/verifier`, `agents/orchestrator`:
  - Implement role-specific agents (see `agent-roles.md`).
  - May import:
    - TypeScript-exposed APIs via HTTP, using generated Python clients from `contracts/py`.
    - Shared prompts from `packages/prompts` (via TS kits and HTTP flows) or local Python prompt assets.

The LangGraph-based **platform flow runtime** is implemented under the platform runtime services hierarchy:

```text
platform/
  runtimes/
    flow-runtime/      # LangGraph-based implementation of the platform flow runtime service (flows + /flows/run, /flows/start, etc.)
```

- `platform/runtimes/flow-runtime/**`:
  - Implements the **platform flow runtime service** (currently LangGraph-based):
    - Builds and executes graphs corresponding to FlowKit flows and AgentKit agents.
    - Exposes contract-first runtime APIs (for example, `/flows/run`, `/flows/start`, `/flows/{runId}`) whose OpenAPI/JSON Schema definitions live under the root `contracts/` registry and are consumed via generated TS/Py clients (for example, `runtime-flows` clients).
  - Is treated as runtime infrastructure behind kit contracts, not as a kit itself, and is part of the shared platform runtime described in `runtime-architecture.md`.

## Platform Runtime Responsibilities (LangGraph Implementation)

The LangGraph-based platform runtime under `platform/runtimes/flow-runtime/**` is responsible for:

- Executing FlowKit flows and AgentKit agents based on manifests/contracts defined in TypeScript kits and/or configs.
- Providing a stable HTTP API (`/flows/run`) whose schema is represented in the `contracts/` registry:
  - Request/response JSON Schemas and OpenAPI definitions under `contracts/openapi` and `contracts/schemas`.
  - Generated TS/Python clients for FlowKit in `contracts/ts` and `contracts/py`.
- Emitting OpenTelemetry traces/logs/metrics with trace IDs correlated to PRs/builds (see `observability-requirements.md` and `knowledge-plane.md`).

Any additional endpoints exposed by the runtime SHOULD follow the same contracts-first pattern and be captured in the `contracts/` registry.

## Turborepo Integration and Python `package.json` Shims

Turborepo discovers tasks via `package.json` scripts. Each Python workspace member that participates in the Turbo graph exposes a minimal `package.json` shim:

```json
{
  "name": "@py/agents-runner",
  "private": true,
  "scripts": {
    "py:lint": "uv run ruff check . && uv run ruff format --check .",
    "py:typecheck": "uv run mypy src",
    "py:test": "uv run -m pytest -q"
  }
}
```

-- This pattern is applied to `agents/*` and `platform/runtimes/flow-runtime/**` and other Python members as needed.

- Turborepo’s pipeline (see `monorepo-polyglot.md`) defines:
  - `py:lint`, `py:typecheck`, `py:test` tasks, with inputs/outputs referencing `pyproject.toml`, `uv.lock`, `src/**`, and `tests/**`.
  - Aggregate `lint`, `typecheck`, and `test` tasks that depend on both `ts:*` and `py:*` tasks.
- All `py:*` tasks depend (directly or indirectly) on `gen:contracts` so that generated Python clients in `contracts/py` are up to date before tests run.

## Contracts and Python Clients

Python code in `agents/*` and `platform/runtimes/flow-runtime/**` MUST use generated clients from `contracts/py` for cross-service HTTP calls:

- API interfaces are defined in `contracts/openapi/*.yaml` and `contracts/schemas/*.json`.
- `gen:contracts` generates Python packages under `contracts/py/*`.
- uv workspace configuration (`[tool.uv.workspace]` and `[tool.uv.sources]`) makes these packages importable from `agents/*`.

Example usage (conceptual):

```python
from inventory_client import Client, api

client = Client(base_url="http://localhost:3000")
resp = api.items.get_item.sync(client=client, id="123")
item = resp.parsed
```

This ensures that TypeScript apps (for example, `apps/api`) and Python agents see the **same contracts**, enforced by CI gates (Pact, Schemathesis) and recorded in the Knowledge Plane.

## CI, Linting, and Testing

CI treats Python workspaces as first-class citizens alongside TypeScript:

- `py:lint`: `uv run ruff check . && uv run ruff format --check .`
- `py:typecheck`: `uv run mypy src`
- `py:test`: `uv run -m pytest -q`

In `turbo.json` (see `monorepo-polyglot.md`):

- Each `py:*` task declares:
  - Inputs: `pyproject.toml`, `uv.lock`, `src/**`, `tests/**`.
  - Outputs: caches (`.pytest_cache`), coverage, junit reports, as applicable.
- Aggregate tasks:
  - `lint`: depends on `ts:lint` and `py:lint`.
  - `typecheck`: depends on `ts:typecheck` and `py:typecheck`.
  - `test`: depends on `ts:test` and `py:test`.

This unified task graph ensures deterministic, cached checks across both languages.

## Observability Requirements for Python Runtimes

The Python runtime workspace follows the same observability requirements as TS apps (see `observability-requirements.md`):

- OpenTelemetry traces/logs/metrics:
  - Propagate W3C trace context (`traceparent`) through the LangGraph runtime and any HTTP calls via generated clients.
  - Include feature/module identifiers, spec IDs, and contract endpoints where feasible.
- CI ↔ Knowledge Plane correlation:
  - Python CI jobs publish correlation payloads to `POST /kp/correlation` just like TS jobs, linking PRs/builds to traces and deployments.
- Redaction and privacy:
  - GuardKit (or equivalent) is applied at log/write boundaries for PII/PHI; secrets are handled exclusively via VaultKit (or equivalent).

## Canonical vs Optional Elements

Canonical (required for Harmony polyglot alignment):

- uv workspace at repo root with `agents/*`, `contracts/py`, and `platform/*` (including `platform/runtimes/flow-runtime/**`) as members.
- `platform/runtimes/flow-runtime/**` as the single shared LangGraph-based platform flow runtime behind contract-first APIs such as `/flows/run` and `/flows/start`.
- `contracts/` as the contracts registry and `contracts/py` as the Python client source.
- Turborepo integration via `py:*` tasks and `package.json` shims.

Optional/implementation-specific:

- Exact routing stack (for example, FastAPI vs another ASGI framework) inside `platform/runtimes/flow-runtime/**`.
- Additional agent hosts beyond `planner`, `builder`, `verifier` (for example, specialized tooling agents), provided they follow the same workspace and contracts patterns.
- Additional Python tooling in `platform/*` as long as it respects the uv workspace boundaries and contracts-first posture.

## Cross-References

- For repository shape and task graph details, see `monorepo-polyglot.md`, `repository-blueprint.md`, and `monorepo-layout.md`.
- For contracts and client generation, see `contracts-registry.md` and `tooling-integration.md`.
- For agent responsibilities and governance, see `agent-roles.md`, `kaizen-subsystem.md`, and `mape-k-loop-modeling.md`.
