---
title: Harmony Architecture Agent Set Up
description: Guide for designing the agent setup and structure for the Harmony monorepo.
version: 1.0.1
date: 2025-11-20
---

# Harmony Architecture Agent Set Up

You are helping design the **agent setup and structure** for the Harmony monorepo.

## Objective

Propose a **clear, future‑proof, and methodology‑aligned** agent architecture for this repo:

- It must align with the **Harmony Methodology** in `docs/handbooks/harmony/methodology/README.md`.
- It must treat the **Harmony Architecture** docs in `docs/handbooks/harmony/architecture/**`—especially `agent-architecture.md`, `agent-roles.md`, `kaizen-subsystem.md`, `monorepo-layout.md`, `repository-blueprint.md`, `runtime-architecture.md`, and `runtime-policy.md`—as the **normative baseline** for agents, runtimes, and Kaizen.
- It should be **flexible, extensible, and maintainable** as the system grows.
- It should refine, clarify, and **operationalize** that baseline (for this repo) and may only propose changes that **explicitly call out deltas** from those normative docs and justify why they remain aligned with Harmony’s pillars.

## Context

- Current architecture docs live under: `docs/handbooks/harmony/architecture/**`.
- There is an existing **agents directory** and a **Kaizen directory** (for ongoing improvements and experiments).
- Agents will likely be used from multiple areas: `apps/**`, `kaizen/**`, and other packages or services in the repo.
- The **target agent model and repo layout** are already sketched in:
  - `docs/handbooks/harmony/architecture/agent-architecture.md` (target agent model, `packages/agents`, `kaizen/agents`, `agents/*`).
  - `docs/handbooks/harmony/architecture/agent-roles.md` (Planner/Builder/Verifier contracts).
  - `docs/handbooks/harmony/architecture/kaizen-subsystem.md` and `monorepo-layout.md` / `repository-blueprint.md` (Kaizen layer and polyglot layout).
  - `docs/handbooks/harmony/architecture/runtime-architecture.md` and `runtime-policy.md` (platform runtime service under `platform/runtimes/flow-runtime/**` and runtime behavior).
- The **Harmony Methodology** defines non‑negotiable **System Guarantees** (spec‑first, no silent apply, deterministic AI config, observability, idempotency, fail‑closed governance) that agents must respect.

## Tasks

1. **Analyze the current agent setup** (only as background, not as something you must preserve):
   - Read the key **agent and Kaizen architecture docs** and summarize how the **target model** describes agents and runtimes:
     - `agent-architecture.md` (what an agent is, `packages/agents` layout, governance bundles, and “How to Add a New Agent (Checklist)”).
     - `agent-roles.md` (Planner/Builder/Verifier responsibilities and contracts).
     - `kaizen-subsystem.md` and the Kaizen sections in `monorepo-layout.md` / `repository-blueprint.md` (Kaizen layer, `kaizen/agents`, policies/evaluators/codemods/reports).
     - `runtime-architecture.md` and `runtime-policy.md` (the shared platform runtime service under `platform/runtimes/flow-runtime/**`, contract‑first APIs like `runtime-flows`, caller metadata, and policy profiles).
   - Summarize how agents are:
     - Conceptualized (roles, responsibilities, boundaries, and how they sit above the platform runtime).
     - Structured in the repo (for example, `packages/agents`, `agents/*` as Python control‑plane runtimes, `kaizen/agents` for Kaizen‑specific agents).
     - Wired into flows and runtimes via **PlanKit/FlowKit/AgentKit** and the **platform runtime service**, using contracts and generated clients rather than embedding engines directly.
   - Identify any **misalignments**, **gaps**, or **tensions** between:
     - The target model in the architecture docs.
     - The Harmony Methodology in `docs/handbooks/harmony/methodology/README.md` (especially System Guarantees and Guided Agentic Autonomy).
     - The current or planned physical repo layout in this monorepo.

2. **Refine and operationalize the target agent architecture for this repo** so it is:
   - **Aligned with Harmony’s principles**: spec‑first, deterministic, observable, testable, reversible, monolith‑first, hexagonal, and **Guided Agentic Autonomy** with explicit HITL checkpoints.
   - **Consistent with the target model** in `agent-architecture.md`, while:
     - Filling in any repo‑specific gaps (for example, how `packages/agents` should be introduced and organized here).
     - Calling out any proposed **deltas** from that document as explicit recommendations (with rationale and risk/benefit trade‑offs).
   - **Layered and clean‑architecture friendly**, clarifying:
     - Where **agent specs and definitions** live (for example, PromptKit manifests, PlanKit plans, FlowKit flow definitions, governance bundles).
     - Where **agent runtime / orchestration** lives (for example, TS factories in `packages/agents`, Python control‑plane runtimes in `agents/*`, and flows in the platform runtime under `platform/runtimes/flow-runtime/**`).
     - How agents interact with **domain logic, infrastructure, and UI** using hexagonal boundaries:
       - Domain use‑cases in `packages/<feature>/domain`.
       - Adapters in `packages/<feature>/adapters` and shared adapters in `packages/adapters`.
       - Thin UI/API surfaces in `apps/*` that call agents via stable TS interfaces (never directly into Python runtimes or LangGraph internals).
   - **Future‑proof** for:
     - Additional apps / surfaces (new Next.js apps, CLIs, background jobs, etc.).
     - New agent types (maintenance agents, eval agents, RAG agents, etc.).
     - Evolving kits (PlanKit, FlowKit, AgentKit, PromptKit, EvalKit, PolicyKit, etc.) and additional runtime families (for example, `eval-runtime`), while keeping public agent contracts runtime‑agnostic.

3. **Give precise repo‑structure recommendations**, explicitly grounding them in the canonical layout from `agent-architecture.md`, `monorepo-layout.md`, and `repository-blueprint.md`:
   - **Kaizen vs. agents vs. packages/agents**
     - Confirm or adapt the canonical split:
       - `packages/agents/**` as the **canonical entrypoint** for production‑grade, reusable agents (TS package exporting specs, definitions, runtime factories, and governance bundles).
       - `agents/*` as **Python control‑plane runtimes** (Planner/Builder/Verifier/Orchestrator) that call the shared platform runtime and kits via contracts and generated clients.
       - `kaizen/agents/**` as **Kaizen‑specific agents** (maintenance/hygiene) that orchestrate evaluators and codemods and open dry‑run PRs.
     - Propose **clear rules** (aligned with `agent-architecture.md` and `kaizen-subsystem.md`) for:
       - What belongs in `kaizen/agents/**` vs `packages/agents/**` vs `agents/**`.
       - When and how a Kaizen agent should be **promoted** into `packages/agents` as a reusable maintenance agent.
       - How to avoid duplication or confusion between Kaizen agents, production agents, and Python runtimes.
   - **Access patterns**
     - Assume agents will be invoked from:
       - `apps/**` (e.g., API routes, UI triggers, Next.js Server Actions).
       - `kaizen/**` (experiments, maintenance, improvement flows).
       - Other shared packages or tooling (e.g., CI, CLIs, background jobs).
     - Propose how to structure exports/interfaces so that:
       - **All consumers** depend on **stable TypeScript contracts** (types, JSON Schemas, OpenAPI, factory functions) exported from `packages/agents` and kits in `packages/kits`, not on internal Python modules or LangGraph engine entrypoints.
       - UI and API surfaces never call `agents/*` or `platform/runtimes/flow-runtime/**` directly; they call TS factories and generated clients instead.
       - Agent internals (prompt manifests, flows, runtime wiring) remain **encapsulated and easy to evolve** behind those public contracts.

4. **Spell out concrete recommendations**, not just generalities:
   - Propose:
     - Directory structure (for example, `packages/agents/**`, `kaizen/agents/**`, `agents/**`, `platform/runtimes/flow-runtime/**`, and related `contracts/**` entries).
     - How to separate:
       - **Core agent specs and definitions** (plans, flows, prompt manifests, schemas) from:
       - **Execution/orchestration** (FlowKit, AgentKit, platform runtimes).
       - **Policies, evals, and observability hooks** (PolicyKit, EvalKit, ObservaKit) bound per agent via governance bundles.
   - Tie each recommendation back to:
     - A specific **Harmony Methodology principle** (e.g., spec‑first, deterministic agents, observability, monolith‑first, hexagonal).
     - A concrete **benefit** (e.g., easier testing, clearer ownership, safer refactors, simpler adoption of new agent types, runtime‑agnostic agents).

## Constraints & Guidance

- **Do not** preserve ad‑hoc or legacy agent structure just because it exists.
  - Treat the **target agent model** and monorepo layout described in `agent-architecture.md`, `monorepo-layout.md`, and `repository-blueprint.md` as the **starting blueprint**, and:
    - Use existing code and directories as **input to critique** and as evidence of gaps or drift.
    - When you propose changes that would alter those normative docs, call them out explicitly as **deltas** and justify how they remain aligned with Harmony’s Methodology (especially System Guarantees and Guided Agentic Autonomy).
- Optimize for:
  - **Clarity** (easy for new contributors to understand where agents live and how to use them).
  - **Separation of concerns** (agent orchestration vs. domain logic vs. infrastructure).
  - **Testability & governance** (where to plug in EvalKit, PolicyKit, ObservaKit, and how to trace runs via the Knowledge Plane and runtime telemetry).
- Where helpful, provide:
  - Example directory trees.
  - Example module boundaries (e.g., “public agent interface” vs “internal wiring”).

## Deliverables

1. A **short critique** of the current agent setup and its alignment/misalalignment with Harmony Methodology.
2. A **refined, repo‑specific agent architecture** that:
   - Is consistent with the target model in `agent-architecture.md` (or clearly documents any intentional deltas).
   - Has a clear directory/module structure.
   - Defines rules for what lives in `packages/agents/**` vs `agents/**` vs `kaizen/agents/**`.
   - Provides guidelines for how apps, kaizen flows, and other packages **consume** agents via stable TS contracts and generated clients.
3. A brief **“How to add a new agent” checklist** that:
   - Starts from and remains compatible with the canonical checklist in `agent-architecture.md`.
   - Calls out any repo‑specific steps or constraints needed to satisfy Harmony’s invariants and this monorepo’s current structure.
