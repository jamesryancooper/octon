---
title: Engine Catalog
description: Catalog of all engines in the Harmony monorepo.
version: v1.0.0
date: 2025-11-21
---

# Engine Catalog

This document catalogs all major **Engines** in the Harmony system. Engines are composable, reusable subsystems that centralize a major capability—such as planning, execution, context, governance, or shipping work—by orchestrating multiple specialized Kits.

- **Purpose:** Each Engine provides a stable, opinionated API for “do X”—for example, generating a plan or executing a workflow—while encapsulating policies, guardrails, evaluation, and observability for its domain.
- **Usage:** Engines are always imported (never run directly). They are composed and invoked by **Agent factories** (in `packages/agents`), which in turn power surfaces like apps, consoles, and orchestrators.
- **Location:** All Engines reside under `packages/engines/*`—making their boundaries and responsibilities clear.

Refer to this catalog to understand what Engines exist today, what they own, and how they fit into the larger Harmony framework.

## 1. Quick framing (so we’re on the same page)

**Run vs import:**

- **Run:** `apps/*`, `/agents/*`, `platform/runtimes/*-runtime/**`
- **Import:** `packages/*`, `contracts/*`

**Where Engines live:**
👉 All Engines are **import-only** modules under `packages/engines/*`.

**How they’re used:**

- `apps/*` and other TS surfaces:

  - call **factories** in `packages/agents/src/factories/*`
  - those factories wire **Agents → Engines → Kits → contracts → platform runtimes**
- `/agents/*` (Python) runtimes:

  - call platform runtimes via `contracts/py`
  - (optionally) mirror similar behavior to TS agents, but still treat `platform/runtimes/*-runtime` as external.

No new runtime roots, no changes to platform runtimes—Engines just give you a clean compositional layer inside `packages/`.

---

## 2. Engine Catalog v1.0 (concise table)

**Core engines I’d define now:**

| Engine               | Primary Responsibility                                | Key Kits it Composes                                                                            | Main TS Agents Using It                                     |
| -------------------- | ----------------------------------------------------- | ----------------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| **PlanEngine**       | Turn goals/specs into governed, high-quality plans    | PromptKit, PlanKit, EvalKit, PolicyKit, ObservaKit, CacheKit                                    | Planner agents, console/orchestrator agents, Kaizen planner |
| **WorkEngine**       | Execute plan steps safely via flows/tools             | FlowKit, AgentKit, ToolKit, PromptKit, PolicyKit, ObservaKit, CacheKit                          | Builder agents, console agents, Kaizen builder              |
| **ContextEngine**    | Own ingestion, indexing, query & prompt-ready context | IngestKit, IndexKit, QueryKit, SearchKit, PromptKit, EvalKit, ObservaKit                        | Planner/builder/verifier agents, console agents             |
| **GovernanceEngine** | Centralize evals, policies, scoring & gating          | EvalKit, PolicyKit, TestKit, DatasetKit, ObservaKit                                             | Verifier agents, Kaizen verifier, CI/checks                 |
| **ReleaseEngine**    | Plan & execute shipping (PRs, previews, releases)     | PatchKit, ReleaseKit, PolicyKit, TestKit, ObservaKit                                            | Builder/verifier agents, Kaizen agents, CI                  |
| **KaizenEngine**     | Drive autonomous improvements across the system       | PlanKit, FlowKit, AgentKit, EvalKit, PolicyKit, PatchKit, TestKit, ObservaKit (+ other engines) | Kaizen planner/builder/verifier agents                      |

Optional later (only if the need clearly appears): `ReliabilityEngine`, `ExperimentEngine`, `SafetyEngine`.

---

## 3. For each Engine: what it owns & how it wraps Kits + Agents

### 3.1 PlanEngine

**Where:**
`packages/engines/plan-engine/`

**What it owns:**

- “Planning as a capability” for the system:

  - Given a goal/spec + constraints + risk → produce a **PlanKit-compatible plan** plus eval/policy metadata.
- Handles:

  - Multiple planning strategies (fast vs deep, incremental vs full).
  - Budgeting (time, tokens, calls) by risk mode.
  - Telemetry/evidence for all planning runs.

**Kits it wraps:**

- `PlanKit` – core plan synthesis.
- `PromptKit` – planning prompts + schemas.
- `EvalKit` – plan quality/coverage evals.
- `PolicyKit` – allowed action types/depth by risk class.
- `ObservaKit` – traces, logs, metrics, evidence artifacts.
- `CacheKit` – reuse known-good plans.

**How TS agents use it (via `/packages/agents`):**

- Under `packages/agents/src/specs`:

  - Define planner agent capabilities + inputs/outputs.
- Under `definitions`:

  - Point planner agents to `PlanEngine.generatePlan(...)`.
- Under `governance`:

  - Describe risk levels & budget modes PlanEngine should use.
- Under `factories`:

  - `createPlannerAgent`, `createConsoleAssistant` call `PlanEngine` instead of manually orchestrating PlanKit + EvalKit.

**Sanity vs repo:**
Fits neatly: pure TS, import-only, backed by Kits, called from factories, no runtime root changes.

---

### 3.2 WorkEngine

**Where:**
`packages/engines/work-engine/`

**What it owns:**

- Execution of plan steps, with safety & observability:

  - Input: plan (or step) + context.
  - Output: updated state, artifacts, telemetry.
- Responsibilities:

  - Map step types → FlowKit flows or tools.
  - Handle retries, idempotency, and budgets.
  - Decide when to use an **agentic step** (AgentKit) vs simple tool call.

**Kits it wraps:**

- `FlowKit` – orchestrate flows for complex steps.
- `AgentKit` – when executing a step is itself a sub-agent.
- `ToolKit` – safe tool/MCP calls, with policies.
- `PromptKit` – prompts tied to tools and flow nodes.
- `PolicyKit` – allowed tools/actions by risk class.
- `ObservaKit` – spans/logs for each step; link to plan + run IDs.
- `CacheKit` – memoization for pure idempotent operations.

**How TS agents use it:**

- Planner → produce plan via `PlanEngine`.
- Builder agent (defined in `packages/agents`) then:

  - For each step, call `WorkEngine.executeStep(step, context)`.
- Console agent:

  - For “do X now” commands, may call `WorkEngine.executeDirect` without a full plan.

**Sanity vs repo:**

- WorkEngine talks to `platform/runtimes/flow-runtime/**` only via:

  - FlowKit + `contracts/ts` generated clients.
- No direct LangGraph imports in agents/apps; cleanly keeps runtime boundaries.

---

### 3.3 ContextEngine

**Where:**
`packages/engines/context-engine/`

**What it owns:**

- ContextOps/RAG end-to-end:

  - Ingest + index maintenance.
  - Query routing and retrieval strategies.
  - Packaging context into prompt-ready structures.

**Kits it wraps:**

- `IngestKit` – pipelines for docs/code/logs/etc.
- `IndexKit` – index lifecycles, reindex, migrations.
- `QueryKit` – retrieval strategies per slice/domain.
- `SearchKit` – search backends (vector, full-text, hybrid).
- `PromptKit` – map raw context → prompt slots.
- `EvalKit` – measure retrieval quality (relevance, grounding).
- `ObservaKit` – retrieval metrics, drift, performance.

**How TS agents use it:**

- Planner/builder/verifier specs refer to “needs context of type X”.
- Definitions call `ContextEngine.getContext({ goal, entityId, slice, risk })`.
- Factories wire the agent to ContextEngine instead of embedding one-off retrieval logic.

**Sanity vs repo:**

- This centralizes RAG/ContextOps that might currently be scattered in:

  - Kits that know too much (e.g., “smart” query code embedded in apps/agents).
  - Ad-hoc code in `apps/*` or `agents/*`.
- No runtime root change; just better structure inside `packages/`.

---

### 3.4 GovernanceEngine

**Where:**
`packages/engines/governance-engine/`

**What it owns:**

- “Should we trust/ship this?” decisions:

  - Running eval suites.
  - Applying policies and thresholds.
  - Returning verdicts + scores + evidence.

**Kits it wraps:**

- `EvalKit` – LLM/heuristic evals of outputs, flows, RAG, etc.
- `DatasetKit` – golden datasets for evals.
- `PolicyKit` – safety, determinism, compliance policies.
- `TestKit` – traditional tests/e2e/contract checks where applicable.
- `ObservaKit` – store eval & policy evidence, tag runs/releases.

**How TS agents & Engines use it:**

- Verifier agents:

  - Call `GovernanceEngine.evaluate({ artifact, context, risk })` instead of rolling their own eval + policy logic.
- Other engines:

  - PlanEngine, WorkEngine, ReleaseEngine call GovernanceEngine internally as part of their own workflows.
- Definitions in `packages/agents`:

  - Link each agent to particular GovernanceEngine “profiles” (e.g., strict for release, lighter for preview).

**Sanity vs repo:**

- Right now, eval/policy/test wiring can easily end up scattered across agents/flows.
- GovernanceEngine centralizes that, which matches your desire for governance bundles.

---

### 3.5 ReleaseEngine

**Where:**
`packages/engines/release-engine/`

**What it owns:**

- The “Ship” step of the loop:

  - Patch generation (PRs/diffs).
  - Previews and rollout.
  - Release notes, changelog, and audit trail.

**Kits it wraps:**

- `PatchKit` – diffs, branches, PR creation.
- `ReleaseKit` – releases, changelog entries, release metadata.
- `PolicyKit` – who/what/when is allowed to ship.
- `TestKit` – gating test suites.
- `ObservaKit` – telemetry around releases (linking runs, incidents, rollbacks).

**How TS agents use it:**

- Builder/verifier & Kaizen agents:

  - After plan + execution + verification, call:

    - `ReleaseEngine.prepareChange(...)` for PRs.
    - `ReleaseEngine.promoteRelease(...)` for certain environments.
- Factories:

  - Provide agent modes like “proposal-only” (PR without auto-merge) vs “autonomous shipping” (still gated by policy).

**Sanity vs repo:**

- This consolidates all “how we ship” logic into one place.
- No runtime conflict: ReleaseEngine is just imported; actual actions go through contracts (GitHub, CI/CD, etc.) via Kits/adapters.

---

### 3.6 KaizenEngine

**Where:**
`packages/engines/kaizen-engine/`

**What it owns:**

- Coordinated, ongoing improvements to the system:

  - Discover opportunities (docs, tests, flags, obs, performance).
  - Plan → Execute → Verify → Propose PRs, on a schedule or via triggers.

**Kits & Engines it uses:**

- Uses other Engines:

  - `PlanEngine` – plan Kaizen work.
  - `WorkEngine` – perform actual changes.
  - `GovernanceEngine` – evaluate impact & safety.
  - `ReleaseEngine` – propose & manage PRs/releases.
- Uses Kits:

  - `PlanKit`, `FlowKit`, `AgentKit`, `EvalKit`, `PolicyKit`, `TestKit`, `PatchKit`, `ObservaKit`, etc.

**How TS agents use it:**

- Kaizen agents under `packages/agents`:

  - Specs: “Kaizen reviewer”, “Kaizen builder” roles.
  - Definitions: call `KaizenEngine` for full lifecycle of Kaizen tasks.
  - Factories: expose convenient entrypoints like `createKaizenAgentForSlice(sliceId)`.

- Runtime:

  - Schedulers or events in `apps/*` or `/agents/*` trigger KaizenEngine via these factories.

**Sanity vs repo:**

- You already have the idea of Kaizen agents and policies; this gives them a central orchestrator.
- Still lives in `packages/`, no new runtime root.

---

## 4. How this maps over your repo layout (sanity check)

**Final shape:**

```text
apps/
  ├── ai-console/
  ├── api/
  └── ...

agents/
  ├── planner/         # Python control-plane runtime
  ├── builder/
  ├── verifier/
  ├── orchestrator/
  └── ...

platform/
  runtimes/
    ├── flow-runtime/    # shared execution substrate for flows
    └── # (future: eval-runtime, batch-runtime, etc.)

packages/
  kits/
    ├── plan-kit/
    ├── flow-kit/
    ├── prompt-kit/
    ├── eval-kit/
    ├── policy-kit/
    ├── ingest-kit/
    ├── index-kit/
    ├── query-kit/
    ├── search-kit/
    ├── patch-kit/
    ├── release-kit/
    ├── observa-kit/
    ├── cache-kit/
    ├── test-kit/
    ├── dataset-kit/
    └── ...

  engines/
    ├── plan-engine/
    ├── work-engine/
    ├── context-engine/
    ├── governance-engine/
    ├── release-engine/
    └── kaizen-engine/

  agents/
    src/
      ├── specs/
      ├── definitions/
      ├── governance/
      └── factories/

contracts/
  ├── ts/
  └── py/

kaizen/
  # policies, reports, maybe some kaizen-specific agents/runtimes
```
