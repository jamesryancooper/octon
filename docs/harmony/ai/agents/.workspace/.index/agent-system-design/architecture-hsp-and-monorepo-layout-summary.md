---
title: Harmony Structural Paradigm and Monorepo Layout — Synthesized Summary
description: Summary of HSP, monorepo structure, slices vs layers, and repository blueprint for agent system design.
---

## Purpose of This Summary

- Condense the **Harmony Structural Paradigm (HSP)**, **monorepo layout**, **repository blueprint**, and **layers vs slices** terminology into a short reference for agent-system design.
- Provide a single document agents can read instead of many architecture files, while keeping the underlying docs authoritative.

## Harmony Structural Paradigm (HSP) at a Glance

- HSP defines a **modular monolith with vertical slices** and a **thin control plane**.
- Target team size: **2–6 developers**; optimize for **local reasoning**, clear ownership, and low coordination overhead.
- Pair a vertical‑slice modulith with:
  - A **contracts‑first** boundary (`contracts/` registry).
  - A **Knowledge Plane** for traceability.
  - A **Kaizen layer** for continuous improvement.
  - A **shared platform runtime** (for flows and agents) under `platform/runtimes/*-runtime/**`.

## Slices vs Layers (Terminology)

- **Slices**:
  - Vertical feature modules under `packages/<feature>`:
    - `domain/` — pure business logic and use‑cases (no IO).
    - `adapters/` — outbound integrations (DB, HTTP, queues).
    - `api/` — inbound interfaces (public ports, OpenAPI/JSON Schema).
    - `tests/` — unit, integration, contract tests.
    - Optional `docs/spec.md` and local schemas.
  - Slices own their data and contracts; other code interacts via published interfaces and/or contracts in `contracts/`.
- **Layers**:
  - Cross‑cutting **control/gov layers** (Kaizen, policy gates, observability, docs, security).
  - Implemented via `kaizen/`, `ci-pipeline/`, `platform/observability`, `docs/`, etc.
  - Layers do not form runtime call stacks; they **span slices** as governance/control planes.

## Canonical Monorepo Layout (Polyglot)

High‑level structure (TypeScript + Python):

- `apps/` — **deployable apps** and UIs (what you run):
  - `apps/ai-console` — Next.js UI for agents/observability.
  - `apps/api` — HTTP API/BFF, spec‑first controllers.
  - `apps/web` — Astro/docs or marketing surfaces.
- `packages/` — **reusable libraries** (what you import):
  - `packages/<feature>` — vertical slices (domain/adapters/api/tests/docs).
  - `packages/common` — carefully curated shared primitives and DTOs.
  - `packages/kits/*` — AI‑Toolkit kits (SpecKit, PlanKit, FlowKit, AgentKit, EvalKit, PolicyKit, ObservaKit, etc.).
  - `packages/prompts` — prompt suites as knowledge‑plane libraries.
- `platform/` — **platform services**:
  - `platform/knowledge-plane` — specs, policies, SBOM, traces, correlation data.
  - `platform/observability` — OTel bootstrap, dashboards, alert rules.
  - `platform/runtimes/config` — control‑plane configuration for runtime services (flags, rollout descriptors, runtime policy bundles, queue/worker profiles, risk tiers, env mappings).
  - `platform/runtimes/flow-runtime/**` — **LangGraph-based platform flow runtime service** (runtime‑plane API, scheduler, executors) that executes flows/graphs on behalf of apps, agents, and Kaizen.
- `agents/` — **Python control‑plane runtimes**:
  - `agents/planner`, `agents/builder`, `agents/verifier`, `agents/orchestrator`.
  - These are long‑running processes used for Planner/Builder/Verifier/Orchestrator roles.
- `kaizen/` — **Kaizen/Autopilot layer**:
  - `kaizen/policies`, `kaizen/evaluators`, `kaizen/codemods`, `kaizen/agents`, `kaizen/reports`.
- `contracts/` — **contracts registry**:
  - `contracts/openapi` — OpenAPI specs.
  - `contracts/schemas` — JSON Schemas.
  - `contracts/ts` — generated TypeScript clients/types.
  - `contracts/py` — generated Python clients for uv workspace members.
- `ci-pipeline/` and `.github/workflows` — CI and quality gates.
- `docs/` — architecture docs, handbooks, ADRs, methodology.

**Rule of thumb**:

- Anything you **run** (HTTP servers, CLIs, agent hosts, platform runtimes) lives under `apps/*`, `agents/*`, `platform/runtimes/*-runtime/**`.
- Anything you **import** lives under `packages/*`; cross‑language boundaries live under `contracts/`.

## Structural Blueprint and Module Boundaries (Enforcement)

- **Feature modules**:
  - Domain code in `packages/<feature>/domain` never depends on adapters or app code.
  - Adapters depend inward on domain ports and may depend on shared infra libs.
  - APIs depend inward on domain and expose contracts (OpenAPI/JSON Schema) via `contracts/`.
- **Kits as control‑plane libraries**:
  - All kits (FlowKit, AgentKit, EvalKit, etc.) live in `packages/kits/*`.
  - Apps/agents/Kaizen/CI import kits as libraries; kits do **not** import apps/agents.
  - Platform runtimes (`platform/runtimes/*-runtime/**`) are infrastructure behind kit contracts.
- **Agents as control‑plane runtimes**:
  - `agents/*` hosts Planner/Builder/Verifier/Orchestrator processes; they call kits and platform runtimes via **contracts and generated clients**, not by importing engine internals.
  - Agents are not libraries; they are runtime processes with clear responsibilities and observability requirements.

## Kaizen/Autopilot Layer (Structural Summary)

- `kaizen/` provides a **cross‑cutting improvement plane**:
  - Policies (`kaizen/policies`) encode risk rubrics and gates (e.g. `risk.yml`, `gates.yml`).
  - Evaluators (`kaizen/evaluators`) analyze docs, tests, coverage, traces, flags, bundles.
  - Codemods (`kaizen/codemods`) implement safe, idempotent code changes.
  - Agents (`kaizen/agents`) orchestrate evaluators/codemods and open **dry‑run PRs**.
  - Reports (`kaizen/reports`) summarize Kaizen activity and outcomes.
- Kaizen is **cross‑slice** and focuses on hygiene, not product features. Higher‑risk changes are always routed to slice owners.

## Implications for Agentic System Design

- Agents must:
  - Respect **vertical slice boundaries** (no cross‑slice reach‑in imports).
  - Operate as **control‑plane runtimes** above slices and platform runtimes, never as alternate data planes.
  - Use `contracts/` and generated clients for all cross‑language or cross‑service calls.
  - Treat platform runtimes as **shared execution services**, not as agent‑specific runtimes.
- A **packages/agents** TS package (as defined in `agent-architecture.md`) should sit above this structure and expose:
  - Typed agent contracts and factories for production agents.
  - Separate Kaizen agents (or promotion paths from `kaizen/agents`) when they become reusable.

## Anti‑Patterns to Avoid

- Agents or apps:
  - Importing `platform/runtimes/flow-runtime/langgraph/**` internals directly.
  - Re‑implementing their own flow runtimes instead of using the shared platform runtime.
  - Reaching into `packages/<feature>/` internals instead of using published APIs/contracts.
- Kits:
  - Owning long‑running processes (that belongs under `apps/*`, `agents/*`, or `platform/runtimes/*-runtime/**`).
  - Embedding runtime engines rather than calling platform runtimes via contracts.



