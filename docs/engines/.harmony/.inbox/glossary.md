---
title: Glossary & Concept Map
description: Glossary and concept map of the Harmony architecture.
version: v1.0.0
date: 2025-11-21
---

# Glossary & Concept Map

This document defines the key concepts and jargon used in this repo so you don’t have to reverse-engineer them from code.

If you only remember one thing, remember this:

> **We separate _what we run_ (apps, agents, runtimes) from _what we import_ (kits, engines, agents, contracts).**

Everything else hangs off that.

---

## Kit

**What it is:**

A **Kit** is a small, focused library under `packages/kits/*` that provides **one capability well**.

Examples:

- `plan-kit` – planning helpers.
- `flow-kit` – helpers for dealing with flows/runtime.
- `eval-kit` – evaluation helpers.
- `policy-kit` – policy enforcement utilities.
- `query-kit`, `search-kit`, `patch-kit`, `release-kit`, etc.

**Key properties:**

- Import-only (never a process).
- Typed, contract-driven API.
- Stateless or deterministic where possible.
- Called by Engines, Agents, and sometimes apps.

> Think: **“sharp tool / primitive”**, not “big system”.

---

## Engine

**What it is:**

An **Engine** is a **subsystem built from Kits** that owns a **domain capability end-to-end**. Engines live under `packages/engines/*` and are import-only.

Examples:

- `plan-engine` – planning as a capability (goals → governed plans).
- `work-engine` – execute plan steps via flows/tools.
- `context-engine` – RAG/ContextOps (ingest/index/query/context).
- `governance-engine` – evals, policies, scoring, gating.
- `release-engine` – patch/PR/release workflows.
- `kaizen-engine` – autonomous improvements (Kaizen).

**Key properties:**

- Compose **multiple Kits** + policies + budgets + observability.
- Expose **small, stable APIs** like `generatePlan`, `executeStep`, `getContext`, `evaluate`, `prepareChange`.
- Are called by TS Agents (and occasionally apps), not by runtimes directly.
- Do **not** start processes or servers; they are libraries.

> Think: **“powered subsystem”** like “Planning” or “RAG”, built entirely from Kits.
> In practice, each Engine should feel like a **named product/capability surface** inside the system (for example, “Planning”, “RAG”, or “Release”), with clear inputs/outputs, modes, and metrics that many agents and surfaces can rely on.

---

## Agent

We use “Agent” in two related senses: **TypeScript Agents** (definitions) and **Python Agent Runtimes** (processes).

### TypeScript Agents (`packages/agents`)

**What they are:**

TS Agents define **what an agent role is and how it behaves**, as reusable code.

Layout:

```text
packages/agents/
  src/
    specs/        # agent input/output contracts, roles, capabilities
    definitions/  # which engines/kits implement the agent’s behavior
    governance/   # risk classes, budgets, policies, eval hooks
    factories/    # TS agent factories for apps/console/etc.
````

They:

- Describe **inputs/outputs** and capabilities (specs).
- Describe **how** the agent uses Engines and Kits (definitions).
- Encode **risk, budgets, and policies** (governance).
- Expose **factory functions** that apps call to build concrete agent instances (factories).

> Think: **“what the agent is and how you construct one in TS.”**

### Python Agent Runtimes (`/agents`)

**What they are:**

Python Agent Runtimes are **long-running processes** with specific roles:

- `agents/planner/`
- `agents/builder/`
- `agents/verifier/`
- `agents/orchestrator/`
- `agents/kaizen/`, etc.

They:

- Are **runtime roots** (things we deploy/run).
- Orchestrate higher-level tasks and flows.
- Talk to platform runtimes via `contracts/py` clients.
- Follow the same conceptual patterns as TS Agents but on the Python side.

> Think: **“brains with a job, running as processes.”**

---

## Platform Runtime

**What it is:**

A **Platform Runtime** is a shared execution service under `platform/runtimes/*-runtime/**` that runs flows/tasks for everyone.

Examples:

- `platform/runtimes/flow-runtime` – executes flow graphs (e.g. LangGraph-based).
- Future: `eval-runtime`, `batch-runtime`, etc.

**Key properties:**

- They are **runtime roots** (processes/services).
- They handle:

  - flow/job execution,
  - checkpointing, retries,
  - budgets, quotas, and policies,
  - telemetry (logs, metrics, traces).
- They are accessed **only** via `contracts/*` clients (TS/Python), usually wrapped by Kits and Engines.

> Think: **“execution substrate”** – given a flow/job, it runs it safely and observably.

---

## Factory

**What it is:**

A **Factory** is an import-only function under `packages/agents/src/factories/*` that builds a **concrete agent instance** for an app or tool.

Example:

```ts
const consoleAgent = createConsoleAssistant(config);
const response = await consoleAgent.handleMessage(request);
```

Factories:

- Bind **specs + definitions + governance** into a usable agent object.
- Wire in **Engines** and **Kits**.
- Are used by `apps/*` (and other TS entrypoints) to get ready-to-use Agents.

> Think: **“how apps get a fully-wired Agent instance.”**

---

## Contract

**What it is:**

A **Contract** is a formal API definition (OpenAPI/JSON Schema) plus generated clients in `contracts/*` that define how services and languages talk to each other.

Layout:

- `contracts/ts` – TypeScript clients.
- `contracts/py` – Python clients.

Contracts:

- Define **request/response shapes** and errors.
- Serve as a **single source of truth** for:

  - TS ↔ Python communication,
  - apps/agents → platform runtimes,
  - potentially external services.

> Think: **“strongly typed, shared API boundary.”**

---

## Flow

**What it is:**

A **Flow** is a graph-like process (often implemented in LangGraph or similar) that the platform runtime executes.

Examples:

- “Implement feature X.”
- “Run tests and collect results.”
- “Generate and validate documentation updates.”

Flows:

- Are defined in the runtime implementation (e.g. `platform/runtimes/flow-runtime`).
- Have inputs, outputs, and a set of nodes/edges (steps and transitions).
- Are executed by the flow runtime with checkpointing, retries, and telemetry.

Most callers (Engines/Agents) interact with Flows via:

- Kits (e.g. FlowKit) → `contracts/ts` → flow runtime.

> Think: **“orchestrated multi-step job”** that runs in a shared runtime.

---

## Kaizen

**What it is:**

**Kaizen** refers to continuous, often autonomous improvement workflows running against the system itself.

Examples:

- Improve test coverage.
- Update or refactor docs.
- Tighten observability or flags.
- Reduce flakiness or performance regressions.

Where it lives:

- `kaizen/` – policies, evaluators, codemods, reports.
- `packages/engines/kaizen-engine` – orchestrates Kaizen work.
- Kaizen Agents (TS and/or Python) that run Kaizen plans.

**Typical pattern:**

- Scheduler/event → Kaizen runtime (app or `/agents/kaizen`)
- → KaizenEngine → PlanEngine → WorkEngine → GovernanceEngine → ReleaseEngine
- → PRs / reports.

> Think: **“self-improvement loops for the system.”**

---

## Control Plane vs Runtime Plane

**Control Plane:**

The **Control Plane** is where we make **decisions and orchestrate**:

- TS libraries in `packages/*`:

  - Kits, Engines, Agents, Factories.
- Python agent runtimes in `/agents`:

  - planner, builder, verifier, orchestrator, Kaizen, etc.
- Apps in `apps/*`:

  - UIs and APIs that kick off work.

Characteristics:

- High-level **planning, orchestration, governance**.
- Calls into platform runtimes via **contracts**.
- Rich use of Engines and Kits.

> Think: **“brains and coordinators.”**

**Runtime Plane:**

The **Runtime Plane** is where we **execute** flows/jobs:

- Platform runtimes in `platform/runtimes/*-runtime/**`:

  - `flow-runtime`, future `eval-runtime`, `batch-runtime`, etc.
- Underlying tools, databases, external services.

Characteristics:

- Focused on **execution mechanics**:

  - running flows,
  - applying retries/timeouts,
  - enforcing budgets & quotas,
  - emitting telemetry.

> Think: **“muscle and machinery.”**

**Relationship:**

- Control Plane (Agents/Engines/Kits/Apps) decides **what** should happen and **why**.
- Runtime Plane (platform runtimes) handles **how** to run it safely and reliably.

---

## Quick Concept Map

Putting it all together:

- **Kits** – small capabilities (building blocks).
- **Engines** – subsystems built from Kits that own domain capabilities (Planning, Work, Context, Governance, Release, Kaizen).
- **Agents (TS)** – role/goal-oriented brains defined in `packages/agents` (specs/definitions/governance/factories).
- **Factories** – how apps get concrete Agent instances.
- **Agents (Python)** – long-running control-plane processes in `/agents`.
- **Platform Runtimes** – shared execution services in `platform/runtimes/*-runtime/**`.
- **Contracts** – typed APIs + clients connecting TS & Python to runtimes.
- **Flows** – multi-step jobs that runtime services execute.
- **Kaizen** – continuous improvement workflows using all of the above.
- **Control Plane** – Agents, Engines, Kits, Apps (decisions and orchestration).
- **Runtime Plane** – Platform runtimes and tools (execution).

Use this glossary as the first stop when a term or directory name looks unfamiliar.
