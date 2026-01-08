---
title: Comparative Landscape: Architectural Paradigms and Scoring Rubric
description: Technical comparison of paradigms with HSP-aligned rubric; recommends a modular monolith with vertical slices and hexagonal boundaries.
---

# Comparative Landscape: Architectural Paradigms and Scoring Rubric

Related docs: [monorepo polyglot (normative)](./monorepo-polyglot.md), [overview](./overview.md), [repository blueprint](./repository-blueprint.md), [monorepo layout](./monorepo-layout.md), [slices vs layers](./slices-vs-layers.md)

This document presents a technical comparison of software architecture paradigms to select the structure for the Harmony Structural Paradigm (HSP). It evaluates monolithic and modular designs, vertical slicing, ports-and-adapters, service-oriented patterns, and event-based approaches. Each paradigm is assessed against criteria aligned to HSP goals: speed, safety, simplicity, determinism, scalability, and support for AI-driven autonomy.

The recommended outcome is a synthesis: a Modular Monolith organized as Vertical Feature Slices, with Hexagonal (Ports & Adapters) boundaries within each slice, guided by DDD-style bounded contexts, and governed by a thin control plane (flags, policy gates, contracts, and observability) to enable guided autonomy and deterministic safety.

## Purpose and Scope

- Provide a decision-grade, developer-focused evaluation of architectural paradigms for HSP.
- Define a rubric and apply consistent ratings with rationale.
- Recommend a target architecture and outline implementation guidance.

## Audience

- Engineers designing and evolving HSP.
- AI agents and tooling operating on HSP’s code and knowledge artifacts.

## Summary Recommendation

Adopt a Modular Monolith with Vertical Feature Slices and internal Hexagonal boundaries, guided by DDD bounded contexts. This combination maximizes development speed, safety, simplicity, and determinism for a small team while preserving an evolution path to services if and when they are justified by scale or boundaries.

```mermaid
graph LR
  subgraph Monolith [Modular Monolith]
    subgraph A [Feature A]
      A_P[Ports] <--> A_D[Domain Core]
      A_P <--> A_Ad[Adapters (UI/DB/Ext)]
    end
    subgraph B [Feature B]
      B_P[Ports] <--> B_D[Domain Core]
      B_P <--> B_Ad[Adapters (UI/DB/Ext)]
    end
    subgraph C [Feature C]
      C_P[Ports] <--> C_D[Domain Core]
      C_P <--> C_Ad[Adapters (UI/DB/Ext)]
    end
  end
```

## Comparative Landscape — Concise Scoring (Implementation Profile: Next.js/Astro/Vercel)

Rubric (1–5): Speed • Simplicity • Determinism • Autonomy • Future‑Resilience

| Paradigm                                 | Speed | Simplicity | Determinism | Autonomy | Future |
| ---------------------------------------- | ----: | ---------: | ----------: | -------: | -----: |
| Layered Monolith (N‑Tier)                |     3 |          3 |           3 |        3 |      3 |
| Modular Monolith + Vertical Slices (HSP) |     5 |          5 |           5 |        4 |      4 |
| Hexagonal (Ports & Adapters, per module) |     4 |          4 |           5 |        4 |      4 |
| Event‑Driven (Scoped, SCS/BFF)           |     4 |          4 |           4 |        4 |      4 |
| Microservices (broad adoption)           |     2 |          2 |           3 |        3 |      5 |

Notes:

- HSP recommendation: Modular Monolith organized by Vertical Feature Slices with Hexagonal boundaries inside each slice; governed by a thin control plane.
- Event‑driven is valuable as a supporting technique (SCS/BFF) where needed; avoid overusing for core synchronous flows to preserve determinism.
- Microservices offer future resilience at the cost of speed/simplicity for small teams; defer until boundaries harden and scale justifies.

## Evaluation Criteria

- Development Speed: Delivery velocity, build/deploy simplicity, developer friction.
- Safety/Reliability: Fault isolation, testability, rollout control, failure modes.
- Simplicity: Conceptual clarity and maintainability by a small team.
- Determinism/Testability: Predictable behavior and ease of writing reliable tests.
- Scalability/Flexibility: Headroom to scale usage and team; ease of adaptation.
- Autonomy Support: How well AI agents can understand, modify, and verify the system.
- Control Plane Fit: Ability to govern via flags, policy gates, contract checks, and observability without increasing runtime complexity.

## Paradigm Evaluations

### Layered Monolith (N-Tier)

- Overview: Single deploy with horizontal layers (presentation, business, data).
- Strengths: Low initial complexity; simple cross-layer calls.
- Trade-offs: Tends to tight coupling; hard to maintain modularity at scale; “big ball of mud” risk. Weak feature boundaries.
- Applicability to HSP: Acceptable for very small systems; insufficient modularity and autonomy support at HSP scale.

### Modular Monolith

- Overview: One deploy with strong module/bounded-context boundaries and interfaces.
- Strengths: Single deploy simplicity; clear separation of concerns; easier debugging and testing; good stepping-stone to services.
- Trade-offs: Requires governance to prevent cross-module leakage; all-or-nothing deploy remains.
- Applicability to HSP: Excellent baseline. High speed, safety, simplicity, determinism. Medium scalability; good autonomy support.

### Hexagonal Architecture (Ports & Adapters)

- Overview: Domain core isolated behind ports; adapters implement infrastructure (UI/DB/external).
- Strengths: Technology-agnostic core; highly testable and deterministic; clear separation of concerns.
- Trade-offs: Adds indirection and initial setup overhead.
- Applicability to HSP: Use within each feature module to enforce determinism and testability.

### Domain-Driven Design (DDD) — Bounded Contexts

- Overview: Align code boundaries to domain subdomains and ubiquitous language.
- Strengths: High cohesion and clarity per context; avoids model conflicts.
- Trade-offs: Requires discipline and translation between contexts.
- Applicability to HSP: Use to define feature-module boundaries and ubiquitous language.

### Vertical Slice Architecture

- Overview: Organize by end-to-end feature slices (UI → domain → data) instead of by horizontal layers.
- Strengths: Enables end-to-end development per feature; improved agility and onboarding; localized change sets.
- Trade-offs: Potential code duplication without a small shared library; requires discipline to share cross-cutting concerns.
- Applicability to HSP: Primary organizational pattern for modules.

### Microservices

- Overview: Many small, independently deployable services communicating over the network.
- Strengths: Independent scaling and deployment; strong isolation when mature.
- Trade-offs: Significant operational and integration complexity; non-determinism and flakiness risks; requires robust DevOps and observability.
- Applicability to HSP: Not appropriate initially; consider later extraction from the monolith as boundaries stabilize and scale justifies added complexity.

### Event-Driven (Message-Oriented)

- Overview: Components communicate via asynchronous events, in-process or via brokers.
- Strengths: Loose coupling; scalable asynchronous workflows; extensibility via subscriptions.
- Trade-offs: Harder reasoning and testing due to asynchrony; determinism and debugging challenges.
- Applicability to HSP: Use selectively (e.g., notifications to Knowledge Plane), not as primary structuring mechanism for core flows.

### Microkernel / Plugin

- Overview: Small core extended via plugins over formal contracts.
- Strengths: Extensibility and isolation of optional features.
- Trade-offs: Lifecycle and isolation management complexity; less typical for web SaaS backends.
- Applicability to HSP: Concepts inform optional/flagged modules; not a primary paradigm.

## Scoring Rubric

Legend: 🟢 High, 🟡 Medium, 🔴 Low

| Paradigm                         | Dev Speed | Safety/Reliability | Simplicity | Determinism/Testability | Scalability/Flexibility | Autonomy Support |
|----------------------------------|-----------|--------------------|------------|-------------------------|-------------------------|------------------|
| Modular Monolith                 | 🟢        | 🟢                 | 🟢         | 🟢                      | 🟡                      | 🟢               |
| Vertical Slice (within Monolith) | 🟢        | 🟡                 | 🟢         | 🟡                      | 🟡                      | 🟢               |
| Layered Monolith                 | 🟡        | 🔴                 | 🟡         | 🟡                      | 🟡                      | 🔴               |
| Microservices                    | 🔴        | 🟡                 | 🔴         | 🔴                      | 🟢                      | 🔴               |
| Hexagonal (Ports & Adapters)     | 🟡        | 🟢                 | 🟡         | 🟢                      | 🟢                      | 🟢               |
| Event-Driven                     | 🟡        | 🟡                 | 🔴         | 🔴                      | 🟢                      | 🟡               |
| Microkernel/Plugin               | 🟡        | 🟢                 | 🟡         | 🟡                      | 🟡                      | 🟡               |

Notes and justifications (selected):

- Modular Monolith: Single-process determinism; low DevOps overhead; strong module boundaries are key to maintainability.
- Vertical Slice: End-to-end feature agility; mitigate duplication via a minimal common library.
- Microservices: Integration and operational complexity outweigh benefits for a small team; consider only after the monolith matures.
- Hexagonal: High testability and change isolation; apply within modules to keep core deterministic.
- Event-Driven: Excellent for extensibility and throughput; adopt narrowly to avoid loss of determinism in core flows.

## Key Observations

- A Modular Monolith with feature slices aligns best with HSP pillars: speed, safety, simplicity, and determinism.
- Hexagonal boundaries complement the monolith by isolating domain logic from infrastructure, enhancing testability and evolvability.
- Event-driven and plugin patterns are valuable as supporting techniques, not primary structuring paradigms for core logic.
- Starting with a well-structured monolith preserves an evolution path to services when scale and stability of boundaries justify the complexity.

## Decision

Adopt a Modular Monolith organized as Vertical Feature Slices, each implementing Hexagonal (Ports & Adapters) boundaries and guided by DDD bounded contexts.

### Reference Implementation: Polyglot Monorepo

Harmony’s canonical implementation of this decision is the **polyglot monorepo** described in `monorepo-polyglot.md`:

- TypeScript control plane and feature slices:
  - Vertical slices under `packages/<feature>` with `domain/ → adapters/ → api/ → tests/`.
  - Control-plane kits under `packages/kits/*` (FlowKit, AgentKit, PlanKit, EvalKit, PolicyKit, TestKit, etc.).
- Python control-plane runtimes and platform runtime services:
  - Control-plane agents under `agents/*` host Planner/Builder/Verifier/Orchestrator loops and other orchestration processes.
  - The shared, LangGraph-based **platform flow runtime service** lives under `platform/runtimes/flow-runtime/**` and is called by apps, agents, and Kaizen via contract-first APIs (for example, `/flows/run`, `/flows/start`) defined in the root `contracts/` registry, rather than being embedded under `agents/*`.
- Contracts-first integration:
  - Root `contracts/` registry (`openapi/`, `schemas/`, `ts/`, `py/`) as the cross-language boundary.
- Unified task graph:
  - Turborepo + pnpm + uv pipeline coordinating `gen:contracts`, `ts:*`, and `py:*` tasks.

This structure realizes the scoring and trade-offs described above for a TS + Python stack while remaining compatible with HSP’s monolith-first, vertical-slice architecture and the platform-centric runtime model described in `runtime-architecture.md`.

## Implementation Guidance (Initial)

- Repository: Single monorepo with a module per feature (bounded context).
- Structure per feature: `domain/` (pure core), `ports/` (interfaces), `adapters/` (UI/DB/integration), `tests/`.
- Cross-cutting: Minimal `common/` utilities only when duplication is material and stable.
- Testing: Emphasize deterministic, in-memory tests at the domain layer; adapters tested with integration tests as needed.
- Observability: Standardized logging/tracing at adapter boundaries; avoid implicit cross-module coupling.
- Autonomy: Keep specs/tests next to features; maintain Knowledge Plane links to modules, ports, and contracts to aid agents.

## Evolution Path

- When boundaries are stable and scale demands it, peel a feature slice into a service by moving its adapters out-of-process while preserving its domain and ports unchanged.
- Use internal contracts and tests as the migration safety net to maintain behavior.
- Consider Self-Contained Systems (SCS) or a dedicated BFF as an intermediate extraction target to keep ownership and coupling clear without premature service sprawl.
- Introduce microkernel/plugin seams for optional capabilities; keep the domain core pure and technology-agnostic.
- For scale/tenancy isolation, adopt cell-style boundaries (per-tenant/region deployments) while preserving monorepo cohesion and contracts.

## References

- Modular monolith and “monolith first”: [martinfowler.com](https://martinfowler.com/)
- Bounded contexts and DDD: [vladikk.com](https://vladikk.com/)
- Hexagonal architecture: [docs.aws.amazon.com](https://docs.aws.amazon.com/whitepapers/latest/monolith-to-microservices/hexagonal-architecture.html)
- Vertical slices: [mehmetozkaya.medium.com](https://mehmetozkaya.medium.com/), [michaeluloth.com](https://michaeluloth.com/)
- Simplicity vs complexity: [danluu.com](https://danluu.com/)
- Microservice complexity: [martinfowler.com](https://martinfowler.com/); distributed issues: [arxiv.org](https://arxiv.org/)


