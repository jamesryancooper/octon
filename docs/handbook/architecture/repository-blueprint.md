
# Structural Repository Blueprint and Module Boundaries

This document specifies the repository layout, module boundaries, and inter-component contracts for a vertically sliced, modular monolith. It aims to maximize clarity for a small team while preserving encapsulation and determinism, enabling safe evolution toward more distributed architectures if warranted.

## Objectives

- Provide a clear, navigable repository structure.
- Enforce strict module boundaries with published interfaces and events.
- Maintain determinism and testability within a single deployable unit.
- Enable straightforward scaling and a future path to service extraction.

## High-Level Structure

Organize by feature (vertical slice) at the top level; organize by clean architecture layers within each feature. Keep shared code minimal and establish explicit platform, agents, CI, and documentation areas.

```plaintext
.
├── services/                  # Feature modules (bounded contexts)
│   └── <FeatureName>/
│       ├── api/              # Inbound adapters (HTTP controllers, GraphQL, etc.)
│       ├── domain/           # Core business logic (use cases, entities)
│       ├── infra/            # Outbound adapters (DB, external services)
│       └── tests/            # Unit & integration tests for this feature
│
├── common/                   # Shared kernel (minimal, truly cross-cutting)
│
├── platform/                 # Cross-cutting platform services
│   ├── knowledge-plane/      # Specs, traces, SBOM, policies, data catalog
│   ├── observability/        # Logging, metrics, tracing, instrumentation
│   └── runtime/              # Feature flags, global policies, rollout rules
│
├── agents/                   # Agent system: planner, builder, verifier
│   ├── planner/
│   ├── builder/
│   └── verifier/
│
├── ci-pipeline/              # CI/CD workflows and policy gates
│   ├── workflows/
│   └── gates/
│
└── docs/                     # Architecture docs, ADRs, handbooks
```

Supporting artifact:

- `repo_structure.json`: machine-readable structure for tools and agents.

## Feature Modules

Each feature in `services/` is a bounded context that encapsulates its domain, interface, infrastructure, and tests. Within a feature:

- `domain/` is the inner hexagon; it never depends on `api/` or `infra/`.
- `api/` and `infra/` act as adapters. They depend inward on `domain/`.
- `tests/` co-locate unit and integration tests with the feature code.

Hexagonal Architecture and dependency direction ensure deterministic, testable modules. The domain layer is technology-agnostic and stable; adapters can change with minimal ripple.

Example flow (InventoryManagement):

- `api/UpdateStockController` receives a REST call.
- Calls `domain/InventoryService` which executes business rules.
- Persists via `infra/SqlInventoryRepository`.
- `tests/` contain both unit tests for rules and integration tests for the slice.

## Shared Code: `common/`

Use `common/` only for genuinely cross-cutting utilities or shared primitives (e.g., value objects like `Money`, date helpers). Keep it small to avoid accidental coupling. Treat it like any other module with explicit APIs.

## Platform Services: `platform/`

- `knowledge-plane/`: Manages specifications, traces, SBOM, policies, and data catalogs. Serves as a knowledge hub for humans and agents.
- `observability/`: Centralizes logging, metrics, tracing, and instrumentation standards. Ensures consistent trace context propagation.
- `runtime/`: Hosts feature flag definitions and rollout policies. Can include global middleware and rate limiting.

## Agent System: `agents/`

Houses Planner, Builder, and Verifier agents. Keep agent logic and resources (prompts, rules) separate from product features to simplify governance and auditing. Shared agent utilities can live under `agents/common/` if needed.

## CI/CD and Policy: `ci-pipeline/`

- `workflows/`: Build, test, and deploy pipelines (e.g., GitHub Actions).
- `gates/`: Quality gates and policy enforcement (linting, coverage, security scans, architecture checks).

Version all CI configuration in-repo to enable reviewability and repeatability.

## Documentation: `docs/`

Keep architecture docs, ADRs, and handbooks alongside the code. Use them to feed the Knowledge Plane and guide both developers and agents.

## Module Boundaries and Contracts

Strictly enforce boundaries to preserve encapsulation, maintainability, and future extractability.

- No direct cross-module access: A module must not reach into another module’s internals or data stores.
- Published interfaces only: Modules expose a small, stable API surface (service classes or functions) for others to call.
- Clear data ownership: Each module owns its data schema and is the sole writer. Reads go through the owner’s interface or sanctioned data products.
- Communication patterns:
  - Synchronous calls use published interfaces (in-process, via DI).
  - Asynchronous events are emitted on an in-process event bus; schemas are documented.
- Dependency injection: Resolve cross-module references via interfaces; avoid concrete type coupling.

Contracts include method signatures, DTOs, and event schemas. Version and document them. Store interface docs and event catalogs in the Knowledge Plane for discoverability.

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

Use multiple layers of enforcement to sustain architectural integrity:

- Static analysis and architecture tests (e.g., ArchUnit-like rules) to forbid disallowed imports or references.
- Code review standards: Require cross-module calls to use published interfaces or events.
- Contracts as code: Interface docs, consumer-driven contract tests, and invariants validated in CI.

## Observability and Determinism

- Propagate trace context across module calls and events for diagnosability.
- Design for deterministic behavior; tests should be reliable and fast.
- Capture module dependencies and event flows in the Knowledge Plane to aid humans and agents.

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
- platform/: Knowledge Plane, Observability, Runtime
- agents/: Planner, Builder, Verifier
- ci-pipeline/: Workflows, Gates (including architecture checks)

## Failure Modes and Mitigations

- Boundary violations: Detect via architecture tests and enforce in review.
- Contract mismatch: Document interfaces; validate with consumer-driven tests and runtime assertions.
- Integration failures: Handle exceptions at boundaries; use global error handling and observability.
- Monolith scaling: Prefer async processing and simple vertical scaling; extract services selectively only when warranted by scale or isolation needs.

## Evolution Path

The modular monolith design intentionally preserves an option to extract services later. Because modules interact only via interfaces or events and own their data, extraction is feasible without large refactors. Do not prematurely distribute; evolve when justified by operational or organizational needs.

## Agent Enablement

The consistent structure makes it easy for agents to:

- Locate relevant features and layers for changes.
- Map specifications in the Knowledge Plane to code and tests.
- Diagnose failures by correlating test paths (e.g., `services/<Feature>/tests/...`) with feature ownership.

## Summary

This blueprint defines a vertically sliced, hexagonal-structured monolith with explicit module contracts and strong enforcement. It optimizes for clarity, determinism, and safe evolution, supporting both developer productivity and agent autonomy.
