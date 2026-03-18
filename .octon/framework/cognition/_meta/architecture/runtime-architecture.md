---
title: Runtime Architecture
description: Platform runtime service for executing flows across apps, agents, and Kaizen with contract-first, multi-tenant, observable execution.
version: 1.0.1
updated: 2025-11-20
---

# Runtime Architecture

The Octon platform exposes a **shared, platform-level runtime service** that executes flows and graphs on behalf of:

- Applications (for example, `apps/api`, `apps/ai-console`).
- Control-plane agents (Planner, Builder, Verifier, Orchestrator).
- Kaizen/Autopilot and governance subsystems.

This runtime is a **runtime-plane service**, not a role-specific agent. It focuses on **execution** (scheduling, running, checkpointing, and observing flows) while control-plane agents and kits remain responsible for planning, policy, and governance.

Related docs: [overview](./overview.md), [monorepo polyglot](./monorepo-polyglot.md), [monorepo layout](./monorepo-layout.md), [repository blueprint](./repository-blueprint.md), [runtime policy](./runtime-policy.md), [tooling integration](./tooling-integration.md), [observability requirements](./observability-requirements.md), [agent roles](./agent-roles.md), [MAPE-K modeling](./mape-k-loop-modeling.md), [kaizen subsystem](./kaizen-subsystem.md), [knowledge plane](../../runtime/knowledge/knowledge.md), [governance model](./governance-model.md), [resources](./resources.md).

## Audience and Scope

This document is intended for:

- **Platform engineers and SREs** operating runtime services, observability, and policies.
- **AI toolkit integrators** and kit authors (for example, FlowKit, AgentKit, EvalKit, PolicyKit).
- **Agent authors** working on Planner/Builder/Verifier/Orchestrator and Kaizen agents.
- **Application developers** integrating with flows from `apps/*`.
- **Docs maintainers and architects** evolving Octon’s runtime model.

Scope:

- Defines the **logical and physical model** of the platform runtime service.
- Specifies the **contracts and integration patterns** used by apps, agents, and Kaizen.
- Describes **internal tiers** (API, scheduler, executors) and how they enforce policy and observability.
- Clarifies **responsibility boundaries** between runtime, agents, kits, Kaizen, and governance.

This document is **normative for runtime behavior**; where other docs describe flow execution or shared runtimes, they should align with this model.

## Role of the Platform Runtime

### Runtime-plane service vs control-plane agents

The platform runtime lives in the **runtime plane** alongside other deployable processes, but its responsibilities are deliberately narrow:

- **Platform runtime (runtime plane):**
  - Executes flows and graphs under resource and policy constraints.
  - Schedules, checkpoints, and resumes runs.
  - Enforces runtime-level safety and quota policies.
  - Emits structured telemetry and run metadata.
- **Control plane (kits and agents):**
  - **Kits** in `packages/kits/*` (for example, FlowKit, AgentKit, EvalKit, PolicyKit) define contracts, orchestration logic, and CI/policy wiring.
  - **Agents** under `agents/*` (Planner, Builder, Verifier, Orchestrator, Kaizen-specific agents) plan, analyze, evaluate, and orchestrate work using those kits.
  - **Governance/Kaizen subsystems** interpret telemetry, apply risk rubrics, and decide what should run, roll back, or be promoted.

Key separation:

- The runtime **does not perform planning or governance**; it executes what it is asked to run, within configured guardrails.
- Agents and apps **do not embed runtime engines directly**; they **call the platform runtime service** via contracts and generated clients.

### Physical layout and runtime families

Logically, the platform runtime is modeled as one or more **runtime families** under a canonical `platform/runtimes/*` hierarchy:

- `platform/runtimes/config/` — **control-plane configuration for platform runtimes** (for example, policy bundles, queue and worker profiles, risk tiers, and environment mappings). This directory lives in the control plane even though it is versioned alongside runtime code; runtime services read from it but do not re-encode policy.
- `platform/runtimes/flow-runtime/**` — **runtime-plane service** that executes product and platform flows on behalf of apps, agents, and Kaizen. It implements the API, scheduler, and executor tiers described in this document.
- `platform/runtimes/eval-runtime/**` — (future) runtime-plane service for scoring, metrics, and quality checks (for example, EvalKit/Eval flows).
- `platform/runtimes/batch-runtime/**` — (future) runtime-plane service for offline or long-running maintenance and data-processing flows.

In the current monorepo, the LangGraph-based implementation of the **flow runtime** lives under:

- `platform/runtimes/flow-runtime/langgraph/**` — LangGraph-based engine and graph definitions used by the platform flow runtime service.

Within this layout:

- External callers (apps, agents, Kaizen, FlowKit) interact only with the **public runtime APIs** exposed by the `platform/runtimes/flow-runtime/api/` layer (for example, `/flows/run`, `/flows/start`), as defined in the root `contracts/` registry.
- Internal engine entrypoints such as `platform/runtimes/flow-runtime/langgraph/server.py` are treated as **backend surfaces** invoked by the runtime’s execution tier; they MUST NOT be exposed as separate public HTTP surfaces or imported directly by apps/agents.

Docs, tooling, and contracts treat `platform/runtimes/*` as the **canonical home** for platform runtime services and `platform/runtimes/config/` as the canonical home for their control-plane configuration.

### Relationship to apps, agents, and Kaizen

- **Apps (`apps/*`)**:
  - Are thin HTTP/UI/CLI hosts.
  - Use kits (for example, FlowKit) and generated clients to request flow execution from the runtime (for example, `POST /flows/run` for synchronous runs, or `POST /flows/start` followed by `GET /flows/{runId}`).
- **Control-plane agents (`agents/planner`, `agents/builder`, `agents/verifier`, `agents/orchestrator`)**:
  - Use the same contracts and clients to ask the runtime to execute flows (for example, evaluation runs, codemods, or orchestrated multi-step flows).
  - Treat the runtime as an execution substrate; they remain focused on orchestration, analysis, and decision-making.
- **Kaizen and governance subsystems**:
  - Use runtime telemetry and run metadata (for example, `flow_id`, `flow_version`, `run_id`, `caller_kind`, `risk_tier`) as inputs to risk scoring, quality evaluation, and continuous improvement loops.
  - May schedule experiments or checks as flows executed via the runtime, under stricter policy profiles.

## Contracts and Integration Model

### Contract-first runtime APIs

The runtime exposes **contract-first APIs** in the root `contracts/` registry that are independent of any specific agent or app. At minimum:

- **Flow Runtime (flow-runtime)**:
  - Conceptual OpenAPI: `contracts/openapi/runtime-flows.yaml`.
  - Typical operations:

  - `POST /flows/run` — synchronous run; returns final result or terminal state.
  - `POST /flows/start` — asynchronous start; returns a `runId`.
  - `GET /flows/{runId}` — fetch status, checkpoints, and partial results.
  - `POST /flows/{runId}/cancel` — request cancellation.
  - `GET /flows/{flowId}/versions` — introspection and metadata.
- **Eval Runtime (eval-runtime)**:
  - Conceptual OpenAPI: `contracts/openapi/runtime-evals.yaml`.
  - Exposes evaluation-oriented operations (for example, start evaluation run, fetch evaluation results and metrics) with similar run semantics but optimized for scoring/QA workloads.
- **Batch Runtime (batch-runtime)**:
  - Conceptual OpenAPI: `contracts/openapi/runtime-batch.yaml`.
  - Exposes operations for starting, monitoring, and cancelling batch jobs.

All runtime-family contracts:

- Are **versioned** and published through the `contracts/` registry.
- Are **language-agnostic**: TypeScript and Python clients are generated from the same OpenAPI/JSON Schema definitions and imported by callers.
- Are **stable**: runtime implementation details (for example, LangGraph vs Temporal) are hidden behind the API contract.

### Multi-tenant DTOs and caller context

All runtime DTOs are designed for **multi-tenant, multi-caller** usage. At minimum, runtime request and run records MUST carry:

- `projectId` — owning project or workspace.
- `environment` — for example, `development`, `staging`, `production`.
- `flowId` / `flowVersion` — identity and version of the flow artifact.
- `callerKind` — for example, `app`, `agent`, `kaizen`, `ci`.
- `callerId` — concrete caller identity (for example, app name, agent name, CI pipeline).
- Optional: `riskTier`, feature/experiment flags, and additional labels.

This metadata:

- Drives **policy selection** (for example, stricter limits for Kaizen or CI, relaxed limits for interactive development).
- Enables **observability and governance** by tagging traces, logs, and metrics with caller and flow attributes.
- Supports **multi-tenant isolation** and quota management.

### Flows as versioned artifacts

Flows are treated as **versioned artifacts**, not ad hoc code:

- Identified by at least `(flowId, flowVersion)`.
- Stored and deployed through the same discipline as application code (for example, version control, CI validation, promotion gates).
- Referenced by callers only via **IDs and versions** plus typed input/output schemas, not by importing engine internals.

This enables:

- Deterministic, reproducible runs.
- Auditability of “what ran” and “with which version” in incident or governance reviews.
- Safe rollbacks to known-good flow versions.

### Generated clients and integration patterns

Callers do not handcraft HTTP calls; they:

- Use **generated clients** from `contracts/ts/*` (TypeScript) or `contracts/py/*` (Python).
- Treat the runtime API as any other external dependency with:
  - Typed request/response DTOs.
  - Explicit error types and retry/idempotency behavior.
  - Policy-aware configuration surfaces (for example, risk profile, timeout hints).

Examples:

- `apps/api` uses a TypeScript client for `runtime-flows` to start and monitor flows in response to HTTP requests.
- `agents/builder` uses a Python client to trigger flows for code generation or refactor steps.
- Kaizen flows use the same clients to schedule hygiene or evaluation runs.

## Internal Architecture of the Runtime

### Overview

Internally, the runtime is decomposed into three primary tiers:

1. **API / gateway tier** — stateless front door (HTTP/gRPC).
2. **Scheduler / orchestration tier** — run lifecycle, queues, and policy-aware scheduling.
3. **Executor tier** — worker pools that execute flows using pluggable execution backends.

The objective is to keep the **external contract** stable while allowing internal evolution (for example, changing queue technologies or flow engines) without breaking callers.

### API / gateway tier

Responsibilities:

- Accept runtime API calls, validate requests, and perform authentication/authorization.
- Normalize caller context and attach standard metadata (for example, caller identifiers, project, environment, risk tier).
- Map high-level operations (`/flows/run`, `/flows/start`) into scheduler commands.
- Remain **stateless**; no durable run state is stored in the gateway.

Characteristics:

- Horizontally scalable, with idempotent handling for retried requests.
- Safe to deploy independently as long as its contract with the scheduler tier remains stable.
- Instrumented with request-level telemetry that correlates to scheduler and executor traces.

### Scheduler / orchestration tier

Responsibilities:

- Maintain **durable run state**, including:
  - `runId`, status, timestamps.
  - Checkpoints and partial results.
  - Caller metadata and policy profile in effect.
- Decide **where and how** a run executes:
  - Synchronous vs asynchronous execution.
  - Queue selection and priority.
  - Concurrency limits and backpressure behavior.
- Enforce **runtime-level policies**:
  - Timeouts, step/token limits, resource caps.
  - Per-caller and per-environment quotas.
  - Risk-tier-specific restrictions (for example, blocking high-risk operations in certain environments).
- Coordinate **resumable runs**, **retries**, and **cancellations**.

Characteristics:

- Backed by durable storage (for example, relational DB or durable key-value store).
- Emits events or telemetry on state transitions (for example, `RUN_STARTED`, `RUN_COMPLETED`, `RUN_FAILED`, `RUN_CANCELLED`).
- Provides queries for run history and metadata (used by observability, Kaizen, and governance systems).

### Executor tier and pluggable execution backends

The executor tier consists of one or more **worker pools** that:

- Pull jobs from queues assigned by the scheduler.
- Execute the specified flow under resource limits.
- Periodically checkpoint progress and report status back to the scheduler.

Workers do not embed a single flow engine; instead, they call flows via an **execution backend abstraction**.

#### `FlowExecutionBackend` contract

All runtime families (`flow-runtime`, `eval-runtime`, `batch-runtime`) use a common minimal backend interface, conceptually:

- `FlowExecutionBackend`:
  - `start_run(request: FlowRunRequest) -> BackendRunHandle`
  - `resume_run(handle: BackendRunHandle) -> BackendRunHandle`
  - `cancel_run(handle: BackendRunHandle) -> None`
  - `get_run_status(handle: BackendRunHandle) -> BackendRunStatus`
- Where:
  - `FlowRunRequest` includes `flowId`, `flowVersion`, input payload, caller metadata (`callerKind`, `callerId`, `projectId`, `environment`, optional `riskTier`), runtime family (`runtimeFamily`, for example, `flow`, `eval`, `batch`), and optional `clientRunKey`.
  - `BackendRunStatus` includes current status, error information (if any), last checkpoint (or pointer), and basic metrics (for example, tokens/steps used where applicable).

In code, `FlowExecutionBackend` interfaces and associated types live in shared **platform runtime packages**, for example:

- TypeScript: `platform/runtime/src/flow-execution-backend.ts`.
- Python: `platform/runtime/py/flow_execution_backend.py`.

Implementations can vary by engine or runtime family:

- `LangGraphExecutionBackend` — current default, using LangGraph for graph execution in the flow runtime.
- `TemporalExecutionBackend` — potential future engine for long-running or highly reliable workflows.
- `LocalSandboxExecutionBackend` — test/demo engine for local development or CI sandboxes.

Benefits:

- Callers are insulated from engine changes.
- Multiple backends and runtime families can coexist (for example, `flow-runtime` vs `eval-runtime`) while sharing a common abstraction.
- Easier experimentation with new engines or sandboxes without changing app/agent code.

## Policy, Safety, and Observability

### Policy enforcement in the runtime

The runtime enforces **runtime-level policies** derived from global governance rules but applied locally at execution time:

- **Resource and concurrency controls**:
  - Timeouts per run and per step.
  - Token/step limits (where applicable).
  - Concurrency caps per caller, per environment, or per flow.
- **Risk-aware routing**:
  - Different queues and resource pools for interactive vs batch vs Kaizen runs.
  - High-risk flows (for example, production writes, destructive operations) routed through stricter policies or pre-approved profiles.
- **Guardrails around dangerous operations**:
  - Policy hooks that can reject or require additional approval for certain operations.
  - Integration with governance systems for allowlists/denylists or risk overrides.

Runtime policies are **configurable** but **not bypassable** by individual callers. Kits and agents can choose among available profiles (for example, interactive vs Kaizen), but the runtime is the final arbiter of allowed resource use and certain operation types.

### Observability and telemetry

The runtime is a **first-class telemetry producer**. Every run MUST emit structured observability signals that include:

- **Standard attributes** (as tags/labels on traces, logs, and metrics) drawn from the canonical **RuntimeRun** schema:
  - `flow_id` — identifier of the flow.
  - `flow_version` — version of the flow artifact.
  - `run_id` — stable identifier of this run across retries and restarts.
  - `caller_kind` — for example, `app`, `agent`, `kaizen`, `ci`.
  - `caller_id` — concrete caller identity (for example, app name, agent name, CI pipeline).
  - `project_id` — owning project or workspace.
  - `environment` — for example, `development`, `staging`, `production`.
  - `runtime_family` — for example, `flow`, `eval`, `batch`.
  - `risk_tier` — optional risk classification for the run.
  - `flags` — optional feature/experiment flags in effect (low-cardinality encoding).
- **Traces spanning the full path**:
  - Caller → runtime API → scheduler → executor → tools/adapters.
  - Consistent propagation of trace context across internal tiers and external tool calls.
- **Run metadata**:
  - `status` — current status (for example, `pending`, `running`, `succeeded`, `failed`, `cancelled`).
  - `started_at`, `updated_at`, and (when complete) `completed_at` timestamps.
  - Error summaries where applicable.
  - Checkpoint summaries (for example, important milestones in long-running flows).

The **RuntimeRun** schema is canonical for:

- Runtime storage of run records in the scheduler’s durable store.
- Observability attributes in traces/logs/metrics (see `observability-requirements.md`).
- Knowledge Plane representations of runtime runs (see `knowledge.md`), so Kaizen and governance systems can query and correlate runtime executions consistently.

This telemetry:

- Feeds into the **Knowledge Plane** for indexing, search, and correlation with specs and contracts.
- Powers **Kaizen evaluators** and governance processes (for example, identifying flaky flows, policy violations, or regression patterns).
- Enables **SRE and platform teams** to understand capacity, hot flows, and failure modes.

### State, storage, and idempotency

API/gateway components are stateless. The runtime’s state model follows these principles:

- **Durable run state**:
  - Stored in a resilient database or equivalent.
  - Checkpoints are taken at meaningful points in the flow (for example, after external side effects or long computations).
- **Idempotency**:
  - Operations support a `clientRunKey` or equivalent idempotency key.
  - Retried requests with the same key do not create duplicate runs or side effects.
- **Resumability and replay**:
  - Runs can be resumed from checkpoints where safe to do so.
  - Replay capabilities exist for debugging and governance (with appropriate safeguards against re-running side effects).

Downstream tooling (for example, Kaizen, observability dashboards) MUST treat run state and metadata as the **source of truth** for “what executed” rather than inferring from logs alone.

## Interaction Patterns

### 1. App-triggered flow (interactive request)

Example: `apps/api` handles an HTTP request that should trigger a short-lived flow.

1. The app controller validates the request and constructs a runtime client request including:
   - `projectId`, `environment`, `flowId`, `flowVersion`, `callerKind="app"`, `callerId="apps/api"`.
2. The app calls `POST /flows/run` via the generated `runtime-flows` TypeScript client.
3. The runtime API authenticates the request, validates DTOs, and forwards to the scheduler.
4. The scheduler:
   - Allocates the run to an appropriate queue and resource pool for interactive workloads.
   - Enforces per-caller limits and timeouts.
   - Schedules work to an executor worker pool.
5. The executor executes the flow using the configured execution backend (for example, LangGraph), checkpointing as needed.
6. On completion, the runtime returns the final result or failure to the app, with trace context preserved for observability.

### 2. Agent-triggered flow (control-plane orchestration)

Example: `agents/builder` needs to run a code-generation or refactor flow as part of a larger plan.

1. The Builder agent computes the desired flow and inputs and selects an appropriate policy profile (for example, `callerKind="agent"`, `riskTier="medium"`).
2. It calls `POST /flows/start` via the Python `runtime-flows` client.
3. The runtime scheduler:
   - Routes the run to a queue with resource limits suitable for agent workflows.
   - Applies policy constraints (for example, additional checks for production-affecting changes).
4. The agent periodically polls `GET /flows/{runId}` or subscribes to events until completion.
5. The agent uses run outputs and telemetry to decide next steps (for example, whether to open a PR).

### 3. Kaizen/governance-triggered flow (batch or experiments)

Example: Kaizen subsystem runs scheduled hygiene or evaluation flows across the codebase.

1. A Kaizen evaluator decides which flows to run (for example, “run observability scaffolding checks for all services”).
2. It uses the runtime client with `callerKind="kaizen"` and a high-safety policy profile to start flows, often via `POST /flows/start`.
3. The runtime:
   - Routes these runs to lower-priority queues and constrained resource pools.
   - Enforces stricter policies (for example, read-only modes in production, limited concurrency).
4. Kaizen jobs collect run results and structured telemetry as evidence.
5. Reports and PRs reference `runId`s, traces, and flow versions as part of the audit trail.

## Future Extensions

The runtime model is explicitly designed to support future evolution without breaking callers:

- **Multiple runtime instances**:
  - Separate but consistently designed runtimes (for example, `flow-runtime`, `eval-runtime`) for different workloads.
  - Shared contract patterns and metadata but distinct physical deployments or configuration profiles.
- **Additional execution backends**:
  - Support for novel flow engines or orchestration frameworks via the `FlowExecutionBackend` abstraction.
  - Sandboxed or ephemeral engines for experimentation and local development.
- **Advanced scheduling and placement**:
  - Placement decisions based on data locality, latency SLOs, and cost profiles.
  - Dynamic autoscaling and preemption aware of caller and flow importance.
- **Deeper integration with the Knowledge Plane**:
  - Automated ingestion of run metadata into knowledge indexes.
  - Cross-linking flows, runs, specs, contracts, and incidents for richer context.

These extensions should preserve:

- The **contract-first, versioned** nature of runtime APIs.
- The **separation of responsibilities** between runtime execution and control-plane planning/governance.
- The **multi-tenant, observable** characteristics of all runtime behavior.

## References

- Structural overview: [overview](./overview.md), [layers](./layers.md), [slices vs layers](./slices-vs-layers.md), [comparative landscape](./comparative-landscape.md).
- Monorepo architecture and layout: [monorepo polyglot](./monorepo-polyglot.md), [monorepo layout](./monorepo-layout.md), [repository blueprint](./repository-blueprint.md), [migration playbook](./migration-playbook.md).
- Runtime-related policy and tooling: [runtime policy](./runtime-policy.md), [tooling integration](./tooling-integration.md), [observability requirements](./observability-requirements.md), [resources](./resources.md).
- Agents, Kaizen, and governance: [agent architecture](./agent-architecture.md), [agent roles](./agent-roles.md), [MAPE-K modeling](./mape-k-loop-modeling.md), [kaizen subsystem](./kaizen-subsystem.md), [knowledge plane](../../runtime/knowledge/knowledge.md), [governance model](./governance-model.md).
- Contracts and data: [contracts registry](./contracts-registry.md), `packages/kits/*`, `contracts/openapi/*`, `contracts/schemas/*`, `contracts/ts/*`, `contracts/py/*`.


