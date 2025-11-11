# Harmony Monorepo Architecture

This document translates the original JSON visualization into developer-facing documentation that describes the Harmony Monorepo structure and the responsibilities of each major component.

## Directory Topology

```text
HarmonyMonorepo
├─ services
│  ├─ FeatureA
│  │  ├─ api
│  │  ├─ domain
│  │  ├─ infra
│  │  └─ tests
│  └─ FeatureB
│     ├─ api
│     ├─ domain
│     ├─ infra
│     └─ tests
├─ common
│  ├─ util
│  └─ models
├─ platform
│  ├─ knowledge-plane
│  │  ├─ specs
│  │  ├─ policies
│  │  ├─ sbom
│  │  └─ traces
│  ├─ observability
│  └─ runtime
├─ agents
│  ├─ planner
│  ├─ builder
│  └─ verifier
├─ ci-pipeline
│  ├─ workflows
│  └─ gates
└─ docs
```

## Services

- **Purpose:** Encapsulates product-facing capabilities. Each feature (e.g., `FeatureA`, `FeatureB`) adopts the same sub-structure for parity and isolation.
- **api:** Public-facing service or handler layer. Define controllers, routes, and transport adapters here.
- **domain:** Core business logic, aggregates, and domain services. Interact with infrastructure via ports/adapters.
- **infra:** Integrations such as databases, queues, and external APIs. Follow the hexagonal adapter conventions to keep the domain pure.
- **tests:** Feature-specific testing assets, including unit, contract, and integration suites that depend on the `api`, `domain`, and `infra` modules.

## Common

- **util:** Cross-cutting helpers (e.g., string utilities, date helpers, resilience operators) shared across services. Keep these stateless and dependency-light.
- **models:** Canonical data contracts and DTOs consumed by multiple services. Any change should be reviewed for downstream impact.

## Platform

- **knowledge-plane:** Governs system intelligence assets.
  - **specs:** Formal specifications that capture decision logic and interface contracts.
  - **policies:** Constraint definitions and enforcement logic used by agents and pipelines.
  - **sbom:** Software Bill of Materials snapshots for provenance tracking.
  - **traces:** Observability artifacts feeding the knowledge plane.
- **observability:** Telemetry collectors, alerting rules, and dashboards.
- **runtime:** Execution scaffolding, runtime policies, and deployment descriptors that unify service execution environments.

## Agents

- **planner:** Strategic reasoning and backlog refinement logic.
- **builder:** Code-generation or automation tasks responsible for implementing planned work.
- **verifier:** Validation logic, QA harnesses, or autonomous reviewers that guard merge criteria.

## CI Pipeline

- **workflows:** Pipeline definitions (e.g., GitHub Actions, Turborepo tasks) that orchestrate builds, tests, and deployments.
- **gates:** Policy-as-code checks applied to the workflows, such as coverage thresholds, static analysis requirements, or manual approvals.

## Documentation

- **docs:** Source-of-truth documentation, including ADRs, runbooks, and user-facing guides. Mirror structural changes from the monorepo here to keep architectural knowledge discoverable.
