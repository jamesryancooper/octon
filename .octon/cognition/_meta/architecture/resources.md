---
title: Architecture Suggested Resources
description: Curated external references that complement `.octon/cognition/architecture`, with brief annotations and cross-references.
---

# Architecture Suggested Resources

Use this page to curate external references that deepen or complement topics covered in `.octon/cognition/architecture`. Keep entries short, annotated, and directly actionable.

## Octon Polyglot Monorepo (Internal Canonical Blueprint)

**Octon Polyglot Monorepo Blueprint** (Internal Doc) — Octon, 2025

- Link: `./monorepo-polyglot.md`
- Why it matters: Canonical reference for the TS + Python polyglot monorepo: `apps/*`, `packages/*`, `packages/kits/*`, `agents/*`, `contracts/`, `platform/*`, `ci-pipeline/`, plus Turborepo + pnpm + uv wiring.
- Key takeaways:
  - Control plane in TypeScript kits (`packages/kits/*`); Python agents under `agents/*` act as control-plane runtimes, and a shared **platform flow runtime service** lives under `platform/runtimes/flow-runtime/**` as the LangGraph-based implementation of the platform runtime (see `runtime-architecture.md`).
  - Contracts-first integration via the root `contracts/` registry (`openapi/`, `schemas/`, `ts/`, `py/`).
  - Unified task graph across TS/Python via `gen:contracts`, `ts:*`, and `py:*` tasks.
- Tags: monorepo-polyglot, contracts-registry, ts-python, turbo, pnpm, uv
- Level: Intermediate
- Last reviewed: 2025-11-18
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md), [monorepo layout](./monorepo-layout.md), [contracts registry](./contracts-registry.md), [python runtime workspace example](/.octon/scaffolding/practices/examples/stack-profiles/python-runtime-workspace.md)

## How to Contribute

- Add new items under the most relevant category below.
- Prefer authoritative sources (standards, papers, primary blogs, high-signal talks).
- Include a one- to two-sentence note on why it matters and how it applies here.

## Entry Format

```text
**Title** (Type) — Author/Source, Year
  - Link: <URL>
  - Why it matters: <short rationale>
  - Key takeaways: <1–3 bullets or a sentence>
  - Tags: <e.g., modular-monolith, hexagonal, governance>
  - Level: Intro | Intermediate | Advanced
  - Last reviewed: YYYY-MM-DD
  - Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)
```

---

## Foundational Architecture

**Clean Architecture** (Book) — Robert C. Martin, 2017

- Link: [https://www.pearson.com/en-us/subject-catalog/p/Clean-Architecture-A-Craftsmans-Guide-to-Software-Structure-and-Design/P200000002821/9780134494166](https://www.pearson.com/en-us/subject-catalog/p/Clean-Architecture-A-Craftsmans-Guide-to-Software-Structure-and-Design/P200000002821/9780134494166)
- Why it matters: Practical guidance on boundaries, dependency direction, and policy vs. detail—core to resilient codebases.
- Key takeaways:
  - Invert dependencies to protect business rules.
  - Separate policies (domain) from mechanisms (frameworks, DBs).
- Tags: layering, boundaries, dependency-rule
- Level: Intermediate
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md), [agent roles](./agent-roles.md)

**Patterns of Enterprise Application Architecture** (Book) — Martin Fowler, 2002

- Link: [https://martinfowler.com/books/eaa.html](https://martinfowler.com/books/eaa.html)
- Why it matters: Canonical pattern catalog for enterprise systems that pairs well with DDD/hexagonal styles.
- Key takeaways:
  - Explains patterns like Repository, Unit of Work, and Gateway.
  - Emphasizes trade-offs behind each pattern.
- Tags: enterprise-patterns, catalogs, architecture
- Level: Intermediate
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Software Architecture: The Hard Parts** (Book) — Neal Ford, Mark Richards, Pramod Sadalage, Zhamak Dehghani/Parsons, 2021

- Link: [https://www.oreilly.com/library/view/software-architecture-the/9781492086895/](https://www.oreilly.com/library/view/software-architecture-the/9781492086895/)
- Why it matters: A vocabulary and set of decision techniques for coupling, data ownership, and organizational alignment.
- Key takeaways:
  - Use fitness functions to make trade-offs explicit.
  - Design data/teams together to avoid accidental complexity.
- Tags: trade-offs, coupling, data-ownership, org-design
- Level: Intermediate
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

## Modular Monolith and Vertical Slices

**Monolith First** (Article) — Martin Fowler, 2015

- Link: [https://martinfowler.com/bliki/MonolithFirst.html](https://martinfowler.com/bliki/MonolithFirst.html)
- Why it matters: Argues learning domain boundaries before splitting into services; reduces premature distributed complexity.
- Key takeaways:
  - Start in-process; extract services when evidence emerges.
  - Optimize for developer flow early.
- Tags: monolith-first, microservices, risk-management
- Level: Intro
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Modular Monoliths** (Slides/Essay) — Simon Brown, 2018

- Link: [https://static.simonbrown.je/modular-monoliths.pdf](https://static.simonbrown.je/modular-monoliths.pdf)
- Why it matters: Shows how to enforce module boundaries inside a single deployable to enable future service extraction.
- Key takeaways:
  - Package by feature, not by layer.
  - Treat modules as independently testable units with explicit interfaces.
- Tags: modular-monolith, boundaries, package-by-feature
- Level: Intermediate
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Modular Monolith: A Primer** (Article Series) — Kamil Grzybek, 2019

- Link: [https://www.kamilgrzybek.com/blog/posts/modular-monolith-primer](https://www.kamilgrzybek.com/blog/posts/modular-monolith-primer)
- Why it matters: Tactically explains module encapsulation, contracts, and enforcement strategies for small teams.
- Key takeaways:
  - Keep module APIs explicit; prevent leaking internals.
  - Align code structure with domain slices.
- Tags: modular-monolith, contracts, encapsulation
- Level: Intermediate
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Vertical Slice Architecture** (Article) — Jimmy Bogard, 2013+

- Link: <https://jimmybogard.com/vertical-slice-architecture/>
- Why it matters: Organizing by feature aligns code along the axis of change; improves locality and onboarding.
- Key takeaways:
  - Build end-to-end per feature (UI → domain → data) instead of by layer.
- Tags: vertical-slice, package-by-feature
- Level: Intro
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [monorepo layout](./monorepo-layout.md)

**Spring Modulith** (Project/Guide) — Oliver Drotbohm, 2023+

- Link: <https://spring.io/projects/spring-modulith>
- Why it matters: Enforces modular boundaries and architecture rules in-process; illustrates modulith practice and evolution paths.
- Key takeaways:
  - Validate module boundaries and dependencies as code.
  - Preserve extraction paths while remaining monolithic.
- Tags: modular-monolith, enforcement, modulith
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [repository blueprint](./repository-blueprint.md)

**Nx: Enforce Module Boundaries** (Docs) — Nx, 2020+

- Link: <https://nx.dev/docs/features/enforce-module-boundaries>
- Why it matters: Practical, configurable guardrails for JS/TS monorepos to keep vertical slices isolated.
- Key takeaways:
  - Enforce dependency graphs and tagged constraints.
  - Prevent cross-slice leakage.
- Tags: monorepo, boundaries, enforcement
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [repository blueprint](./repository-blueprint.md), [monorepo layout](./monorepo-layout.md)
- Note: Octon uses Turborepo; this entry is provided for teams using Nx.

**dependency-cruiser** (Tool) — 2017+

- Link: <https://github.com/sverweij/dependency-cruiser>
- Why it matters: Define and enforce architectural dependency rules across TS/JS codebases; ideal for Turborepo pipelines.
- Key takeaways:
  - Forbid imports between features or from adapters→domain.
  - Generate dependency graphs for reviews.
- Tags: boundaries, architecture-tests, monorepo
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [repository blueprint](./repository-blueprint.md), [monorepo layout](./monorepo-layout.md)

**eslint-plugin-boundaries** (Tool) — 2018+

- Link: <https://github.com/javierbrea/eslint-plugin-boundaries>
- Why it matters: Enforce import boundaries by folder tags/boundaries (e.g., domain cannot import adapters) during development and CI.
- Key takeaways:
  - Encode boundary rules in ESLint; fast local feedback.
- Tags: eslint, boundaries, layering
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [repository blueprint](./repository-blueprint.md), [monorepo layout](./monorepo-layout.md)

**Why Google Stores Billions of Lines of Code in a Single Repository** (Article) — Potvin & Levenberg, Communications of the ACM, 2016

- Link: [https://cacm.acm.org/research/why-google-stores-billions-of-lines-of-code-in-a-single-repository/](https://cacm.acm.org/research/why-google-stores-billions-of-lines-of-code-in-a-single-repository/)
- Why it matters: Evidence-backed rationale for monorepos (atomic changes, broad reuse) and the tooling required.
- Key takeaways:
  - Monorepos scale with strict conventions and tooling.
  - Enables sweeping refactors and consistent dependency management.
- Tags: monorepo, tooling, codebase-health
- Level: Intermediate
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

## Hexagonal Architecture (Ports & Adapters)

**Hexagonal Architecture** (Essay) — Alistair Cockburn, 2005

- Link: <https://alistair.cockburn.us/hexagonal-architecture/>
- Why it matters: Origin of ports/adapters; codifies isolating domain from infrastructure to maximize testability and determinism.
- Key takeaways:
  - Domain depends on abstractions (ports), not frameworks.
  - Adapters implement ports for UI/DB/external systems.
- Tags: hexagonal, ports-adapters, testing
- Level: Intermediate
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Onion Architecture** (Blog) — Jeffrey Palermo, 2008

- Link: <https://jeffreypalermo.com/2008/07/the-onion-architecture-part-1/>
- Why it matters: A variant reinforcing dependency rule and domain-centric design; complements hexagonal practices.
- Key takeaways:
  - Keep business rules at the core; dependencies point inward.
- Tags: layering, dependency-rule, domain-first
- Level: Intermediate
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md)

## Contracts and Testing

**Pact** (Docs) — Pact Foundation

- Link: <https://docs.pact.io/>
- Why it matters: Consumer-driven contract testing aligns providers and consumers; prevents breaking changes at module/API boundaries.
- Key takeaways:
  - Treat contracts as code; validate in CI.
- Tags: contracts, testing, ci
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [tooling integration](./tooling-integration.md)

**Schemathesis** (Docs)

- Link: <https://schemathesis.readthedocs.io/>
- Why it matters: Fuzz/negative testing against OpenAPI/JSON Schema to catch edge cases deterministically.
- Key takeaways:
  - Augment happy-path tests with automated negative cases.
- Tags: contracts, fuzzing, testing
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [tooling integration](./tooling-integration.md)

## Domain-Driven Design (DDD)

**Domain-Driven Design** (Book) — Eric Evans, 2003

- Link: [https://www.informit.com/store/domain-driven-design-tackling-complexity-in-the-heart-9780321125217](https://www.informit.com/store/domain-driven-design-tackling-complexity-in-the-heart-9780321125217)
- Why it matters: Establishes ubiquitous language, bounded contexts, and strategic design.
- Key takeaways:
  - Model the domain explicitly; use context maps.
  - Isolate core domain and protect it from infrastructure details.
- Tags: ddd, bounded-contexts, strategic-design
- Level: Advanced
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Implementing Domain-Driven Design** (Book) — Vaughn Vernon, 2013

- Link: [https://www.oreilly.com/library/view/implementing-domain-driven-design/9780133039906/](https://www.oreilly.com/library/view/implementing-domain-driven-design/9780133039906/)
- Why it matters: Opinionated patterns (aggregates, repositories, sagas) for building DDD systems.
- Key takeaways:
  - Define aggregate boundaries around invariants.
  - Use domain events to decouple and coordinate.
- Tags: ddd, aggregates, events
- Level: Advanced
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Sagas** (Paper) — SIGMOD, 1987

- Link: <https://www.cs.cornell.edu/andru/cs711/2002fa/reading/sagas.pdf>
- Why it matters: Models long-running transactions as ordered sub-transactions with compensations—foundation for safe multi-step workflows.
- Key takeaways:
  - Use compensating actions to maintain invariants across steps; prefer orchestration for clarity.
- Tags: sagas, long-running-transactions, compensations
- Level: Advanced
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

## Evolution Techniques

**Strangler Fig** (Article) — Martin Fowler

- Link: <https://martinfowler.com/bliki/StranglerFigApplication.html>
- Why it matters: Safely extract capabilities from a monolith behind stable interfaces.
- Key takeaways:
  - Gradual migration with anti-corruption layers.
- Tags: migration, strangler, evolution
- Level: Intro
- Last reviewed: 2025-11-12
- Related docs: [comparative landscape](./comparative-landscape.md)

## Frameworks & Runtime (Next.js/Vercel/Astro)

**Functions: Server Actions** (Docs) — Next.js, 2024+

- Link: <https://nextjs.org/docs/13/app/api-reference/functions/server-actions>
- Why it matters: Encourages thin, deterministic controllers at the framework edge; delegate business logic to feature modules.
- Key takeaways:
  - Keep mutations server‑side; validate at boundaries; return typed DTOs.
- Tags: nextjs, server-actions, controllers
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [implementation profile example](/.octon/scaffolding/practices/examples/stack-profiles/nextjs-astro-vercel.md)

**Partial Prerendering (PPR)** (Docs) — Next.js 15, 2024+

- Link: <https://nextjs.org/docs/15/app/getting-started/partial-prerendering>
- Why it matters: Opt‑in streaming of dynamic “holes” while keeping correctness paths deterministic. HSP’s stack profile targets Next.js 16+ with React 19, but this PPR documentation remains the authoritative description of the feature’s behavior.
- Key takeaways:
  - Use selectively; keep dynamic data `no-store` unless keys are stable.
- Tags: nextjs, ppr, streaming
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [implementation profile example](/.octon/scaffolding/practices/examples/stack-profiles/nextjs-astro-vercel.md)

**Next.js 15 Release Notes (Caching Changes)** (Post) — Next.js, 2024

- Link: <https://nextjs.org/blog/next-15>
- Why it matters: GET route handlers are uncached by default; caching must be explicit and justified. HSP adopts these semantics as the baseline for Next.js 16+; this post documents where the behavior was introduced.
- Key takeaways:
  - Default to uncached; opt‑in with explicit keys/TTL.
- Tags: nextjs, caching, runtime
- Level: Intro
- Last reviewed: 2025-11-12
- Related docs: [implementation profile example](/.octon/scaffolding/practices/examples/stack-profiles/nextjs-astro-vercel.md)

**Promoting Deployments** (Docs) — Vercel, 2024+

- Link: <https://vercel.com/docs/deployments/promoting-a-deployment>
- Why it matters: Manual promote and instant rollback enable safe previews → production flow.
- Key takeaways:
  - Rehearse promote/rollback; treat rollout as an operational runbook.
- Tags: vercel, delivery, rollback
- Level: Intro
- Last reviewed: 2025-11-12
- Related docs: [runtime policy](./runtime-policy.md)

**Edge Config & Feature Flags** (Docs) — Vercel, 2024+

- Link: <https://vercel.com/docs/edge-config>
- Why it matters: Lightweight, low‑latency flag evaluation at the edge; evaluate server‑side and propagate decisions inward.
- Key takeaways:
  - Default new flags OFF; fail‑closed on resolution errors.
- Tags: feature-flags, edge, vercel
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [runtime policy](./runtime-policy.md), [tooling integration](./tooling-integration.md)

**OpenTelemetry for Node.js** (Guide) — OpenTelemetry, 2024+

- Link: <https://opentelemetry.io/docs/languages/js/getting-started/nodejs/>
- Why it matters: Unified traces/logs/metrics and W3C context propagation; required for provenance and DORA correlation.
- Key takeaways:
  - Standardize span names, keep cardinality low, and link traces to PRs.
- Tags: observability, traces, nodejs
- Level: Intro
- Last reviewed: 2025-11-12
- Related docs: [observability requirements](./observability-requirements.md), [tooling integration](./tooling-integration.md)

**Self-Contained Systems (SCS)** (Site) — SCS Architecture

- Link: <https://scs-architecture.org/>
- Why it matters: Emphasizes clear ownership and decoupled deployment while avoiding microlith sprawl; a pragmatic intermediary between monolith and microservices.
- Key takeaways:
  - Prefer whole-slice extraction with clear ownership.
- Tags: scs, evolution, ownership
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [comparative landscape](./comparative-landscape.md)

## Flow, Delivery, and Team Design (Velocity through Agentic Automation and Trust through Governed Determinism)

**Accelerate** (Book) — Nicole Forsgren, Jez Humble, Gene Kim, 2018

- Link: [https://itrevolution.com/accelerate/](https://itrevolution.com/accelerate/)
- Why it matters: Empirical link between practices (small batches, CI/CD) and performance.
- Key takeaways:
  - Four key metrics predict outcomes.
  - Documentation quality amplifies delivery performance.
- Tags: dora, devops, metrics
- Level: Intro
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Continuous Delivery** (Book) — Jez Humble & David Farley, 2010

- Link: [https://martinfowler.com/books/continuousDelivery.html](https://martinfowler.com/books/continuousDelivery.html)
- Why it matters: The playbook for pipelines and release safety.
- Key takeaways:
  - Build deployment pipelines; automate everything.
  - Favour trunk-based development and small changes.
- Tags: cd, pipelines, releases
- Level: Intermediate
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Team Topologies** (Book) — Matthew Skelton & Manuel Pais, 2019

- Link: [https://teamtopologies.com/book](https://teamtopologies.com/book)
- Why it matters: Defines stream-aligned teams and interaction modes that speed flow.
- Key takeaways:
  - Four team types; three interaction modes.
  - Prioritize cognitive load limits.
- Tags: org-design, platform-team, interaction-modes
- Level: Intro
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Software Engineering at Google** (Book) — Winters, Manshreck, Wright, 2020

- Link: [https://www.oreilly.com/library/view/software-engineering-at/9781492082781/](https://www.oreilly.com/library/view/software-engineering-at/9781492082781/)
- Why it matters: Case study of monorepo, testing culture, and review practices at scale.
- Key takeaways:
  - Optimize codebase health for the long term.
  - Strong tooling + conventions > ad-hoc heroics.
- Tags: monorepo, engineering-practices, code-review
- Level: Intermediate
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**DORA Capability: Trunk-Based Development** (Guide) — DORA, n.d.

- Link: [https://dora.dev/devops-capabilities/technical/trunk-based-development/](https://dora.dev/devops-capabilities/technical/trunk-based-development/)
- Why it matters: Summarizes why small batches/frequent merges correlate with high performance.
- Key takeaways:
  - Keep branches short-lived; integrate continuously.
- Tags: trunk-based, branching, version-control
- Level: Intro
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**State of DevOps Report (2023)** (Report) — Google/DORA, 2023

- Link: [https://services.google.com/fh/files/misc/2023_final_report_sodr.pdf](https://services.google.com/fh/files/misc/2023_final_report_sodr.pdf)
- Why it matters: Latest evidence on practices and organizational factors that improve delivery.
- Key takeaways:
  - Documentation quality and continuous deployment magnify trunk-based benefits.
- Tags: dora, research, delivery
- Level: Intro
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Short-Lived Feature Branches** (Guide) — trunkbaseddevelopment.com, n.d.

- Link: [https://trunkbaseddevelopment.com/short-lived-feature-branches/](https://trunkbaseddevelopment.com/short-lived-feature-branches/)
- Why it matters: Practical branching guidance to keep feedback cycles tight.
- Key takeaways:
  - Prefer hours/days over weeks; avoid long-running divergence.
- Tags: branching, trunk-based, workflow
- Level: Intro
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Canary Release** (Article) — Martin Fowler (Danilo Sato), 2014

- Link: [https://martinfowler.com/bliki/CanaryRelease.html](https://martinfowler.com/bliki/CanaryRelease.html)
- Why it matters: Progressive exposure reduces release risk and supports quick rollback.
- Key takeaways:
  - Start with a subset of users; expand as confidence grows.
- Tags: progressive-delivery, release-safety
- Level: Intro
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Feature Toggles (aka Feature Flags)** (Article) — Martin Fowler, 2016

- Link: [https://martinfowler.com/articles/feature-toggles.html](https://martinfowler.com/articles/feature-toggles.html)
- Why it matters: Decouples deploy from release; enables experiments and safe rollouts.
- Key takeaways:
  - Categorize toggles (release, ops, experiment, permission).
  - Manage lifecycle to avoid technical debt.
- Tags: feature-flags, progressive-delivery, experimentation
- Level: Intermediate
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

## LLM Multi-Agent Systems

**A Multi-Agent Approach for REST API Testing with Semantic Graphs and LLM-Driven Inputs (AutoRestTest)** (Paper) — ICSE Research Track, 2025

- Link: <https://arxiv.org/pdf/2411.07098>
- Why it matters: Presents a concrete, reproducible multi-agent pattern (four cooperating agents with semantic graphs and LLM-driven inputs) that outperforms state-of-the-art REST API testers—applicable for teams introducing agentic testing workflows.
- Key takeaways:
  - Coordinate specialized agents (planner, explorer, generator, evaluator) for API testing.
  - Use semantic graphs and MARL/LLM inputs to boost coverage and defect discovery.
- Tags: multi-agent, testing, rest, llm, semantics
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**An LLM-Based Agent-Oriented Approach for Automated Code Design Issue Localization (LocalizeAgent)** (Paper) — ICSE Research Track, 2025

- Link: <https://lab-design.github.io/papers/ICSE-25b/LocalizeAgent.pdf>
- Why it matters: A multi-agent pipeline (analysis, program-analysis, prompt-builder, ranking agents) that converts static-analysis output into LLM-ready summaries and improves design issue localization on real codebases.
- Key takeaways:
  - Chain specialized agents to refine and rank candidate design issues.
  - Bridge classic static analysis with LLM reasoning for better localization.
- Tags: multi-agent, code-quality, design-issues, static-analysis, llm
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md)

**Agent for User: Testing Multi-User Interactive Features in TikTok** (Paper) — ICSE SE in Practice, 2025

- Link: <https://arxiv.org/pdf/2504.15474>
- Why it matters: Real-world multi-agent user-simulation (one LLM agent per device plus coordination) integrated into a large-scale testing platform; demonstrates production viability with substantial time savings and numerous bug findings.
- Key takeaways:
  - Simulate multi-user scenarios with coordinated LLM agents to scale testing.
  - Integrate agents with existing test infra for measurable efficiency gains.
- Tags: multi-agent, testing, simulation, seip, llm
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [monorepo layout](./monorepo-layout.md)

**SALLMA: A Prototypical Software Architecture for LLM-Based Multi-Agent Systems** (Paper) — ICSE SATrends, 2025

- Link: <https://softwarearchitecturetrends.github.io/pdf/SALLMA-A-prototypical-software-architecture-for-LLM-based-multi-agent-systems.pdf>
- Why it matters: Provides a clear reference architecture (layers, components, interactions) for building LLM multi-agent systems, reducing ad-hoc designs and improving maintainability and safety.
- Key takeaways:
  - Adopt layered components and explicit interaction patterns for MAS.
  - Treat safety, observability, and lifecycle as first-class architectural concerns.
- Tags: multi-agent, architecture, blueprint, safety, maintainability
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**MAAD: Knowledge-Based Multi-Agent Framework for Automated Software Architecture Design** (Paper) — FSE Companion (IVR), 2025

- Link: <https://wssun.github.io/papers/2025-FSE-IVR-MAAD.pdf>
- Why it matters: Maps classic architecture roles (Analyst, Modeler, Designer, Evaluator) to cooperating LLM agents with shared knowledge sources and collaboration protocols—useful scaffolding for early-stage system design.
- Key takeaways:
  - Assign architecture roles to agents with explicit knowledge bases.
  - Use collaboration protocols to converge on coherent design options.
- Tags: multi-agent, architecture-design, knowledge-base, llm
- Level: Advanced
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**SOEN-101: Code Generation by Emulating Software Process Models Using Large Language Model Agents (FlowGen)** (Paper) — ICSE Research Track, 2025

- Link: <https://arxiv.org/abs/2403.15852>
- Why it matters: Demonstrates "agents-as-roles" (requirements, architect, developer, tester, scrum master) coordinated by process emulations (Waterfall/TDD/Scrum) for end-to-end code generation with solid benchmark gains.
- Key takeaways:
  - Compose small teams of role-based agents; start with a TDD pair and scale.
  - Use explicit process templates to stabilize multi-agent handoffs.
- Tags: multi-agent, roles, tdd, process, code-generation
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Human-in-the-Loop Software Development Agents (HULA)** (Industry/SEIP) — ICSE 2025

- Link: <https://arxiv.org/abs/2411.12924>
- Why it matters: Production-aligned framework integrating agents with human oversight (e.g., JIRA), letting engineers steer planning and code generation step-by-step while retaining control. Ideal for 2–6 dev teams introducing agentic workflows without losing control.
- Key takeaways:
  - Keep humans in-the-loop for planning, review, and governance.
  - Integrate with existing work management tools to reduce adoption friction.
- Tags: multi-agent, acp, governance, workflow
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**An LLM-Based Multi-Agent Framework for Agile Effort Estimation** (Paper) — ASE 2025

- Link: <https://conf.researchr.org/details/ase-2025/ase-2025-papers/38/An-LLM-based-multi-agent-framework-for-agile-effort-estimation>
- Why it matters: Practical multi-agent dialogue with humans to converge on story-point estimates; validated on real datasets and a practitioner study—low-risk entry point for agent use in rituals.
- Key takeaways:
  - Use multi-agent discussion to structure estimation and reduce variance.
  - Fit into planning poker/backlog grooming without architectural changes.
- Tags: multi-agent, agile, estimation, planning
- Level: Intro
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md)

**AgileCoder: Dynamic Collaborative Agents for Software Development based on Agile Methodology** (Paper) — FORGE 2025

- Link: <https://conf.researchr.org/details/forge-2025/forge-2025-papers/1/AgileCoder-Dynamic-Collaborative-Agents-for-Software-Development-based-on-Agile-Meth>
- Why it matters: Organizes agent work as sprints/backlogs with a live dependency graph; reports improvements over prior multi-agent baselines on code benchmarks and case studies.
- Key takeaways:
  - Model tasks/backlogs and maintain dependency graphs for coordinated agent work.
  - Use sprint-like cycles to synchronize planning and integration.
- Tags: multi-agent, agile, backlog, dependency-graph
- Level: Intermediate
- Last reviewed: 2025-11-12

**Enhancing Multi-agent System Testing with Diversity-Guided Exploration and Adaptive Critical State Exploitation (MASTest)** (Paper) — ISSTA, 2024

- Link: <https://dl.acm.org/doi/epdf/10.1145/3650212.3680376>
- Why it matters: Introduces an agent-aware testing harness that drives MAS into diverse, failure-revealing states using diversity-guided exploration and targeted perturbations—useful to make multi-agent systems testable and reproducible.
- Key takeaways:
  - Balance broad exploration with adaptive exploitation of critical states to uncover faults.
  - Use replayable seeds and artifact capture to ensure determinism and reproducibility in CI.
- Tags: multi-agent, testing, search-based, reproducibility
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Agents for DDD – Back and Forth** (Workshop Chapter) — EMAS (LNCS), 2024

- Link: <https://link.springer.com/chapter/10.1007/978-3-031-71152-7_11>
- Why it matters: Bridges Domain-Driven Design with agent-oriented software engineering, aligning bounded contexts with agent organizations and roles to keep multi-agent architectures simple and evolvable.
- Key takeaways:
  - Map bounded contexts to agent organizations and roles for clear ownership.
  - Use DDD patterns to structure interactions and maintain conceptual integrity.
  - Use events and typed contracts to connect agent roles across contexts.
- Tags: multi-agent, ddd, architecture, roles
- Level: Intro
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Triangle: Empowering Incident Triage with Multi-Agent** (Paper, Experience) — ASE 2025

- Link: <TBD>
- Why it matters: Production-proven multi-agent incident triage system that mirrors human on-call workflows, showing how to automate noisy ops safely for small teams.
- Key takeaways:
  - Coordinate specialized role agents with policy gates and audit trails.
  - Use semantic distillation to reduce noise and speed triage.
  - Introduce ACP fallback and role negotiation when needed.
- Tags: multi-agent, incident-triage, ops-automation, governance
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [observability requirements](./observability-requirements.md), [tooling integration](./tooling-integration.md), [governance model](./governance-model.md)

**Demystifying LLM-Based Software Engineering Agents** (Paper) — FSE 2025

- Link: <https://conf.researchr.org/details/fse-2025/fse-2025-research-papers/85/Demystifying-LLM-based-Software-Engineering-Agents>
- Why it matters: Empirical evaluation showing simpler agentless pipelines can outperform complex stacks; supports a “minimal agentic core + add agents selectively” strategy with PR-centric governance.
- Key takeaways:
  - Prefer simple planner/builder/verifier loops with guardrails; add agents only when justified.
- Tags: llm-agents, governance, tooling-integration
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

## Autonomic Systems and MAPE-K

**Software Engineering for Self-Adaptive Systems (SEfSAS)** (Book) — de Lemos et al., 2009

- Link: [https://link.springer.com/book/10.1007/978-3-642-02161-9](https://link.springer.com/book/10.1007/978-3-642-02161-9)
- Why it matters: Dagstuhl roadmap and foundational work on the MAPE-K loop.
- Key takeaways:
  - Architect the monitor-analyze-plan-execute loop around a shared knowledge base.
- Tags: self-adaptive, mape-k, roadmap
- Level: Advanced
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**An Introduction to Self-Adaptive Systems** (Book) — Danny Weyns, 2020

- Link: [https://www.springer.com/gp/book/9783030309144](https://www.springer.com/gp/book/9783030309144)
- Why it matters: Modern engineering perspective on self-adaptation with patterns and assurances.
- Key takeaways:
  - Balance autonomy with safety via constraints and verification.
- Tags: self-adaptive, assurance, patterns
- Level: Advanced
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Self-Aware Computing Systems** (Book) — Kounev et al., 2017

- Link: [https://link.springer.com/book/10.1007/978-3-319-47474-8](https://link.springer.com/book/10.1007/978-3-319-47474-8)
- Why it matters: Patterns for self-aware/autonomic behavior in systems.
- Key takeaways:
  - Use feedback loops and models at runtime to adapt safely.
- Tags: self-aware, autonomic, runtime-models
- Level: Advanced
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**The Vision of Autonomic Computing** (Paper) — Kephart & Chess, 2003

- Link: [https://www.cs.tufts.edu/comp/250SA/papers/kephart2003.pdf](https://www.cs.tufts.edu/comp/250SA/papers/kephart2003.pdf)
- Why it matters: Introduces the MAPE-K reference model.
- Key takeaways:
  - Separate sensing, analysis, planning, and execution; share knowledge.
- Tags: autonomic, mape-k, reference-model
- Level: Intro
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Software Engineering for Self-Adaptive Systems (Roadmap II)** (Paper) — de Lemos et al., 2013

- Link: [https://people.cs.umass.edu/~brun/pubs/pubs/Lemos13.pdf](https://people.cs.umass.edu/~brun/pubs/pubs/Lemos13.pdf)
- Why it matters: Consolidates patterns for self-monitoring/adaptation with assurance concerns.
- Key takeaways:
  - Design guardrails and ACP gates.
- Tags: self-adaptive, assurance, governance
- Level: Advanced
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Repairnator: Program Repair Bot** (Paper/Project) — Urli et al., 2018

- Link: [https://arxiv.org/pdf/1811.09852.pdf](https://arxiv.org/pdf/1811.09852.pdf)
- Why it matters: Real bot that watches CI failures and proposes patches—evidence for Kaizen-style automated fixes.
- Key takeaways:
  - Narrow, reversible automation can deliver practical value.
- Tags: program-repair, ci-bots, automation
- Level: Intermediate
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**DSPy: Compiling Declarative Language Model Calls into Self-Improving Pipelines** (Paper) — Khattab et al., 2024

- Link: <https://openreview.net/pdf?id=PFS4ffN9Yx>
- Why it matters: Treats LLM chains as typed, testable modules compiled into pipelines that improve via data-driven optimization—aligns with determinism + reversible changes.
- Key takeaways:
  - Define signatures and metrics; iterate prompts/weights with offline/online eval loops.
  - Keep improvements behind flags and measurable fitness functions.
- Tags: self-adaptive, llm, pipelines, determinism
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Analysis of the MAPE-K Loop in Self-Adaptive Systems (Cloud/IoT/CPS)** (Chapter) — 2024

- Link: <https://link.springer.com/content/pdf/10.1007/978-3-031-26507-5_11.pdf>
- Why it matters: Contemporary synthesis on applying the canonical monitor–analyze–plan–execute over knowledge loop in modern platforms.
- Key takeaways:
  - Model feedback loops explicitly; define signals, policies, and guardrails.
- Tags: mape-k, self-adaptive, feedback-loops
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Closing the Loop: Self-Adaptive Software for Continuous Optimization** (Tutorial) — ICPE Companion, 2024

- Link: <https://research.spec.org/icpe_proceedings/2024/companion/p258.pdf>
- Why it matters: Practical controller designs (centralized/decentralized) for runtime auto-tuning with observability and rollback.
- Key takeaways:
  - Start with simple SLO-aligned controllers; evolve as signal quality improves.
- Tags: self-adaptive, control, optimization
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**MAPE-K-Based Guidelines for Designing Reactive & Proactive Self-Adaptive Systems** (Chapter) — 2024

- Link: <https://link.springer.com/chapter/10.1007/978-3-031-66326-0_4>
- Why it matters: Provides concrete design guidance for structuring MAPE-K controllers and the Knowledge base for both reactive and proactive adaptation.
- Key takeaways:
  - Separate reactive vs. proactive planning and encode policies/goals explicitly in the Knowledge store.
  - Use typed events and auditable decisions to keep adaptations safe and explainable.
- Tags: mapek, guidelines, knowledge-modeling
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

## Reliability, Observability, and Operability

**Site Reliability Engineering** (Book) — Beyer et al., 2016

- Link: [https://sre.google/books/](https://sre.google/books/)
- Why it matters: SRE principles for reliable systems at scale.
- Key takeaways:
  - Use SLOs and error budgets to guide change.
- Tags: sre, reliability, production
- Level: Intermediate
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**The Site Reliability Workbook** (Book) — Beyer et al., 2018

- Link: [https://sre.google/books/workbook/](https://sre.google/books/workbook/)
- Why it matters: Hands-on playbooks and case studies.
- Key takeaways:
  - Implement SLOs, alerting, and incident response with templates.
- Tags: sre, playbooks, operations
- Level: Intermediate
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Release It! (2e)** (Book) — Michael Nygard, 2018

- Link: [https://pragprog.com/titles/mnee2/release-it-second-edition/](https://pragprog.com/titles/mnee2/release-it-second-edition/)
- Why it matters: Stability patterns and failure modes for production systems.
- Key takeaways:
  - Apply bulkheads, circuit breakers, and backpressure to contain faults.
- Tags: resilience, stability-patterns, operability
- Level: Intermediate
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**SRE Workbook: Implementing SLOs / Alerting on SLOs / Canarying Releases** (Guide) — Google SRE, n.d.

- Link: [https://sre.google/workbook/implementing-slos/](https://sre.google/workbook/implementing-slos/)
- Why it matters: Copy-pastable guidance for SLOs, error budgets, and canarying to gate risk.
- Key takeaways:
  - Start from user journeys; tie alerts to SLO violations.
- Tags: slos, canary, alerting
- Level: Intro
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

## Knowledge Plane and Observability

**Observability Engineering** (Book) — Majors, Fong-Jones, Miranda, 2022

- Link: [https://www.oreilly.com/library/view/observability-engineering/9781492076438/](https://www.oreilly.com/library/view/observability-engineering/9781492076438/)
- Why it matters: Modern observability practices and ODD.
- Key takeaways:
  - Instrument for high-cardinality, event-centric debugging; tie signals back to users.
- Tags: observability, odd, telemetry
- Level: Intermediate
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Knowledge Graphs** (Book) — Hogan, Blomqvist, Cochez, d’Amato, de Melo, 2021

- Link: [https://mitpressbookstore.mit.edu/book/9781636392356](https://mitpressbookstore.mit.edu/book/9781636392356)
- Why it matters: Fundamentals and applications of KGs for linking code, tests, issues, and traces.
- Key takeaways:
  - Use graph models to connect software artifacts and improve retrieval/automation.
- Tags: knowledge-graph, data-modeling
- Level: Intermediate
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Dapper: A Large-Scale Distributed Systems Tracing Infrastructure** (Paper) — Sigelman et al., 2010

- Link: [https://research.google.com/archive/papers/dapper-2010-1.pdf](https://research.google.com/archive/papers/dapper-2010-1.pdf)
- Why it matters: The seminal work behind distributed tracing and spans.
- Key takeaways:
  - Correlate requests across services to debug deterministically.
- Tags: tracing, distributed-systems, observability
- Level: Intermediate
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**OpenTelemetry (Project Overview & Semantic Conventions)** (Docs) — CNCF/OTel, 2019–

- Link: [https://www.cncf.io/projects/opentelemetry/](https://www.cncf.io/projects/opentelemetry/)
- Why it matters: Vendor-neutral APIs/SDKs and semantic conventions for metrics, logs, traces—including CI/CD.
- Key takeaways:
  - Standardize telemetry to keep vendor choice open and improve portability.
- Tags: opentelemetry, standards, telemetry
- Level: Intro
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Application of Knowledge Graph in Software Engineering** (Paper) — Information & Software Technology (Elsevier), 2023

- Link: [https://www.sciencedirect.com/science/article/pii/S0950584923001829](https://www.sciencedirect.com/science/article/pii/S0950584923001829)
- Why it matters: Surveys KG construction/usage across software engineering; informs knowledge-plane design.
- Key takeaways:
  - Start small (APIs, SBOMs, spans) and expand evidence graph iteratively.
- Tags: knowledge-graph, se-research
- Level: Advanced
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**KGCompass: Knowledge-Graph-Enhanced Repository-Level Repair** (Paper) — arXiv, 2025

- Link: [https://arxiv.org/abs/2503.21710v1](https://arxiv.org/abs/2503.21710v1)
- Why it matters: Shows repo-aware KGs can improve LLM repair accuracy/cost—evidence for “code-as-data” Kaizen loops.
- Key takeaways:
  - Link issues/PRs to code entities/tests to guide automated fixes.
- Tags: knowledge-graph, automated-repair, llm
- Level: Advanced
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

## Agentic Autonomy Patterns

**Voyager: An Open-Ended Embodied Agent in Minecraft** (Paper) — 2023

- Link: <https://arxiv.org/abs/2305.16291>
- Why it matters: Demonstrates a skill-library pattern with iterative self-improvement and automatic curriculum—transferable to SaaS features as a growing capability shelf behind flags and policies.
- Key takeaways:
  - Persist, reuse, and curate learned skills; gate activation via policy and evaluation.
- Tags: llm-agents, skill-library, self-improvement
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

## Governance, Safety, and ACP

**Runtime Verification (Survey)** (Survey) — 2023

- Link: <https://rv23.org/> (representative survey resources)
- Why it matters: Adds fail-closed runtime monitors and property checks to bound nondeterminism in production.
- Key takeaways:
  - Start with high-value properties (SLOs/invariants); integrate alerts and automated stops.
- Tags: runtime-verification, properties, production-safety
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**AutoGen: Multi-Agent Conversation with Tools and ACP** (Paper/Framework) — Microsoft, 2023

- Link: <https://arxiv.org/abs/2308.08155>
- Why it matters: Configurable agent roles, tool use, and ACP-governed approvals; a pragmatic base for guided autonomy.
- Key takeaways:
  - Encode roles/tools/policies; bound loops; gate risky actions via review.
- Tags: llm-agents, orchestration, acp, governance
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Zanzibar: Google’s Consistent, Global Authorization System** (Paper) — SOSP, 2019

- Link: <https://www.usenix.org/system/files/atc19-pang.pdf>
- Why it matters: Policy-as-data with typed relationships and strong semantics—fits auditable agent/tool gating.
- Key takeaways:
  - Centralize authorization schemas; make policy decisions deterministic and explainable.
- Tags: authorization, policy-as-data, governance
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Use of Formal Methods at Amazon Web Services** (Article) — CACM, 2015

- Link: <https://dl.acm.org/doi/10.1145/2699417>
- Why it matters: Shows how lightweight, spec-first modeling (TLA+) prevents costly design bugs in distributed systems before code.
- Key takeaways:
  - Apply formal specs to 1–2 riskiest workflows; model-check invariants early.
- Tags: formal-methods, tla-plus, design-specs, safety
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**IronFleet: Proving Practical Distributed Systems Correct** (Paper) — OSDI, 2015

- Link: <https://www.usenix.org/system/files/conference/osdi15/osdi15-paper-hawblitzel.pdf>
- Why it matters: End-to-end proofs of real distributed systems (e.g., Paxos KV, RSM) demonstrate what “provable safety” looks like in practice.
- Key takeaways:
  - Apply heavyweight verification surgically to the riskiest components and invariants.
  - Keep specs executable and tie them to implementations to avoid drift.
- Tags: formal-methods, verification, distributed-systems, safety
- Level: Advanced
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Verdi: A Framework for Formally Verifying Distributed Systems Implementations** (Paper) — PLDI, 2015

- Link: <https://dl.acm.org/doi/10.1145/2737924.2737958>
- Why it matters: Provides a compositional approach to verified distributed systems, separating network semantics from application logic.
- Key takeaways:
  - Use modular, typed components with explicit failure models to keep proofs tractable.
  - Borrow the methodology to structure unverified code for higher assurance.
- Tags: formal-methods, verification, compositionality, distributed-systems
- Level: Advanced
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

## Determinism, Testing, and Quality Gates

**Refactoring (2e)** (Book) — Martin Fowler (with Kent Beck), 2018

- Link: [https://martinfowler.com/books/refactoring.html](https://martinfowler.com/books/refactoring.html)
- Why it matters: Small, behavior-preserving steps keep code malleable.
- Key takeaways:
  - Refactor continuously; lean on tests for safety.
- Tags: refactoring, code-health
- Level: Intro
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Working Effectively with Legacy Code** (Book) — Michael Feathers, 2004

- Link: [https://www.pearson.com/en-us/subject-catalog/p/Feathers-FEATHERS-WORK-EFFECT-LEG-CODE-p-1/P200000008984/9780131177055](https://www.pearson.com/en-us/subject-catalog/p/Feathers-FEATHERS-WORK-EFFECT-LEG-CODE-p-1/P200000008984/9780131177055)
- Why it matters: Tactics for carving seams and adding tests to hard-to-touch systems.
- Key takeaways:
  - Characterization tests + seams enable safe change.
- Tags: legacy-code, seams, characterization-tests
- Level: Intermediate
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Rapid Regression Detection via Sequential Monitoring** (Paper) — 2022

- Link: <https://arxiv.org/pdf/2205.14762>
- Why it matters: Sequential tests detect canary regressions faster than fixed-horizon checks, enabling safer rollouts.
- Key takeaways:
  - Predefine metrics, error bounds, and stop rules; automate promotion/rollback.
- Tags: canary, sequential-testing, gates
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Automating Canary Analysis at Netflix (Kayenta)** (Talk/Report) — SREcon EU, 2019

- Link: <https://github.com/Netflix/kayenta>
- Why it matters: Implements automated canary analysis with metrics-based hypothesis tests to safely gate progressive delivery.
- Key takeaways:
  - Define SLIs/thresholds upfront; promote only if the canary passes; rollback fast.
- Tags: canary, progressive-delivery, gates, sre
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Microservices Testing: Methods, Challenges, Solutions (Comprehensive Review)** (Article) — JSS/Elsevier, 2024

- Link: <https://www.sciencedirect.com/science/article/pii/S0164121224002760>
- Why it matters: Strong evidence that contract-driven testing keeps complexity manageable versus heavy end-to-end suites.
- Key takeaways:
  - Prefer CDC/contracts; supplement with targeted integration tests.
- Tags: contract-testing, microservices, testing-strategy
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Empirical Comparison of Black-Box Test Generation Tools for REST APIs** (Paper) — 2021

- Link: <https://arxiv.org/abs/2108.08196>
- Why it matters: Benchmarks REST API fuzzers/generators to guide tool choices for spec-driven gates.
- Key takeaways:
  - Use OpenAPI-based generators to expand coverage quickly.
- Tags: api-testing, fuzzing, openapi
- Level: Intro
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**xUnit Test Patterns** (Book) — Gerard Meszaros, 2007

- Link: [https://openlibrary.org/books/OL7336835M/xUnit_Test_Patterns](https://openlibrary.org/books/OL7336835M/xUnit_Test_Patterns)
- Why it matters: Encyclopedia of test design and “test smells.”
- Key takeaways:
  - Name, structure, and refactor tests deliberately.
- Tags: testing, test-smells, patterns
- Level: Intermediate
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Growing Object-Oriented Software, Guided by Tests** (Book) — Freeman & Pryce, 2009

- Link: [https://www.oreilly.com/library/view/growing-object-oriented-software/9780321574442/](https://www.oreilly.com/library/view/growing-object-oriented-software/9780321574442/)
- Why it matters: End-to-end TDD with emergent design through collaboration.
- Key takeaways:
  - Drive design from tests; use mocks to discover collaboration.
- Tags: tdd, emergent-design, ood
- Level: Intermediate
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Consumer-Driven Contracts** (Article) — Ian Robinson (martinfowler.com), 2006

- Link: [https://martinfowler.com/articles/consumerDrivenContracts.html](https://martinfowler.com/articles/consumerDrivenContracts.html)
- Why it matters: Explains contract-evolution pitfalls and strategies; groundwork for Pact-style verification.
- Key takeaways:
  - Share contracts, not types; validate “just enough.”
- Tags: contracts, service-evolution, api
- Level: Intermediate
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Pact Docs: Consumer-Driven Contract Testing** (Docs) — Pact, n.d.

- Link: [https://docs.pact.io/](https://docs.pact.io/)
- Why it matters: Practical, tool-focused CDC approach for HTTP/messaging.
- Key takeaways:
  - Code-first contracts; verify consumers/providers independently.
- Tags: pact, contract-testing, http, messaging
- Level: Intro
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Design-First (OpenAPI) vs Code-First** (Article) — Swagger, 2023

- Link: [https://swagger.io/blog/code-first-vs-design-first-api/](https://swagger.io/blog/code-first-vs-design-first-api/)
- Why it matters: Compares API design approaches; informs when to prioritize contracts before code.
- Key takeaways:
  - Design-first enables parallel work (stubs/mocks/docs); code-first can drift.
- Tags: openapi, api-design, contracts
- Level: Intro
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

## CI/CD and Policy-as-Code

**Accelerate** (Book) — Forsgren, Humble, Kim, 2018

- Link: [https://itrevolution.com/accelerate/](https://itrevolution.com/accelerate/)
- Why it matters: Evidence-based practices for pipeline/policy design.
- Key takeaways:
  - Optimize lead time, deploy frequency, change failure rate, MTTR.
- Tags: dora, evidence, pipelines
- Level: Intro
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Continuous Delivery** (Book) — Humble & Farley, 2010

- Link: [https://martinfowler.com/books/continuousDelivery.html](https://martinfowler.com/books/continuousDelivery.html)
- Why it matters: Foundational continuous delivery practices.
- Key takeaways:
  - Automate build/test/deploy; keep releases routine.
- Tags: ci-cd, release-engineering
- Level: Intermediate
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Effective Feature Management** (Report) — John Kodumal (O’Reilly), 2019

- Link: [https://go.launchdarkly.com/rs/850-KKH-319/images/launchdarkly-oreilly-effective-feature-management.pdf](https://go.launchdarkly.com/rs/850-KKH-319/images/launchdarkly-oreilly-effective-feature-management.pdf)
- Why it matters: Practical guide to feature flags and controlled rollouts.
- Key takeaways:
  - Decouple deploy from release; manage experiment lifecycles.
- Tags: feature-flags, progressive-delivery, experimentation
- Level: Intro
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Feature Management with LaunchDarkly** (Book) — Michael Gillett, 2021

- Link: [https://www.oreilly.com/library/view/feature-management-with/9781800562974/](https://www.oreilly.com/library/view/feature-management-with/9781800562974/)
- Why it matters: Hands-on patterns for flags, progressive delivery, and testing in production.
- Key takeaways:
  - Use percentage rollouts, kill switches, and targeted exposure safely.
- Tags: feature-management, progressive-delivery, testing-in-prod
- Level: Intro
- Last reviewed: 2025-11-11
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**TFX: TensorFlow Extended for Production ML** (Paper) — KDD, 2017

- Link: <https://dl.acm.org/doi/10.1145/3097983.3098021>
- Why it matters: Deterministic, reproducible pipelines (data validation, schema checks, canaries) for safe ML rollouts.
- Key takeaways:
  - Treat ML as code: metadata, validation, and staged releases.
- Tags: ml-pipelines, determinism, validation
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

**Open Policy Agent (OPA): Policy-as-Code for Cloud-Native Systems** (Docs/Case Studies) — CNCF, ongoing

- Link: <https://www.openpolicyagent.org/>
- Why it matters: Unifies authorization and policy checks across services and CI/CD; makes agent/tool actions auditable and deterministic.
- Key takeaways:
  - Centralize policy in Rego; enforce consistently in pipelines and at runtime.
- Tags: policy-as-code, opa, governance, authorization
- Level: Intro
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

## Case Studies and Production Write-ups

**Reinforcement Learning in Production at Facebook (ReAgent/Horizon)** (System) — 2018

- Link: <https://github.com/facebookresearch/ReAgent>
- Why it matters: Demonstrates offline evaluation, safety filters, and guarded online learning in production.
- Key takeaways:
  - Separate policy training from gated deployment; instrument extensively.
- Tags: rl, production, safety
- Level: Intermediate
- Last reviewed: 2025-11-12
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

## Tools, Frameworks, and Utilities

- TBD

> Notes: Rating counts/averages fluctuate over time and by edition; figures above are snapshots at the time of writing. Prefer primary sources where possible.
