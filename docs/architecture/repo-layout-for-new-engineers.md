---
title: Repo Layout for New Engineers
description: Onboarding-friendly guide to the Harmony monorepo structure using the "run at the top, import from packages" rule of thumb.
version: v1.0.0
date: 2025-11-21
---

# Repo layout for new engineers

Related docs: [monorepo layout](./monorepo-layout.md), [repository blueprint](./repository-blueprint.md), [layers](./layers.md), [migration playbook](./migration-playbook.md)

This repo follows a simple rule:

> **Anything you run lives at the top level. Anything you import lives under `packages/`.**

If you remember that, most of the structure will make sense.

## 1. Things you run (runtime roots)

These directories contain **processes and services** that actually run in an environment (local, dev, prod). They are where Docker images, PM2 processes, k8s workloads, etc. should come from.

### `apps/`

- User-facing entrypoints:
  - Web apps (e.g. Next.js)
  - HTTP APIs
  - CLIs or other TS/Node processes
- They are intentionally **thin**:
  - Handle transport (HTTP, CLI args, etc.)
  - Instantiate agents via **factories** from `packages/agents`
  - Delegate real work to **Engines** and **Kits**

Think: “UI and edge APIs live here.”

### `agents/`

- **Python agent runtimes** – long-running control-plane processes with a specific role:
  - Planner, Builder, Verifier, Orchestrator, etc.
- Responsibilities:
  - Interpret goals and system state
  - Orchestrate work across flows and tools
  - Call platform runtimes via generated clients from `contracts/py`

These are “brains with a role,” not generic execution engines.

Think: “Orchestrators/controllers that decide *what* to do.”

### `platform/runtimes/*-runtime/`

- **Shared platform runtime services**:
  - Today: the flow runtime (e.g. LangGraph-based execution engine)
  - Later: eval runtimes, batch runtimes, etc.
- Responsibilities:
  - Execute flows/graphs for any caller (apps, agents, Kaizen, CI)
  - Enforce quotas, policies, retries, and telemetry
- Exposed via contracts (OpenAPI/JSON Schema) in `contracts/`, with generated TS/Python clients.

Think: “Execution substrate: given a flow to run, it runs it—safely and observably.”

---

## 2. Things you import (libraries, abstractions, definitions)

These directories contain **shared logic** and **definitions**. They are never run directly; they are imported by the runtime roots above.

### `packages/`

Everything under `packages/` is **import-only**. The main categories:

#### `packages/kits/`

- Small, focused libraries that provide **one capability well**:
  - Planning, flows, prompts, evals, policies, context/RAG, caching, observability, etc.
- Stateless or deterministic by design where possible.
- Called by Engines, agents, and sometimes apps.

Think: “Sharp tools / primitives.”

#### `packages/engines/`

- Higher-level **subsystems built from kits**:
  - `plan-engine/` – planning as a capability
  - `work-engine/` – executing plan steps via flows/tools
  - `context-engine/` – RAG/ContextOps
  - `governance-engine/`, `release-engine/`, `kaizen-engine/`, etc.
- Each Engine:
  - Composes multiple Kits
  - Encapsulates policies, evals, budgets, and observability for its domain
  - Exposes a small, stable API for “do X” (e.g. `generatePlan`, `executeStep`, `getContext`)

Think: “Subsystems like ‘Planning’ or ‘RAG’, not just helper functions.”

#### `packages/agents/`

Defines **what an agent is** in a reusable TypeScript form:

```text
packages/agents/
  src/
    specs/        # agent input/output contracts, roles, capabilities
    definitions/  # what flows/engines/kits an agent uses
    governance/   # risk classes, budgets, eval & policy hooks
    factories/    # TS agent factories for apps/console/etc.
```

- **`specs/`**
  - Types and contracts: what the agent accepts, returns, and is allowed to do.
- **`definitions/`**
  - Logical wiring: which flows, Engines, and Kits implement the agent’s behavior.
- **`governance/`**
  - Risk levels, budgets, policies, eval suites, observability hooks.
- **`factories/`**
  - **Factory functions** used by `apps/*` (and other TS entrypoints) to instantiate concrete agents:
    - e.g. `createConsoleAssistant(config)`, `createKaizenReviewer(config)`
  - Factories wire specs + definitions + governance together with Engines, Kits, and platform runtime clients.
  - Import-only: these are **not** runtime roots.

Think: “All the reusable agent smarts live here; apps and services just call the factories.”

#### Other `packages/*`

- Domain modules, adapters, shared utils, prompt libraries, design tokens, etc.
- Same rule: **never run directly; always imported.**

---

### `contracts/`

- API contracts (OpenAPI/JSON Schema) and generated clients:
  - `contracts/ts` – TypeScript clients
  - `contracts/py` – Python clients
- Used by:
  - `apps/*` and `packages/*` (TS) to talk to platform runtimes
  - `agents/*` (Python) to talk to the same runtimes

Think: “Single source of truth for service boundaries between TypeScript and Python.”

---

### `kaizen/` (if present)

- Everything related to **continuous improvement**:
  - Kaizen policies and playbooks
  - Kaizen evaluators and codemods
  - Kaizen agents (often consuming Engines + Kits)
- Typically combines:
  - `packages/engines/kaizen-engine`
  - `packages/agents` factories
  - Runtime roots in `apps/*` or `agents/*` to actually run Kaizen work

---

## 3. Typical request flow (big picture)

For a TypeScript app:

```text
User → apps/ai-console
     → packages/agents (factory builds a console agent)
     → packages/engines (PlanEngine, WorkEngine, ContextEngine, ...)
     → packages/kits (PlanKit, FlowKit, EvalKit, ...)
     → contracts/ts client
     → platform/runtimes/flow-runtime/** (executes flows)
```

For a Python planner agent:

```text
Scheduler/Event → agents/planner (Python process)
                → contracts/py client
                → platform/runtimes/flow-runtime/**
                → flows, tools, DBs, etc.
```

In both cases, **only** `apps/*`, `agents/*`, and `platform/runtimes/*-runtime/**` are actual processes. Everything else in `packages/*` and `contracts/*` is imported.

---

If you keep this mental model in mind—**“run at the top level, import from `packages/`”**—you’ll navigate and extend the repo comfortably, even without knowing all of the internal framework terminology.
