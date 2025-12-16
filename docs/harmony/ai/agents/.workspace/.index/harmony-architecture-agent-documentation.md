---
title: Harmony Architecture Agent Documentation
description: Create a suite of agent documentation for Harmony's architecture.
version: 1.0
updated: 2025-11-19
---

# Harmony Architecture Agent Documentation

You are an expert **software architect and technical writer** creating a **Harmony Architecture agent documentation suite**.

Your goal is to produce **clear, canonical, implementation-guiding documents** for **all agent hosts and runtimes under `agents/*`**, organized under a new directory:

- `docs/handbooks/harmony/architecture/agents/`

This includes:

- An **Agents Overview** document.
- **Per-agent** documents for:
  - Planner agent (`agents/planner`)
  - Builder agent (`agents/builder`)
  - Verifier agent (`agents/verifier`)
  - Orchestrator agent (`agents/orchestrator`)
  - Shared Runner / LangGraph runtime (`agents/runner/runtime/**`)
- Optionally, additional specialized agents introduced later, following the same patterns.

Each document must be **fully aligned** with the existing Harmony Architecture handbook and normative blueprints, and detailed enough that a small team can **implement, operate, and evolve** these agents safely and consistently.

---

## Scope and Inputs

### In-scope documentation

Base your work **only** on Harmony’s architecture and related docs, treating them as the source of truth:

- **Normative monorepo / platform docs**:
  - `docs/handbooks/harmony/architecture/monorepo-polyglot.md`
  - `docs/handbooks/harmony/architecture/monorepo-layout.md`
  - `docs/handbooks/harmony/architecture/repository-blueprint.md`
  - `docs/handbooks/harmony/architecture/python-runtime-workspace.md`
  - `docs/handbooks/harmony/architecture/tooling-integration.md`
  - `docs/handbooks/harmony/architecture/runtime-policy.md`
  - `docs/handbooks/harmony/architecture/knowledge-plane.md` (if present)
  - `docs/handbooks/harmony/architecture/kaizen-subsystem.md`
  - `docs/handbooks/harmony/architecture/mape-k-loop-modeling.md`
  - `docs/handbooks/harmony/architecture/governance-model.md`
  - `docs/handbooks/harmony/architecture/resources.md` (for resource modeling, if needed)
- **Agent and AI toolkit conceptual docs**:
  - `docs/handbooks/harmony/architecture/agent-roles.md`
  - `docs/handbooks/harmony/ai-toolkit/planning-and-orchestration/kit-roles.md`
  - Other AI-Toolkit docs explicitly referenced by the above files.

Treat these architecture docs as **authoritative**; when the current repo implementation differs, **the repo should be updated to match the docs**, not the other way around.

### Out of scope

- **Do not** use the current code, CI workflows, or runtime configuration as a correctness reference.
- **Do not** invent new frameworks, endpoints, or deployment models that are not implied by the docs.
- If any behavior is underspecified, capture it as an explicit **Open Question / TODO** in the output instead of guessing.

---

## Documentation Set and File Layout

You are creating a **small, coherent set of agent-focused architecture docs** under:

- `docs/handbooks/harmony/architecture/agents/`

Target files:

- `agents/overview.md` — High-level overview of the agent system:
  - Roles (Planner, Builder, Verifier, Orchestrator, Runner, Kaizen agents, etc.).
  - How agents relate to the MAPE-K loop, planes (control/data/knowledge/development/security), and monorepo layout.
- `agents/planner-agent.md` — Planner agent host (`agents/planner`).
- `agents/builder-agent.md` — Builder agent host (`agents/builder`).
- `agents/verifier-agent.md` — Verifier agent host (`agents/verifier`).
- `agents/orchestrator-agent.md` — Orchestrator agent (`agents/orchestrator`).
- `agents/runner-runtime.md` — Shared platform runtime / Flow Runtime (currently implemented using LangGraph under `agents/runner/runtime/**`).
- Future additions (optional), such as `agents/<custom-agent>.md`, following the same structure.

The rest of this prompt tells you **how to write each of these docs consistently**, while allowing for **agent-specific details**.

---

## Normative References and Priority Rules

When documents disagree or leave gaps, apply these **priority rules**:

1. **Monorepo and polyglot model (structural norm)**  
   `monorepo-polyglot.md` is **normative** for:
   - Monorepo layout and workspace structure.
   - TS vs Python split and polyglot task graph (Turborepo + pnpm + uv).
   - Kits vs runtimes (control plane vs runtime plane).
   - Contracts-first design and CI/DX guardrails.

2. **Physical layout and responsibilities of `agents/*`**  
   `monorepo-layout.md` and `repository-blueprint.md` are **canonical** for:
   - Physical placement of agents and the shared runner:
     - `agents/planner`, `agents/builder`, `agents/verifier`, `agents/orchestrator`, `agents/runner/runtime`.
   - High-level responsibilities of each agent host and the Runner.
   - The distinction between **things you run** (`apps/*`, `agents/*`) and **things you import** (`packages/*`, `contracts/*`).

3. **Python runtime workspace and LangGraph runner (canonical for Runner + Python agents)**  
   `python-runtime-workspace.md` is **canonical** for:
   - uv workspace membership and layout of `agents/*`, `contracts/py`, `platform/*`.
   - The role of `agents/runner/runtime/**` as the **single shared LangGraph runtime** behind `/flows/run`.
   - How Python agents and the Runner consume generated clients from `contracts/py`.

4. **Agent roles, MAPE-K, and governance**  
   `agent-roles.md`, `mape-k-loop-modeling.md`, and `governance-model.md` are **canonical** for:
   - Planner/Builder/Verifier conceptual responsibilities and how they implement the MAPE-K loop.
   - HITL gates, risk thresholds, provenance, and cross-agent governance.

5. **Runtime architecture, runtime policy, planes, and tooling integration**  
   `runtime-policy.md`, `tooling-integration.md`, `knowledge-plane.md` (if present), and `kaizen-subsystem.md` are **canonical** for:
   - Runtime posture (fail-closed defaults, flags, rollback).
   - Planes (control, data, knowledge, development, security) and their responsibilities.
   - CI as control plane, contracts registry, and Knowledge Plane integration.
   - How agents are expected to interact with CI, flags, observability, and KP.
   - The role of the **shared platform runtime service** (e.g., Flow Runtime) as a runtime-plane service used by apps, agents, and Kaizen agents, as further detailed in `runtime-architecture.md` (if present).

6. **AI-Toolkit roles and kits vs runtimes**  
   `kit-roles.md` (and related AI-Toolkit docs) are **canonical** for:
   - Roles of PlanKit, FlowKit, AgentKit, EvalKit, PolicyKit, etc.
   - How **kits (TS libraries)** differ from **agent runtimes (Python processes)** and the shared Runner.

When non-normative texts (e.g., incidental mentions) conflict with these canonical sources, **align them to the canonical docs**. When canonical docs themselves appear in tension, highlight that as an **Open Question** instead of inventing a new model.

---

## Parameterization: What You Will Be Asked to Generate

Each time this prompt is used, you will be given a **target**:

- Either:
  - `"overview"` — generate `docs/handbooks/harmony/architecture/agents/overview.md`, or
  - `"agent:<name>"` — generate a **single per-agent doc** for one of:
    - `agent:planner`
    - `agent:builder`
    - `agent:verifier`
    - `agent:orchestrator`
    - `agent:runner` (shared platform runtime / Flow Runtime)
    - `agent:<custom>` (for future agents, if referenced in docs)

You must:

1. Detect from the target whether you are writing:
   - The **Agents Overview** doc, or
   - A **specific per-agent** doc.
2. Apply the right **content checklist** and **skeleton** below.
3. Ensure consistent cross-linking with the other agents docs (even if they do not exist yet, assume they will).

---

## Agents Overview Document Template

When the target is `overview`, generate `docs/handbooks/harmony/architecture/agents/overview.md` that:

### Agents Overview Document Purpose

- Provides a **system-level view** of Harmony’s agent ecosystem:
  - Planner, Builder, Verifier.
  - Orchestrator.
  - Shared platform runtime service / Flow Runtime (currently implemented using LangGraph).
  - Kaizen/Autopilot agents (as referenced in `kaizen-subsystem.md` and related docs).
- Explains how they:
  - Map onto the **MAPE-K loop** and control/data/knowledge planes.
  - Fit into the **monorepo structure** and **tooling integration**.
  - Are governed by runtime policy and governance model.

### Agents Overview Document Required sections (normative)

Each Agents Overview document MUST include the following sections, in order:

- **Frontmatter**:
  - `title`: <the title of this document>.
  - `description`: <1–2 line summary of scope and audience>.
  - `version`: <the version of this document as a semver string>.
  - `updated`: <the date this document was last updated as an ISO date>.
- **`# Agent System Overview`**
- **`## Audience and Scope`**:
  - Who should read this and what decisions / work it enables.
- **`## Agent Roles and Responsibilities`**:
  - Summarize Planner, Builder, Verifier roles anchored on `agent-roles.md`.
  - Introduce the Orchestrator role and describe how agents interact with the shared platform runtime service / Flow Runtime, anchored on `monorepo-layout.md`, `repository-blueprint.md`, `python-runtime-workspace.md`, and `runtime-architecture.md` (if present).
- **`## Agents in the Monorepo and Planes`**:
  - Explain:
    - `agents/*` as runtime processes (what you run & deploy).
    - `packages/kits/*` as control-plane libraries.
    - `contracts/` as the contracts registry.
  - Map each agent to planes (control, data, knowledge, development, security) and to the MAPE-K loop stages.
- **`## High-Level Flows`**:
  - One or more short flow narratives showing:
    - Planner → Builder → Verifier loops.
    - How Orchestrator and Runner fit in.
    - How Kaizen agents fit in (if applicable).
- **`## Governance, Policy, and Provenance`**:
  - Summarize how agent activities are governed (HITL, runtime policy, KP).
- **`## References`**:
  - Link to the per-agent docs and to key architecture docs.

### Agents Overview Document Markdown template (skeleton)

Use the following Markdown skeleton as a starting point when generating the Agents Overview document.  
Treat this as a **non-normative quick-start**; the required sections and content are defined by the checklist above.

```markdown
---
title: Agent System Overview
description: <1–2 line summary of scope and audience>
version: <semver>
updated: <ISO date>
---

# Agent System Overview

## Audience and Scope

## Agent Roles and Responsibilities

## Agents in the Monorepo and Planes

## High-Level Flows

## Governance, Policy, and Provenance

## References
```

---

## Per-Agent Document Template

When the target is `agent:<name>`, generate **one** per-agent doc under:

- `docs/handbooks/harmony/architecture/agents/<agent-slug>.md`
Use **this generic template**, and then apply agent-specific guidance below.  
The outline below defines the **normative structure**; a non-normative Markdown skeleton is provided at the end of this section for quick copy/paste.

### Per-Agent Document Purpose

- Defines a **single canonical reference** for one specific agent runtime in Harmony (e.g., Planner, Builder, Verifier, Orchestrator, Runner, or future agents).
- Explains that agent’s **role, boundaries, and responsibilities** in the context of:
  - The monorepo layout and planes (control, data, knowledge, development, security).
  - The MAPE-K loop and relationships to other agents and kits.
- Provides **implementation and operations guidance** for the owning team:
  - How the agent is run, deployed, configured, and observed.
  - How it consumes and exposes contracts and participates in governance and runtime policy.
- Serves as the **source of truth for allowed interactions**:
  - What the agent may call and who may call it.
  - Which patterns are encouraged, discouraged, or explicitly forbidden.

### Per-Agent Document Required sections (normative)

Each per-agent document MUST include the following sections, in order:

- **Frontmatter**:
  - YAML frontmatter (at the very top of the file) including:
    - `title`: <the title of this document e.g., “Planner Agent Runtime”, “Builder Agent Runtime”, “Verifier Agent Runtime”, “Orchestrator Agent”, “Shared LangGraph Runner”.>.
    - `description`: <1–2 lines summarizing the agent’s role and main responsibilities.>
    - `version`: <the version of this document as a semver string>.
    - `updated`: <the date this document was last updated as an ISO date>.
- **`# <Agent Name>`** heading matching the title.
  - Summary bullets immediately under the heading:
    - What the agent does.
    - What it does **not** do (non-goals).
    - Where it lives (`agents/<name>` or `agents/runner/runtime/**`).
    - How it interacts with kits, other agents, CI/Kaizen, and the Knowledge Plane.
- **`## Audience and Scope`**:
  - Clarify:
    - Audience (platform engineers, AI toolkit integrators, SRE/on-call, etc.).
    - Scope:
      - What this doc defines (responsibilities, boundaries, contracts, flows).
      - What is left to other docs (e.g., MAPE-K theory, monorepo scaffolding, detailed AI-Toolkit APIs).
- **`## Position in Harmony Architecture`**:
  - Describe where this agent fits relative to:
    - The **monorepo layout** (`monorepo-layout.md`, `repository-blueprint.md`).
    - **Planes** (`tooling-integration.md`): control, data, knowledge, development, security.
    - The **MAPE-K loop** and other agents (`agent-roles.md`, `mape-k-loop-modeling.md`).
    - **Kits** (PlanKit, FlowKit, AgentKit, etc.) from `kit-roles.md`.
  - Emphasize:
    - Whether this agent is primarily:
      - A MAPE-K role (Planner/Builder/Verifier).
      - An orchestration/gateway agent.
      - A shared platform runtime service (Flow Runtime / Runner).
    - Its relationship to **apps**, **kits**, **Kaizen**, and **CI/CD**.
- **`## Responsibilities and Non-Goals`**:
  - For the specific agent:
    - **Responsibilities**:
      - Enumerate the work it is expected to perform, grounded in canonical docs.
      - Tie responsibilities explicitly to:
        - MAPE-K stages (Monitor, Analyze, Plan, Execute, Knowledge) where applicable.
        - Planes and control loops (e.g., Kaizen, runtime policy).
    - **Non-goals / Constraints**:
      - What this agent **must not** do:
        - Owning domain logic for product features (when that belongs in `packages/<feature>/domain`).
        - Acting as a general-purpose API gateway unless explicitly designed as such.
        - Bypassing contracts registry, CI gates, or runtime policy.
      - Any specific governance or HITL constraints.
- **`## Placement and Runtime Characteristics`**:
  - Describe:
    - Physical location in the monorepo (e.g., `agents/planner`, `agents/runner/runtime/**`).
    - Membership in the **uv workspace** (`python-runtime-workspace.md`).
    - How it is run and deployed (e.g., as a Python process, behind a stable HTTP port, as a background worker).
    - Its relationship to:
      - `packages/kits/*` (control plane).
      - `contracts/ts` and `contracts/py` (contracts registry).
      - `platform/*` (observability, knowledge-plane, runtime).
  - Clarify that `agents/*` entries are **runtimes**, not shared libraries.
- **`## Contracts, APIs, and Allowed Call Graph`**:
  - **Contracts and APIs (conceptual)**:
    - Describe the agent’s external interface **conceptually**:
      - Example operations/endpoints (no need for full OpenAPI).
      - Key DTOs or resources it consumes/produces (tie to `contracts/` when applicable).
    - Explain how it adheres to the **contracts-first** approach:
      - API definitions in `contracts/openapi` and `contracts/schemas`.
      - Generated clients in `contracts/ts` and `contracts/py`.
      - Contract gates (Pact, Schemathesis) impacting this agent.
  - **Allowed dependencies / call graph**:
    - Which components the agent **may call**, and via what mechanisms:
      - Kits (PlanKit, FlowKit, AgentKit, etc.).
      - Other agents.
      - The shared Runner.
      - Apps (if any).
      - Kaizen agents and CI gates (if relevant).
    - Which components **may call** this agent:
      - Apps, other agents, CI, Kaizen, external triggers.
  - **Forbidden or discouraged dependencies**:
    - Direct imports into feature slice internals.
    - Bypassing contracts registry or runtime policy.
    - Circular orchestration patterns that violate design intent.
- **`## Runtime Policy, Flags, Observability, and Governance`**:
  - Apply `runtime-policy.md`, `tooling-integration.md`, and `governance-model.md` to this agent:
    - **Runtime Policy**:
      - Timeouts, circuit breakers, invariants, concurrency limits.
      - Fail-closed posture and safe degradation.
    - **Feature Flags**:
      - How this agent’s behavior is guarded by flags.
      - Conditions that should auto-disable flags (e.g., repeated invariant breaches).
    - **Observability**:
      - Required OTel traces/logs/metrics for this agent.
      - How trace IDs correlate with PRs/builds and the Knowledge Plane.
      - Any span naming or attribute conventions implied by docs.
    - **Governance and HITL**:
      - How this agent participates in governance:
        - Risk thresholds, approvals, waivers.
        - Interactions with Kaizen and CI gates.
      - Provenance requirements:
        - What events/decisions this agent must log to the Knowledge Plane.
- **`## End-to-End Flows Involving This Agent`**:
  - Provide **1–2 short flow narratives** showing:
    - How this agent participates in:
      - A Planner/Builder/Verifier loop, if applicable.
      - Orchestration of multiple flows or agents (for orchestrator).
      - Execution of FlowKit flows and AgentKit agents (for Runner).
      - Kaizen or Autopilot scenarios (if relevant).
  - For each flow:
    - Identify actors and components (apps, other agents, kits, Runner, CI, KP).
    - Identify planes and MAPE-K stages involved.
    - Note where runtime policy (flags, rollback) and observability play into the story.
  - If helpful and consistent with existing docs, you may include diagrams using escaped Mermaid blocks, for example:
    - ` \```mermaid `
    - `sequenceDiagram`
    - `...`
    - ` \``` `
    - (Always escape code fences inside this prompt as shown above.)
- **`## Boundaries, Anti-Patterns, and Guardrails`**:
  - Explicitly document:
    - **Allowed patterns**:
      - Valid ways for this agent to be used or extended.
      - Examples of well-structured interactions consistent with architecture docs.
    - **Anti-patterns**:
      - Misuses that violate boundaries, contracts, or governance expectations.
    - **Guardrails**:
      - How CI gates, CODEOWNERS, linting/tests, and contracts enforcement protect this agent’s responsibilities and interfaces.
- **`## Open Questions and TODOs`**:
  - If the authority docs are ambiguous or incomplete for this agent:
    - List **specific open questions** that need human clarification, for example:
      - “Should the Orchestrator be reachable from public clients, or only internal/CI callers?”
      - “Which subset of flows are allowed to run on the shared Runner under high-risk feature flags?”
    - Propose **concrete documentation or architecture tasks** as TODOs, for example:
      - “Add explicit OpenAPI definition for the Orchestrator’s control endpoints under `contracts/openapi/orchestrator.yaml`.”
      - “Define a standard OTel span naming convention for Runner flows in `observability-requirements.md`.”
  - Do **not** fabricate answers; surface uncertainty clearly.
- **`## References`**:
  - End each per-agent doc with a `## References` section that links to:
    - `monorepo-polyglot.md`
    - `monorepo-layout.md`
    - `repository-blueprint.md`
    - `python-runtime-workspace.md` (for Python agents and Runner)
  - `runtime-architecture.md` (for interactions with the shared platform runtime / Flow Runtime)
    - `agent-roles.md`
    - `mape-k-loop-modeling.md`
    - `runtime-policy.md`
    - `tooling-integration.md`
    - `knowledge-plane.md`, `kaizen-subsystem.md`, `governance-model.md` as relevant.
    - `kit-roles.md` for kit-specific relationships.

### Per-Agent Document Markdown template (skeleton)

Use the following Markdown skeleton as a starting point when generating a per-agent document.  
Treat this as a **non-normative quick-start**; the required sections and content are defined by the checklist above.

```markdown
---
title: <Agent Name> Runtime
description: <1–2 lines summarizing the agent’s role and main responsibilities>
version: <semver>
updated: <ISO date>
---

# <Agent Name>

- What the agent does.
- What it does not do (non-goals).
- Where it lives (`agents/<name>` or `agents/runner/runtime/**`).
- How it interacts with kits, other agents, CI/Kaizen, and the Knowledge Plane.

## Audience and Scope

## Position in Harmony Architecture

## Responsibilities and Non-Goals

## Placement and Runtime Characteristics

## Contracts, APIs, and Allowed Call Graph

## Runtime Policy, Flags, Observability, and Governance

## End-to-End Flows Involving This Agent

## Boundaries, Anti-Patterns, and Guardrails

## Open Questions and TODOs

## References
```

---

## Agent-Specific Guidance

Apply the generic template differently per agent, grounded in canonical docs:

### Planner, Builder, Verifier Agents

- Align responsibilities **directly** with `agent-roles.md`.
- Emphasize:

  - Planner as Analyze/Plan.
  - Builder as Implement.
  - Verifier as Validate.

- Clarify how each:

  - Uses kits (PlanKit, AgentKit, etc.).
  - Interacts with CI, Knowledge Plane, and runtime policy.
  - Fits into the MAPE-K loop and planes.

### Orchestrator Agent (`agents/orchestrator`)

- Align with descriptions in `monorepo-layout.md` and `repository-blueprint.md`:

  - Orchestration/gateway agent exposing a stable HTTP port.
  - May call kits and other agents, coordinates AI work across the system.
  - Owns **no domain logic**.

- Focus on:

  - Its role as an orchestrator across Planner/Builder/Verifier/Kaizen and Runner.
  - How it fits in the planes and MAPE-K loops (particularly Plan/Execute coordination).
  - How it obeys runtime policy and contracts-first conventions.

### Shared Platform Runtime / Flow Runtime (`agents/runner/runtime/**` and platform runtime service)

- Align with `runtime-architecture.md` (if present), `python-runtime-workspace.md`, `monorepo-polyglot.md`, `monorepo-layout.md`, and `repository-blueprint.md`:

  - Single shared **platform runtime service** (Flow Runtime), currently implemented using LangGraph and exposed behind contracts such as `/flows/run` and related runtime APIs.
  - Executes FlowKit flows and AgentKit agents on behalf of apps, control-plane agents (Planner/Builder/Verifier/Orchestrator), and Kaizen/Autopilot subsystems.
  - Treated as runtime infrastructure behind contracts, **not** a kit and **not** a control-plane agent.

- Focus on:

  - Execution model for flows and agents, including how runs are identified, versioned, and isolated.
  - Contracts and API surface (runtime-flows concepts, `/flows/run` and friends, and their representation in `contracts/` and generated clients).
  - Observability and rollback patterns, including how runs are traced and audited across callers.
  - Clear non-goals:
    - No product/domain logic.
    - No independent control-plane decisions (planning, approvals, governance).
    - No bypass of contracts, policy, or feature-flag safeguards owned by agents/Kaizen/governance.

### Future / Custom Agents

- If a new agent under `agents/<name>` is introduced and documented:

  - Derive its responsibilities from:
    - `agent-roles.md` if it extends existing roles.
    - Any new architecture docs that describe it; if none exist, mark responsibilities as speculative/open questions.
  - Follow the same template and guardrails above.

---

## Style and Output Rules

When generating any of these docs:

- **Tone**:
  - Neutral, precise, prescriptive.
  - Focused on unblocking engineers and architects implementing and operating these agents.
- **Formatting**:
  - Use YAML frontmatter at the top (consistent with other architecture docs).
  - Use Markdown headings (`##`, `###`) consistent with the existing handbook style.
  - Use backticks for file paths, commands, flags, and code identifiers.
  - When embedding this prompt inside another prompt, escape any additional in-prompt code fences as ` \```lang ` … ` \``` ` to avoid interfering with the outer prompt. The Markdown skeletons above intentionally use real code fences for readability and copy/paste and are an explicit exception.
- **Cross-linking**:
  - Prefer short, direct cross-links to existing docs instead of restating their full content.
- **Evidence**:
  - When making specific claims about responsibilities or boundaries, root them in the referenced docs.
  - Do not restate entire documents; focus on what is necessary for understanding each agent.

---

<!-- Summary: This generalized prompt configures an AI architect/writer to create a complete suite of Harmony Architecture agent docs under `docs/handbooks/harmony/architecture/agents`, including an overview plus per-agent documents (Planner, Builder, Verifier, Orchestrator, Runner, and future agents). It anchors responsibilities and boundaries on existing normative docs (`monorepo-polyglot.md`, `python-runtime-workspace.md`, `monorepo-layout.md`, `repository-blueprint.md`, `agent-roles.md`, `runtime-policy.md`, `tooling-integration.md`, etc.) and defines a consistent template, content checklist, and agent-specific guidance, while requiring explicit handling of ambiguities as open questions. -->
