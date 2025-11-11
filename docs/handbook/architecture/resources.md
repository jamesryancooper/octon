# Architecture Suggested Resources

Use this page to curate external references that deepen or complement topics covered in `docs/handbook/architecture`. Keep entries short, annotated, and directly actionable.

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
- Related docs: [overview](./overview.md), [repository blueprint](./repository-blueprint.md)

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

- TBD

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

## Flow, Delivery, and Team Design (Speed with Safety)

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
  - Design guardrails and human-in-the-loop checkpoints.
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

**Agentless: Demystifying LLM-Based Software Engineering Agents** (Paper) — Xia et al., 2024

- Link: [https://arxiv.org/abs/2407.01489](https://arxiv.org/abs/2407.01489)
- Why it matters: Empirical look at agent patterns/limits; argues for tool-integrated pipelines (PR-only governance).
- Key takeaways:
  - Prefer simple planner/builder/verifier loops with guardrails.
- Tags: llm-agents, governance, tooling-integration
- Level: Intermediate
- Last reviewed: 2025-11-11
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

## Governance, Safety, and HITL

- TBD

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

## Case Studies and Production Write-ups

- TBD

## Tools, Frameworks, and Utilities

- TBD

> Notes: Rating counts/averages fluctuate over time and by edition; figures above are snapshots at the time of writing. Prefer primary sources where possible.
