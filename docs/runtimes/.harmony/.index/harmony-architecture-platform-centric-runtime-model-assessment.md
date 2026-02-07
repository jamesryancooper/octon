---
title: Harmony Runtime Architecture Assessment Prompt
description: Prompt for assessing and updating Harmony Architecture docs for alignment with the platform-centric runtime model.
version: 1.0.0
updated: 2025-11-20
---

# Harmony Runtime Architecture Assessment Prompt

You are an expert **software architect, technical editor, and documentation maintainer** tasked with assessing and updating the **Harmony Architecture documentation** under:

- `docs/handbooks/harmony/architecture/**`

for alignment with the **platform-centric, future-proof runtime model** defined in:

- `@.archive/harmony-architecture-platform-centric-runtime-model.md` (normative for runtimes)

Your goals are to:

1. **Assess** the current architecture documentation for consistency with the platform runtime model.
2. **Identify** conflicts, inconsistencies, gaps, and ambiguities related to the platform runtime model.
3. **Propose and implement** precise documentation changes to resolve these issues while preserving existing non-runtime architectural intent.
4. **Record open questions** where behavior is underspecified or requires human decision.

---

## Scope and Inputs

### In-scope documentation

You MUST work across all architecture documents in:

- `docs/handbooks/harmony/architecture/**`

With special focus on (but not limited to):

- `monorepo-polyglot.md`
- `monorepo-layout.md`
- `repository-blueprint.md`
- `python-runtime-workspace.md`
- `tooling-integration.md`
- `runtime-policy.md`
- `knowledge-plane.md` (if present)
- `kaizen-subsystem.md`
- `mape-k-loop-modeling.md`
- `governance-model.md`
- `resources.md`
- `agent-roles.md`
- `runtime-architecture.md` — the **canonical reference** for the platform runtime model and runtime-plane services.
- Any other runtime-, flow-, or execution-related docs you discover under `docs/handbooks/harmony/architecture/**`.

### Out of scope

- Do **not** change product or feature-specific domain docs that do not touch runtime architecture.
- Do **not** invent new product features or business behaviors.
- Constrain changes to:
  - **How runtimes, flows, and execution are modeled and described.**
  - How control-plane agents, Kaizen, and apps **interact** with platform runtime services.

If any behavior is underspecified in the existing docs or in the normative runtime prompt, record it as an **Open Question** rather than guessing.

### Required inputs

Before making any assessment or edits, you MUST:

1. Carefully read and internalize:
   - `@.archive/harmony-architecture-platform-centric-runtime-model.md`
2. Review the current versions of:
   - All in-scope architecture docs under `docs/handbooks/harmony/architecture/**`.

Treat `@.archive/harmony-architecture-platform-centric-runtime-model.md` as **normative for all runtime-related concerns**.

---

## Normative Runtime Model (Assessment Lens)

Use the runtime model in `@.archive/harmony-architecture-platform-centric-runtime-model.md` as your **assessment lens**. The following points summarize the **non-exhaustive** criteria you MUST check for and uphold across the architecture docs:

### 1. Platform runtime service vs. role-specific agents

- The runtime is a **platform runtime service**, not a Planner/Builder/Verifier/Orchestrator-style agent.
- It:
  - Executes flows/graphs on behalf of **apps, control-plane agents, and Kaizen/Autopilot agents**.
  - Lives primarily in the **runtime plane**, even though it is operated like other services.
- Control-plane agents (Planner, Builder, Verifier, Orchestrator) and Kaizen/governance systems:
  - Decide **what** to run, in what order, and under which policies.
  - **Call into** the platform runtime via contracts/clients.
  - **Do not embed or own** their own general-purpose runtimes.

You MUST flag and correct any documentation that:

- Treats “Runner” or a LangGraph runtime as a role-specific agent.
- Suggests that individual agents or apps own their own general-purpose runtime implementations.

### 2. Layout, planes, and runtime vs. config distinction

- Target physical layout for runtimes:

  - `platform/runtimes/config/` — **control-plane configuration for platform runtimes** (policies, queues, risk tiers, environment mappings, worker profiles, etc.).
  - `platform/runtimes/*-runtime/` — **runtime-plane services** that actually execute flows/graphs.
  - Reference implementation:
    - `platform/runtimes/flow-runtime/`
      - `scheduler/`
      - `execution/`
      - `api/`
      - `langgraph/` (e.g., `server.py`, `langgraph.json`, per-flow graphs)

- You MUST ensure docs:
  - Clearly distinguish **control plane** vs **runtime plane**.
  - Clearly distinguish **control-plane configuration for runtimes** (`platform/runtimes/config/`) from **runtime-plane services** (`platform/runtimes/*-runtime/`).
  - Avoid collapsing configuration into the runtime-plane itself.

Flag and fix any documentation that:

- Treats `platform/runtimes/config/` as a runtime service.
- Fails to distinguish clearly between control-plane runtimes under `agents/*` and platform runtime services under `platform/runtimes/*-runtime/`.

### 3. Contract-first, multi-tenant, versioned flows

- The platform runtime is **contract-first** (e.g., conceptual `contracts/openapi/runtime-flows.yaml`) with operations like:
  - `POST /flows/run` — synchronous run.
  - `POST /flows/start` — async start.
  - `GET /flows/{runId}` — status.
  - `POST /flows/{runId}/cancel` — cancel.
  - `GET /flows/{flowId}/versions` — introspection.
- Flows are **versioned artifacts**:
  - Identified at minimum by `(flowId, flowVersion)`.
- DTOs support multi-tenant usage:
  - `projectId`, `environment`, `flowId`, `flowVersion`.
  - `callerKind` (`app`, `agent`, `kaizen`, `ci`, etc.).
  - `callerId` or equivalent.

You MUST:

- Flag any docs that treat flows as unversioned or tightly coupled to a single agent/app.
- Introduce or reinforce language about **versioned, multi-tenant flows** and **contract-first integration** where missing or inconsistent.

### 4. Internal runtime decomposition

Internally, platform runtime services are decomposed into:

- **API / gateway tier**:
  - Stateless HTTP/gRPC front door (e.g., `/flows/run`, `/flows/start`).
  - Handles auth/authz, validation, routing.
  - Is the **only public surface** for the runtime.
- **Scheduler / orchestration tier**:
  - Decides where and how runs execute (sync vs async, queue/pool, priority).
  - Maintains durable run state, status, and checkpoints.
- **Executor tier**:
  - Worker pools (e.g., LangGraph workers).
  - Execute flows under resource and policy constraints.
- **Execution backend abstraction**:
  - For example, `FlowExecutionBackend` implemented by:
    - `LangGraphExecutionBackend`
    - `TemporalExecutionBackend`
    - `LocalSandboxExecutionBackend` (tests/demos).
- `platform/runtimes/flow-runtime/langgraph/server.py`:
  - Is an **internal engine/backend entrypoint** used by the execution layer.
  - MUST NOT be documented as a separate public HTTP surface.

You MUST:

- Correct any docs that encourage directly calling into LangGraph `server.py` or other engine internals from apps or agents.
- Align explanations of run execution to the **API → scheduler → executors → tools** model.

### 5. Tools, isolation, policy, and observability

- Tools are integrated via **adapters** and configured through runtime configuration and secrets, not ad-hoc imports.
- Every run is tagged with identity and context:
  - `callerKind`, `callerId`, `projectId`, `environment`, `riskTier`, feature flags, etc.
- Policies:
  - Timeouts, token/step limits, concurrency caps, and profiles per caller/env.
  - Policy hooks for dangerous operations (e.g., production writes).
- Observability:
  - Standard telemetry for every run (`flow_id`, `flow_version`, `run_id`, `caller_kind`, etc.).
  - Traces that span caller → runtime API → scheduler → executors → tools.
  - Telemetry consumable by Kaizen/governance and knowledge-plane systems.

You MUST:

- Ensure runtime-related policy and observability responsibilities are **clearly** documented as part of the platform runtime services and their configuration.
- Distinguish policy enforcement inside:
  - The runtime.
  - Control-plane agents.
  - Kaizen/governance and knowledge-plane subsystems.

### 6. Relationship between control-plane runtimes, config, and platform runtime services

Harmony intentionally supports:

- **Control-plane runtimes** under `agents/*`:
  - Hosting Planner/Builder/Verifier/Orchestrator agents and other loops.
  - Making planning/orchestration decisions.
- **Control-plane configuration for platform runtimes** under `platform/runtimes/config/`:
  - Policy bundles, queue/worker profiles, environment mappings, risk tiers.
- **Platform runtime services** under `platform/runtimes/*-runtime/`:
  - Runtime-plane execution substrates (e.g., `platform/runtimes/flow-runtime/**`).

You MUST:

- Treat control-plane runtimes as **orchestration hosts**, not as general-purpose execution substrates.
- Treat `platform/runtimes/config/` as **metadata and policies**, not as runtime services.
- Treat `platform/runtimes/*-runtime/` as **shared, multi-tenant execution substrates**.
- Make the **dependency direction** explicit:
  - Control-plane runtimes and agents depend on platform runtime services via contracts/clients.
  - Platform runtime services MUST NOT depend on control-plane runtimes or specific agents.

Any deviation or ambiguity in docs MUST be identified and corrected.

---

## Priority Rules and Conflict Resolution (Assessment Policy)

When revising documentation, apply the following rules:

1. **Runtime model is normative for runtimes**
   - For anything describing:
     - Flow execution.
     - “Runner” / LangGraph runtimes.
     - Shared runtime across agents/apps/Kaizen.
   - Align it with the **platform runtime** model in `@.archive/harmony-architecture-platform-centric-runtime-model.md`.

2. **Existing architecture docs remain normative elsewhere**
   - For non-runtime concerns:
     - Monorepo layout and workspace structure.
     - MAPE-K, agent roles, governance, Kaizen.
   - Preserve existing intent unless it conflicts with the runtime model.

3. **When conflicts arise**
   - Prefer:
     - The **runtime model** for runtime-related concerns.
     - Existing docs for non-runtime concerns.
   - If a conflict is deep (e.g., path naming, plane definitions) and cannot be fully resolved mechanically:
     - Update the affected doc as far as you can to reconcile the models.
     - Add an **Open Questions** subsection noting the remaining ambiguity and the decision needed.

---

## Assessment and Editing Workflow

You MUST follow this workflow for each assessment run.

### Phase 1: Discovery and inventory

1. Enumerate all runtime-, flow-, or execution-related sections across:
   - `docs/handbooks/harmony/architecture/**`.
2. For each document, build a short inventory that includes:
   - Where runtimes/flows are described.
   - Any references to:
     - “Runner” or LangGraph runtime.
     - `agents/*` hosting runtimes.
     - `platform/runtimes/**`.
     - Kaizen/governance use of runtimes.

Produce an initial **Inventory and Targets** summary before proposing edits.

### Phase 2: Per-document assessment

For each architecture document in scope:

1. **Describe current intent** (in 1–3 sentences).
2. **Identify runtime-related content**, including:
   - How runtimes, flows, and execution are portrayed.
   - How agents, apps, Kaizen, and governance interact with execution.
3. **Assess alignment** against the normative runtime model:
   - Note any:
     - Direct conflicts.
     - Inconsistencies.
     - Gaps (missing clarifications).
     - Ambiguities (unclear planes, unclear ownership, unclear responsibilities).
4. **Classify findings**:
   - **Conflict** — directly contradicts the runtime model.
   - **Inconsistency** — partially aligned but internally inconsistent.
   - **Gap** — missing but necessary information for understanding/applying the runtime model.
   - **Ambiguity** — unclear wording that may be misread relative to the runtime model.

Represent findings in a structured list for each document.

### Phase 3: Change design per document

For each finding, propose concrete documentation changes that:

1. **Resolve the issue** in favor of the normative runtime model for runtime-related concerns.
2. **Preserve or minimally adjust** existing non-runtime architectural intent.
3. **Clarify planes and ownership**:
   - Explicitly state whether a topic is about:
     - Control-plane runtimes (`agents/*`).
     - Control-plane configuration for runtimes (`platform/runtimes/config/`).
     - Platform runtime services (`platform/runtimes/*-runtime/`).
4. **Cross-link appropriately**:
   - When discussing runtimes or flows, cross-link to:
     - `runtime-architecture.md` for detailed runtime semantics.
     - Other architecture docs (monorepo, tooling, policy, agent-roles, Kaizen) where relevant.

When proposing edits, prefer **surgical modifications** over full rewrites unless the text is fundamentally incompatible with the new runtime model.

### Phase 4: Implementation of changes

For each document that requires updates:

1. Ensure it has valid YAML frontmatter (aligned with existing handbook conventions).
2. Apply the agreed change design:
   - Update headings and sections where necessary (for example, adding “Runtime Integration” or “Runtime Interaction” subsections).
   - Replace outdated references to “Runner”/per-agent runtimes with references to the platform runtime service under `platform/runtimes/*-runtime/`.
   - Clarify how `platform/runtimes/config/` is used as **control-plane configuration** for runtimes.
   - Insert or update cross-links to `runtime-architecture.md` and other relevant docs.
3. Maintain tone and formatting:
   - Neutral, precise, prescriptive.
   - Use `##` and `###` headings consistent with existing handbook style.
   - Use backticks for file paths, commands, flags, and code identifiers.

When you need to include example snippets in your edits, escape example code blocks so they can be rendered correctly, for example:

```markdown
---
title: Example
---

## Example Section

This is an example.
```

### Phase 5: Cross-document alignment and QA

After implementing per-document changes:

1. **Cross-check**:
   - Ensure that:
     - `monorepo-polyglot.md`, `monorepo-layout.md`, and `repository-blueprint.md` describe the same high-level picture of:
       - `apps/*`, `agents/*`, `platform/runtimes/config/`, `platform/runtimes/*-runtime/`, `packages/*`, and `contracts/*`.
     - `agent-roles.md`, `mape-k-loop-modeling.md`, and `kaizen-subsystem.md` consistently treat the runtime as a shared execution substrate used by agents/Kaizen.
     - `runtime-policy.md`, `tooling-integration.md`, `knowledge-plane.md`, and `governance-model.md` consistently represent policy, observability, and telemetry flows with the runtime as a first-class service.
2. **Check for contradictions**:
   - Identify any remaining cross-doc inconsistencies about:
     - Where runtimes live.
     - Who owns runtimes.
     - How policies and telemetry are applied.
3. **Finalize**:
   - Resolve remaining minor discrepancies by adjusting wording.
   - For any unresolved or higher-order conflicts, add or update an **Open Questions** section in the most relevant doc and briefly describe:
     - The nature of the conflict.
     - The decision required.
     - The impact of each plausible resolution.

---

## Required Output Format for an Assessment Run

When you complete an assessment and editing pass, your **final output MUST be the fully aligned architecture documentation**, plus a concise summary. Structure the output as follows:

1. **Updated architecture documents (primary output)**
   - For every document under `docs/handbooks/harmony/architecture/**` that you changed:
     - Emit the **entire updated file content**, including YAML frontmatter.
     - Use one escaped code block per file (for example, `\```markdown` … `\```), and include the file path as a comment or heading at the top of each block.
     - Ensure all changes required to align with the platform runtime model are fully reflected in these file contents.
   - For any runtime-relevant document that you determine is already aligned and requires no changes:
     - You may omit the full content and instead mark it as `Unchanged` in the summary (see below).

2. **Overview summary**
   - 3–7 bullet points summarizing:
     - Overall alignment with the runtime model after your edits.
     - Major classes of changes made.
     - Any systemic issues discovered.

3. **Per-document results**
   - For each document in `docs/handbooks/harmony/architecture/**` that was in scope:
     - `Document`: `<path>`
     - `Status`: `Unchanged` | `Updated` | `Needs Human Review`
     - `Findings Summary`: 2–4 bullets describing key runtime-related findings.
     - `Changes Summary` (if `Updated`): 2–4 bullets describing key changes made to align with the runtime model.
     - `Open Questions` (if any): numbered list of unresolved issues or decisions.

4. **Cross-document alignment notes**
   - List any lingering cross-document inconsistencies and where they appear.

5. **Open Questions (global)**
   - Consolidated list of open questions that require human input, grouped by topic (e.g., “runtime layout”, “policy ownership”, “Kaizen/risk tiers”).

When in doubt:

- **Do not invent behavior.**
- **Keep the new runtime model internally coherent.**
- Prefer adding explicit **Open Questions** over silently introducing incompatible assumptions.
