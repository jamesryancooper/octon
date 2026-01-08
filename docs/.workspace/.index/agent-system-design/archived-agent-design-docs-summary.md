---
title: Archived Agent Design Prompts and Docs — Synthesized Summary
description: Summary of archived Harmony agent documentation prompts, setup guides, and review/redesign instructions.
---

## Purpose of This Summary

- Provide a compact overview of the archived agent‑related docs under `.archive/architecture-agents`, notably:
  - `harmony-architecture-agent-documentation.md`
  - `agent-system-review-and-redesign.md`
  - `harmony-architecture-agent-set-up.md`
  - `pydantic-langgraph.md`
  - `bmad-pydantic-langgraph.md`
  - `bmad.md`
  - `agentic-system-implementation.md`
- Help downstream agents understand **design intent and prior work** while still treating the main Harmony handbook as normative.

## Common Themes Across Archived Docs

- Agents and their runtimes must be **aligned to Harmony’s Methodology and Architecture**, not improvised on top.
- There is a strong desire for:
  - Clear, reusable **agent documentation** (overview + per‑agent docs).
  - A **normative agent architecture** with well‑defined responsibilities and repo placement.
  - A **review/redesign process** for existing agent setups to converge on that target architecture.
- LangGraph and pydantic are chosen as **implementation tools** for Python agent/flow runtimes within the Harmony structure, not as architecture drivers on their own.

## Harmony Architecture Agent Documentation Prompt (Intent)

The `harmony-architecture-agent-documentation.md` prompt describes a documentation suite to be created under `docs/handbooks/harmony/architecture/agents/`:

- Files:
  - `agents/overview.md` — high‑level agent system overview.
  - `agents/planner-agent.md`, `agents/builder-agent.md`, `agents/verifier-agent.md`, `agents/orchestrator-agent.md`, `agents/runner-runtime.md`.
- Normative references:
  - Monorepo polyglot layout, Python runtime workspace, runtime architecture/policy, knowledge plane, governance model, agent roles, kit roles.
- Requirements:
  - Strong parameterization (target = overview or agent:<name>).
  - Consistent section structure (Audience & Scope, Position in Harmony, Responsibilities, Placement, Contracts, Policy & Observability, Flows, Boundaries, Open Questions, References).
- Key instruction:
  - **Architecture handbook is authoritative**; the doc suite should **reflect** it, not redefine it.

This prompt is essentially a **meta‑spec** for how agents should be documented in the future.

## Agent Architecture Review & Redesign Prompt (Intent)

The `agent-system-review-and-redesign.md` prompt instructs an AI to:

- Critically analyze the **current agent setup**:
  - Inventory agents, roles, locations, invocations, flows, runtimes, guardrails, observability.
  - Map agents to Harmony stages, pillars, and kit usage.
  - Identify misalignments with HSP, agent architecture, Kaizen subsystem, governance model, and comms expectations.
- Design a **target‑state agent architecture**:
  - Clear catalog of agents (Planner/Builder/Verifier/Orchestrator/Kaizen/Product/Eval).
  - Repo structure and ownership (packages/agents, agents/*, kaizen/agents, platform runtimes).
  - Guardrails, budgets, HITL, and observability requirements.
  - MCP/tooling integration where relevant.
- Provide a **migration plan**:
  - Immediate hygiene fixes.
  - Structural refactors.
  - Long‑term alignment and optimization.

It codifies the **expected shape** of a Harmony‑aligned agent system and how to migrate from an ad‑hoc setup to that model.

## Agent Setup Prompt (Repo-Specific Alignment)

The `harmony-architecture-agent-set-up.md` prompt narrows focus to this repo and:

- Reasserts the normative baseline:
  - Harmony Methodology.
  - Architecture docs (`agent-architecture.md`, `agent-roles.md`, `kaizen-subsystem.md`, `monorepo-layout.md`, `repository-blueprint.md`, `runtime-architecture.md`, `runtime-policy.md`).
- Tasks:
  - Summarize the **target agent model** from those docs.
  - Refine and operationalize the agent architecture **for this monorepo**, including:
    - How to introduce and structure `packages/agents`.
    - How agents are wired to domain logic, infra, UI, and platform runtimes.
    - How to keep agents future‑proof as kits and runtimes evolve.
  - Provide repo‑specific rules for:
    - What belongs in `packages/agents/**` vs `agents/**` vs `kaizen/agents/**`.
    - Promotion paths from Kaizen to production agents.
    - Access patterns for apps, Kaizen, CI, and other callers.

This prompt is about **operationalizing** the target agent architecture in the concrete monorepo, not preserving legacy structure.

## BMAD and Pydantic/LangGraph Notes

The `bmad.md`, `bmad-pydantic-langgraph.md`, and `pydantic-langgraph.md` archives:

- Clarify that:
  - **BMAD** (and BMB) shape planning, story structure, and persona design for agents.
  - **LangGraph + pydantic** provide a convenient way to implement durable flow graphs and typed state for agent workflows.
- Emphasize:
  - BMAD concepts should be **wrapped by PlanKit**; callers integrate with PlanKit, not BMB internals.
  - LangGraph flows should be wrapped in a **platform flow runtime service**; callers integrate via FlowKit and generated clients, not `server.py` internals.

For this repo:

- These archives reflect **implementation choices** that must fit behind the Harmony runtime/kit boundaries:
  - PlanKit wraps BMAD.
  - FlowKit + AgentKit + platform runtime wrap LangGraph and Pydantic state.

## Agentic System Implementation Notes

`agentic-system-implementation.md` (currently minimal or placeholder) is intended to:

- Anchor a **concrete implementation** of the Harmony‑aligned agentic system:
  - How PlanKit, FlowKit, AgentKit, and the platform runtime are wired together.
  - How TS `packages/agents`, Python `agents/*`, and `platform/runtimes/flow-runtime/**` compose.
  - How governance bundles, Knowledge Plane integration, and CI gates are attached to each agent.

It should be seen as the **implementation counterpart** to the architecture and setup prompts.

## How to Use These Archives

- Treat all `.archive/architecture-agents` docs as **design intent and prompts**, not canonical architecture:
  - The canonical sources are the Harmony handbook and HSP docs.
  - These archives show how the team wants agents **documented, evaluated, and improved** over time.
- For new agents or redesign work:
  - Use:
    - `harmony-architecture-agent-documentation.md` for documentation patterns.
    - `agent-system-review-and-redesign.md` for analysis/redesign structure.
    - `harmony-architecture-agent-set-up.md` for repo‑specific alignment tasks.
  - Then implement according to the normative summaries in:
    - `harmony-methodology-and-principles-summary.md`
    - `architecture-hsp-and-monorepo-layout-summary.md`
    - `runtime-and-planes-summary.md`
    - `agents-kaizen-and-mape-k-summary.md`
    - `ai-toolkit-and-agent-layer-summary.md`
