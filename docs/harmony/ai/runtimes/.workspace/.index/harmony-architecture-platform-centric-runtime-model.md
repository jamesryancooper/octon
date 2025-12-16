---
title: Harmony Runtime Architecture Documentation
description: Prompt for updating all Harmony Architecture docs to a platform-centric, future-proof runtime model.
version: 1.0.1
updated: 2025-11-19
---

# Harmony Runtime Architecture Documentation

You are an expert **software architect and technical writer** tasked with updating the **Harmony Architecture documentation** under:

- `docs/handbooks/harmony/architecture/**`

to reflect a **platform-centric, future-proof runtime model**. Your goal is to introduce and normalize a **platform runtime service** abstraction that can be shared across apps, agents, and Kaizen agents, while preserving Harmony’s clean architecture principles.

---

## Scope and Inputs

### In-scope documentation

You will work across all architecture documents in:

- `docs/handbooks/harmony/architecture/**`

Across these architecture docs, you must implement this runtime model consistently: any description of runtimes, “Runner”, LangGraph execution, or flow execution should be brought into alignment with the **platform runtime** model defined here and, where relevant, should reference the intended `platform/runtimes/flow-runtime/**` runtime layout described in this prompt as the target implementation path, rather than legacy or ad-hoc structures.

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
- `runtime-architecture.md` — the primary reference for the platform runtime model.
- Any other runtime-, flow-, or execution-related docs you discover.

### Out of scope

- Do **not** change product or feature-specific domain docs that do not touch runtime architecture.
- Do **not** invent new business features; constrain changes to **how runtime execution is modeled and described**.
- If any behavior is underspecified, record it as an **Open Question** rather than guessing.

---

## Target Runtime Architecture (Normative for Runtimes)

For the purposes of this prompt, treat the following **platform runtime model** as **normative** for all future runtime-related documentation. This runtime model defines the target implementation under a `platform/runtimes/**` layout, including **control-plane configuration for runtimes** under `platform/runtimes/config/` and **runtime-plane services** under `platform/runtimes/*-runtime/`. Documentation updates should describe and normalize this model (and its `platform/runtimes/flow-runtime/**` structure) as the reference architecture, rather than preserving purely conceptual or legacy designs. As runtime implementations are rolled out, keep the docs consistent with the actual code locations.

### 1. Platform runtime service, not a role-specific agent

- The runtime is a **platform runtime service** that executes flows/graphs on behalf of:
  - Apps.
  - Control-plane agents (Planner, Builder, Verifier, Orchestrator).
  - Kaizen/Autopilot agents.
- It is **not** a Planner/Builder/Verifier/Orchestrator-style agent:
  - It does **execution**, not planning or governance.
  - It lives primarily in the **runtime plane**, even though it is operated like other services.
- Example physical layout (reference this implementation):

```plaintext

platform/
  └─ runtimes/                        # Platform runtime services and control-plane configuration (see `runtime-architecture.md`)
      ├─ config/                      # Control-plane configuration for platform runtimes (policies, queues, risk tiers, env mappings)
      └─ flow-runtime/                # Implementation of the platform flow runtime service
          ├─ scheduler/               # Scheduler and execution abstraction (run state, queues, orchestration)
          ├─ execution/               # Executors, worker pools, and runtime interfaces
          ├─ api/                     # HTTP/gRPC front door, auth, validation
          └─ langgraph/               # LangGraph-based implementation of the platform flow runtime service
              ├─ assessment/…         # Graphs per flow
              ├─ server.py            # `/flows/run` HTTP for FlowKit
              └─ langgraph.json       # Studio entrypoints

```

Within this layout:

- `platform/runtimes/config/` is **control-plane configuration for platform runtimes**, not a runtime-plane service. It holds versioned configuration (for example, queue and worker profiles, risk tiers, policy bundles, and environment mappings) that shapes how platform runtime services behave.
- `platform/runtimes/*-runtime/` directories (such as `platform/runtimes/flow-runtime/`) are **runtime-plane services** that actually execute flows/graphs.

When updating docs, always use this distinction in wording (for example, “control-plane configuration for runtimes under `platform/runtimes/config/`” vs “runtime-plane services under `platform/runtimes/*-runtime/`”) to avoid collapsing configuration into the runtime plane itself.

### 2. Contract-first, multi-tenant, versioned

- Provide a **runtime contract** independent of any single agent:

  - `contracts/openapi/runtime-flows.yaml` (conceptual) with operations such as:
    - `POST /flows/run` — synchronous run.
    - `POST /flows/start` — async start.
    - `GET /flows/{runId}` — status.
    - `POST /flows/{runId}/cancel` — cancel.
    - `GET /flows/{flowId}/versions` — introspection.

- DTOs MUST support multi-tenant usage:

  - `projectId`, `environment`, `flowId`, `flowVersion`.
  - `callerKind` (e.g. `app`, `agent`, `kaizen`, `ci`).
  - `callerId` or equivalent.

- Flows are treated as **versioned artifacts**, not just code:

  - Identified at minimum by `(flowId, version)`.

### 3. Separated API, scheduler, and executors

Internally, the runtime service is decomposed into:

- **API / gateway tier**:
  - Stateless HTTP/gRPC front door.
  - Handles auth/authz, request validation, and routing.
  - In the reference `platform/runtimes/flow-runtime/` implementation, all external callers (including FlowKit) hit only this `api/` layer (for example, `/flows/run`, `/flows/start`); this is the unique public HTTP/gRPC surface for the runtime.
  - The `langgraph/server.py` entrypoint under `platform/runtimes/flow-runtime/langgraph/` is an internal engine/backend surface invoked by the `execution/` layer and must not be exposed as a separate public API.

- **Scheduler / orchestration tier** (internal to the runtime):
  - Decides **where** and **how** a run executes:
    - Sync vs async.
    - Which pool/queue and priority.
    - Concurrency limits and backpressure.
  - Maintains durable run state: `runId`, status, checkpoints.

- **Executor tier**:
  - One or more worker pools (e.g. LangGraph workers) that:
    - Pull jobs from queues.
    - Execute flows under resource constraints (CPU, memory, runtime).

### 4. Pluggable engines and tools

- The scheduler calls flows via an **execution backend abstraction**:

  - e.g., `FlowExecutionBackend` interface implemented by:
    - `LangGraphExecutionBackend`
    - `TemporalExecutionBackend`
    - `LocalSandboxExecutionBackend` (tests, demos)

- Tools (HTTP, DB, Git, CI, etc.) are integrated via **adapters**, not random imports:

  - Tools are configured through runtime configuration and secrets.
  - Flow authors depend on stable tool contracts, not low-level infra.

### 5. Isolation, policy, and observability

- Every run is tagged with:

  - Caller identity and `callerKind`.
  - Environment, project, and risk tier.
  - Feature / experiment flags in effect.

- Policy and safety:

  - Timeouts, step/token limits, concurrency caps per caller and env.
  - Policy hooks around dangerous operations (e.g. production writes).
  - Different policy profiles (interactive, kaizen/high-risk, CI-only, etc.).

- Observability:

  - Standard telemetry across all runs:
    - `flow_id`, `flow_version`, `run_id`, `caller_kind`, `caller_id`, `risk_tier`, `env`.
  - Traces span:
    - Caller → runtime API → scheduler → executor → tools.
  - Run metadata is queryable by Kaizen/governance systems.

### 6. State, storage, and idempotency

- The API tiers are **stateless**; run state is:

  - Stored in a durable database.
  - Checkpointed at meaningful steps.
  - Linked to external blobs (plans, diffs, attachments) when large.

- The runtime supports:

  - **Resumable runs** (restart from checkpoint).
  - **Idempotent operations** via a `clientRunKey`/similar.
  - **Replay & audit** for governance and debugging.

### 7. Integration pattern for apps, agents, and Kaizen

- Apps, agents, and Kaizen agents all:

  - Use **generated clients** from contracts (TS/Python, etc.).
  - Call the **same runtime APIs** with appropriate context.
  - Do **not** import the runtime’s engine internals directly.

- Control-plane behavior (planning, policy, governance) remains in:

  - Planner/Builder/Verifier/Orchestrator agents.
  - Kaizen/governance subsystems.

The runtime is a **shared, general-purpose execution substrate**; agents and apps **ask it to run things** rather than implementing runtime concerns themselves.

### 8. Relationship between control-plane runtimes and platform runtime services

- Harmony **intentionally supports both**:

  - **Control-plane runtimes** under `agents/*` that host Planner/Builder/Verifier/Orchestrator-style agents and other control-plane loops.
  - **Control-plane configuration for platform runtimes** under `platform/runtimes/config/` (for example, policy bundles, queue/worker profiles, and environment-specific defaults) that define how platform runtime services should behave in different environments and risk tiers.
  - **Platform runtime services** under `platform/runtimes/*-runtime/` (for example, `platform/runtimes/flow-runtime/**`) that implement the runtime plane and execute flows/graphs on behalf of callers.

- This is the **preferred and normative pattern**:

  - Control-plane runtimes and agents decide **what** to run, in what order, under which policies and contexts.
  - Control-plane configuration under `platform/runtimes/config/` encodes how those decisions are realized by the runtime (for example, risk tiers, queue selection, concurrency limits, and default policies).
  - Platform runtime services decide **how** runs are executed (scheduling, worker pools, resource limits, engine selection) and provide shared execution, policy enforcement, and telemetry across apps/agents/Kaizen, consuming configuration from `platform/runtimes/config/` rather than re-encoding policy.

- Documentation updated under this prompt should:

  - Treat control-plane runtimes (in `agents/*`) as **orchestration hosts**, not as general-purpose execution substrates.
  - Treat control-plane configuration for runtimes (in `platform/runtimes/config/`) as **control-plane metadata and policies** that shape how runtimes operate, not as runtime-plane services.
  - Treat platform runtime services (in `platform/runtimes/*-runtime/`) as **shared, multi-tenant execution substrates**, not as role-specific agents.
  - Make the **dependency direction explicit**: control-plane runtimes and agents **depend on** platform runtime services via contracts/clients; platform runtime services **must not depend on** control-plane runtimes or individual agents.
  - Avoid introducing “mini control planes” inside platform services (for example, re-defining global run/flow semantics there) that conflict with this runtime model.

- Where relevant (for example, in `monorepo-polyglot.md`, `monorepo-layout.md`, `agent-roles.md`, `runtime-architecture.md`):

  - Call out that it is **expected and healthy** to have both control-plane runtimes, control-plane configuration for runtimes, and platform runtime services in the same monorepo.
  - Emphasize clear boundaries, ownership, and planes (control plane vs runtime plane) rather than collapsing everything into a single “agent runtime.”

---

## Priority Rules and Conflict Resolution

When revising documentation:

1. **Runtime model (this prompt) is normative for runtimes**
   - For anything describing:
     - “Runner” / LangGraph runtime.
     - Flow execution.
     - Shared runtime across agents/apps/Kaizen.
   - Align it with the **platform runtime** model above.

2. **Other architectural docs remain normative elsewhere**
   - For:
     - Monorepo layout and workspace structure (`monorepo-polyglot.md`, `monorepo-layout.md`, `repository-blueprint.md`).
     - MAPE-K, agent roles, governance, Kaizen.
   - Keep existing intent unless it explicitly conflicts with the new runtime model.

3. **When conflict arises**
   - Prefer:
     - This **runtime model** for runtime-related concerns.
     - Existing docs for non-runtime concerns.
   - If a conflict is deep (e.g. path naming, planes definitions), either:
     - Update the affected doc to reconcile the model, and/or
     - Add a note that a human decision is required.

---

## Documentation Work Plan

You will **update** the existing runtime reference doc and **update** existing docs to reference and align with it.

### 1. Update `runtime-architecture.md` (canonical)

Update the existing `runtime-architecture.md` to reflect the new platform runtime model.

#### Required sections (normative)

The updated `runtime-architecture.md` document MUST include at least:

- **Frontmatter**:
  - `title`: Runtime Architecture
  - `description`: <1–2 lines summarizing the platform runtime service and its role.>
  - `version`: <semver>
  - `updated`: <ISO date>
- **`# Runtime Architecture`**
- **`## Audience and Scope`**:
  - Who should read this and why (platform engineers, SRE, AI toolkit integrators, agent authors, docs maintainers).
- **`## Role of the Platform Runtime`**:
  - Runtime-plane service vs control-plane agents.
  - How it relates to apps, agents, and Kaizen.
- **`## Contracts and Integration Model`**:
  - Contract-first API.
  - Multi-tenant flows, versioning, and client usage.
- **`## Internal Architecture of the Runtime`**:
  - API tier, scheduler, executors, pluggable backends.
- **`## Policy, Safety, and Observability`**:
  - Isolation, risk tiers, telemetry, audit.
- **`## Interaction Patterns`**:
  - Example flows for apps, agents, Kaizen.
- **`## Future Extensions`** (optional but recommended):
  - Additional flow engines, tooling ecosystems.
- **`## References`**:
  - Links to `monorepo-polyglot.md`, `monorepo-layout.md`, `python-runtime-workspace.md`, `tooling-integration.md`, `runtime-policy.md`, `agent-roles.md`, `kaizen-subsystem.md`, `governance-model.md`.

#### Example skeleton

Use this skeleton as a non-normative starting point:

```markdown
---

title: Runtime Architecture
description: <Platform runtime service for executing flows across apps, agents, and Kaizen.>
version: <semver>
updated: <ISO date>
---

# Runtime Architecture

## Audience and Scope

## Role of the Platform Runtime

## Contracts and Integration Model

## Internal Architecture of the Runtime

## Policy, Safety, and Observability

## Interaction Patterns

## Future Extensions

## References

```

### 2. Update `monorepo-polyglot.md`

- Ensure it:
  - Mentions the **platform runtime** explicitly as a shared service, separate from agents and kits.
  - Clarifies:
    - `apps/*` — things you run for end-users.
    - `agents/*` — **control-plane runtimes** you run for planning, building, verifying, orchestrating; they host agents and orchestration loops that **call** into platform runtime services instead of embedding their own general-purpose execution engines.
    - `platform/runtimes/config/` — **control-plane configuration for platform runtimes** (for example, risk tiers, queue/worker profiles, policy bundles, and environment mappings); lives in the control plane even though it is versioned alongside runtime code.
    - `platform/runtimes/*-runtime/` — **platform runtime services** following the target runtime layout (for example, the flow runtime under `platform/runtimes/flow-runtime/`), shared across apps/agents/Kaizen.
    - `packages/*`, `contracts/*` — things you import and generate from.
- Add cross-links to `runtime-architecture.md` where runtimes are discussed.

### 3. Update `monorepo-layout.md` and `repository-blueprint.md`

- Wherever “Runner” or LangGraph runtime is mentioned, update to:

  - Refer to the **platform runtime service** and its conceptual location (runtime plane).
  - Clarify that:
    - Agents **call** the runtime; they do not embed it.
    - Apps and Kaizen can also call it directly, via contracts.
  - Explicitly distinguish:
    - `platform/runtimes/config/` as **control-plane configuration for platform runtimes** (for example, policy bundles and environment-specific defaults).
    - `platform/runtimes/*-runtime/` as **runtime-plane services** that execute flows/graphs.

- Ensure it:
  - Describes the runtime as **shared** across agents/apps/Kaizen.
  - References `runtime-architecture.md` for deeper details.

### 4. Update `python-runtime-workspace.md`

- Reflect that Python code for the runtime is:

  - Part of the **platform runtime** located at `platform/runtimes/flow-runtime/langgraph/`, not bound to a single agent host.
  - Member of the uv workspace in a way consistent with the new layout.

- Clarify:
  - Generated Python clients from `contracts/py` are used by:
    - Apps/agents/Kaizen.
    - The runtime implementation itself (if needed for intra-platform calls).
  - FlowKit and other callers interact with the runtime only via the `api/` layer (for example, `/flows/run`, `/flows/start`), and `platform/runtimes/flow-runtime/langgraph/server.py` is documented as an internal engine entrypoint used by the `execution/` layer rather than as a separate public HTTP surface.

### 5. Update `tooling-integration.md` and `runtime-policy.md`

- Show how:

  - Runtime-specific policies (timeouts, concurrency limits, risk tiers) are enforced at the runtime layer.
  - Feature flags can control:
    - Which flows are allowed.
    - Which policy profile applies per caller, per env.

- Ensure tooling integration examples show:

  - Agents and apps calling the platform runtime via generated clients.
  - Observability wiring (runtime spans, run IDs) integrating with the broader platform.
  - Where appropriate, reference `platform/runtimes/config/` as the home for **control-plane configuration for runtimes** (for example, policy bundles, queue and worker profiles, and environment mappings) and make it clear that runtime services under `platform/runtimes/*-runtime/` consume this configuration rather than re-encoding policy.

### 6. Update `agent-roles.md` and `mape-k-loop-modeling.md`

- Clarify:

  - Agents (Planner/Builder/Verifier/Orchestrator) **do not own** the runtime.
  - They:
    - Plan, analyze, evaluate, orchestrate.
    - Call into the platform runtime to **execute** flows.

- Update any existing text that conflates “Runner” as an agent-like entity to:

  - Distinguish clearly between:
    - **Control-plane agents**.
    - The **platform runtime** as an infra service.

- Add cross-links to `runtime-architecture.md` where interactions with flows/runtimes are described.

### 7. Update `kaizen-subsystem.md`, `knowledge-plane.md`, `governance-model.md`

- Ensure:

  - Kaizen and governance flows treat the runtime as:
    - A **tool and substrate** they use to run experiments and changes.
    - A source of telemetry and audit logs for quality and compliance checks.
  - The runtime’s telemetry and run metadata are explicitly listed as:
    - Inputs to the Knowledge Plane and Kaizen loops.
    - Evidence in governance decisions (approvals, waivers, rollbacks).

- Clarify:

  - Which policies are enforced **within the runtime** vs **within Kaizen/governance** vs **within agents**.

### 8. Update any remaining runtime- or flow-related docs

- For any other runtime/flow-execution mentions:

  - Align the language with:
    - “Platform runtime service”.
    - Contracts-first access.
    - Shared usage across apps/agents/Kaizen.
    - The distinction between:
      - **Control-plane configuration for runtimes** under `platform/runtimes/config/`.
      - **Runtime-plane services** under `platform/runtimes/*-runtime/`.

- Add cross-links to `runtime-architecture.md` where appropriate.

If you cannot reconcile a conflict cleanly, favor:

- Keeping the new runtime model internally coherent.
- Marking areas needing human review.

---

## Style and Output Rules

When generating or updating docs:

- **Tone**:
  - Neutral, precise, prescriptive.
  - Focused on enabling engineers to implement, operate, and evolve the runtime safely.

- **Formatting**:
  - Use YAML frontmatter at the top of each architecture doc.
  - Use Markdown headings (`##`, `###`) consistent with the existing handbook style.
  - Use backticks for file paths, commands, flags, and code identifiers.

- **Cross-linking**:
  - Whenever the runtime is discussed, link to:
    - `runtime-architecture.md` for detailed runtime semantics.
    - Other docs (monorepo, tooling, policy, agent-roles, Kaizen) as appropriate.

- **Evidence and alignment**:
  - Root specific claims about runtime responsibilities and boundaries in:
    - This prompt’s runtime model (for runtime topics).
    - Existing Harmony docs (for all other topics).
  - Avoid restating content unnecessarily; prefer short, precise cross-references.

By following this prompt, you will evolve the Harmony Architecture documentation to treat the runtime as a **first-class platform service**, shared across apps, agents, and Kaizen, and ready for future engine and tooling evolution.
