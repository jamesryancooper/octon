---
title: ADR-00X: Introduce Engines and TS Agents Factories
description: ADR to introduce Engines and TS Agents Factories to the Harmony monorepo.
version: v1.0.0
date: 2025-11-21
---

# ADR-00X: Introduce Engines and TS Agents Factories

**Status**: Proposed / Accepted
**Date**: 2025-XX-XX
**Owner**: Architecture / Platform

---

## 1. Context

We started with a clean separation between:

- **Kits** under `packages/kits/*` – small, focused libraries providing specific capabilities (planning, flows, eval, policies, RAG, etc.).
- **Runtimes** under:
  - `apps/*` – user-facing apps/APIs.
  - `/agents/*` – Python agent runtimes (planner, builder, verifier, orchestrator, Kaizen, etc.).
  - `platform/runtimes/*-runtime/**` – shared platform runtimes (e.g., flow-runtime).

This worked well for simple use cases but exposed several issues as the system grew:

1. **Cross-kit orchestration duplication**

   Many agents and apps started to perform the same orchestration of kits:

   - Call PlanKit → EvalKit → PolicyKit → ObservaKit in slightly different ways.
   - Call IngestKit → IndexKit → QueryKit for RAG/context in multiple places.
   - Create patches/releases with PatchKit/ReleaseKit scattered across code.

   This led to:

   - Behavior drift across agents.
   - Harder testing and reasoning about “how planning really works” or “how we ship”.

2. **Governance scattered across call sites**

   Governance concerns—risk levels, budgets, policies, evals, observability—were often implemented:

   - Directly in agents.
   - Ad-hoc in apps.
   - Partially embedded in kits.

   There was no single “place” where:

   - Planning risk modes were defined.
   - RAG quality and safety checks were standardized.
   - Release decisions and evidence were consistently enforced.

3. **No central “capability surfaces”**

   We lacked named, reusable “subsystems” such as:

   - “Planning as a capability”
   - “Execution of plans”
   - “Context/RAG system”
   - “Governance system”
   - “Release system”
   - “Kaizen system”

   Instead, each agent pieced things together. This made it hard to:

   - Share capabilities across surfaces (console, APIs, Kaizen).
   - Communicate clearly about which parts of the system own what.

4. **TS agent definitions were not clearly separated**

   We had Python runtimes under `/agents`, but no clear TypeScript home for:

   - Agent specs (inputs, outputs, roles).
   - Agent definitions (which flows/engines/kits they use).
   - Agent-level governance (risk classes, budgets, eval hooks).
   - Reusable factories for apps/console to instantiate agents.

   Behavior was at risk of being implemented directly in apps or scattered between TS and Python.

---

## 2. Decision

We introduce two architectural elements:

1. **Engines under `packages/engines/*`**

   Engines are **import-only subsystems** built from Kits that own a **single domain capability end-to-end**. They:

   - Live under `packages/engines/<name>-engine/`.
   - Compose multiple Kits + policies + budgets + observability.
   - Expose a small, stable API (e.g. `generatePlan`, `executeStep`, `getContext`, `evaluate`, `prepareChange`).
   - Do **not** start processes or servers; they are libraries only.
   - Access platform runtimes only via `contracts/*` clients (often through Kits), never by importing runtime internals.

   Initial Engine catalog:

   - `plan-engine` – planning as a capability (goals/specs → governed plans).
   - `work-engine` – executing plan steps via flows/tools.
   - `context-engine` – context/RAG (ingest/index/query/context).
   - `governance-engine` – evals, policies, scoring, gating.
   - `release-engine` – patch/PR/release workflows.
   - `kaizen-engine` – autonomous Kaizen improvements.

2. **TypeScript Agents module with factories under `packages/agents/*`**

   We add a TS-level Agents package with a clear structure:

```text
packages/agents/
    src/
    specs/        # agent input/output contracts, roles, capabilities
    definitions/  # which engines/kits implement agent behavior
    governance/   # risk classes, budgets, policies, eval hooks
    factories/    # TS agent factories for apps/console/etc.
```

- **Specs** define agent contracts and roles.
- **Definitions** wire agent behavior in terms of Engines and Kits.
- **Governance** encodes risk profiles, budgets, and policies at the agent level.
- **Factories** provide convenient functions to build concrete agent instances for apps and tools.

Runtimes remain:

- `/agents/*` – Python agent processes (planner, builder, verifier, orchestrator, Kaizen, etc.).
- `platform/runtimes/*-runtime/**` – shared platform runtime services (e.g. flow-runtime).

These processes use generated clients from `contracts/*` and do not import Engines or Kits across the language boundary.

---

## 3. Rationale

### Why Kits weren’t enough

Kits are intentionally small and focused. They:

- Don’t know how they are composed with other Kits.
- Don’t own domain-level policies or budgets.
- Don’t define “this is how planning works in our system”.

This is good for reuse but:

- Leads to duplicated orchestration in multiple agents.
- Makes governance and observability scatter across agents and apps.
- Makes it harder to evolve domain behavior without touching many call sites.

### Why Engines

Engines give us:

- A named, central place per capability (Plan, Work, Context, Governance, Release, Kaizen).
- A natural layer to embed:

  - budgets,
  - risk modes,
  - policies,
  - evals,
  - observability.
- A stable API for agents and apps:

  - e.g. “ask PlanEngine for a plan” instead of re-building planning logic everywhere.

### How Engines support Harmony principles

Engines are explicitly designed to reinforce our core architecture principles:

- **Speed with safety**: Each domain (planning, RAG, release, Kaizen, etc.) has a single, governed Engine where we can evolve behavior quickly while centralizing risk modes, budgets, and eval hooks.
- **Simplicity over complexity**: Instead of every agent stitching together PlanKit + EvalKit + PolicyKit + ObservaKit differently, Engines provide a single, high-level capability surface (for example, `PlanEngine.generatePlan`) that agents and apps can reuse.
- **Quality through determinism**: Engines are the natural home for pinned model configs, prompt variants, and policy combinations, so the same call from different agents behaves consistently under the same configuration.
- **Guided agentic autonomy**: Engines are “boxes of autonomy” that can loop, refine, and self-evaluate internally, but always within the budgets, risk classes, and HITL gates defined in their policies.
- **Monolith-first, hexagonal boundaries**: Engines live in `packages/` and only talk to platform runtimes via Kits and `contracts/*` clients, which keeps the system modular and evolvable without introducing new distributed runtime boundaries.

This fits our hexagonal, monolith-first approach: Engines are just modules in `packages/`, not new services.

### Why `packages/agents` and factories

We need a TS-native home for agent definitions that:

- Is separate from runtime concerns.
- Lets apps/CIs/CLIs instantiate agents in a consistent way.
- Keeps agent behavior (specs/definitions/governance) close to Engines and Kits.

Factories under `packages/agents/src/factories` give apps a simple entrypoint:

- e.g. `createConsoleAssistant`, `createReleaseCopilot`, `createKaizenReviewer`.

This avoids deep wiring code inside `apps/*` and keeps “what an agent is” in a single place.

---

## 4. Consequences

### 4.1 Positive

1. **Centralized domain capabilities**

   - Planning, execution, RAG, governance, release, and Kaizen each have a well-defined Engine.
   - Behaviors like “how we plan” or “how we ship” are easier to locate and reason about.

2. **Consistent governance and observability**

   - Risk modes, budgets, policies, and evals live in Engines and agent governance modules.
   - Evidence (plans, diffs, eval results, context bundles) is attached consistently at Engine-level APIs.
   - Observability (traces, metrics, logs) can be standardized per Engine.

3. **Reduced duplication**

   - Kits are still the primitives, but Engines own common cross-kit orchestration.
   - Agents and apps call Engines instead of re-wiring Kits differently each time.

4. **Clear agent story**

   - TS Agents: defined in `packages/agents` as specs/definitions/governance/factories.
   - Python agent runtimes: `/agents/*` processes that orchestrate via contracts.
   - Apps: import factories from `packages/agents` rather than re-implementing agent logic.

5. **Better evolution and testing**

   - You can upgrade or refactor an Engine without touching every agent or app.
   - Engines can be unit/integration tested independently with mocked Kits and contracts.
   - New surfaces (apps, tools) can reuse existing Engines and Agents.

### 4.2 Negative / Trade-offs

1. **Additional abstraction layer**

   - We now have Kits → Engines → Agents → Runtimes.
   - This increases conceptual surface area and can feel heavy to newcomers.

2. **Learning curve and naming overhead**

   - New engineers must learn:

     - what belongs in Kits vs Engines vs Agents vs Runtimes,
     - where TS vs Python agents live,
     - how contracts fit into the picture.
   - Poor naming or scope creep can lead to “god Engines” or confusing boundaries.

3. **Discipline required**

   - Engineers must resist:

     - putting orchestration logic back into apps or runtimes,
     - bypassing Engines and re-implementing logic directly on top of Kits,
     - calling platform runtimes without going through Kits/Engines where appropriate.
   - Governance (risk, budgets, policies) must actually be wired into Engines and Agents, not left as TODOs.

---

## 5. Migration Plan

We will introduce Engines and TS Agents incrementally.

### Phase 1 – Scaffolding

- Create `packages/engines/` and `packages/agents/` with the agreed structure.
- Document:

  - Engines in `docs/architecture/engines.md`.
  - Agents & factories in `docs/architecture/agents-and-factories.md`.
  - Run vs import rule in `docs/architecture/run-vs-import.md`.

### Phase 2 – Implement core Engines

Start with Engines that immediately reduce duplication:

1. **PlanEngine**

   - Wrap existing PlanKit + PromptKit + EvalKit + PolicyKit + ObservaKit.
   - Introduce `generatePlan` and `refinePlan` as initial APIs.

2. **WorkEngine**

   - Wrap FlowKit + AgentKit + ToolKit + ObservaKit.
   - Introduce `executeStep` / `executePlan` APIs.

Optionally:

3. **ContextEngine**

   - Wrap IngestKit + IndexKit + QueryKit + SearchKit + PromptKit.

4. **GovernanceEngine**

   - Wrap EvalKit + PolicyKit + TestKit + DatasetKit.

5. **ReleaseEngine**

   - Wrap PatchKit + ReleaseKit + PolicyKit.

6. **KaizenEngine**

   - Orchestrate Kaizen workflows using the Engines above.

### Phase 3 – Introduce TS Agents and factories

- Create TS Agents for:

  - console assistant,
  - planner,
  - builder,
  - verifier,
  - Kaizen roles.
- For each:

  - Add spec, definition, governance, and factory.
  - Refactor existing TS-based orchestration into these modules.

### Phase 4 – Refactor apps to use factories

- Update `apps/*` to:

  - Import and use `packages/agents/src/factories/*`.
  - Remove ad-hoc orchestration logic that belongs in Agents/Engines.

### Phase 5 – Align Python agents gradually

- Ensure `/agents/*` use `contracts/py` clients that match the same flows/platform APIs cited by TS Engines.
- Optionally:

  - Bring their behavior conceptually in line with TS Engines/Kits, while respecting language boundaries.

---

## 6. Alternatives Considered

1. **“Just use Kits” (no Engines)**

   - Pros:

     - Less abstraction.
     - Fewer concepts to teach.
   - Cons:

     - Cross-kit orchestration and governance remain scattered.
     - Harder to evolve domain capabilities consistently.
     - Repetition of planning/RAG/release logic in many agents and apps.

2. **Turn every Engine into a separate microservice**

   - Pros:

     - Strong runtime isolation and scaling control per capability.
   - Cons:

     - Violates monolith-first, hexagonal spirit.
     - Dramatically increases operational overhead and latency.
     - Overkill for our current scale and evolution needs.

3. **Keep Agents only in Python**

   - Pros:

     - Single language for agents.
   - Cons:

     - TS apps would lack a first-class agent abstraction.
     - Tight coupling between Python runtimes and UI/API behavior.
     - Harder to share behavior across TS apps and Python agents.

Engines + TS Agents + factories within the monolith gives us **clarity and reuse** without exploding the number of services we operate.

---

## 7. Notes / Follow-ups

- **Engine catalog is not fixed**:

  - We can add/remove Engines as real needs appear.
  - Each Engine should have a clear responsibility and non-goals.

- **Documentation must stay in sync**:

  - Update the Engines guide and Agents & Factories guide as new Engines/Agents are introduced.
  - keep the “Run vs Import” guideline up to date if layout conventions change.

- **Review points**:

  - Periodically review Engines for scope creep (“god Engines”).
  - Periodically audit apps and agents to ensure they’re using Engines/Kits rather than bespoke orchestration.

This ADR should be the reference answer to: **“Why do Engines exist, and why do we have `packages/agents` with factories?”**.
