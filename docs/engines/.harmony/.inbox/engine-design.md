---
title: Engines Design Guide
description: Guide to the Harmony engines system.
version: v1.0.0
date: 2025-11-21
---

# Engines Design Guide

Engines are a core abstraction in this system. They sit between **Kits** and **Agents**, and give us a clean way to package up powerful, governed capabilities as reusable subsystems.

This guide explains:

- What an Engine is (and isn’t)
- When to create an Engine vs a Kit vs an Agent
- The current Engine catalog
- Design principles for Engines
- How to add a new Engine safely

---

## 1. What is an Engine

**Short definition:**

> An **Engine** is an import-only subsystem under `packages/engines/*` that **composes multiple Kits plus policies, budgets, and observability** to own a **single domain capability end-to-end** (e.g. planning, execution, RAG, governance, release, Kaizen).

More concretely:

- Engines:

  - Live under `packages/engines/*`.
  - Are **not** runtime roots (no processes, servers, or CLIs).
  - Are called by:

    - TS agents (`packages/agents` via `factories/`),
    - occasionally `apps/*` for very simple cases.

- Engines **wrap Kits**:

  - Kits provide low-level operations (PlanKit, FlowKit, EvalKit, PolicyKit, etc.).
  - Engines orchestrate those operations into a coherent capability.

- Engines **are not Agents**:

  - Agents are about **goals, roles, personas, UX, and conversations**.
  - Engines are about **“do X reliably and safely”** for a given domain.

Call stack (TS side) looks like:

> `apps/*` → `packages/agents/factories` → **Engines** → Kits → `contracts/ts` → platform runtimes

### 1.1 How Engines are invoked

Engines are designed to be reused across the system in a few common modes:

- **Direct calls from TS Agents**  
  Agents constructed via `packages/agents/src/factories/*` call Engines directly, for example `PlanEngine.generatePlan`, `WorkEngine.executePlan`, `ContextEngine.getContext`, `GovernanceEngine.evaluate`, and `ReleaseEngine.prepareChange`.

- **As logical steps inside flows**  
  Flow graphs executed by the flow runtime can call Engines (via Kits and adapters) as part of their nodes, instead of re-implementing cross-Kit orchestration inside each flow.

- **Scheduled / Kaizen tasks**  
  Kaizen entrypoints (TS apps or Python `/agents/kaizen`) call `KaizenEngine`, which in turn orchestrates other Engines (Plan, Work, Context, Governance, Release) on a schedule or in response to system health signals.

- **Event-driven reactions**  
  Event handlers can call Engines in response to platform events (for example, deployment completed, error budget breached, data drift detected), while still honoring the same risk modes, budgets, and policies as interactive agents.

In all of these cases, Engines remain **import-only** modules in `packages/engines/*`: they are never runtime roots, and they reach platform runtimes only via Kits and `contracts/*` clients.

---

## 2. When to use Kits vs Engines vs Agents vs Runtimes

Use this table as a quick decision guide:

| You’re building…                                                   | Use…        | Lives in…                                                                                 |
| ------------------------------------------------------------------ | ----------- | ----------------------------------------------------------------------------------------- |
| A focused operation (e.g. “generate plan skeleton”, “score reply”) | **Kit**     | `packages/kits/*`                                                                         |
| A domain subsystem (“planning”, “RAG”, “release”) that:            | **Engine**  | `packages/engines/*`                                                                      |
| - orchestrates multiple kits, and                                  |             |                                                                                           |
| - embeds budgets/policies/evals/telemetry                          |             |                                                                                           |
| A goal/role-focused “brain” (console assistant, planner, etc.)     | **Agent**   | TS: `packages/agents/*` (specs/defs/governance/factories) / Python: `/agents/*` (runtime) |
| A process you deploy (web app, API, worker, flow runtime)          | **Runtime** | `apps/*`, `/agents/*`, `platform/runtimes/*-runtime/**`                                   |

**Create an Engine when:**

- Multiple agents or surfaces repeatedly do the **same orchestration** of kits.
- You want one place to define:

  - policies, budgets, and risk behavior for a domain,
  - common observability and evidence.
- The capability is big enough to feel like “its own product” (planning, RAG, release, Kaizen, etc.).

**Don’t create an Engine when:**

- It’s just a couple of Kit calls that only one agent uses.
- The behavior is truly local to one app/agent and unlikely to be reused.

---

## 3. Engine Catalog

The initial set of Engines we recognize:

| Engine               | Responsibility (capability)                                | Main Callers (TS)                                    | Key Kits it Composes (examples)                                                                 |
| -------------------- | ---------------------------------------------------------- | ---------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| **PlanEngine**       | Goals/specs → governed, high-quality plans                 | Planner agents, console/orchestrator, Kaizen planner | PlanKit, PromptKit, EvalKit, PolicyKit, ObservaKit, CacheKit                                    |
| **WorkEngine**       | Execute plan steps safely via flows/tools                  | Builder agents, console agents, Kaizen builder       | FlowKit, AgentKit, ToolKit, PromptKit, PolicyKit, ObservaKit, CacheKit                          |
| **ContextEngine**    | Ingestion, indexing, query, and prompt-ready context (RAG) | Planner/builder/verifier agents, console agents      | IngestKit, IndexKit, QueryKit, SearchKit, PromptKit, EvalKit, ObservaKit                        |
| **GovernanceEngine** | Evals, policies, scoring & gating                          | Verifier agents, Kaizen verifier, CI/checks          | EvalKit, PolicyKit, TestKit, DatasetKit, ObservaKit                                             |
| **ReleaseEngine**    | Patch/PR creation, previews, promotion & release workflows | Builder/verifier agents, Kaizen agents, CI           | PatchKit, ReleaseKit, PolicyKit, TestKit, ObservaKit                                            |
| **KaizenEngine**     | Autonomous improvements across the system                  | Kaizen planner/builder/verifier agents               | PlanKit, FlowKit, AgentKit, EvalKit, PolicyKit, PatchKit, TestKit, ObservaKit (+ other Engines) |

You do **not** need all of these on day one. Engines can be introduced **incrementally** where duplication and governance needs are obvious (PlanEngine and WorkEngine are good first candidates).

---

## 4. Design principles for Engines

Engines should make the system **simpler to use and safer to change**, not more complex. Use these principles:

### 4.1 Single domain responsibility

Each Engine should:

- Own a **single domain capability** (planning, execution, context, governance, release, Kaizen).
- Provide a **small, coherent API** for that capability.

Bad:

- `EverythingEngine` that plans, executes, does RAG, and ships.

Good:

- `PlanEngine.generatePlan`
- `PlanEngine.refinePlan`
- `PlanEngine.summarizePlanHistory`

### 4.2 Explicit boundaries & dependencies

Engines:

- Depend on Kits and **generated clients from `contracts/ts`**.
- **Never** import runtime internals (`platform/runtimes/*-runtime` code).
- Expose a well-typed public surface via `index.ts`.

If an Engine needs to talk to the flow runtime, it should do so through:

- FlowKit + `contracts/ts` clients,
- not by importing LangGraph or Python code.

### 4.3 Budgets, risk, and policies built-in

Every Engine should:

- Accept **risk mode / profile** as part of its inputs (e.g., `risk: "low" | "medium" | "high"`).
- Apply:

  - call budgets,
  - token/time limits,
  - allowed actions by risk class.

This is where **PolicyKit** and related governance logic should live, not scattered across agents.

### 4.4 Observability & evidence by default

Every Engine call should:

- Take or create a **run ID / trace context**.
- Emit:

  - structured logs,
  - traces/spans,
  - metrics.
- Attach **evidence objects/artifacts** where appropriate (plans, diffs, eval results, context bundles, etc.).

Engine APIs should make it easy to get the evidence a verifier or human needs.

### 4.5 Determinism where it matters

Engines should aim for **deterministic behavior** under the same inputs and configuration:

- Use **pinned models and parameters** via Kits.
- Prefer clearly named **modes** over free-form options, e.g.:

  - `mode: "fast"` (low cost, good-enough),
  - `mode: "deep"` (more cost, higher quality).
- Keep randomness and sampling under control unless explicitly required.

### 4.6 Composable but not tangled

Engines **can** call other Engines if needed, but:

- The dependency graph should be **mostly acyclic**, or at least clearly layered:

  - KaizenEngine may call PlanEngine + WorkEngine + GovernanceEngine + ReleaseEngine.
  - PlanEngine should not depend on KaizenEngine.

Avoid circular dependencies and “god engines”.

### 4.7 Common anti-patterns

- **Renaming a Kit to an Engine without changing its role**  
  If a module is still “just a library of pure functions” that does not embed budgets, policies, evals, and observability, it should remain a Kit. Introduce an Engine only when there is real cross-Kit orchestration plus shared governance that multiple agents or surfaces will reuse.

- **“Mini-monolith” Engines**  
  An Engine that tries to handle planning, execution, RAG, governance, and release at once is a smell. Engines should have a narrow, named domain (for example, `PlanEngine`, `ContextEngine`, `ReleaseEngine`) and collaborate via their public APIs instead of becoming a kitchen-sink subsystem.

---

## 5. Engine anatomy (folder structure & API)

A typical Engine looks like:

```text
packages/engines/plan-engine/
  src/
    index.ts           # Public API: types + exported functions
    core.ts            # Main orchestration logic
    policy.ts          # Risk modes, budgets, allowed actions
    observability.ts   # Tracing, logging, metrics helpers
    types.ts           # Internal types/interfaces
  tests/
    plan-engine.spec.ts
```

### 5.1 `index.ts`

- Exposes the **public API**:

  - Types/interfaces for inputs/outputs.
  - Factory function(s) if needed.
  - Core operations (`generatePlan`, `refinePlan`, etc.).
- Keeps imports relatively clean; internal wiring stays in `core.ts` etc.

### 5.2 `core.ts`

- Orchestrates Kits and other Engines:

  - Builds prompts via PromptKit.
  - Calls PlanKit/EvalKit/PolicyKit.
  - Calls platform runtimes via Kits + `contracts/ts`.
- Implements the actual logic of the Engine.

### 5.3 `policy.ts`

- Encodes:

  - risk modes,
  - budgets,
  - which actions are allowed at which risk level.
- Should be relatively declarative and easy to inspect/change.

### 5.4 `observability.ts`

- Helper functions for:

  - Opening/closing spans.
  - Consistent logging structure.
  - Emitting metrics.
- Optionally helpers for collecting/store evidence artifacts.

### 5.5 `types.ts`

- Shared internal types:

  - Engine-level input/output payloads.
  - Internal representations (e.g. `PlanEngineContext`, `PlanEvaluationResult`).

---

## 6. Do’s and Don’ts

### Do

- ✅ **Do** give each Engine a crisp, domain-specific name and scope.
- ✅ **Do** embed governance (risk, budgets, policies, evals) in Engines.
- ✅ **Do** use Kits as the primary building blocks inside Engines.
- ✅ **Do** keep public APIs small, consistent, and well-typed.
- ✅ **Do** make Engines easy to observe and debug.

### Don’t

- ❌ **Don’t** create Engines just to wrap a single Kit method.
- ❌ **Don’t** let Engines become “fat services” that know about everything.
- ❌ **Don’t** import runtime internals (`platform/runtimes/*-runtime`) from Engines.
- ❌ **Don’t** bypass Kits and talk directly to external systems inside Engines (unless the Kit layer is truly missing and you plan to add it).
- ❌ **Don’t** have circular Engine dependencies.

---

## 7. How to add a new Engine

Use this checklist when adding an Engine.

1. **Validate the need**

   - Are multiple agents/apps doing the same complex orchestration?
   - Does this domain need shared policies, budgets, and observability?
   - Is it likely to be used across slices and surfaces?

2. **Define scope & responsibilities**

   - Write 2–3 sentences:

     - “`XEngine` is responsible for **Y**, and **not** responsible for Z.”
   - Identify:

     - Inputs/outputs.
     - Callers (which agents/surfaces).

3. **Identify backing Kits and other Engines**

   - List which Kits you’ll use (PlanKit, FlowKit, etc.).
   - Decide if you need to call any existing Engines (and ensure no cycles).

4. **Design the public API**

   - Start with 1–3 functions, e.g.:

     - `generatePlan`, `executeStep`, `getContext`, `evaluate`, `prepareChange`.
   - Define TypeScript types for inputs/outputs.
   - Ensure you can pass:

     - risk mode,
     - trace/run IDs,
     - optional configuration.

5. **Create the folder skeleton**

   ```text
   packages/engines/x-engine/
     src/
       index.ts
       core.ts
       policy.ts
       observability.ts
       types.ts
     tests/
       x-engine.spec.ts
   ```

6. **Wire Kits and contracts**

   - Use the relevant Kits to:

     - call models,
     - call flows via FlowKit + `contracts/ts`,
     - run evals, apply policies.
   - Avoid direct runtime imports.

7. **Add observability**

   - Ensure each public function:

     - opens a span,
     - logs key decisions,
     - returns or records evidence.

8. **Integrate with Agents**

   - Update `packages/agents`:

     - `specs` – define/update agent capabilities that use the Engine.
     - `definitions` – call the Engine instead of raw Kit calls.
     - `governance` – point agent governance to appropriate Engine modes.
     - `factories` – wire the Engine into the concrete agent factories.

9. **Document briefly**

   - Add a short entry for the Engine in the Engines section of the Architecture docs.
   - Note:

     - what it owns,
     - who calls it,
     - which Kits it depends on.

---

## 8. Example: PlanEngine at a glance

A very simplified sketch of what `PlanEngine` might look like:

```ts
// packages/engines/plan-engine/src/index.ts
import { generatePlanCore } from "./core";
import { PlanEngineInput, PlanEngineOutput } from "./types";

export async function generatePlan(
  input: PlanEngineInput
): Promise<PlanEngineOutput> {
  return generatePlanCore(input);
}
```

```ts
// packages/engines/plan-engine/src/core.ts
import { withPlanEngineSpan } from "./observability";
import { applyPlanPolicies } from "./policy";
import { callPlanKit } from "./plan-kit-adapter";
import { runPlanEvals } from "./eval-adapter";

export async function generatePlanCore(input: PlanEngineInput) {
  return withPlanEngineSpan("generatePlan", input, async (span) => {
    const policyContext = applyPlanPolicies(input);
    const planDraft = await callPlanKit(policyContext);
    const evalResults = await runPlanEvals(planDraft, policyContext);

    // decide if plan is acceptable, or needs refinement / rejection
    // possibly loop with PlanKit if necessary, within budgets

    return {
      plan: planDraft,
      evalResults,
      policyContext,
      runId: span.runId,
      evidence: { /* ... */ },
    };
  });
}
```

The Agents using this Engine never need to know:

- which models or prompts PlanKit uses,
- how evals and policies are combined,
- or how evidence is recorded.

They just call `PlanEngine.generatePlan(...)` with clear inputs and handle the result.

---
