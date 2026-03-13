---
title: Agent Architecture
description: Target architecture, repo layout, and access patterns for Octon agents, aligned with the Octon Structural Paradigm and methodology.
---

# Agent Architecture (Target Model)

## Purpose and Scope

This document defines the **target architecture** for Octon agents—how they are **conceptualized**, **structured in the monorepo**, and **consumed** by apps, Kaizen flows, and other tooling.

It is intentionally **spec‑first and forward‑looking** and should be treated as **normative** over any older references to agents or runtimes in this folder. It aligns with:

- The **Octon Methodology** (Spec‑First, Trust through Governed Determinism, Agent-First System Governance).
- The **Octon Structural Paradigm (HSP)** and polyglot layout.
- The **Kaizen subsystem** and **runtime policy** documents.

This page does **not** prescribe implementation details of specific kits (PlanKit, FlowKit, AgentKit, etc.), but instead defines the **contracts and structure** that those kits and runtimes should adhere to.

## 1. Current Model (Summary and Critique)

### 1.1 Current Conceptual Model

- Agents are primarily defined as **Planner, Builder, and Verifier** roles in a **MAPE‑K loop**.
- The **control plane** is implemented in TypeScript kits under `packages/kits/*` (PlanKit, FlowKit, AgentKit, EvalKit, PolicyKit, TestKit).
- Python agent runtimes live under `agents/*`, and call the LangGraph-based implementation of the **platform flow runtime service** under `platform/runtimes/flow-runtime/**`. Agents treat this runtime as a shared platform service they call via contracts and generated clients; they do not embed or own the runtime itself. See `runtime-architecture.md` for the canonical runtime model.
- The **Kaizen subsystem** defines an agentic improvement loop that:
  - Observes the repo and signals (CI, observability, contracts, flags).
  - Uses Planner/Builder/Verifier style behavior to open **dry‑run Kaizen PRs**.
  - Enforces **fail‑closed** and **ACP** governance.
- Tooling integration docs position agents as consumers and producers in the **Knowledge Plane**, CI, and feature flag control plane.

### 1.2 Alignment with Octon Methodology

Strengths:

- **Spec‑first and contract‑first**: agents are described in terms of contracts, roles, and provenance.
- **Agent-First System Governance**: agents are explicitly governed by risk rubrics, ACP gates, and fail‑closed defaults.
- **Monolith‑first and hexagonal**: agents sit on top of a modular monolith with clear planes (apps, agents, packages, contracts, platform).
- **Kaizen layer**: a cross‑cutting, evidence‑driven layer for continuous improvement is already modeled.

Tensions and gaps:

- **Diffuse definition of where agents live**:
  - Roles are documented and runtimes are mentioned, but there is **no single, normative “agent home”** for:
    - Agent **specs** (inputs/outputs, capabilities, SLAs).
    - Agent **definitions** (plans, flows, prompt manifests).
    - Agent‑level **policies, evals, and observability hooks**.
- **Runtime‑centric framing**:
  - Current docs lean heavily on the **LangGraph runtime** and Python hosts as the “place where agents are implemented”.
  - This risks coupling “agent” to a specific runtime rather than to **specs + contracts + kits** that are **runtime‑agnostic**.
- **Kaizen vs non‑Kaizen agents blurred**:
  - Kaizen agents (maintenance, hygiene, PR‑opening bots) and **product‑facing agents** (e.g., console assistants, API‑backed agents) are not clearly distinguished in terms of:
    - Repo placement.
    - Promotion lifecycle.
    - Ownership and governance.
- **No stable TS‑level agents package**:
  - Consumers in `apps/*`, CI, or tooling must know which kits and prompts to compose.
  - There is **no single `packages/agents` (or similar)** exporting stable, typed agent interfaces and factories.
- **Policies and evals scattered**:
  - PolicyKit/EvalKit/TestKit are documented, but there is no **agent‑scoped home** for:
    - Policy bundles (which policies apply to which agents).
    - Eval suites (what “good” looks like for a given agent).
    - Observability baselines (what each agent must emit).

These gaps do not contradict Octon Methodology, but they **increase cognitive load** and make it harder to:

- Add new agents consistently.
- Share agents across surfaces (Next.js apps, CLIs, maintenance flows).
- Evolve runtimes without breaking contracts.

The remainder of this document defines a **target agent architecture** that resolves these gaps while staying true to Octon’s pillars.

## 2. Target Agent Model (Conceptual)

### 2.1 What Is an Agent in Octon

An **agent** is a **spec‑first, governed, long‑lived capability** that:

- Accepts well‑typed **inputs** and produces well‑typed **outputs**.
- **Plans and orchestrates work** using one or more kits (PlanKit, FlowKit, AgentKit, ToolKit).
- Operates inside a **deterministic loop** (Plan → Diff → Explain → Test) with:
  - Pinned model/provider/params.
  - Observability (traces/logs/metrics).
  - Policy/eval gates (PolicyKit/EvalKit/TestKit).
- Is **invoked** by surfaces (Next.js apps, APIs, CLIs, Kaizen workflows, schedules) via **stable TypeScript interfaces**.
- May use **Python flows** and runtimes as implementation details behind contracts, but **never exposes raw runtimes** as its public interface.

Key invariants:

- **Spec‑first**: every agent has a canonical spec describing purpose, inputs/outputs, quality attributes, and risk class.
- **Contract‑first**: agents expose **TypeScript types and JSON Schemas** for inputs/outputs; if they are called via HTTP, they are additionally modeled in OpenAPI.
- **Deterministic by default**: pinned models/config, low temperature, and golden tests for critical behaviors.
- **Governed**: policies and evals are **bound to agents by name and version**.
- **Runtime‑agnostic public surface**: TypeScript callers do not care whether an agent uses only TypeScript flows or Python LangGraph flows internally.

### 2.2 Agent Building Blocks

Each agent is composed of four primary building blocks:

- **Agent Spec** — declarative definition of:
  - Inputs/outputs (types, JSON Schema).
  - Responsibilities and constraints.
  - Risk class, ACP requirements, and observability expectations.
- **Agent Definition** — configuration that binds:
  - Prompts (PromptKit manifests).
  - Plans and flows (PlanKit/FlowKit configurations).
  - Tools and domain use‑cases (ports/adapters) it is allowed to call.
- **Agent Implementation** — runtime wiring:
  - Factories in TypeScript (for example, in `packages/agents`) that create running agent instances bound to a given runtime and kit configuration.
  - Optional Python flows under `agents/*` or the platform flow runtime service (currently implemented as a LangGraph-based runtime under `platform/runtimes/flow-runtime/**`) when long‑lived or stateful flows are needed. These flows are executed by the platform runtime; agents and kits access them via the runtime’s contract‑first APIs rather than importing runtime internals directly.
- **Agent Governance Bundle** — cross‑cutting controls:
  - Policies (PolicyKit) attached to the agent’s actions.
  - Evals (EvalKit/TestKit scenarios) attached to its behavior.
  - Observability profile (required spans/metrics/logging).

### 2.3 Harness Interpretation as a Complementary Runtime

This architecture document defines how product and platform agents are designed, packaged, and consumed in the runtime plane. Octon now also treats the `.octon/` harness itself as an **agent-interpreted runtime surface** under the agent-as-runtime model.

The two models are complementary, not competing:

- **This document (agent architecture):**
  - Defines long-lived agent capabilities, runtime wiring, governance bundles, and consumer-facing interfaces.
  - Focuses on reusable product and Kaizen agents exposed through `packages/agents` and runtime services.
- **Agent-as-runtime model (`agent-as-runtime.md`):**
  - Defines how declarative harness content (schemas, rules, fixtures, conventions) is interpreted for governance and validation.
  - Focuses on portable harness execution semantics with deterministic Tier 1 validation and fixture-calibrated Tier 2 evaluation.

Boundary clarification:

- Harness interpretation does not replace platform runtime services in `platform/runtimes/**`.
- Platform runtime execution does not replace harness contract interpretation responsibilities.

Shared invariants across both models:

- Contract-first interfaces.
- Fail-closed governance.
- Provenance and observability evidence.
- Risk-tiered ACP controls.

For harness-specific semantics, caveats, and controls, treat these as normative companions to this document:

- `.octon/cognition/_meta/architecture/agent-as-runtime.md`
- `.octon/cognition/_meta/architecture/agent-runtime-caveats.md`

## 3. Target Repo Structure for Agents

### 3.1 High‑Level Layout

Agents are centered in a dedicated **TypeScript package** that exposes stable contracts and factories, with clear homes for Kaizen vs production agents:

plaintext (illustrative)
/packages/
  agents/
    src/
      index.ts
      specs/
      definitions/
      runtime/
      governance/
        policies/
        evals/
        observability/
    package.json

/kaizen/
  agents/
  evaluators/
  policies/
  reports/

/agents/
  runner/
    runtime/
  maintenance/

Key rules:

- `packages/agents` is the **canonical entrypoint** for **all production‑grade, reusable agents**.
- `kaizen/agents` contains Kaizen‑specific planners/builders/verifiers that open PRs and operate under the Kaizen subsystem.
- `agents/*` remains the place for **Python runtimes and LangGraph flows**, treated as **implementation details** behind contracts exported from `packages/agents`.

### 3.2 Inside `packages/agents`

Within `packages/agents`:

plaintext (illustrative)
/packages/agents/src/
  index.ts                 # public exports (stable interfaces + factories)
  agent.types.ts           # shared types (AgentId, AgentVersion, etc.)
  specs/
    console-assistant/
      spec.json            # JSON Schema for inputs/outputs
      spec.md              # human-readable spec
    maint-dependency-bump/
      spec.json
  definitions/
    console-assistant/
      plan.json            # PlanKit plan template
      flows.json           # FlowKit wiring
      prompts.yaml         # PromptKit manifest references
    maint-dependency-bump/
      ...
  runtime/
    console-assistant.ts   # TypeScript factory that binds kits and runtime
    maint-dependency-bump.ts
    python/
      console-assistant-lifecycle.ts  # TS client to Python flow (via contracts/ts)
  governance/
    console-assistant/
      policies.yaml
      evals.yaml
      observability.yaml
    maint-dependency-bump/
      policies.yaml
      evals.yaml
      observability.yaml

This layout keeps:

- **Specs and definitions** separate from **runtime wiring**.
- **Public contracts** (types and factory functions, via `index.ts`) separate from **internal details**.
- **Governance configuration** co‑located with the agent rather than scattered across the repo.

## 4. Access Patterns and Boundaries

### 4.1 How Apps and Tools Invoke Agents

All consumers (Next.js apps, APIs, CLIs, Kaizen workflows, background jobs) should depend on **stable TypeScript interfaces** exported from `packages/agents`.

At a high level:

- `packages/agents/src/index.ts` exports:
  - **Agent identifiers** (for example, `AGENT_ID_CONSOLE_ASSISTANT`).
  - **TypeScript types** for each agent’s input and output.
  - **Factory functions** that bind an agent to a runtime and environment (for example, `createConsoleAssistantAgent(config)`).
- Apps under `apps/*`:
  - Import types and factories from `packages/agents`.
  - Pass in environment‑specific configuration (secrets, URLs, flags) at the edge of the system.
  - Do **not** reach into `agents/*` or `packages/kits/*` directly for agent behavior.
- Kaizen workflows under `kaizen/*`:
  - May either:
    - Use Kaizen‑specific agents exposed from `packages/agents` (for shared maintenance flows), or
    - Use dedicated Kaizen agents under `kaizen/agents` when they are not intended for reuse beyond Kaizen.

Boundary rules:

- UI and API surfaces **never call Python runtimes directly**; they call TypeScript factories from `packages/agents`.
- Only the `packages/agents` runtime layer knows whether a given agent uses:
  - TypeScript‑only flows, or
  - Python flows behind the contracts in `contracts/*`.

### 4.2 Domain and Infrastructure Boundaries

To preserve **Hexagonal Architecture** and **monolith‑first** principles:

- Agents call **domain use‑cases** and **infrastructure adapters** through:
  - Domain services in `packages/domain`.
  - Adapters in `packages/adapters`.
- Agents **do not** embed business rules or persistence logic directly; they orchestrate:
  - Plans and flows.
  - Calls to domain services (ports) via adapters.
  - LLM calls, tools, and external APIs via kits.

This ensures that:

- Business rules remain testable outside of agents.
- Agents can be replaced or upgraded without rewriting domain logic.

## 5. Kaizen vs Production Agents

### 5.1 Kaizen Agents (`kaizen/agents`)

Kaizen agents are **maintenance and hygiene agents** that:

- Run under **Kaizen workflows** (scheduled or event‑driven).
- Operate on **docs, tests, observability, contracts, and flags**.
- Open **dry‑run PRs** with evidence, never merging on their own.

Placement and rules:

- Live under `kaizen/agents` with:
  - Small, focused planners that produce Kaizen plans.
  - Builders that synthesize diffs and open PRs.
  - Verifiers that orchestrate validation for Kaizen PRs.
- Use the same **Agent Spec / Definition / Implementation / Governance** model, but:
  - Are **scoped** to Kaizen use‑cases.
  - Are allowed to be more experimental.
  - May be promoted into `packages/agents` when they become stable, reusable maintenance agents.

### 5.2 Production Agents (`packages/agents`)

Production agents:

- Serve **end‑user or internal product flows** (for example, AI console assistants, API helpers, RAG agents).
- Have **versioned specs** and **clear owners**.
- Must:
  - Satisfy Octon’s **System Guarantees** (determinism, observability, rollback).
  - Have **associated policies and evals**.
  - Be callable from any surface via `packages/agents`.

Promotion path from Kaizen to production:

- Start as experimental Kaizen agents under `kaizen/agents` or as local experiments.
- Once stable and clearly reusable:
  - Move spec/definition/runtime/governance into `packages/agents`.
  - Assign an **AgentId** and **version**.
  - Add minimal **eval coverage** and **policy bindings**.
  - Update docs in this file to include the new agent.

## 6. Policies, Evals, and Observability

### 6.1 Policy Binding (PolicyKit)

- Each agent has an **agent‑scoped policy bundle** under `packages/agents/src/governance/<agent>/policies.yaml`.
- Policy bundles:
  - Reference shared policies (for example, “no secrets”, “pinned models”, “DoSafe/DoSm”).
  - Declare **risk class** and **gate requirements** (for example, eval suites that must pass before promotion).
- PolicyKit:
  - Evaluates policy bundles during:
    - Plan generation.
    - Pre‑merge verification.
    - Runtime operation when applicable.

### 6.2 Eval Binding (EvalKit/TestKit)

- Each agent has:
  - **Golden tests** for deterministic behaviors.
  - **Eval suites** for qualitative measures (for example, hallucination, grounding, style).
- Eval definitions live under `packages/agents/src/governance/<agent>/evals.*` and:
  - Reference reusable datasets (DatasetKit).
  - Are invoked:
    - In CI for PRs that touch the agent.
    - Periodically in Kaizen runs for regression monitoring.

### 6.3 Observability (ObservaKit and OTel)

- Each agent publishes an **observability profile** under `packages/agents/src/governance/<agent>/observability.*` describing:
  - Required spans and metrics.
  - How to correlate runs with PRs and deployments.
- Agent runtimes:
  - Emit OTel spans/logs/metrics with:
    - `agent.id`, `agent.version`, and `agent.run_id`.
    - `trace_id` correlated with CI and PRs via the Knowledge Plane.

## 7. How to Add a New Agent (Checklist)

This checklist is the **single source of truth** for adding a new agent under the target architecture. It assumes you are working in the Turborepo monolith, with Next.js, Astro, TypeScript, and Python runtimes available.

1. **Write the Agent Spec**
   - Create `packages/agents/src/specs/<agent-id>/spec.md` and (optionally) `spec.json`:
     - Define purpose, inputs/outputs, quality attributes, risk class, ACP gates, and surfaces that will call this agent.
     - Align with Octon’s **Spec‑First** and **Agent-First System Governance** pillars.
2. **Define Contracts**
   - Add TypeScript types for input/output to `packages/agents/src/agent.types.ts` (or a dedicated types file).
   - If the agent is also exposed via HTTP:
     - Extend `contracts/openapi` and `contracts/schemas` as needed.
     - Regenerate TS/Py clients via `gen:contracts`.
3. **Design Plans, Flows, and Prompts**
   - Under `packages/agents/src/definitions/<agent-id>/`:
     - Add PlanKit plan templates (for example, `plan.json`).
     - Add FlowKit flow definitions (for example, `flows.json`).
     - Reference PromptKit manifests (for example, `prompts.yaml` pointing to `packages/prompts` entries).
   - Ensure flows call only:
     - Domain services in `packages/domain`.
     - Adapters in `packages/adapters`.
4. **Implement the Agent Runtime**
   - Under `packages/agents/src/runtime/`:
     - Add `<agent-id>.ts` with a factory function that:
       - Accepts a runtime configuration (LLM client, flags, environment).
       - Binds PlanKit, FlowKit, AgentKit, and tools.
       - Optionally calls Python flows via `contracts/ts` clients if stateful or long‑running behavior is needed.
   - Export the factory and types from `packages/agents/src/index.ts`.
5. **Attach Governance (Policies, Evals, Observability)**
   - Under `packages/agents/src/governance/<agent-id>/`:
     - Define `policies.*` with:
       - Risk class.
       - Required checks (tests, evals, observability).
     - Define `evals.*` with:
       - Golden tests and evaluation suites (EvalKit/TestKit).
     - Define `observability.*` with:
       - Required spans/metrics/logging and example trace annotations.
6. **Wire to Surfaces**
   - In each consumer (for example, `apps/ai-console`, `apps/api`):
     - Import the agent factory and types from `packages/agents`.
     - Create thin handlers/controllers that:
       - Construct the agent instance with environment configuration.
       - Invoke the agent with validated input and return output.
7. **Add Tests and Eval Hooks**
   - Add unit and integration tests:
     - For the agent factory and orchestration logic.
     - For domain use‑cases it calls (if not already covered).
   - Add CI wiring so:
     - Tests and evals run when the agent or its dependencies change.
8. **Document and Register**
   - Update:
     - `agent-architecture.md` (this file) with a short entry for the new agent (purpose, inputs/outputs, surfaces, owners).
     - Any relevant architecture docs (for example, feature‑specific pages).
   - Add ownership entries in `CODEOWNERS` for:
     - `packages/agents/src/specs/<agent-id>/**`
     - `packages/agents/src/runtime/<agent-id>.ts`
9. **Promote from Kaizen (Optional)**
   - When promoting a Kaizen agent:
     - Move its spec/definitions/runtime/governance into `packages/agents`.
     - Tighten policies and evals to match production expectations.
     - Update Kaizen docs to reference the shared agent rather than duplicating logic.

By following this structure, Octon agents remain **spec‑first, deterministic, observable, testable, and reversible**, while staying decoupled from specific runtimes and easy to consume across any surface in the monorepo.
