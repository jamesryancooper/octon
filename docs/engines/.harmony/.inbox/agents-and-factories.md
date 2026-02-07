---
title: Agents & Factories Guide
description: Guide to the Harmony agents and factories system.
version: v1.0.0
date: 2025-11-21
---

# Agents & Factories Guide

This guide explains how **Agents** are modeled in the system, how they relate to **Engines** and **Kits**, and how **Factories** in `packages/agents` are used by runtime entrypoints (apps and Python agent processes).

If you understand this doc, you should be able to:

- Know where agent logic lives.
- Know how to instantiate an agent from an app or console.
- Add a new agent in a Harmony-aligned way.

---

## 1. What is an Agent

At a high level:

> An **Agent** is a role/goal-oriented “brain” that uses Engines and Kits to achieve objectives under governance (risk, budgets, policies, evals).

Agents:

- Have a **role** (planner, builder, verifier, console assistant, kaizen reviewer, etc.).
- Understand **goals** and **context**.
- Decide **which Engines** to call (`PlanEngine`, `WorkEngine`, `ContextEngine`, `GovernanceEngine`, `ReleaseEngine`, `KaizenEngine`, …).
- Operate under **constraints**:

  - risk level,
  - budgets (time/calls/tokens),
  - policies and evals.

There are two views of Agents in the repo:

1. **TypeScript agents** in `packages/agents` → **definitions** and **factories**
2. **Python agent runtimes** in `/agents` → **processes** that run in production

---

## 2. Two kinds of Agents: TS vs Python

### 2.1 TypeScript Agents (`packages/agents`)

These are the **importable definitions** of agents:

- What inputs/outputs they accept.
- What Engines and Kits they use.
- What governance (risk, budgets, policies, evals) they operate under.
- Factory functions to construct usable agent instances for apps and tools.

They are **not** processes – they are libraries.

### 2.2 Python Agent Runtimes (`/agents`)

These are **long-running processes** that host agents, typically in Python:

- Example roles: `planner/`, `builder/`, `verifier/`, `orchestrator/`, `kaizen/`.
- They:

  - Receive tasks (via queue, API, schedule).
  - Orchestrate flows and tools at a higher level.
  - Call platform runtimes via `contracts/py` clients.
  - Log and emit telemetry.

They do **not** import Engines/Kits directly across the TS/Python boundary. Instead, they treat platform runtimes as services and talk to them via contracts.

Think of it like this:

- **TS agents** = “what this agent *is* and how you build one”.
- **Python agent runtimes** = “where a particular agent role *runs*”.

---

## 3. `packages/agents` layout

TypeScript agents live under `packages/agents` and are structured like this:

```text
packages/agents/
  src/
    specs/        # agent input/output contracts, roles, capabilities
    definitions/  # which engines/kits implement agent behavior
    governance/   # risk classes, budgets, policies, eval & observability hooks
    factories/    # TS agent factories for apps/console/etc.
```

Each directory has a specific purpose:

### 3.1 `specs/` – What the agent is allowed to do

Here you define:

- **Agent capabilities**:

  - e.g., “console assistant can answer questions about the repo, propose changes, and call tools A/B/C.”
- **Inputs/outputs**:

  - Types for requests and responses (`ConsoleAgentRequest`, `PlannerAgentTask`, etc.).
- **Role metadata**:

  - Name, description, scope, and any requirements.

Specs should be **small and declarative**: they’re the contract that callers rely on.

---

### 3.2 `definitions/` – How the agent does its work (with Engines & Kits)

Here you define **how** an agent behaves:

- Which **Engines** it calls and in what order:

  - e.g., console assistant:

    - `PlanEngine` for breaking down goals,
    - `ContextEngine` for RAG,
    - `WorkEngine` for executing steps,
    - `GovernanceEngine` for evaluation.
- Any **local orchestration logic**:

  - e.g., when to escalate risk, when to ask for clarification, when to stop.
- How it reacts to:

  - errors,
  - partial results,
  - user feedback.

Definitions should be:

- **Role-specific** (tied to a particular agent role).
- Expressed in terms of **Engines** and **Kits**, not raw platform runtimes.

---

### 3.3 `governance/` – Risk, budgets, policies, evals

Here you define agent-specific governance:

- **Risk classes** supported:

  - e.g., `read_only`, `proposal_only`, `autonomous_safe`, `autonomous_high_risk`.
- **Budgets**:

  - Max tokens, calls, time per request/episode.
- **Policies**:

  - Allowed actions per risk class.
  - When a human-in-the-loop (HITL) is required.
- **Evaluators & observability hooks**:

  - Which eval suites to run (via GovernanceEngine/EvalKit).
  - What evidence to record (plans, diffs, traces, artifacts).

This is where you **encode trust boundaries** for the agent.

---

### 3.4 `factories/` – How apps/console actually get an agent instance

Factories are **import-only functions** that apps and tools use to construct concrete agents.

Examples:

- `console-assistant.ts`
- `planner.ts`
- `kaizen-reviewer.ts`

Each factory typically:

1. Reads/loads the agent **spec**.
2. Binds the spec to a **definition** (which Engines & Kits to use).
3. Attaches **governance** (risk profiles, policies, evals).
4. Returns an object with a clear interface, e.g.:

   ```ts
   export interface ConsoleAssistantAgent {
     handleMessage(input: ConsoleAgentRequest): Promise<ConsoleAgentResponse>;
   }
   ```

   And a factory like:

   ```ts
   export function createConsoleAssistant(
     config: ConsoleAssistantConfig
   ): ConsoleAssistantAgent {
     // wire specs + definitions + governance + engines
   }
   ```

These factories are what `apps/*` import and call.

> **Key point:** Factories are *not* runtime processes. They just build agent instances in-process.

---

## 4. How TypeScript Agents, Engines, and Kits work together

Here’s the typical call stack on the TypeScript side:

1. **App entrypoint** (e.g., `apps/ai-console`):

   - Receives user input.
   - Calls a factory from `packages/agents/src/factories` to get an agent instance.

2. **TS Agent instance** (from `packages/agents`):

   - Uses its **definition** to decide which Engines to call for a given request.

3. **Engines** (from `packages/engines`):

   - Use **Kits** (from `packages/kits`) to do the heavy lifting:

     - Planning, flows, RAG, eval, policies, etc.
   - Use `contracts/ts` clients to talk to platform runtimes when needed.

4. **Platform runtimes** (`platform/runtimes/*-runtime/**`):

   - Execute flows/tasks on behalf of Engines and Agents.

So, in code-ish terms:

```ts
// apps/ai-console
const agent = createConsoleAssistant(config);
const response = await agent.handleMessage(userInput);
```

Inside that agent:

```ts
// packages/agents/src/definitions/console-assistant.ts
// pseudo-logic
if (goalNeedsPlan) {
  const plan = await PlanEngine.generatePlan(...);
  const result = await WorkEngine.executePlan(plan, ...);
  const verdict = await GovernanceEngine.evaluate(result, ...);
  // ...
}
```

---

## 5. How Python Agent Runtimes fit in (`/agents`)

Python agent runtimes are **processes**, not libraries. They:

- Live under `/agents/*`.
- Use **generated Python clients from `contracts/py`** to talk to:

  - flow runtime,
  - other platform services.

They conceptually mirror some of the behavior encoded in TS agents, but they do not:

- Import `packages/engines` or `packages/kits` directly.
- Break the contract boundary between TS and Python.

You can think of them as:

> “External controllers that orchestrate the same platform capabilities used by TS agents, but from Python, via contracts.”

Examples:

- `/agents/planner`:

  - Accepts tasks,
  - Calls `flow-runtime` via `contracts/py`,
  - May implement planning logic in Python that conceptually parallels `PlanEngine` (but still respects the same service contracts).

Over time, you may refactor more behavior into shared TS Kits/Engines, leaving Python agents focused on orchestration and integration.

---

## 6. How apps actually use Agents (via factories)

### Example: console assistant in a web app

In `apps/ai-console`:

```ts
import { createConsoleAssistant } from "@/packages/agents/src/factories/console-assistant";

const consoleAssistant = createConsoleAssistant({
  // config: logging, risk profile, feature flags, etc.
});

export async function handleUserMessage(userInput: string) {
  const response = await consoleAssistant.handleMessage({
    message: userInput,
    // other context: user id, session, slice, etc.
  });

  return response;
}
```

This keeps the app:

- Thin (no deep planning/flow logic).
- Clearly separated from platform internals.
- Easy to test (mock the agent interface if needed).

---

## 7. How to add a new Agent (TS)

Use this checklist when introducing a new agent in TypeScript.

### Step 1 – Decide what type of agent this is

Examples:

- Product-facing:

  - `console-assistant`
  - `docs-explorer`
  - `release-copilot`
- Kaizen:

  - `kaizen-tester`
  - `kaizen-docs-improver`

Clarify:

- Role/purpose.
- Main surfaces (UI, CLI, webhooks).
- Risk envelope (read-only, proposal, autonomous, etc.).

---

### Step 2 – Add a spec

Create a file under `packages/agents/src/specs`:

- Define:

  - Request/response types.
  - Capabilities and constraints.
  - Any domain-specific metadata (e.g., which slices it can touch).

---

### Step 3 – Add a definition

Create a file under `packages/agents/src/definitions`:

- Implement high-level behavior in terms of Engines:

  - When to call `PlanEngine`, `WorkEngine`, `ContextEngine`, `GovernanceEngine`, `ReleaseEngine`, etc.
- Keep it **role-focused**, not app-specific.

---

### Step 4 – Add governance

Create a file under `packages/agents/src/governance`:

- Choose supported risk levels.
- Define budgets per request/episode.
- Map risk levels to:

  - allowed actions,
  - required evaluations,
  - HITL requirements.

This will often hook into GovernanceEngine’s modes.

---

### Step 5 – Add a factory

Create a file under `packages/agents/src/factories`:

- Import the spec, definition, and governance.
- Bind them together into an ergonomic interface.

Example:

```ts
export function createReleaseCopilot(
  config: ReleaseCopilotConfig
): ReleaseCopilotAgent {
  // assemble spec + definition + governance + engines
}
```

This is the only thing apps should need to import to use the agent.

---

### Step 6 – Wire it into an app or tool

In `apps/*`, import the factory and expose the agent via an appropriate interface (HTTP route, WebSocket, CLI command, etc.).

---

## 8. Common pitfalls and how to avoid them

### Pitfall 1 – Putting business logic directly in `apps/*`

**Symptom:** HTTP handlers with lots of planning/flow/tool logic.

**Fix:**

- Move agent logic into `packages/agents` (specs/definitions/governance).
- Have the app just:

  - parse requests,
  - call an agent factory,
  - return responses.

---

### Pitfall 2 – Skipping Engines and talking to Kits directly everywhere

**Symptom:** Every agent wires PlanKit + EvalKit + PolicyKit in slightly different ways.

**Fix:**

- Create Engines (e.g. `PlanEngine`, `WorkEngine`) to centralize cross-kit orchestration and governance.
- Definitions call Engines, not raw Kits, for non-trivial flows.

---

### Pitfall 3 – Mixing TS and Python logic haphazardly

**Symptom:** Python code trying to import TS or vice versa; logic duplicated without shared contracts.

**Fix:**

- Always cross the TS/Python boundary via `contracts/*`.
- Treat TS and Python as separate clients of the same platform runtimes.

---

### Pitfall 4 – Overloading factories with logic

**Symptom:** Factories doing heavy decision-making instead of wiring.

**Fix:**

- Keep factories focused on:

  - configuration,
  - wiring,
  - instantiation.
- Move decision logic into `definitions/` (agent behavior) and Engines.

---

## 9. Mental model to remember

If you forget the details, remember this:

> - **Kits**: small tools.
> - **Engines**: powered subsystems built from Kits.
> - **Agents**: “brains with a role” that use Engines to achieve goals under governance.
> - **Factories**: convenient ways for apps and tools to **build agents**.
> - **Python `/agents`**: long-running processes that orchestrate work via contracts.

As long as each of those pieces stays in its lane, the architecture stays simple, evolvable, and safe.
