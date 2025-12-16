---
title: Runtime Architecture, Policy, Knowledge Plane, Observability, and Tooling — Synthesized Summary
description: Summary of runtime architecture and planes for apps, agents, and platform runtimes, including Knowledge Plane and observability requirements.
---

## Purpose of This Summary

- Provide a cohesive overview of:
  - **Runtime Architecture**
  - **Runtime Policy**
  - **Knowledge Plane**
  - **Observability Requirements**
  - **Tooling Integration**
  - **Containerization Profile**
- Focus specifically on what agents and agentic systems must respect when interacting with runtimes and planes.

## Planes and Roles (Control, Runtime, Knowledge, Development, Security)

- **Data/Execution Plane (Runtime)**:
  - Apps under `apps/*` (Next.js/Astro/API), platform runtimes under `platform/runtimes/*-runtime/**`, and agent hosts under `agents/*`.
  - Executes business logic, flows, and requests.
- **Control Plane**:
  - Kits in `packages/kits/*`, TS `packages/agents`, CI/CD pipelines in `ci-pipeline/` and `.github/workflows`, feature flags, runtime configs under `platform/runtimes/config/**`.
  - Configures and governs what runs where and under what policies.
- **Knowledge Plane**:
  - `platform/knowledge-plane/**` plus indexed docs/specs/contracts/tests, runtime run records, SBOMs, and correlation data.
  - Provides a queryable graph of Spec ↔ Code ↔ Tests ↔ Traces ↔ Deployments.
- **Development/Planning Plane**:
  - VCS, PRs, issue trackers, IDEs, and agent prompts for planning and design.
- **Security Plane (conceptual overlay)**:
  - Policies, risk rubrics, and security tooling that constrain behavior across all planes.

Agents and kits operate primarily in the **control and development planes**, call into the **runtime plane**, and read/write to the **Knowledge Plane**, all subject to the **Security Plane**.

## Platform Runtime Architecture (Flow Runtime and Families)

### Shared Platform Runtime Service

- The shared **platform flow runtime service** lives under:
  - `platform/runtimes/flow-runtime/**` — a **runtime‑plane service** that executes flows and graphs on behalf of:
    - Apps (`apps/*`)
    - Agents (`agents/*`)
    - Kaizen/governance subsystems (`kaizen/*`)
- It is **not** an agent; it is execution infrastructure.
- It exposes contract‑first APIs (conceptually via `contracts/openapi/runtime-flows.yaml`), including:
  - `POST /flows/run` — synchronous run with final result.
  - `POST /flows/start` — asynchronous run that returns a `runId`.
  - `GET /flows/{runId}` — status and checkpoint data.
  - `POST /flows/{runId}/cancel` — cancellation.

### Internal Tiers

- **API/gateway tier**:
  - Validates inputs, authenticates/authorizes callers.
  - Normalizes caller metadata (project/environment/flow/version/callerKind/callerId/riskTier).
  - Forwards commands to the scheduler; remains stateless.
- **Scheduler/orchestration tier**:
  - Maintains durable run state (`runId`, status, timestamps, checkpoints, caller metadata).
  - Enforces timeouts, quotas, and risk‑aware routing (queues/pools per workload).
  - Coordinates retries, cancellations, and pause/resume.
- **Executor tier**:
  - Worker pools that execute flows using pluggable execution backends.
  - Checkpoint progress and update the scheduler.

### FlowExecutionBackend Abstraction

- Runtimes use a common backend interface (conceptual):
  - `start_run(request: FlowRunRequest)`, `resume_run(handle)`, `cancel_run(handle)`, `get_run_status(handle)`.
- Concrete backends:
  - `LangGraphExecutionBackend` — current default (LangGraph).
  - Potential alternatives: Temporal, in‑memory testing engines, batch engines.
- Callers (apps/agents/Kaizen) are **insulated** from backend choices; they talk only to the runtime APIs via generated clients.

## Runtime Policy (Posture and Safety)

### Runtime-Level Policies

- Resource and concurrency:
  - Per‑run and per‑step timeouts.
  - Token/step limits and concurrency caps per caller/env/flow.
- Risk‑aware routing:
  - Different queues for interactive vs batch vs Kaizen workloads.
  - Stricter policies for high‑risk or production‑affecting flows.
- Guardrails:
  - Deny/approve profiles for certain operations.
  - Integration with governance/PolicyKit for risk, approvals, and waivers.

### Control-Plane Configuration

- `platform/runtimes/config/**` holds:
  - Policy bundles (profiles, queues, risk tiers).
  - Rollout descriptors and feature flags for runtimes.
  - Environment mappings for dev/stage/prod.
- Runtimes **consume** this configuration; they do not encode policy directly in code.

### Separation of Responsibilities

- Runtimes:
  - Execute flows under configured policies and report run metadata and telemetry.
  - Do not perform planning or governance decisions.
- Kits/agents:
  - Plan and orchestrate work (PlanKit, AgentKit, FlowKit).
  - Apply governance (PolicyKit, EvalKit, TestKit, ComplianceKit).
  - Decide when and how to trigger runtime executions.

## Knowledge Plane (Runtime and CI Integration)

### Knowledge Plane Role

- Unified, queryable knowledge base linking:
  - Specs, policies, ADRs.
  - Contracts (OpenAPI/JSON Schema, interfaces).
  - Code modules and tests.
  - Runtime runs (`RuntimeRun` entities).
  - CI builds, deployments, and SBOMs.
- Enables agents and humans to perform:
  - Impact analysis.
  - Coverage and risk assessment.
  - Compliance and audit queries.

### RuntimeRun and Correlation

- Every runtime execution becomes a **RuntimeRun** with canonical metadata:
  - `flow_id`, `flow_version`, `run_id`
  - `caller_kind` (e.g. `app`, `agent`, `kaizen`, `ci`)
  - `caller_id` (specific app/agent/CI job)
  - `project_id`, `environment`
  - `runtime_family` (e.g. `flow`, `eval`, `batch`)
  - Optional `risk_tier`, feature flags in effect
  - Status, timestamps, and summary
- CI and runtime systems push correlation payloads (PR/build/trace/deployment) via `POST /kp/correlation` with a strict schema:
  - `pr_number`, `commit_sha`, `repo`, `branch`, `build_id`, `run_id`, `trace_id`, `traceparent`, optional artifacts and deployment info.
- This supports queries like:
  - “For PR X, show builds, runtimes, and traces.”
  - “For flow F, show failing runs in env E after commit C.”

## Observability Requirements (Across Planes)

### Tracing

- Use **OpenTelemetry** for spans/logs/metrics across apps, agents, runtimes, and kits.
- Required attributes on runtime and kit spans:
  - `flow_id`, `flow_version`, `run_id`
  - `caller_kind`, `caller_id`, `project_id`, `environment`
  - `runtime_family` (where applicable)
  - `kit.name`, `kit.version`, `stage`, `git.sha`, `repo`, `branch`
  - If AI used: `ai.provider`, `ai.model`, `ai.version`, `ai.temperature`, `ai.top_p`, optional `ai.seed`, `prompt_hash`
- Sampling:
  - High sampling (or 100%) in lower envs.
  - In production, ensure all error traces and a representative sample of normal traffic.
  - Never drop error spans.

### Logging and Metrics

- Logs:
  - Structured JSON.
  - Include `trace_id`, `span_id`, severity, summary.
  - No PII/PHI; GuardKit applies redaction at write boundaries.
- Metrics:
  - Core runtime metrics: throughput, latency per flow, error rates, resource usage.
  - Domain metrics: business KPIs (e.g., orders processed).
  - Observability drives SLO/error‑budget alerts.

### Redaction and Privacy

- Sensitive classes: secrets, auth tokens, PII, key material, payment data, health data, other sensitive values.
- Redaction rules:
  - Never serialize secrets or PII into run records, spans, logs, file names, or prompts.
  - Replace with placeholders like `<REDACTED:<CLASS>>`.
  - GuardKit performs redaction; VaultKit handles secrets.
- Violations:
  - Treated as policy failures; block merges and/or trigger incident processes.

## Tooling Integration (CI and Control Plane)

### Polyglot Task Graph

- Turborepo with **pnpm** and **uv**:
  - TS tasks (`ts:build`, `ts:test`, `ts:lint`, `ts:typecheck`).
  - Python tasks (`py:lint`, `py:typecheck`, `py:test`) wired via small `package.json` shims.
  - `gen:contracts` runs first, generating TS/Py clients from OpenAPI/JSON Schema.
- CI workflows:
  - Build, test, lint, typecheck across both TS and Python.
  - Contract tests (Pact/Schemathesis) for all published APIs (including runtimes).
  - Security scans, SBOM generation, and provenance attestations.

### CI ↔ Knowledge Plane and Observability

- CI publishes:
  - Test results, coverage, contract/gate outcomes.
  - SBOM digests and security findings.
  - Correlation metadata for PR/build/trace/deploy via `POST /kp/correlation`.
- Observability backends (traces/metrics/logs) feed summary data into the Knowledge Plane or are linked by IDs.

### Kaizen Integration

- Kaizen workflows:
  - Triggered by schedule or events (CI failures, drift, performance anomalies).
  - Run evaluators and flows via the platform runtime with `caller_kind="kaizen"`.
  - Open PRs with evidence; operate under stricter policy profiles and Autopilot/Copilot tracks.

## Containerization Profile (Apps, Agents, Runtimes)

- Container boundaries:
  - `apps/*`: app images (Node multi‑stage builds).
  - `agents/*`: Python agent images with uv; control‑plane runtimes.
  - `platform/runtimes/*-runtime/**`: runtime‑plane service images (e.g., flow runtime).
- Common conventions:
  - Run as non‑root.
  - Environment‑driven configuration; no secrets in images.
  - Health endpoints for readiness/liveness.
  - Structured logs to stdout/stderr; OTel exporters configured via env.
  - Images built and scanned in CI with SBOMs and security gates.

## Implications for Agents and Kits

- Agents must:
  - Call platform runtimes via **generated TS/Py clients** from `contracts/`, not import internal engine modules.
  - Include caller metadata (kind/id/project/environment/risk) with every runtime request.
  - Emit required OTel spans/logs/metrics with standardized attributes and link to PRs/builds via Knowledge Plane correlation.
  - Respect runtime policies (timeouts, quotas, risk tiers) and handle blocked or failed runs gracefully.
- Kits must:
  - Treat runtime APIs as stable contracts and avoid embedding runtime logic.
  - Use ObservaKit as the primary telemetry path and align with run record schemas.



