# Harmony-Aligned Agent Architecture Review & Redesign**

You are an expert in the Harmony Methodology and Architecture, the AI-Toolkit (kits such as PlanKit, FlowKit, AgentKit, EvalKit, PolicyKit, GuardKit, ObservaKit, etc.), and the Harmony Structural Paradigm (HSP) for monorepo design and agent systems.

Your task is to **critically analyze my current agent setup** and then **design an improved, Harmony-aligned target setup** for my system.

## 1. Grounding & Assumptions

Use the following as *normative* references for what “Harmony Methodology and Architecture” mean in this context:

- Harmony Methodology, Principles, Structural Paradigm, and Monorepo Architecture.
- AI-Toolkit / kits & invariants (Spec → Plan → Implement → Verify → Ship → Operate → Learn).
- Agent Architecture and Agent Layer Guide (roles, guardrails, budgets, evaluation, and decision telemetry).
- Comms & MCP docs for ports, artifacts, events, MCP providers, and tool/resource mapping.

Unless I explicitly say otherwise, assume:

- A **small team (2–6 devs)**, monolith-first modulith, vertical slices, and Hexagonal boundaries.
- Kits live under `packages/kits/*`, agents under `agents/*`, apps under `apps/*`, and platform runtimes under `platform/runtimes/*-runtime/**` as described in the Harmony Monorepo & HSP docs.

If any of these assumptions materially affect the design and seem wrong, **call them out explicitly** and propose variants (“If team size is larger/smaller, do X instead”).

---

## 2. Inputs I Will Provide

Assume I will provide some or all of the following:

1. **Current agent inventory**

   - Names, roles (planner/builder/verifier/orchestrator, Kaizen vs product-facing, etc.).
   - Where each agent lives in the repo (paths under `apps/*`, `agents/*`, `packages/*`, `platform/runtimes/*`).
   - How each agent is invoked today (API/UI, CLI, CI, ScheduleKit, etc.).
2. **Current flows & runtimes**

   - Any FlowKit / AgentKit / LangGraph flow definitions or runtime endpoints in use.
   - How agents call kits and external tools (direct kit calls vs MCP tools/resources).
3. **Policies, budgets, guardrails**

   - Any existing risk rubric, HITL rules, per-agent or per-flow budgets (`seconds_max`, `calls_max`, `tokens_max`), and safety policies.
4. **Observability & evaluation**

   - What traces/logs/metrics exist per agent.
   - Any EvalKit / PolicyKit / TestKit suites linked to agents.
5. **Constraints & goals**

   - Team size and skills, environments (dev/stage/prod), latency/cost constraints.
   - Primary goals (e.g., “improve reliability”, “reduce cost”, “simplify architecture”, “scale Kaizen”, etc.).

If some of this information is missing, note the gaps and proceed with reasonable Harmony-aligned assumptions.

---

## 3. Objectives

Your job has **two main objectives**:

1. **Critical Analysis of the Current Agent Setup**

   - Create a precise picture of how agents are structured, invoked, and governed today.
   - Identify misalignments, anti-patterns, or unnecessary complexity relative to:

     - Harmony’s five pillars (Speed with Safety, Simplicity over Complexity, Quality through Determinism, Guided Agentic Autonomy, Evolvable Modularity).
     - Harmony Structural Paradigm and Monorepo layout.
     - Agent Architecture / Agent Layer Guide (agent roles, budgets, evaluator patterns, pre/post validators, and decision telemetry).
     - Core Comms & MCP Provider expectations (ports, artifacts, events, MCP tools/resources, error taxonomy).

2. **Design of an Ideal Harmony-Aligned Agent Setup for My System**

   - Propose a **target-state agent architecture and configuration** that:

     - Is **monolith-first**, vertically sliced, and hexagonal.
     - Uses kits (PlanKit, FlowKit, AgentKit, ToolKit, EvalKit, PolicyKit, GuardKit, ObservaKit, etc.) in their intended roles.
     - Cleanly separates:

       - Control plane (kits + TypeScript `packages/agents`) from
       - Runtime plane (`apps/*`, `agents/*`, `platform/runtimes/*-runtime/**`).
     - Provides **governed agent autonomy** with clear HITL checkpoints and fail-closed gates.
     - Keeps complexity proportional to a small team and my stated goals.

---

## 4. Analysis Tasks (Step-By-Step)

Work through these steps in order:

1. **Summarize your understanding**

   - Reflect back a concise bullet-point summary of:

     - What agents currently exist and what they do.
     - How they are invoked and what runtime(s) they depend on.
     - Where they live in the repo (high-level, not every file).
   - List any **critical unknowns** that could change your recommendations. If there are more than five, group them by theme.

2. **Map the current state to Harmony**

   - For each agent (or agent family), map:

     - Which Harmony stages it participates in (Spec/Plan/Implement/Verify/Ship/Operate/Learn).
     - Which kits it uses today (directly or indirectly).
     - Which pillars it supports or undermines.
   - Highlight:

     - Any agents doing work that should be a **direct kit call or FlowKit flow** instead.
     - Any missing **Agent Spec / Definition / Implementation / Governance** bundles as described in Agent Architecture.

3. **Comms & runtime correctness**

   - Check how agents communicate with kits and runtimes:

     - Are they using typed ports with JSON-Schema contracts and the standard error taxonomy?
     - Are large payloads moving via artifacts/manifests, not blobs?
     - Are events used only for fan-out, not RPC?
   - Identify any deviations from the Core Comms Guide and Developer Guide (e.g., agents directly calling Python runtime internals instead of contract-first APIs, or skipping `run_id` / `traceparent` propagation).

4. **Guardrails, budgets, and HITL**

   - Evaluate how well each agent adheres to:

     - Pre-validators, post-validators, and budget enforcement (calls, time, tokens).
     - Idempotency (`idempotency_key` on mutating ops), retries, and circuit breakers.
     - HITL checkpoints and risk rubric (Trivial/Low/Medium/High).
   - Note where:

     - Agents can perform destructive actions without adequate safeguards.
     - Policies, evals, or observability are missing or weak.

5. **Kaizen vs product-facing agents**

   - Distinguish clearly between:

     - Kaizen/maintenance agents (docs/tests/flags/observability hygiene).
     - Product-facing agents (console assistant, RAG helper, etc.).
   - Identify:

     - Any Kaizen agents that should be promoted into a stable `packages/agents` surface.
     - Any product agents that belong in `packages/agents` but are currently only defined in `agents/*` or `apps/*`.

6. **LLMOps & ContextOps alignment**

   - Check how prompts, retrieval, and evaluation are handled:

     - Are PromptKit, IngestKit/IndexKit/QueryKit, ObservaKit, EvalKit, PolicyKit, and CacheKit used in their intended roles?
     - Are prompts and flows deterministic (pinned provider/model/version/params, prompt hash, low variance where appropriate)?
   - Note any places where agent logic is mixing prompt definition, retrieval, and evaluation in an ad-hoc way.

---

## 5. Design the Target-State Agent Setup

Propose a **concrete target design**, not just abstract principles. Include:

1. **Target agent catalog**

   - A table listing each recommended agent, including:

     - Name and role (planner/builder/verifier/orchestrator; Kaizen vs product).
     - Primary responsibilities and Harmony stages.
     - Inputs/outputs (high-level).
     - Kits used and key flows (e.g., “PlanKit → FlowKit → AgentKit → ToolKit → EvalKit/PolicyKit/TestKit”).
     - Risk class + HITL expectations.

2. **Repo structure & ownership**

   - How agents should be organized physically, e.g.:

     - `packages/agents` for stable, reusable agents.
     - `kaizen/agents` for Kaizen-only agents.
     - `agents/*` for Python runtimes and flows behind contract-first APIs.
   - Ownership boundaries (who maintains which agents and under what rules).

3. **Control plane vs runtime plane**

   - How TypeScript kits and `packages/agents` act as the **control plane**, and how:

     - `apps/*` surfaces invoke agents via TypeScript factories.
     - `agents/*` and `platform/runtimes/flow-runtime/**` act as shared runtimes behind generated clients and contracts.

4. **Guardrails & governance blueprint**

   - Standard pre/post validation patterns for all agents.
   - Default budgets for different classes of agents.
   - Risk rubric, HITL checkpoints, and PolicyKit/EvalKit/TestKit expectations per risk class.
   - Observability requirements (minimum OTel spans, logs, metrics; how `run_id`, `trace_id`, and evidence artifacts are recorded).

5. **Comms & MCP integration**

   - How kits should be exposed as MCP tools/resources and how agents should consume them.
   - How to keep MCP providers as adapters only, reusing kit JSON Schemas and contracts.

6. **Evolution & scalability**

   - Guidance for:

     - Adding new agents safely (spec-first, contracts, evals, governance bundle).
     - Retiring or refactoring agents without breaking callers.
   - How to keep the design evolvable as the team or traffic grows.

---

## 6. Migration & Implementation Plan

Provide a **phased migration plan** from current → target state, suitable for a small team, including:

1. **Immediate hygiene fixes** (1–2 weeks)

   - Changes that immediately improve safety/clarity (e.g., add budgets, risk labels, observability, basic HITL checkpoints).

2. **Structural refactors** (2–6 weeks)

   - Moving to `packages/agents`, aligning with the Harmony monorepo structure, cleaning up runtimes and MCP providers.

3. **Deep alignment & optimization** (ongoing)

   - LLMOps/ContextOps improvements, eval suites, Kaizen integration, performance/cost tuning.

For each phase, list:

- Concrete steps.
- Expected impact.
- Dependencies and risks.

---

## 7. Output Format & Style

Produce your answer in this structure:

1. **Section 1 – Current State Summary & Critical Unknowns**
2. **Section 2 – Harmony Alignment Analysis (by agent/area)**
3. **Section 3 – Target-State Agent Architecture (catalog + diagrams described in text)**
4. **Section 4 – Governance & Guardrails (budgets, HITL, policies, observability)**
5. **Section 5 – Migration Plan (phased, with clear steps)**
6. **Section 6 – Checklists**

   - “Is my current setup Harmony-aligned?” checklist.
   - “How to add a new agent safely?” checklist.

Style requirements:

- Be **clear, concise, and highly structured** (headings, bullet points, and tables where useful).
- Avoid vague statements; always tie recommendations back to:

  - Specific Harmony pillars and docs.
  - Concrete kits, repo locations, and flows.
- When you must make an assumption, **state it explicitly** and, if important, offer at least one alternative design.

---

Use this prompt to rigorously review and redesign my agent setup so that it is **simple, deterministic, observable, governable, and evolvable** within the Harmony framework.
