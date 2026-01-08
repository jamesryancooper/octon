---
title: Implementation Profile — Next.js/Astro/Vercel
description: Stack-specific guidance for applying HSP using Next.js 16/React 19, Astro, and Vercel with the canonical apps/* + packages/* layout and platform runtime services.
---

# Implementation Profile: Next.js/Astro/Vercel

Related docs: [monorepo polyglot (normative)](./monorepo-polyglot.md), [overview](./overview.md), [monorepo layout](./monorepo-layout.md), [repository blueprint](./repository-blueprint.md), [runtime architecture](./runtime-architecture.md), [runtime policy](./runtime-policy.md), [observability requirements](./observability-requirements.md), [tooling integration](./tooling-integration.md), [contracts registry](./contracts-registry.md), [python runtime workspace](./python-runtime-workspace.md)

This profile applies the Harmony Structural Paradigm (HSP) to the Next.js/Astro/Vercel stack. It does not change HSP’s architectural decisions; it provides concrete practices for this stack using the canonical polyglot monorepo layout (`apps/*`, `packages/*`, `packages/kits/*`, `agents/*`, `contracts/`, `platform/*`, `ci-pipeline/`), with a **platform-centric runtime model** under `platform/runtimes/*-runtime/` as described in `runtime-architecture.md`.

Version note: this profile targets **Next.js 16 with React 19**. Some referenced resources (see `resources.md`) describe the introduction of caching and Partial Prerendering (PPR) behavior in Next.js 15; the architectural guidance here assumes those semantics as carried forward into 16+.

## Layout

- `apps/ai-console` (Next.js 16, App Router)
  - Thin controllers (Server Components, server actions, and route handlers); orchestrate flows; delegate to `packages/<feature>/domain`.
  - Prefer Node runtime for heavy/AI tasks; reserve Edge runtime for read-mostly endpoints and low-latency fan-out.
- `apps/api` (Node HTTP ports)
  - Hosts OpenAPI-defined routes; imports DTOs/contracts from the root `contracts/` registry via generated TS types/clients in `contracts/ts`.
- Python AI/runtime workloads
  - Specialized Python flows and control-plane agent runtimes live under `agents/*` and are accessed via FlowKit/AgentKit and generated Python clients from `contracts/py`.
  - The shared, LangGraph-based **platform flow runtime service** lives under `platform/runtimes/flow-runtime/**` and is treated as a runtime-plane service: apps, agents, and Kaizen call its contract-first APIs (for example, `/flows/run`, `/flows/start`) via generated TS/Py clients, not by importing LangGraph internals or calling engine entrypoints directly.
- `apps/web` (Astro)
  - Docs/marketing; can embed read-only telemetry and runtime status.
- `packages/<feature>.*`
  - `*.domain`: pure use cases; no framework imports; deterministic by default.
  - `*.adapters`: DB/HTTP/cache; implement ports; unit/integration tested.
  - `*.api`: interfaces, generated clients/servers from OpenAPI/JSON Schema when applicable.
  - `*.tests`: unit, contract (Pact), and Schemathesis-driven negative tests.

## Contracts

- Contract-first for published HTTP APIs: maintain OpenAPI/JSON Schema in the root `contracts/openapi` and `contracts/schemas` directories, owned by the relevant feature slices and kits.
- Generated clients:
  - TypeScript: `openapi-typescript` (or equivalent) generates types/clients under `contracts/ts`, consumed by `apps/*`, `packages/*`, and `packages/kits/*`.
  - Python: `openapi-python-client` generates clients under `contracts/py`, consumed by `agents/*` and platform runtime services under `platform/runtimes/*-runtime/**` (for example, the flow runtime under `platform/runtimes/flow-runtime/**`) via the uv workspace.
- CI gates: run Pact consumer/provider tests and Schemathesis fuzz/negative tests against the contracts registry; block merges on failures unless explicitly waived per governance.

This profile assumes that all callers (apps, agents, Kaizen, and the platform runtime itself when it calls other services) use these generated clients rather than hand-rolled HTTP or direct engine imports.

## Observability

- Use OpenTelemetry SDK for traces/logs/metrics across `apps/*` and `packages/*`.
- Propagate W3C trace context (`traceparent`) through server actions, route handlers, and background jobs.
- Link traces to PRs/builds via custom PR annotations in CI (see `tooling-integration.md`) and expose trace IDs in PR comments for reviewers.
- Ensure runtime-related spans include standardized attributes such as `flow_id`, `flow_version`, `run_id`, `caller_kind`, `caller_id`, `project_id`, `environment`, and `risk_tier` when interacting with the platform runtime service.

## Runtime Guidance (Next.js 16 / React 19)

- Server Components and Server Actions:
  - Keep controllers thin; avoid embedding business logic in route handlers or server actions.
  - Validate inputs at boundaries; delegate to `packages/<feature>/domain` or to FlowKit/AgentKit when flows or agents are required.
  - For long-running or multi-step flows, offload execution to the **platform flow runtime** via its contract-first API rather than running orchestration loops inside Next.js handlers.
- Edge vs Node:
  - Prefer Node for compute-heavy, stateful, or AI/LLM interactions.
  - Use Edge only for read-mostly, low-latency endpoints (for example, public health checks, flag evaluation, static content composition) with strict limitations on IO and heavy computation.
- Caching:
  - Default dynamic reads to `no-store` unless proven safe via tests and monitoring.
  - In Next.js 16, GET route handlers are **uncached by default**; opt in to caching explicitly with stable keys/TTLs.
  - Use explicit, stable cache keys and low-cardinality labels; avoid implicit cache coupling across features or routes.
  - Treat caching as an optimization guarded by tests and observability, not a correctness mechanism.
- Scheduling and background work:
  - Offload heavy or non-interactive work to background jobs (for example, via `next/after`, queues, or the platform runtime’s batch/eval capabilities) guarded by feature flags and policy.
  - Ensure background tasks carry the same trace context and caller metadata used in foreground flows so they remain observable and attributable.
- Partial Prerendering (PPR):
  - Opt in selectively for pages with well-defined dynamic "holes" that can be progressively hydrated.
  - Keep critical correctness paths server-rendered and deterministic; avoid complex business logic in client-only components when correctness or policy enforcement is involved.

## Flags and Rollouts

- Manage feature flags in the platform/control plane (for example, under `platform/runtimes/config/` for runtime-related policies and flags, and app-specific configs for UI behavior); guard new paths and risky adapters.
- Default all new flags **OFF**; under resolution errors, use deterministic safe defaults (fail‑closed).
- Progressive rollout:
  - Internal/test users → small percentage of traffic → full rollout.
  - Clean up flags post-stabilization; treat stale flags as technical debt surfaced via Kaizen/Autopilot jobs.
- Provider integration:
  - Use a lightweight provider (for example, Vercel Edge Config via an adapter) for server-side evaluation in Next.js.
  - Evaluate flags at the server boundary (Edge or Node) and pass decisions inward as explicit configuration; do not embed provider-specific logic deep in domain code.
  - For flows executed by Python agents or the **platform flow runtime service**, pass flag decisions as part of the runtime contract payload rather than re-resolving flags inside Python flows.

## CI/CD and Knowledge Plane Correlation

- PR annotation:
  - A custom CI step posts `{ build_id, pr_number, trace_context, commit_sha }` to PRs and to the Knowledge Plane correlation API (`POST /kp/correlation`) as described in `knowledge-plane.md`.
  - This correlation is used to link PRs ↔ builds ↔ deployments ↔ traces for debugging and governance.
- Vercel previews:
  - Every PR for `apps/*` produces a Vercel Preview; reviewers validate behavior (including runtime interactions) there before promotion.
- Promotion and rollback:
  - Promote previews to production manually after verification; rehearse instant rollback regularly.
  - Treat promote/rollback and flag flips as operational runbooks; record events and outcomes in the Knowledge Plane.

## Example Dependency Boundaries

- `apps/*`:
  - May depend on `packages/<feature>/api` and `packages/<feature>/domain` via stable interfaces.
  - May consume generated contracts from `contracts/ts`.
  - Must **not** depend directly on `agents/*` or `platform/runtimes/*-runtime/**`; all interactions with Python agents or platform runtimes go through contracts (HTTP APIs and generated clients).
- `packages/<feature>/adapters`:
  - Depend inward on `packages/<feature>/domain` only; they implement ports but do not import UI or app code.
- `packages/common/*`:
  - Are dependency-light and curated to avoid accidental coupling; treat them as shared primitives, not a dumping ground.

These boundaries preserve the monolith-first, vertically sliced architecture while making the Next.js/Astro/Vercel stack a thin orchestration layer over domain and runtime services.

## Testing Strategy

- Domain:
  - Deterministic, fast unit tests for `packages/<feature>/domain`; use property-based testing where useful.
- Adapters:
  - Integration tests with containers/emulators for DB/queue/external APIs.
  - Contract tests (Pact) for HTTP providers/consumers using the root `contracts/` registry.
- Next.js apps:
  - Component-level tests where valuable; prefer server-side tests for critical logic.
  - E2E smoke tests against previews for key flows (for example, login, checkout) with trace correlation.
- Runtime interactions:
  - Schemathesis for fuzz/negative tests against runtime-related OpenAPI specs (for example, `runtime-flows` APIs).
  - Golden-path flows (for example, a representative flow run via `/flows/run`) covered by CI, with run metadata and traces stored in the Knowledge Plane.

## Deployment

- Vercel previews on every PR for `apps/*` (Next.js and Astro).
- Manual promote to production after:
  - PR review and CI green.
  - Preview verification by humans and, optionally, by automated smoke tests.
- Keep deploy and release decoupled via feature flags:
  - Deploy code with flags OFF; flip flags progressively once behavior is validated.
  - For runtime changes (for example, new flows in `platform/runtimes/flow-runtime/**`), use the same promote/rollback and flag-based control described in `runtime-policy.md`.

## Notes

- This profile is **implementation-specific but non-normative**: core HSP decisions and the runtime model in `runtime-architecture.md` remain authoritative.
- When in doubt:
  - Keep Next.js surfaces thin and deterministic.
  - Treat `platform/runtimes/*-runtime/**` as the shared execution substrate for flows and graphs.
  - Use the root `contracts/` registry and generated clients (`contracts/ts`, `contracts/py`) for all cross-language and runtime calls.
