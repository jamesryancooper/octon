---
title: Agents, Agent Roles, Kaizen Subsystem, MAPE-K, and Governance — Synthesized Summary
description: Summary of agent roles, target agent architecture, Kaizen subsystem, MAPE-K loop, and governance model for Harmony agents.
---

## Purpose of This Summary

- Combine the core content of:
  - `agent-architecture.md`
  - `agent-roles.md`
  - `kaizen-subsystem.md`
  - `mape-k-loop-modeling.md`
  - `governance-model.md`
- Provide a single, agent‑centric reference for designing, critiquing, and evolving Harmony‑aligned agents.

## What an Agent Is in Harmony

An **agent** is a **spec‑first, governed, long‑lived capability** that:

- Accepts well‑typed **inputs** and produces well‑typed **outputs** (types + JSON Schema; OpenAPI if HTTP).
- **Plans and orchestrates work** using Harmony kits (PlanKit, FlowKit, AgentKit, ToolKit, etc.) and domain use‑cases via ports/adapters.
- Operates inside a **deterministic loop**: **Plan → Diff → Explain → Test** (no silent apply).
- Runs under:
  - Pinned model/provider/config.
  - Structured observability (traces/logs/metrics).
  - Policy/Eval/Test gates (PolicyKit, EvalKit, TestKit).
- Is invoked by surfaces (apps, CI, Kaizen, CLIs) via **stable TypeScript contracts** (e.g. factories and types from `packages/agents`), not raw Python modules or runtime internals.
- May use **Python flows** running in the **platform flow runtime service** under `platform/runtimes/flow-runtime/**` as an implementation detail, but **never exposes runtime internals**.

Key invariants:

- **Spec‑first**: each agent has a canonical spec describing purpose, IO, risk class, HITL requirements, and observability expectations.
- **Contract‑first**: inputs/outputs are modeled as TS types + JSON Schema; HTTP‑exposed agents also live in OpenAPI at `contracts/openapi`.
- **Deterministic by default**: pinned config, low variance settings, golden tests for critical behaviors.
- **Governed**: policies and evals are **bound to agents by name and version** via governance bundles.
- **Runtime‑agnostic public surface**: TS callers do not need to know whether implementation uses only TS flows or Python LangGraph flows behind contracts.

## Agent Building Blocks (Spec / Definition / Implementation / Governance)

Each agent is composed of four primary elements:

- **Agent Spec**:
  - Purpose, inputs/outputs, quality attributes, risk class, HITL checkpoints, allowed surfaces.
  - Tied back to Harmony specs and architecture docs.
- **Agent Definition**:
  - Bindings of prompts (PromptKit manifests), plans (PlanKit), flows (FlowKit), and allowed tools/use‑cases.
  - Declares which kits and domain services the agent may call.
- **Agent Implementation**:
  - TS factories (for example, under `packages/agents/src/runtime/`) that create configured agent instances.
  - Optional Python flows under `agents/*` or the platform flow runtime (`platform/runtimes/flow-runtime/**`) used via generated clients.
- **Agent Governance Bundle**:
  - Policies (PolicyKit) attached to the agent.
  - Evals (EvalKit/TestKit) and golden tests.
  - Observability profile (required spans/metrics/log structure).

## Agent Roles: Planner, Builder, Verifier

### Planner Agent

- **Responsibilities**:
  - Ingest signals from the Knowledge Plane (metrics, SLOs, CI results, coverage, SBOM, incidents).
  - Identify problems/opportunities (errors, drift, CVEs, performance issues, refactors, feature gaps).
  - Produce **decision‑grade plans** with:
    - Scope, steps, dependencies, risk assessment, and validation criteria.
    - Links to specs, contracts, architecture docs, and policies.
  - Prioritize by impact, urgency, and risk; escalate ambiguous or high‑risk work to humans.
- **Outputs**:
  - Plan documents/objects with clear tasks and acceptance criteria.
  - Risk classification (Trivial/Low/Medium/High) and suggested gates.
- **Governance**:
  - PolicyKit pre‑checks on planned actions (e.g. ASVS/SSDF/STRIDE, risk rubric).
  - HITL at planning for Medium/High risk work; humans approve or adjust plans.
  - Full provenance: log plan inputs, rationale, approvals, and outcomes in the Knowledge Plane.

### Builder Agent

- **Responsibilities**:
  - Implement approved plans in **small, scoped branches**.
  - Modify code/config/docs; add or update tests.
  - Run local/agentic self‑checks (lint, types, unit tests) and respond to CI feedback.
  - Open PRs referencing plans, specs, and risk classification.
- **Outputs**:
  - Minimal diffs; updated tests/docs; PR descriptions summarizing intent and validation.
- **Governance**:
  - No direct commits to protected branches; always via PR.
  - Obeys scope guardrails and risk rubric; surfaces unknowns as questions, not guesses.
  - Records deviations from plan and reasons; links PRs and CI runs in the Knowledge Plane.

### Verifier Agent

- **Responsibilities**:
  - Execute and aggregate validation:
    - Unit/integration/e2e tests.
    - Contract tests (Pact, Schemathesis).
    - Static analysis (CodeQL, Semgrep), security scans, SBOM checks.
    - Policy and quality checks (PolicyKit/EvalKit/TestKit).
  - Validate plan success criteria using metrics and targeted checks.
  - Produce clear pass/fail reports with next steps for minor gaps.
- **Outputs**:
  - Reports detailing test results, coverage deltas, policy outcomes, anomalies.
- **Governance**:
  - Fail‑closed behavior: gates do not auto‑weaken; waivers require explicit human approval.
  - Independence: Verifier is not allowed to adjust gate definitions; it enforces configured rules.
  - Provenance: Records verification artifacts keyed by commit/PR and surfaced in the Knowledge Plane.

## Kaizen Subsystem (Autopilot Layer)

- **Purpose**:
  - Continuous, fail‑closed improvement loop that proposes **small, reversible changes** via dry‑run PRs.
  - Focus areas: docs, governance hygiene, observability scaffolding, preview/e2e smoke coverage, contract drift, performance nudges, flag hygiene.
- **Scope**:
  - In‑scope:
    - Docs and spec hygiene (lint/links/structure).
    - Governance and CODEOWNERS hints.
    - Observability scaffolding on changed paths.
    - Contract drift detection and suggested schema updates.
    - Perf and cost nudges and stale flag cleanup.
  - Out of scope:
    - Material runtime behavior changes without explicit human initiation.
    - Secrets, key management, and policy exceptions.
    - Self‑approved or self‑merged PRs; cutting releases; production deployments.
- **Physical layout**:
  - `kaizen/` with:
    - `policies/` — risk rubric and gate definitions.
    - `evaluators/` — scripts that generate findings/reports.
    - `codemods/` — safe AST transforms and refactors.
    - `agents/` — Kaizen‑specific Planner/Builder/Verifier flows.
    - `reports/` — weekly digests and evidence artifacts.
- **Operation model**:
  - Triggered by schedule or events; loop:
    - Trigger → Plan → HITL (if risk ≥ threshold) → Build (branch + PR) → Verify (CI) → Review → Merge → Monitor → Log to Knowledge → Idle.
  - Autopilot for trivial/low‑risk; Copilot for medium/high‑risk (always HITL).
  - Default posture: **no change without evidence and approval**.

## MAPE-K Loop in Harmony

- **Monitor (M)**:
  - Collects runtime metrics, traces/logs, CI outcomes, SBOM/vuln information, and error signals.
  - Data flows into the Knowledge Plane.
- **Analyze (A)**:
  - Planner agents and analyzers interpret signals to identify issues or opportunities.
  - Outputs structured findings with evidence and risk scores.
- **Plan (P)**:
  - Planner agents translate findings into explicit plans with validations and risk classifications.
  - HITL approval required above certain risk thresholds.
- **Execute (E)**:
  - Builder agents and humans implement plans, open PRs, run tests; Verifier agents/CI validate.
  - Deployments are guarded by flags, gates, and manual promote/rollback.
- **Knowledge (K)**:
  - Stores specs, plans, results, incidents, waivers, and runtime run records.
  - Supports future Monitor/Analyze/Plan steps with historical context.

Agents (Planner/Builder/Verifier) are the **managing element** in MAPE‑K; the monorepo and platform runtimes form the **managed element**; the Knowledge Plane is K.

## Governance Model for Agents

### HITL Gates

- **Planning gate**:
  - Medium/High risk plans require human approval.
  - Artifacts: plan, rationale, alternatives, risk, rollback.
- **Pre‑merge review gate**:
  - All PRs to protected branches require at least one human review; high‑risk work may require multiple reviewers (navigator + security).
  - Artifacts: diffs, test results, contract diffs, risk rubric, rollback plan, trace links.
- **Pre‑production gate**:
  - High‑risk changes must have explicit rollout plans, canaries, and watch windows; require navigator/security approval.
- **Post‑deployment oversight**:
  - On‑call monitors SLO/error‑budget; can freeze, rollback, or tighten gates.

### Waiver Policy

- **Who can waive**:
  - Designated roles per domain (QA, security, platform).
- **Requirements**:
  - Clear rationale, tightly scoped checks, explicit risk/mitigation, expiry, and ownership.
  - Logged in PRs, Knowledge Plane, and audit logs.
- **Forbidden waivers**:
  - Secrets/PII exposure.
  - Missing observability on changed flows.
  - Missing flags/rollback for risky changes.
  - Sustained SLO burn‑rate violations.

### Risk Rubric (Trivial/Low/Medium/High)

- **Trivial/Low**:
  - Docs hygiene, small refactors, non‑behavioral changes.
  - Single reviewer; standard gates; no required flags (but allowed).
- **Medium**:
  - Feature changes behind flags, non‑critical behavior adjustments.
  - Navigator review; preview smoke recommended; flags and rollback required.
- **High**:
  - Auth, payments, critical flows, schema/data migrations, complex refactors.
  - Two‑person rule; extended tests, canaries, watch windows; mandatory flags and rollback rehearsals.

Agents must **label plans and PRs** with risk, drive appropriate gates, and never weaken those gates silently.

## Target Agent Repo Structure (Conceptual)

- **TypeScript control-plane agents**:
  - `packages/agents/`:
    - `src/specs/<agent-id>/spec.md` and optional `spec.json`.
    - `src/definitions/<agent-id>/` for PlanKit/FlowKit/PromptKit bindings.
    - `src/runtime/<agent-id>.ts` for factories.
    - `src/governance/<agent-id>/` for policies, evals, observability.
    - `src/index.ts` exports types, identifiers, and factory functions.
- **Python control-plane runtimes**:
  - `agents/planner`, `agents/builder`, `agents/verifier`, `agents/orchestrator` with uv workspaces.
  - Call TS kit contracts and the platform runtime via generated clients.
- **Kaizen-specific agents**:
  - `kaizen/agents/` with the same Spec/Definition/Implementation/Governance model, scoped to maintenance flows.

## Kaizen vs Production Agents (Separation)

- **Kaizen agents**:
  - Live under `kaizen/agents/`.
  - Operate only in Kaizen/autopilot contexts.
  - Are more experimental; can be promoted to `packages/agents` when stable.
- **Production agents**:
  - Live under `packages/agents`.
  - Serve user‑facing or internal product flows (console assistants, API helpers, RAG services).
  - Must satisfy System Guarantees and have full governance bundles.

## Implications for Agentic System Design

- Every proposed agent must:
  - Have a clear role (Planner/Builder/Verifier/Orchestrator/Kaizen/product) tied to MAPE‑K and Harmony stages.
  - Be defined via Spec/Definition/Implementation/Governance, not ad‑hoc code.
  - Respect hexagonal boundaries, contracts, and risk/governance rules.
  - Integrate cleanly with the platform runtime, Knowledge Plane, CI, and observability.



