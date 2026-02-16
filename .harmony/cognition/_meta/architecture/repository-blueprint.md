---
title: Structural Repository Blueprint and Module Boundaries
description: Canonical repo layout, module boundaries, and contracts for a vertically sliced, modular monolith with a thin control plane.
---

# Structural Repository Blueprint and Module Boundaries

Related docs: [monorepo polyglot (normative)](./monorepo-polyglot.md), [overview](./overview.md), [monorepo layout](./monorepo-layout.md), [tooling integration](./tooling-integration.md)

This document specifies the repository layout, module boundaries, and inter-component contracts for a vertically sliced, modular monolith. Harmony standardizes on an `apps/*` + `packages/*` layout. It aims to maximize clarity for a small team while preserving encapsulation and determinism, enabling safe evolution toward more distributed architectures if warranted.

## Objectives

- Provide a clear, navigable repository structure.
- Enforce strict module boundaries with published interfaces and events.
- Maintain determinism and testability within a single deployable unit.
- Enable straightforward scaling and a future path to service extraction.

## High-Level Structure

Organize by feature (vertical slice) in `packages/*`; enforce hexagonal (ports/adapters) boundaries within each feature. Keep shared code minimal and establish explicit apps (thin adapters), platform, agents, Kaizen, contracts, CI, and docs areas. A thin control plane (flags, policy, contracts, observability) lives in-repo as libraries and CI gates, not as a separate runtime.

```plaintext
HarmonyMonorepo
├─ apps/                     # Deployable TypeScript applications and UIs (thin adapters)
│  ├─ ai-console             # Next.js app (controllers, server actions)
│  ├─ api                    # HTTP ports (OpenAPI), BFFs, webhooks
│  └─ web                    # Astro/docs/marketing
├─ packages/                 # Reusable libraries organized by feature slices and control-plane kits
│  ├─ <feature>/             # Vertical feature slice (single workspace package)
│  │  ├─ domain              # Pure domain/use-cases (functional core)
│  │  ├─ adapters            # DB/HTTP/cache integrations (outbound adapters)
│  │  ├─ api                 # Inbound API surface (interfaces/contracts)
│  │  ├─ tests               # Unit/integration/contract tests for the slice
│  │  └─ docs/spec.md        # Brief slice spec (scope, contracts, risks)
│  ├─ common/                # Cross-cutting helpers and canonical DTOs
│  │  ├─ util                # Cross-cutting helpers (minimal)
│  │  └─ models              # Canonical DTOs/value objects
│  ├─ kits                   # AI-Toolkit control-plane libs (FlowKit, PlanKit, PromptKit, EvalKit, TestKit, GuardKit, etc.)
│  └─ prompts                # Prompt suites (knowledge-plane library) imported by kits and agents
├─ platform/
│  ├─ knowledge-plane        # Specs, policies, sbom, traces (authoritative)
│  ├─ observability          # OTel bootstrap, dashboards, rules
│  └─ runtimes/              # Platform runtime services (runtime plane; shared across apps, agents, and Kaizen) and their control-plane configuration (see `runtime-architecture.md`)
│     ├─ config/             # Control-plane configuration for platform runtimes (flags, rollout descriptors, runtime policy bundles, queue/worker profiles, risk tiers, env mappings)
│     └─ flow-runtime/       # LangGraph-based implementation of the platform flow runtime service (runtime-plane API/scheduler/executors; exposed via contract-first `/flows/run`, `/flows/start`, etc.)
├─ agents/                   # Python control-plane runtimes hosting Planner/Builder/Verifier/Orchestrator agents
│  ├─ planner
│  ├─ builder
│  ├─ verifier
│  └─ orchestrator           # Python orchestration agent behind a stable HTTP port (may call kits/agents, owns no domain)
├─ kaizen/                   # Kaizen/Autopilot layer (policies, evaluators, codemods, agents, reports)
│  ├─ policies/
│  ├─ evaluators/
│  ├─ codemods/
│  ├─ agents/
│  └─ reports/
├─ contracts/                # Contracts registry (OpenAPI/JSON Schema + generated TS/Python clients)
│  ├─ openapi
│  ├─ schemas
│  ├─ ts
│  └─ py
├─ ci-pipeline/
│  ├─ workflows              # CI pipelines (build/test/scan)
│  └─ gates                  # Policy/contract/coverage gates
├─ .github/
│  └─ workflows/
│     └─ kaizen.yaml         # Scheduled & on-demand Kaizen jobs (docs/flags hygiene)
└─ docs/                     # Architecture docs, ADRs, handbooks, guides
```

Supporting artifact:

- `repo_structure.json`: machine-readable structure for tools and agents.

## Feature Modules

Each feature in `packages/<feature>` is a bounded context that encapsulates its domain, interface, infrastructure, and tests. Within a feature package:

- `domain/` is the inner hexagon; it never depends on `api/` or `adapters/`.
- `api/` and `adapters/` act as adapters. They depend inward on `domain/`.
- `tests/` co-locates unit, integration, and contract tests with the feature code.
- Optional: co-locate a brief spec (`docs/spec.md`) and slice-level JSON Schemas; re-export externally via the root `contracts/` registry for uniform CI contract testing and client generation.

Hexagonal Architecture and dependency direction ensure deterministic, testable modules. The domain core is technology-agnostic and stable; adapters can change with minimal ripple.

## Kits as Control-Plane Libraries: `packages/kits`

Kits live in the **control plane** and are reused across the entire repo. They are implemented as libraries under `packages/kits/*` and expose stable contracts and APIs that apps, agents, Kaizen jobs, and CI gates can call.

- **Primary placement (kits):**
  - `packages/kits/<kit-name>/...`
  - Source of truth for:
    - Kit config and contracts (types, schemas, interfaces).
    - Public APIs used by `apps/*`, `agents/*`, `kaizen/*`, and `ci-pipeline/*`.
    - Any “local dev tool” commands that operate on the repo (for example, CLIs that help improve docs or code).
- **Secondary placements (runtimes/adapters) are consumers of kits:**
  - `apps/*` — thin HTTP/CLI adapters that call kits in `packages/kits/*`.
  - `agents/*` — agent flows that use kits as tools during planner/builder/verifier work.
  - `kaizen/*` — hygiene/improvement jobs that call kits for analysis and patch proposals.
  - `ci-pipeline/*` — quality gates that import kit APIs (for example, EvalKit/FlowKit checks).

For example:

- **FlowKit** (planning & orchestration):
  - Contracts and TypeScript interfaces live under `packages/kits/flowkit/`.
  - The LangGraph-based implementation of the platform flow runtime service is treated as runtime infrastructure for FlowKit and lives under `platform/runtimes/flow-runtime/**`, not inside the kit itself.
  - Apps such as `apps/web`, `apps/api`, and `apps/ai-console` depend on FlowKit via the TS package, not the other way around. Python agents and orchestrators under `agents/*` (for example, `agents/orchestrator`) and the shared platform flow runtime under `platform/runtimes/flow-runtime/**` are accessed via FlowKit/AgentKit and runtime contracts in `contracts/`, not via a separate ad-hoc `apps/ai-gateway` service and not by importing LangGraph engine internals directly.

The general rule: **kits are libraries and contracts in `packages/kits`, with optional hosts in `apps/*`, `agents/*`, `kaizen/*`, and CI**. Runtimes (for example, LangGraph flows, external services) sit behind those kit contracts.

Example flow (InventoryManagement):

- `apps/api` receives `PUT /inventory/stock` (controller).
- Controller invokes `packages/inventory/domain` use case which executes business rules.
- Persistence via `packages/inventory/adapters/SqlInventoryRepository`.
- `packages/inventory/tests` contains unit tests for rules and integration tests for the slice.

## Shared Code: `common/`

Use `packages/common/*` only for genuinely cross-cutting utilities or shared primitives (e.g., value objects like `Money`, date helpers). Keep it small to avoid accidental coupling. Treat it like any other module with explicit APIs.

## Platform Services: `platform/`

- `knowledge-plane/`: Manages specifications, traces, SBOM, policies, and data catalogs. Serves as a knowledge hub for humans and agents.
- `observability/`: Centralizes logging, metrics, tracing, and instrumentation standards. Ensures consistent trace context propagation.
- `runtimes/config/`: Hosts **control-plane configuration for platform runtimes** (feature flag definitions, rollout policies, runtime policy bundles, queue/worker profiles, risk tiers, environment mappings). Runtime services under `platform/runtimes/*-runtime/` consume this configuration; for the canonical runtime model and internal tiers, see `runtime-architecture.md`.

## Agent System: `agents/`

Houses Planner, Builder, Verifier, and Orchestrator agents as **control-plane runtimes**:

- **planner/**: Planner agent runtime responsible for strategic reasoning and backlog refinement.
- **builder/**: Builder agent runtime responsible for code-generation or automation tasks that implement planned work.
- **verifier/**: Verifier agent runtime responsible for validation, QA harnesses, and autonomous review against merge criteria.
- **orchestrator/**: Orchestration/gateway agent that exposes a stable HTTP port, may call kits and other agents, and coordinates AI work across the system without owning domain logic.

Agents under `agents/` are **control-plane runtime processes**, not shared libraries: they are invoked by FlowKit or other callers (for example, via CLI or a Python module entrypoint) and may themselves import kits and prompt libraries from `packages/*`. They plan, analyze, and orchestrate work, and when they need to execute flows/graphs they call the shared **platform flow runtime service** under `platform/runtimes/flow-runtime/**` via generated clients and runtime contracts in `contracts/`, rather than embedding or owning their own general-purpose runtime.

The **platform flow runtime service** is a separate **runtime-plane service** under `platform/runtimes/flow-runtime/**` that:

- Builds and executes graphs for FlowKit flows using prompts and workflow manifests via engine backends such as the LangGraph implementation under `platform/runtimes/flow-runtime/langgraph/**`.
- Exposes a single, contract-first HTTP API surface (for example, `/flows/run`, `/flows/start`) used by FlowKit, AgentKit, apps, agents, and Kaizen (see `runtime-architecture.md`).
- Provides internal LangGraph Studio entrypoints via `langgraph.json` and related files; these are engine surfaces used by the runtime, not public APIs for apps or agents.

This keeps a clear distinction between things you **run** at the root control plane (`apps/*`, `agents/*`) and things you **run in the runtime plane** (`platform/runtimes/*-runtime/`), as well as the libraries and knowledge you **import** (`packages/*`, including `packages/prompts`). For conceptual roles and responsibilities of PlanKit, AgentKit, FlowKit, and the platform runtime, see `.harmony/capabilities/services/execution/service-roles.md` and `runtime-architecture.md`.

## Contracts Registry: `contracts/`

The root `contracts/` directory is the **canonical contracts registry** for all published interfaces that cross slice or language boundaries:

- `contracts/openapi/*.yaml`: OpenAPI specs per slice or surface.
- `contracts/schemas/*.json`: JSON Schemas for shared DTOs/events.
- `contracts/ts/*`: Generated TypeScript types/clients (for apps, kits, and TS packages).
- `contracts/py/*`: Generated Python clients (for agents and runtimes in the uv workspace).

A single, cached `gen:contracts` task (see `monorepo-polyglot.md` and `tooling-integration.md`) keeps these generated clients in sync:

- OpenAPI/JSON Schema are the **source of truth**.
- `openapi-typescript` generates `contracts/ts/*`.
- `openapi-python-client` generates `contracts/py/*` and installs them into the uv workspace.
- All `ts:*` and `py:*` build/test tasks depend on `gen:contracts` to avoid drift.

## CI/CD and Policy: `ci-pipeline/`

- `workflows/`: Build, test, and deploy pipelines (e.g., GitHub Actions).
- `gates/`: Quality gates and policy enforcement (linting, coverage, security scans, architecture checks).

Version all CI configuration in-repo to enable reviewability and repeatability.

## Workflow Defaults

- Trunk-based development with small, reviewable PRs.
- Every PR produces a Vercel Preview deployment for human and automated verification.
- Manual promote/rollback is the default; progressive delivery guarded by feature flags.
- Contract-first checks (Pact/Schemathesis) and observability baselines (OTel) are required preconditions to merge/deploy, with PR ↔ build ↔ trace correlation recorded.

## Documentation: `docs/`

Keep architecture docs, ADRs, and handbooks alongside the code. Use them to feed the Knowledge Plane and guide both developers and agents.

## Module Boundaries and Contracts

Strictly enforce boundaries to preserve encapsulation, maintainability, and future extractability.

- No direct cross-module access: A module must not reach into another module’s internals or data stores.
- Published interfaces only: Modules expose a small, stable API surface (service classes or functions) for others to call.
- Clear data ownership: Each module owns its data schema and is the sole writer. Reads go through the owner’s interface or sanctioned data products.
- Communication patterns:
  - Synchronous calls use published interfaces (in-process, via DI) or generated HTTP clients from `contracts/ts` and `contracts/py`.
  - Asynchronous events are emitted on an in-process event bus; schemas are documented (and, where appropriate, mirrored in `contracts/schemas`).
- Dependency injection: Resolve cross-module references via interfaces; avoid concrete type coupling.

Contracts include method signatures, DTOs, and event schemas. For external HTTP ports, specify OpenAPI/JSON Schema in `contracts/openapi` (and associated `contracts/schemas`) and validate via consumer-driven contract tests (e.g., Pact) and negative/fuzz testing (e.g., Schemathesis) in CI. Generated TS/Python clients live under `contracts/ts` and `contracts/py` and are consumed by apps, kits, and agents. Version and document all contracts. Store interface docs and event catalogs in the Knowledge Plane for discoverability and provenance.

## Contract Examples

Function call (Orders → Inventory):

```ts
interface InventoryService {
  ReserveStock(productId: string, qty: number): boolean;
}
```

- Behavior: Return `true` if stock reserved; `false` if unavailable.
- Consumer responsibility: Abort order creation when `false`.
- Knowledge Plane: Link interface, invariants, and tests validating expected behavior.

Event (Billing → Subscribers):

```json
{
  "event": "PaymentCompleted",
  "userId": "<uuid>",
  "orderId": "<uuid>",
  "amount": 123.45
}
```

- Semantics: Fire-and-forget; idempotent handlers recommended.
- Subscribers: Orders (mark paid), Analytics (revenue).
- Versioning: Additive changes preferred; use versioned names if breaking.

Data product via Knowledge Plane (Analytics):

- Example: `analytics_summary` dataset published daily for reporting.
- Purpose: Decouple analytical queries from feature database schemas.

## Safeguards and Enforcement

Use multiple levels of enforcement to sustain architectural integrity:

- Static analysis and architecture tests (e.g., ArchUnit-like rules) to forbid disallowed imports or references.
- Example tooling: in JS/TS monorepos with Turborepo, enforce slice/boundary rules using ESLint (`eslint-plugin-boundaries`, `no-restricted-imports`) and `dependency-cruiser` (CI task in the Turbo pipeline). In JVM stacks, Spring Modulith provides similar checks. Choice of tool is an implementation detail; the architectural rule is invariant.
- Next.js runtime guardrails (Edge vs Node): codify a CI lint/check to prevent accidental heavy/AI/IO work in Edge runtimes. Enforce that Edge routes/actions only perform read‑mostly, low‑latency work and forbid usage of flagged modules/patterns (e.g., long CPU tasks, large model calls, filesystem/network patterns that exceed Edge constraints). Implement via ESLint custom rule(s) plus static detectors in CI.
- Code review standards: Require cross-module calls to use published interfaces or events.
- Contracts as code: Interface docs, consumer-driven contract tests, and invariants validated in CI.

## Observability and Determinism

- Propagate trace context across module calls and events for diagnosability (OpenTelemetry). Link trace IDs to PRs/builds for auditability.
- Design for deterministic behavior; tests should be reliable and fast.
- Capture module dependencies and event flows in the Knowledge Plane to aid humans and agents.

## Control Plane Responsibilities (Thin)

- Feature flags and progressive rollout defaults; manual promote/rollback.
- Policy/evaluation gates in CI that enforce architectural rules and risk thresholds (align with ASVS/SSDF where applicable).
- Contract-first validation (OpenAPI/JSON Schema) with Pact/Schemathesis checks.
- Observability baselines and trace linking to PRs/releases.

For guidance on how selected modules can evolve into self-contained, forkable repos (for example, feature slices in `packages/<feature>`, selected kits in `packages/kits/*`, and platform runtimes under `platform/runtimes/*-runtime/**`), see:

- `self-contained-repos.md` — Practical candidates and high-level extraction playbook.

These controls live as repo-local libraries, workflows, and checks to keep the monolith simple while enabling guided autonomy and safety.

## Kaizen/Autopilot Layer: `kaizen/`

Kaizen is the cross-cutting Autopilot layer that continuously proposes small, reversible improvements to docs, tests, observability, flags, and guardrails across all slices, aligning with the `Kaizen/Autopilot Layer` described in `monorepo-layout.md`:

- **Layout:** Root-level `kaizen/` directory with:
  - `kaizen/policies/`: Risk rubric and gate definitions (for example, `risk.yml`, `gates.yml`) consumed by CI and bots.
  - `kaizen/evaluators/`: Evaluators that read CI output, coverage, OpenTelemetry traces/logs/metrics, and repository state to score risk and surface candidates for improvement.
  - `kaizen/codemods/`: Idempotent, reversible codemods and refactor scripts the Kaizen agents can apply to propose changes.
  - `kaizen/agents/`: Kaizen-specific agents and flows that orchestrate evaluators and codemods (they may call `packages/*`, the shared **platform flow runtime service** under `platform/runtimes/flow-runtime/**`, and the `agents/orchestrator` HTTP agent via contract-first APIs and generated clients).
  - `kaizen/reports/`: Generated reports, scorecards, and evidence artifacts referenced from docs and CI.
- **Scope:** Autopilot for trivial/low-risk changes (for example, docs hygiene, stale-flag cleanup, span/log scaffolding); Copilot-style PRs for anything touching runtime behavior or contracts.
- **Workflows:** `.github/workflows/kaizen.yaml` schedules and runs Kaizen jobs under normal branch protections and human-in-the-loop review; outputs land under `kaizen/reports/**` and are referenced from `docs/`.
- **Ownership:** Use CODEOWNERS to route `/kaizen/**` to platform/quality. Allow Kaizen PRs to touch `docs/**`, `.github/**`, `infra/**`, and per-slice scaffolds as read-only suggest/PR changes; owners review and merge.

## Blueprint Visualization (Textual)

- Feature A (e.g., Billing)
  - Domain, API, Infra, Tests
  - Exports: `BillingService`, event `InvoiceGenerated`
- Feature B (e.g., Inventory)
  - Domain, API, Infra, Tests
  - Exports: `InventoryService`, event `StockLow`
- Feature C (e.g., Orders)
  - Depends on `InventoryService` via DI; emits `OrderPlaced`; handles `PaymentCompleted`
- common/: Shared primitives and utilities
- platform/: Knowledge Plane, Observability, Platform Runtimes (for example, `platform/runtimes/flow-runtime/**`)
- agents/: Planner, Builder, Verifier, Orchestrator (control-plane runtimes that call the platform runtime service)
- ci-pipeline/: Workflows, Gates (including architecture checks)

## Failure Modes and Mitigations

- Boundary violations: Detect via architecture tests and enforce in review.
- Contract mismatch: Document interfaces; validate with consumer-driven tests and runtime assertions.
- Integration failures: Handle exceptions at boundaries; use global error handling and observability.
- Monolith scaling: Prefer async processing and simple vertical scaling; extract services selectively only when warranted by scale or isolation needs.

## Evolution Path

The modular monolith design intentionally preserves an option to extract services later. Because modules interact only via interfaces or events and own their data, extraction is feasible without large refactors. Do not prematurely distribute; evolve when justified by operational or organizational needs.

- For tenancy/scale isolation, consider cell‑style boundaries (per tenant/region deployments) that replicate the same slice layout behind stable contracts while preserving repo cohesion and shared policy/observability.

## Agent Enablement

The consistent structure makes it easy for agents to:

- Locate relevant features and cross‑cutting layers for changes.
- Map specifications in the Knowledge Plane to code and tests.
- Diagnose failures by correlating test paths (e.g., `services/<Feature>/tests/...`) with feature ownership.

## Summary

This blueprint defines a vertically sliced, hexagonal-structured monolith with explicit module contracts and strong enforcement. It optimizes for clarity, determinism, and safe evolution, supporting both developer productivity and agent autonomy.
