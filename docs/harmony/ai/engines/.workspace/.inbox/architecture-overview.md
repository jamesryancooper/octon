---
title: Architecture Overview
description: Overview of the Harmony architecture.
version: v1.0.0
date: 2025-11-21
---

# Architecture Overview

This repository is organized around a simple core rule:

> **Anything you run lives at the top level. Anything you import lives under `packages/` (and `contracts/`).**

On top of that, the system is structured into **layers of responsibility**:

- **Runtimes** – processes we deploy and operate.
- **Agents** – role/goal-oriented orchestrators.
- **Engines** – domain subsystems built from kits.
- **Kits** – focused libraries that provide specific capabilities.
- **Contracts** – typed boundaries between services and languages.

If you keep “run vs import” and these layers in mind, the repo and architecture become straightforward to navigate.

---

## 1. Planes & Layers

### Runtime plane (things we run)

These are **processes**: containers, services, CLIs, schedulers. They live at the top level:

- `apps/*` – user-facing apps and APIs.
- `agents/*` – Python control-plane agent runtimes.
- `platform/runtimes/*-runtime/**` – shared platform runtime services (e.g. flow runtime).

### Control / knowledge plane (things we import)

These are **libraries and definitions**, never started directly:

- `packages/*` – domain slices, kits, engines, and TypeScript agents.
- `contracts/*` – API contracts and generated clients used by TS and Python.
- `kaizen/*` – (optional) Kaizen policies, evaluators, and related assets.

The call graph usually looks like this:

> **Surfaces (apps, CLIs, schedulers)**
> → **Agents (TS factories or Python runtimes)**
> → **Engines (Plan, Work, Context, Governance, Release, Kaizen)**
> → **Kits (PlanKit, FlowKit, EvalKit, etc.)**
> → **Platform runtimes / tools / external systems**

---

## 2. Things You Run (Runtime Roots)

### `apps/` – Applications & APIs

- Web UIs (e.g. Next.js apps).
- HTTP APIs.
- CLIs or other Node/TS processes.

Responsibilities:

- Handle transport & IO (HTTP, CLI args, auth, sessions).
- Instantiate agents via factories from `packages/agents`.
- Delegate planning, execution, and governance to Engines and Kits.

> **Rule:** `apps/*` should stay thin; business logic belongs in `packages/*`.

---

### `agents/` – Python Agent Runtimes

- Long-running **control-plane** processes with specific roles:

  - Planner, Builder, Verifier, Orchestrator, Kaizen, etc.
- Typically implemented in Python (often using LangGraph or similar under the hood).

Responsibilities:

- Interpret goals and system state.
- Orchestrate flows and tools at a higher level.
- Call platform runtimes and services via `contracts/py` clients.
- Emit telemetry and logs for decisions.

> **Think:** “Brains with a job,” not generic execution engines.

---

### `platform/runtimes/*-runtime/` – Shared Platform Runtimes

- Shared execution substrates used by *many* callers:

  - Today: `flow-runtime` (flow/graph execution service).
  - Later: `eval-runtime`, `batch-runtime`, etc.

Responsibilities:

- Execute flows and tasks on behalf of apps, agents, and Kaizen.
- Enforce quotas, policies, retries, timeouts, and budgets.
- Emit rich telemetry (traces, logs, metrics).

Access:

- Never imported directly.
- Always called through **contracts** (`contracts/ts`, `contracts/py`) and often wrapped by Kits/Engines.

> **Think:** “Give me this flow to run; I will run it safely and observably.”

---

## 3. Things You Import (Libraries & Definitions)

### `packages/kits/` – Kits (Capabilities)

**Kits** are small, focused libraries that provide **one capability well**. Examples:

- Planning, flows, prompts.
- Evaluation, policies, testing.
- Ingestion, indexing, querying, search.
- Caching, observability, scheduling.

Characteristics:

- Stateless or deterministic where possible.
- Typed, contract-driven APIs.
- Called by Engines, TS agents, and sometimes directly by apps.

> **Think:** “Sharp tools / primitives” – not full systems.

---

### `packages/engines/` – Engines (Subsystems)

**Engines** are **subsystems built from kits** that own a **domain capability end-to-end**. For example:

- `plan-engine/` – planning as a service (goals → governed plans).
- `work-engine/` – execution of plan steps via flows and tools.
- `context-engine/` – ingestion/indexing/query/context for RAG.
- `governance-engine/` – evals, policies, scoring, gating.
- `release-engine/` – patching, releases, and deployment workflows.
- `kaizen-engine/` – coordinated autonomous improvements.

Characteristics:

- Live under `packages/engines/` and are **import-only**.
- Compose multiple Kits plus policies, budgets, and observability.
- Expose small, stable APIs like `generatePlan`, `executeStep`, `getContext`, `evaluate`, `prepareChange`.

> **Think:** “Powered subsystems like ‘Planning’ or ‘RAG’, not just helper functions.”

---

### `packages/agents/` – TypeScript Agents

Defines **what an agent is** in TypeScript: capabilities, wiring, and governance.

Structure:

```text
packages/agents/
  src/
    specs/        # agent input/output contracts, roles, capabilities
    definitions/  # what flows/engines/kits an agent uses
    governance/   # risk classes, budgets, eval & policy hooks
    factories/    # TS agent factories for apps/console/etc.
```

- **`specs/`** – Types and contracts: what inputs/outputs and abilities the agent has.
- **`definitions/`** – Logical wiring: which Engines and Kits implement the agent’s behavior.
- **`governance/`** – Risk classification, budgets, guardrails, eval hooks.
- **`factories/`** – Import-only factory functions used by `apps/*` (and other TS entrypoints) to construct ready-to-use agents.

> **Think:** “All the reusable agent logic and configuration; apps just call the factories.”

---

### `contracts/` – Service Boundaries

Defines **how services talk to each other**, and how TS and Python stay in sync:

- OpenAPI / JSON Schema definitions.
- Generated clients:

  - `contracts/ts` for TypeScript.
  - `contracts/py` for Python.

Used by:

- `apps/*` and `packages/*` to call platform runtimes and other services.
- `/agents/*` to call the same services from Python.

> **Think:** “Single source of truth for cross-service and cross-language APIs.”

---

### `kaizen/` (if present) – Kaizen & Continuous Improvement

Holds everything related to **continuous autonomous improvement**:

- Kaizen policies, playbooks, and metrics.
- Kaizen evaluators and codemods.
- Kaizen agents and reports.

Kaizen typically uses:

- Engines (`kaizen-engine`, `plan-engine`, `work-engine`, etc.).
- Kits (EvalKit, PolicyKit, PatchKit, TestKit).
- Runtimes under `apps/*` and `/agents/*` to actually run Kaizen workflows.

---

## 4. Example End-to-End Flows

### Example 1: User asks the console to implement a feature

1. User interacts with `apps/ai-console`.
2. The app creates an agent instance via `packages/agents/src/factories/console-assistant`.
3. The console agent:

   - Calls `PlanEngine` to produce a governed plan.
   - Calls `WorkEngine` to execute plan steps via flows and tools.
   - Calls `GovernanceEngine` to evaluate outputs.
   - Calls `ReleaseEngine` to open a PR with the proposed changes.
4. Engines use Kits (PlanKit, FlowKit, EvalKit, PolicyKit, PatchKit, etc.).
5. Flow execution happens in `platform/runtimes/flow-runtime/**`, accessed via `contracts/ts` clients.

### Example 2: Kaizen run improves test coverage

1. A scheduler triggers a Kaizen job from `apps/*` or `/agents/*`.
2. The Kaizen entrypoint calls `KaizenEngine`.
3. `KaizenEngine`:

   - Calls `ContextEngine` to understand the current state (coverage, flakiness, hotspots).
   - Calls `PlanEngine` to design Kaizen work.
   - Calls `WorkEngine` to apply changes (tests, refactors).
   - Calls `GovernanceEngine` to evaluate impact.
   - Calls `ReleaseEngine` to open PRs or suggestions.
4. All heavy lifting is handled by Engines + Kits; runtimes execute flows and tasks.

---

## 5. Where Does New Code Go? (Rules of Thumb)

When you add something new, ask:

1. **Is it a process that should run on its own?**

   - Yes → `apps/*`, `/agents/*`, or `platform/runtimes/*-runtime/**`.
   - No → it probably belongs in `packages/*`.

2. **Is it a sharp, reusable capability (one concern)?**

   - Yes → `packages/kits/*`.

3. **Is it a domain subsystem that orchestrates multiple capabilities and embeds governance?**

   - Yes → `packages/engines/*`.

4. **Is it about defining or wiring agents (roles, specs, governance, factories)?**

   - Yes → `packages/agents/*`.

5. **Is it an API boundary between TS and Python or between services?**

   - Yes → `contracts/*`.

If you follow those rules, you’ll stay aligned with the architecture and keep the monorepo easy to evolve.

---

This overview is designed as a “map of the territory” for new engineers and reviewers. Deeper details (Engines catalog, Agents & Factories Guide, run vs import rules, etc.) can live in separate focused docs that build on this foundation.
