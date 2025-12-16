---
title: Run vs Import Guideline
description: Guideline for where to put code in the Harmony monorepo.
version: v1.0.0
date: 2025-11-21
---

# Run vs Import Guideline

This repo is organized around one core rule:

> **Anything you run lives at the top level. Anything you import lives under `packages/` (and `contracts/`).**

If we follow this rule consistently, it becomes easy to answer:

- *Where should new code live?*
- *What gets built into containers / deployed?*
- *What is just shared logic?*

This document spells out how to apply that rule in practice.

---

## 1. Two categories of code

### 1.1 Things you *run* (runtime roots)

These are **processes**:

- They have a main entrypoint.
- They run as servers, workers, CLIs, schedulers, etc.
- They are what we deploy and operate.

They live **only** in:

- `apps/*`
- `/agents/*`
- `platform/runtimes/*-runtime/**`

If it needs its own container, systemd unit, PM2 process, or k8s Deployment, it belongs in one of those three.

---

### 1.2 Things you *import* (libraries and definitions)

These are **libraries**:

- They export functions, types, classes, configs.
- They are never executed directly as a process.
- They are imported by runtime roots and by other libraries.

They live in:

- `packages/*` – domain modules, Kits, Engines, agents, utilities.
- `contracts/*` – contracts + generated clients.
- `kaizen/*` – (optional) Kaizen policies/evaluators/etc. that are imported by runtimes.

If it doesn’t need its own process and can be imported, it belongs here.

---

## 2. Directory reference – where things go

Use this as a quick map.

### 2.1 Runtime roots (run here)

- **`apps/*`**

  - Web apps, HTTP APIs, CLIs, scheduled jobs (in TS/Node).
  - Thin entrypoints that wire requests → agents → engines → kits.

- **`/agents/*`**

  - Python agent runtimes (planner, builder, verifier, orchestrator, Kaizen, etc.).
  - Long-lived control-plane processes.

- **`platform/runtimes/*-runtime/**`**

  - Shared execution services (flow runtime, future eval runtime, batch runtime, etc.).
  - “Platform-level” runtimes that everybody calls.

If it’s not one of these three, *it is not a runtime root* and must not behave like one.

---

### 2.2 Import-only modules (import from here)

- **`packages/kits/*`**

  - Small capability libraries (PlanKit, FlowKit, PromptKit, EvalKit, PolicyKit, etc.).

- **`packages/engines/*`**

  - Subsystems built from Kits (PlanEngine, WorkEngine, ContextEngine, GovernanceEngine, ReleaseEngine, KaizenEngine, etc.).

- **`packages/agents/*`**

  - TypeScript agent definitions:

    - `specs/` – agent contracts & roles.
    - `definitions/` – which Engines/Kits they use.
    - `governance/` – risk, budgets, policies, eval hooks.
    - `factories/` – functions to construct agent instances for apps/console.

- **Other `packages/*`**

  - Domain modules, adapters, utilities, prompt libraries, etc.

- **`contracts/*`**

  - OpenAPI/JSON Schema + generated TS/Python clients for platform runtimes and services.

- **`kaizen/*`**

  - Kaizen policies, evaluators, reports, etc., imported by runtime roots.

None of these directories should contain an application `main()`, HTTP server bootstrap, or other “start me as a process” entrypoints.

---

## 3. How to decide where new code belongs

When you’re about to create something new, run through these questions:

### Q1: Does this need to run as its own process

Examples:

- A new HTTP API.
- A new web app.
- A new background worker or scheduler.
- A new shared runtime service (like a second flow runtime).

If **yes** → put it in:

- `apps/*` for TS/Node apps, or
- `/agents/*` for Python control-plane agents, or
- `platform/runtimes/*-runtime/**` for platform services.

If **no** → it’s a library → go to Q2.

---

### Q2: Is this a small, focused capability or a bigger subsystem

- If it’s a **small, focused capability** (one concern):

  - e.g. “plan generator”, “flow helper”, “RAG query helper”, “eval scorer”
  - → put it in `packages/kits/*`.

- If it’s a **bigger subsystem** that:

  - orchestrates multiple Kits,
  - has its own policies, budgets, and telemetry,
  - is used by multiple agents/surfaces,
  - e.g. “planning system”, “RAG system”, “release system”, “Kaizen system”
  - → put it in `packages/engines/*` as an Engine.

---

### Q3: Is this about defining an agent

If the main concern is:

- “What does this agent role do?”
- “Which Engines/Kits does it use?”
- “What are its inputs/outputs, risk levels, and policies?”
- “How does an app get an instance of this agent?”

Then it belongs in **`packages/agents`**:

- `specs/` – contracts & role definition.
- `definitions/` – how it works (in terms of Engines/Kits).
- `governance/` – risk & budgets.
- `factories/` – how apps actually construct it.

If the concern is instead “run this agent as a long-lived process in Python”, that’s a runtime → `/agents/*`.

---

### Q4: Is this just shared domain logic, adapters, or utilities

If it doesn’t fit any of the above, it probably belongs in a plain `packages/*` module, e.g.:

- `packages/domain-*`
- `packages/adapters-*`
- `packages/utils-*`
- `packages/prompts-*`

These are normal libraries imported by Kits, Engines, Agents, and apps.

---

## 4. Good vs bad examples

### Example 1: New web console

- ✅ Good: `apps/ai-console/`

  - HTTP/WebSocket server.
  - Imports `createConsoleAssistant` from `packages/agents/src/factories`.
- ❌ Bad: `packages/console-app/` with its own HTTP server.

---

### Example 2: New planning capability

- You’re adding a new way to generate plans.

- ✅ Good:

  - Core logic → `packages/kits/plan-kit/` (if it’s low-level).
  - Orchestration with evals/policies/telemetry → `packages/engines/plan-engine/`.

- ❌ Bad:

  - Planning logic directly inside `apps/*` or `/agents/*`.
  - A standalone `/planning-service` runtime that bypasses existing platform runtimes/contracts without a clear need.

---

### Example 3: New “Release Copilot” agent

- ✅ Good:

  - Agent spec/behavior/governance/factory → `packages/agents/src/*`.
  - Uses `ReleaseEngine` + `GovernanceEngine` internally.
  - Apps instantiate it via a factory.
- ❌ Bad:

  - Putting all its logic in `apps/release-dashboard` route handlers.
  - Implementing arbitrary GitHub API calls directly in app code instead of through Kits/Engines.

---

## 5. Common mistakes to avoid

### Mistake 1: Hiding runtimes under `packages/`

If you find:

- HTTP servers, CLIs, schedulers, or long-running loops inside `packages/*`…

…that’s a smell. Those should move to:

- `apps/*`, `/agents/*`, or `platform/runtimes/*-runtime/**` as appropriate, with the logic turned into importable libraries under `packages/*`.

---

### Mistake 2: Putting shared logic directly in runtime roots

If you have:

- Big chunks of planning/execution/eval/RAG logic in `apps/*`, `/agents/*`, or `platform/runtimes/*-runtime/**`…

…you risk:

- duplication,
- inconsistent behavior,
- harder testing.

Prefer to move that logic into:

- Kits (`packages/kits/*`) for primitives.
- Engines (`packages/engines/*`) for larger capabilities.
- Agent definitions (`packages/agents/*`) for role-specific behavior.

---

### Mistake 3: Blurring TS ↔ Python boundaries

TypeScript and Python should talk via **contracts**, not import each other:

- TS code → `contracts/ts` clients → platform runtimes.
- Python code → `contracts/py` clients → platform runtimes.

If you catch yourself thinking:

- “Can I just import this TS Engine from Python?” or
- “Can I just shell out to this Python script from TS?”,

stop and consider whether it should instead be:

- a platform runtime endpoint defined in `contracts/`,
- used by both TS and Python.

---

## 6. Checklist before you open a PR

When you’re adding or moving code, ask:

1. **Is this code starting a process?**

   - If yes, is it in `apps/`, `/agents/`, or `platform/runtimes/*-runtime`?
2. **If it’s library logic, is it under `packages/` or `contracts/`?**
3. **Am I duplicating logic that should live in a Kit or Engine?**
4. **For agent-related stuff:**

   - Specs/definitions/governance/factories in `packages/agents`?
   - Long-running runtime in `/agents`?
5. **Am I respecting the TS/Python contract boundary?**

If the answer to any of those is “no” or “not sure”, that’s a good moment to pause and ask for a quick architectural review.
