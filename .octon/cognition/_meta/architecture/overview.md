---
title: Octon Structural Paradigm (HSP) Overview
description: Modular-monolith architecture with vertical slices, deterministic quality gates, and a guided MAPE‑K autonomic loop with ACP-governed autonomy for a small, fast team.
---

# Octon Structural Paradigm (HSP)

HSP‑v1: The Octon Hexa‑Modulith with Vertical Slices and a Thin Control Plane.

Related docs: [monorepo polyglot (normative)](./monorepo-polyglot.md), [repository blueprint](./repository-blueprint.md), [monorepo layout](./monorepo-layout.md), [governance model](./governance-model.md), [runtime policy](/.octon/cognition/_meta/architecture/runtime-policy.md), [observability requirements](./observability-requirements.md), [knowledge plane](../../runtime/knowledge/knowledge.md), [kaizen subsystem](./kaizen-subsystem.md), [tooling integration](./tooling-integration.md), [agent roles](./agent-roles.md), [MAPE-K modeling](./mape-k-loop-modeling.md), [containerization profile](/.octon/cognition/_meta/architecture/containerization-profile.md), [self-contained modules and repos](/.octon/cognition/_meta/architecture/self-contained-repos.md)

The Octon Structural Paradigm (HSP) is the architectural blueprint for our Octon-driven monorepo. It combines proven software patterns with an AI-guided, self-improvement loop while enforcing four non‑negotiable pillars:

- Velocity through Agentic Automation and Trust through Governed Determinism
- Focus through Absorbed Complexity
- Trust through Governed Determinism
- Agent-First System Governance

HSP is optimized for a small team (2 developers, scaling to ~6) to build and evolve a SaaS platform quickly, safely, and predictably.

HSP aligns process and tooling end‑to‑end across all lifecycle stages (Spec → Plan → Implement → Verify → Ship → Operate → Learn) while upholding the six pillars above. The toolkit is designed to cover each stage with thin, predictable interfaces and fail‑closed governance.

## Terminology: Slices vs Layers

- Runtime code is organized by vertical feature slices with hexagonal (ports/adapters) boundaries. We do not use classic n‑tier layering for application calls.
- “layer” refers to cross‑cutting governance/control‑plane concerns (e.g., Kaizen, quality gates, observability) that span slices, not runtime call layers.
- See also: [slices vs layers](./slices-vs-layers.md) and [layers overview](./layers.md).

## Planes and Physical Layout: runtime vs knowledge

At the repository root, Octon distinguishes between **runtime planes** and **knowledge/logic planes**. The canonical, polyglot monorepo layout (see [monorepo polyglot](./monorepo-polyglot.md)) is:

- `apps/`: deployable TypeScript applications and UIs (things you **run**) such as `apps/web`, `apps/api`, and `apps/ai-console`. Apps are thin UI/BFF adapters over kits and feature slices.
- `agents/`: Python agent runtimes and long‑running flows (things you **run** via FlowKit or CLIs), such as `agents/planner`, `agents/builder`, `agents/verifier`, and `agents/orchestrator`.
- `packages/`: reusable TypeScript libraries and knowledge‑plane modules (things you **import**), including domain vertical slices (`packages/<feature>`), control‑plane kits in `packages/kits/*`, and prompt libraries such as `packages/prompts`.
- `contracts/`: contracts registry (OpenAPI/JSON Schema plus generated TypeScript and Python clients) that forms the cross‑language boundary between TypeScript control plane and Python runtimes.
- `platform/`: cross‑cutting platform services (`knowledge-plane/`, `observability/`, and `runtimes/` such as `platform/runtimes/config/**` for shared runtime control-plane configuration and `platform/runtimes/flow-runtime/**` for the LangGraph-based platform flow runtime service; see `runtime-architecture.md`).
- `infra/`, `ci-pipeline/`: infrastructure and CI/CD workflows and gates.
- `docs/`: specifications, ADRs, and other documentation.

Rule of thumb:

- Anything you **run** (HTTP servers, CLIs, flows, runners) lives in a runtime plane (`apps/*`, `agents/*`).
- Anything you **import** across those planes (shared domain logic, kits, prompt suites) lives under `packages/*`; cross‑language contracts live under `contracts/`.
- The LangGraph-based **platform flow runtime implementation** that executes FlowKit flows and AgentKit agents lives under `platform/runtimes/flow-runtime/**` and is treated as runtime infrastructure behind the FlowKit and AgentKit kit boundaries.

This keeps runtime concerns (processes and deployables) clearly separated from shared knowledge and logic (libraries and kits) and aligns the monorepo layout with the Octon Structural Paradigm. For more on how PlanKit, AgentKit, FlowKit, and the shared LangGraph runtime work together, see `.octon/capabilities/runtime/services/execution/service-roles.md`.

### Control Plane vs Runtimes (Polyglot Split)

- **Control plane (TypeScript):** lives in `packages/kits/*` and feature slices under `packages/<feature>`. Kits (for example, FlowKit, AgentKit, PlanKit, EvalKit, PolicyKit, TestKit) define orchestration, policy, contracts, and CI wiring; they do not host long‑running processes.
- **Runtimes (Python + TypeScript hosts):**
  - TypeScript apps under `apps/*` are thin HTTP/UI/CLI hosts that call kits and domain slices.
  - Python agents and flows live under `agents/*` and call the shared platform flow runtime service at `platform/runtimes/flow-runtime/**`, which provides contract-first APIs (for example, `/flows/run`, `/flows/start`) used by FlowKit and AgentKit.
- **Contracts‑first boundary:** OpenAPI/JSON Schema in `contracts/openapi` and `contracts/schemas` generate TypeScript clients (`contracts/ts/*`) and Python clients (`contracts/py/*`) that all hosts use to cross the TS↔Python boundary deterministically.

### Alignment Coverage (Stamp)

- Lifecycle: Each stage is covered by at least one kit (e.g., SpecKit/PlanKit for Spec/Plan; AgentKit for Implement; EvalKit/TestKit for Verify; PatchKit for Ship; ObservaKit for Operate; Dockit for Learn).
- Pillars: All four Octon pillars are reinforced in practice (e.g., Velocity through Agentic Automation and Trust through Governed Determinism via flags/rollback and CI gates; Trust through Governed Determinism via contracts/tests/observability; Focus through Absorbed Complexity via monolith‑first/vertical slices; Agent-First System Governance via the governed MAPE‑K loop).
- Optional kits extend quality and learning without changing core decisions (e.g., A11yKit for accessibility checks; PostmortemKit for structured incident learning).

### Non‑negotiables satisfied

- Monolith‑first with clear, reversible extraction paths (vertical slices; ports/adapters)
- Contract‑first APIs (OpenAPI/JSON Schema) validated via Pact and Schemathesis in CI
- Hexagonal separation (pure domain inward; adapters outward)
- Trunk‑based development with small PRs, Vercel Previews, and manual promote/rollback
- Simplicity and low cognitive load over premature distribution

## Objectives

- Enable rapid delivery without compromising stability or security.
- Keep the system simple to reason about and operate.
- Make behavior deterministic and reproducible end-to-end.
- Harness AI agents for acceleration within clearly governed boundaries.

### Self‑Improvement (Kaizen/Autopilot) Layer

An in‑repo Kaizen layer runs beside normal development to propose tiny, reversible improvements. It detects opportunities (metrics, gates, traces, docs hygiene), evaluates them against written policy (ASVS/SSDF, risk rubric, change‑type gates), and opens PRs with evidence. Autopilot is limited to Trivial/Low‑risk hygiene (e.g., docs, stale‑flags, span/log scaffolding); Copilot PRs for Medium/High‑risk or behavioral changes always require ACP promotion gating with evidence and quorum before durable promotion. Non‑negotiables apply: no direct pushes, no bot approvals, pinned AI configs, and full provenance. See `.octon/cognition/_meta/architecture/kaizen-subsystem.md` for technical design and operations, and `.octon/cognition/_meta/architecture/tooling-integration.md` for the workflow wiring.

#### Cross‑Cutting Nature

- Spans all areas/slices: proposes hygiene across docs, tests, observability, contracts, flags, and CI.
- Policy + evidence driven: opens PRs with proof; never ships changes itself.
- Targets quality attributes, not features: governs how we build/run (consistency, safety), not user‑visible behavior.

Boundaries

- Domain logic or UX changes belong to the owning slice; Kaizen may suggest but owners decide.
- Higher‑risk refactors or anything changing runtime semantics escalate to owners (Copilot track + required reviews).
- During incidents/freezes, operate in suggest‑only mode (issues over PRs).

Quick Rubric (Does it fit Autopilot?)

- Small and reversible; evidence‑driven; policyable; does not change runtime semantics.

## Pillars and Design Practices

### Velocity through Agentic Automation and Trust through Governed Determinism

- Prefer a modular monolith: a single deployable application, logically partitioned into feature modules for fast iteration and low coordination overhead.
- Gate every change with automated tests and ACP policy evaluation prior to release.
- Use feature flags to decouple deploy from user release, enabling progressive rollout and instant rollback.
- Employ AI assistance (Planner/Builder/Verifier agents) to accelerate coding and maintenance, with explicit ACP promotion gates to prevent unsafe changes.
- Favor trunk-based development with small PRs and preview environments to accelerate feedback while preserving safety through policy gates.

### Focus through Absorbed Complexity

- Adopt a monolith‑first approach with clear internal modularity; avoid premature microservices.
- Organize by vertical slices (feature‑focused folders) rather than strictly layered architecture to localize change and reduce cognitive load.
- Eliminate unnecessary distributed coordination (e.g., cross‑service RPC) for a small team; add distribution only when demanded by scale or boundaries.
- Keep shared tooling thin: maintain ToolKit as a minimal wrapper over deterministic actions; if scope grows, prefer specialized sub‑kits to retain clarity and single purpose.

### Trust through Governed Determinism

- Separate pure domain logic from side effects using Hexagonal Architecture (Ports & Adapters) to make behavior predictable and testable.
- Ensure reproducible builds (locked dependencies, deterministic build steps) and run automated tests on every change.
- Prefer deterministic design choices: stable ordering, time control, functional core, explicit side effects.
- Apply deep testing techniques where useful (simulation, property‑based tests) to surface defects early.
- Define and enforce API/data contracts (OpenAPI/JSON Schema). Add consumer‑provider contract tests (e.g., Pact) and schema‑based fuzzing (e.g., Schemathesis) in CI to detect regressions early.
- Instrument with OpenTelemetry for traces/logs/metrics and link trace IDs to PRs/releases for provenance.
- Treat accessibility as a first‑class quality concern: integrate automated a11y checks into CI and handle violations as policy/evaluation failures. Prefer deterministic, reproducible checks and record evidence/provenance.
- AI determinism: pin provider/model/version, prefer low temperature (≤ 0.3), record prompt hashes and idempotency/cache keys for reproducibility.

### Agent-First System Governance

- Introduce an autonomic improvement loop with AI agents that Plan, Build, and Verify changes under strict governance.
- Keep humans on the loop for high‑impact decisions via ACP receipts and escalation digests.
- Require provenance and transparency: log agent actions and rationales; require ACP decisions and quorum attestations for potentially risky actions.
- Favor fail‑closed behavior: unapproved or failing changes never reach production.
- Establish a thin control plane (flags, policies, contracts, observability) so agents operate within guardrails and achieve deterministic outcomes.

## Architecture Summary

HSP pairs a Modular Monolith with Vertical Slices and an AI‑driven MAPE‑K loop.

### Modular Monolith with Vertical Slices

- Single repository and deployable artifact containing all services and features.
- Feature modules encapsulate end‑to‑end capability (UI, domain logic, data access) for local reasoning and parallel work.
- Internal boundaries follow Hexagonal Architecture to isolate business rules from infrastructure.
- Domain‑Driven Design (DDD) principles define bounded contexts to prevent model drift and “big ball of mud” coupling.
- Enforce internal module boundaries and stable coupling rules to prevent cross‑slice entanglement; design seams to allow reversible extraction when warranted.
  See also: `.octon/cognition/_meta/architecture/repository-blueprint.md`, `.octon/cognition/_meta/architecture/monorepo-layout.md`, and `.octon/cognition/_meta/architecture/feature-unit-taxonomy.md` (non‑normative examples) for structure, boundaries, enforcement details, and illustrative feature mappings.

### Autonomic Loop (MAPE‑K)

MAPE‑K: Monitor → Analyze → Plan → Execute, backed by a shared Knowledge base.

- Planner Agent: analyzes knowledge (requirements, code health, telemetry) and proposes improvements or features.
- Builder Agent: implements proposed changes in a controlled sandbox (branches/PRs).
- Verifier Agent: tests/evaluates against specifications and policies.
- ACP Gate: policy engine enforces promotion/finalize decisions using evidence, reversibility, budgets, and quorum; unresolved high‑risk cases escalate.
- Fail‑closed posture: only ACP-allowed, passing changes are eligible to ship.
- Provenance: associate runs, PRs, and releases with trace IDs and run records for auditability.

### Knowledge Plane

- Unified catalog linking specifications, design contracts, test cases, SBOM, traces, and logs.
- Provides traceability and context for developers and agents.
- Enables retrieval‑augmented planning and verification (e.g., align a code fix to its requirement and tests).
- Source‑of‑truth artifacts (specs, prompts, test definitions, etc.) stay in their owning packages and slices (for example, prompt suites live in `packages/prompts` as importable libraries).
- Knowledge Plane services under `platform/knowledge-plane/**` catalog, index, and serve those artifacts (and related telemetry) rather than relocating their source, so apps, agents, and tools share a consistent, versioned view.

### Thin Control Plane

- Responsibilities scoped to governance and safety while remaining lightweight:
  - Flags and progressive rollout with manual promote/rollback.
  - Policy and evaluation gates in CI (align to ASVS/SSDF where applicable).
  - Contract‑first interfaces (OpenAPI/JSON Schema) verified via contract tests.
  - Observability via OpenTelemetry with PR/trace linkage for provenance.

## Development and Release Flow

- Propose change (human or Planner Agent) with traceable rationale tied to specs.
- Implement change in a branch or PR (human or Builder Agent).
- Verify with automated tests and policy checks (Verifier Agent + CI).
- ACP promotion gate (plus human review where repository policy requires it); deploy behind feature flags.
- Gradually enable via flags; monitor telemetry; promote rollout on healthy signals.
- Prefer trunk‑based flow with small, reviewable PRs and preview deployments to shorten feedback loops.

## Determinism and Reliability

- Reproducible CI builds with locked dependencies and deterministic steps.
- Deterministic tests; failures indicate real defects, not flukes.
- Avoid flakiness: control time, concurrency, and non‑deterministic IO where feasible.
- Enforce module boundaries and coupling rules to keep vertical slices independent and predictable over time.

## Governance and Safety

- ACP promotion/finalize gates for merges, production promotion, and other high‑risk actions.
- Full provenance of agent actions, decisions, and attestations.
- Feature flags to decouple release from deploy; default to safe rollouts and instant rollback.
- CI policy gates enforce security and quality controls (e.g., alignment with ASVS/SSDF), contract compliance, and observability baselines.

## Team Scope and Scaling

- Designed for 2 developers initially; scales to ~6 with clear module boundaries and automation.
- Emphasizes local reasoning, parallel work on vertical slices, and minimal coordination.

### Evolution Path

- When boundaries strain or scale demands increase, evolve predictably:
  - Extract hot or independently evolving slices behind stable contracts using the Strangler pattern (e.g., to a BFF or Self‑Contained System) while the modulith remains the system of record.
  - Introduce plugin‑style seams for optional capabilities without polluting the domain core.
  - For scale or tenancy isolation, adopt cell‑style boundaries (per tenant/region) while preserving repo cohesion.
  - Only if necessary, split into services with unchanged external contracts and CI policy gates once boundaries are proven.

## Deliverables (Roadmap)

- Comparative analysis of alternative paradigms and trade‑offs.
- Repository structure blueprint (`repo_structure.json`).
- Detailed MAPE‑K loop design and guardrails.
- Knowledge Plane data model and workflows.
- Agent roles, ACP governance model, and risk controls.
- Continuous improvement (Kaizen) subsystem.
- Operational policies and failure‑mode analysis.
- Scoring rubric and risk analysis supporting HSP adoption.

This blueprint is intended to be immediately actionable for a small team and to scale with the team and product as they grow, maintaining speed with safety and clarity.
