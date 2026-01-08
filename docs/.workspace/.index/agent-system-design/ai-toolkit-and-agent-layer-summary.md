---
title: AI-Toolkit, Kit Roles, FlowKit/AgentKit, and Agent Layer — Synthesized Summary
description: Summary of the AI-Toolkit, planning/orchestration kit roles, FlowKit/AgentKit design, and the agent layer guardrails.
---

## Purpose of This Summary

- Distill the key ideas from:
  - `ai-toolkit/README.md`
  - `ai-toolkit/agent-layer-guide.md`
  - `ai-toolkit/planning-and-orchestration/kit-roles.md`
  - `ai-toolkit/planning-and-orchestration/flowkit/guide.md`
  - `ai-toolkit/planning-and-orchestration/agentkit/guide.md`
- Provide a single, kit‑centric view for designing agentic systems that use Harmony’s AI‑Toolkit correctly.

## AI-Toolkit Overview

- A **modular, local‑first toolkit** of **kits** (libraries) that:
  - Each have a **single, crisp purpose**, typed inputs/outputs, and clear integration points.
  - Operate in the **control plane** under `packages/kits/*`.
  - Are designed to be predictable, deterministic, and safe to call from agents, apps, Kaizen, and CI.
- Goal: turn multi‑agent complexity into **structured, observable, tool‑driven workflows**, not ad‑hoc orchestration.
- Kits align directly with Harmony’s lifecycle:
  - **Spec** → SpecKit.
  - **Plan** → PlanKit.
  - **Implement** → AgentKit/ToolKit/DevKit/CodeModKit.
  - **Verify** → EvalKit/TestKit/PolicyKit/ComplianceKit.
  - **Ship** → PatchKit/ReleaseKit/FlagKit.
  - **Operate** → ObservaKit/BenchKit.
  - **Learn** → Dockit.

## System Invariants for All Kits

Common non‑negotiables:

- **Crisp purpose and contracts**:
  - Each kit has a well‑bounded responsibility; inputs/outputs specified via JSON Schema under `packages/contracts/schemas/kits/`.
- **Spec‑first, no silent apply**:
  - Implement flows via Plan → Diff → Explain → Test; CLI default `--dry-run`.
- **Determinism by default**:
  - Pin provider/model/version/params; compute and record `prompt_hash`.
  - Use idempotency keys for mutating ops; cache keys for pure/repeatable ones.
- **Observability everywhere**:
  - Emit OTel spans/logs with required resource attributes (`service.name`, `kit.name`, `kit.version`, `run.id`, etc.).
  - Support offline buffering and later flush for local runs.
- **Governance and typed failures**:
  - PolicyKit and EvalKit gates are fail‑closed by default.
  - Typed errors and standard exit codes (0–8) with JSON summaries.
- **Safety and secret hygiene**:
  - GuardKit handles redaction; VaultKit handles secret access.
  - Never serialize secrets/PII into logs, spans, artifacts, or prompts.
- **HITL compatibility**:
  - Risk/rubric fields (`risk`, `stage`, `hitl`) in run records.
  - Kits integrate with PatchKit templates and PolicyKit rulesets.

## Core Planning and Orchestration Kits

### SpecKit (`speckit`)

- Wraps GitHub’s Spec Kit for **spec‑first** work.
- Produces:
  - Spec one‑pagers.
  - ADR skeletons.
  - Threat models and non‑functional requirements.
- Kits and agents treat SpecKit artifacts as the primary input for planning.

### PlanKit (`plankit`)

- Wraps BMAD to generate **plans** and ADRs from validated specs.
- Outputs:
  - `plan.json` (machine‑readable plan).
  - Narrative plans/ADRs in docs.
- Bridges SpecKit outputs and subsequent agentic execution (AgentKit/FlowKit).

### FlowKit

- Defines **flow contracts** (`FlowConfig`, `FlowRunner`, `FlowRunResult`).
- Provides:
  - TS clients/abstractions to call the **platform flow runtime** via HTTP (`/flows/run`).
  - CLI helpers and integration with Cursor custom commands.
- Responsibilities:
  - Turn “run this flow with this manifest/prompt/config” into a single runtime call.
  - Keep flows runtime‑agnostic; the actual runtime lives under `platform/runtimes/flow-runtime/**` (LangGraph‑based).
- Not responsible for:
  - Long‑running process hosting — that’s the platform runtime.
  - Agent lifecycle or planning — that’s PlanKit/AgentKit.

### AgentKit

- Runs **PlanKit plans** as durable, stateful agent graphs:
  - PlanKit → `plan.json`.
  - AgentKit → instantiate flows via FlowKit and call other kits/tools.
- Built on top of FlowKit and the shared platform flow runtime.
- Responsibilities:
  - Execute plans step‑by‑step with retries/resume/HITL pauses.
  - Maintain agent state and working memory across runs/checkpoints.
  - Emit artifacts in `runs/**` for diffs, reports, and tests.
- Not responsible for:
  - Owning its own runtime (always reuses platform flow runtime).
  - Defining core business/domain logic (that lives in slices under `packages/<feature>/domain`).

### ToolKit

- Thin, deterministic wrappers over actions:
  - Git operations, shell commands, HTTP/API calls, file operations, etc.
- Responsibilities:
  - Provide safe, predictable operations that AgentKit and flows can call.
  - Respect idempotency, redaction, and observability invariants.

## Quality, Governance, and Evidence Kits

- **EvalKit**:
  - Evaluates LLM outputs or flows (structure, grounding, style, hallucinations).
  - Works with DatasetKit for golden sets; integrates with PromptKit fixtures.
- **TestKit**:
  - Orchestrates unit, contract, and e2e tests.
  - Ensures contract tests (OpenAPI/Pact/Schemathesis) are run in CI.
- **PolicyKit**:
  - Encodes policy rulesets (ASVS, SSDF, STRIDE, Harmony risk profiles).
  - Fail‑closed by default; blocks on missing evidence or violations.
- **ComplianceKit**:
  - Assembles evidence packs across kits, runs, and CI for audits and postmortems.

## LLMOps and ContextOps Responsibilities

### PromptKit (PromptOps)

- Manages **prompt templates, variable schemas, variants, and fixtures**.
- Compiles templates into canonical prompts with `prompt_hash` and metadata.
- Provides fixtures and test harnesses for EvalKit/TestKit.
- **Does not**:
  - Own retrieval (RAG pipelines).
  - Own logging, dashboards, or evaluation policies.

### ContextOps Kits (RAG)

- **IngestKit**:
  - Normalizes and ingests documents (first‑party and optionally external).
- **IndexKit**:
  - Builds and maintains indexes over ingested content.
- **SearchKit** (optional):
  - Pulls external documentation or data sources.
- **QueryKit**:
  - Executes deterministic retrieval queries with evidence and provenance.

PromptKit defines **context slots and schemas** in prompts (e.g. `{retrieved_docs}`); IngestKit/IndexKit/SearchKit/QueryKit determine *what* goes into those slots; ObservaKit/EvalKit/PolicyKit/CacheKit/ModelKit/CostKit enforce runtime LLMOps.

### LLMOps Kits

- **ObservaKit**:
  - Traces/logs/metrics for all model calls and flows; computes DORA metrics and SLO guardrails.
- **EvalKit + DatasetKit**:
  - Evaluate LLM behavior and flows; maintain golden test sets.
- **PolicyKit**:
  - Enforce policy around determinism, redaction, safety, and allowed models/providers.
- **CacheKit**:
  - Add memoization and idempotent caching for pure/expensive LLM operations.
- **ModelKit/CostKit**:
  - Govern allowed models/providers, routing, and cost budgets.

## Agent Layer Guide (“Agent Sandwich”)

The agent layer is a **thin policy and control wrapper** around kits and flows, not a free‑form reasoning engine:

- **Pre‑validators**:
  - Schema validation of inputs.
  - Safety/allowlist checks for operations and URIs.
  - Budget checks (`seconds_max`, `calls_max`, `tokens_max`).
- **Core decision loop**:
  - Use PlanKit plans and Knowledge Plane context to choose:
    - Which kits/flows to call.
    - In what order and under what constraints.
  - Summarize decisions as structured telemetry (no chain‑of‑thought dumping).
- **Post‑validators**:
  - Schema checks on outputs and invariants (e.g. set sizes, deduplication).
  - Sanity checks on budgets and side‑effects.
  - Attach provenance (tool version, parameters, evidence URIs).
- **Budgets and circuit breakers**:
  - Per‑run budgets for time, calls, and tokens.
  - Per‑call deadlines forwarded to kits.
  - Abort or down‑scope when burn‑rate exceeds thresholds.
- **Idempotency and retries**:
  - All mutating kit calls require `idempotency_key`.
  - Retries only for transient errors with bounded backoff.
- **Decision telemetry**:
  - Each agent step emits a compact record:
    - `run_id`, `goal`, `capabilities_used`, `actions` with args refs, budgets, `trace_id`.
  - This enables debugging, evaluation, and governance without exposing chain‑of‑thought.

## FlowKit and AgentKit with Platform Runtime

- Kits and agents do **not** spin up their own runtimes.
- Instead:
  - FlowKit receives `FlowConfig` and uses an HTTP runner client to call `/flows/run` on the **platform flow runtime**.
  - AgentKit uses FlowKit as the execution layer for plan steps.
  - The LangGraph‑based implementation under `platform/runtimes/flow-runtime/**` is:
    - A shared runtime service for all flows/agents.
    - Configured via `platform/runtimes/config/**`.
    - Instrumented per runtime/observability docs.

This preserves:

- **Clean layering**:
  - Kits are libraries; runtimes are platform services.
- **Reusability**:
  - Apps, agents, Kaizen, and CI can all call the same flows.
- **Swapability**:
  - LangGraph can be replaced with other engines as long as runtime APIs and FlowExecutionBackend contracts stay stable.

## Contracts Registry and Kit Metadata

- All kit inputs/outputs must be modeled as JSON Schemas under:
  - `packages/contracts/schemas/kits/<kit>.inputs.v<MAJOR>.json`
  - `packages/contracts/schemas/kits/<kit>.outputs.v<MAJOR>.json`
- Kit metadata files (`metadata/kit.metadata.json`) conform to a **KitMetadata** schema and declare:
  - Name, version.
  - Pillars and lifecycle stages.
  - Input/output schema paths.
  - Observability requirements (`requiredSpans`).
  - Determinism and idempotency invariants.
  - Compatibility and deprecation windows.
- CI enforces contract and metadata consistency:
  - Schema diffs and MAJOR/MINOR bumps for breaking vs additive changes.
  - Pact/Schemathesis and other gates where applicable.

## Implications for Agentic System Design

- Agents should use AI‑Toolkit kits as **stable, deterministic tools**:
  - Never bypass kit interfaces to talk directly to infra, models, or runtimes.
  - Prefer PlanKit/FlowKit/AgentKit composition over bespoke orchestration.
- When designing new agent behaviors:
  - Prefer factoring repeated logic into new kits or flows.
  - Maintain crisp separation between **agent policy/decisions** and **kit/runtimes that perform work**.
- For each new flow or agent:
  - Define specs and contracts in `packages/contracts`.
  - Use FlowKit + platform runtime + AgentKit as the execution backbone.
  - Use EvalKit/PolicyKit/ComplianceKit to guard quality, security, and compliance.



