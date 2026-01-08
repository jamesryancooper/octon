---
title: Agent Roles
description: Contracts, constraints, and provenance for Planner, Builder, and Verifier agents operating within the MAPE-K loop under governance.
---

# Agent Roles (Technical): Planner, Builder, Verifier

Related docs: [monorepo polyglot (normative)](./monorepo-polyglot.md), [MAPE-K modeling](./mape-k-loop-modeling.md), [kaizen subsystem](./kaizen-subsystem.md), [governance model](./governance-model.md), [knowledge plane](./knowledge-plane.md), [contracts registry](./contracts-registry.md), [python runtime workspace](./python-runtime-workspace.md), [kit roles](../ai-toolkit/planning-and-orchestration/kit-roles.md)

This document specifies the technical contracts, governance constraints, and provenance requirements for the three Harmony agents that drive continuous improvement within the MAPE-K loop: Planner, Builder, and Verifier. It should be read together with the AI-Toolkit planning and orchestration docs (`PlanKit`, `AgentKit`, `FlowKit`, and the platform runtime service) described in `../ai-toolkit/planning-and-orchestration/kit-roles.md`, and with the polyglot monorepo blueprint (`monorepo-polyglot.md`) that defines where TS kits and Python runtimes live. For the canonical runtime model, see `runtime-architecture.md`.

## Summary

- Agents: Planner (Analyze/Plan), Builder (Implement), Verifier (Validate).
- Contracts: explicit, decision-grade outputs with traceable rationale.
- Governance: risk thresholds, policy compliance, HITL gates, fail-closed defaults.
- Provenance: end-to-end audit trail across plans, code changes, and verifications.

## Audience and Scope

This is developer-facing documentation for engineers and operators implementing or extending Harmony’s agent loop. It defines responsibilities, expected outputs, constraints, and logging for each agent. It does not prescribe tool-specific CI/CD details beyond required outcomes and traceability.

## Role Overview

- Planner Agent: analyzes signals and produces actionable, scoped plans with risk and validation criteria.
- Builder Agent: implements approved plans as focused code/config changes with tests and documentation updates.
- Verifier Agent: validates changes via tests, analysis, and policy checks; reports pass/fail and details.

---

## Planner Agent

### Planner Agent Responsibilities

- Ingest signals from the Knowledge Plane (metrics, tests, issues, code quality reports).
- Identify problems/opportunities (errors, drift, CVEs, performance, refactors, feature requests).
- Formulate plans with clear scope, approach, and validation criteria; prioritize by impact/urgency/risk.
- Present plans for approval per governance (auto-approve only when risk ≤ threshold and policy allows).

### Planner Agent Contract (Expected Outputs)

A deterministic, decision-grade Plan object/document containing:

- Description: issue/opportunity and intended change with identifiers (e.g., bug/FR IDs).
- Scope: modules/components to be changed.
- Steps/Approach: tasks, pseudocode, or sub-work breakdown when applicable.
- Links to Knowledge: requirements, policies, CVEs, architecture references.
- Risk Assessment: low/medium/high with potential side effects and mitigation notes.
- Rollout & Metrics: success criteria and how they will be measured post-change.

Quality requirements:

- No unsafe suggestions (e.g., removing validation to gain performance).
- Align with coding standards and feasibility constraints.
- Stay within authority; do not bypass tests or lower quality gates without explicit, recorded waiver.

### Planner Agent Governance & Constraints

- Policy Compliance: validate planned actions against policy knowledge (security, secrets, banned APIs, quality bars).
- Risk Thresholds: require human approval for medium/high-risk or sensitive changes (HITL at planning).
- Explainability: provide rationale and evidence; opaque recommendations are rejected.
- Scope Respect: do not plan architectural/infrastructure changes outside remit unless explicitly allowed.
- Escalation: when ambiguous or beyond scope, request human decision rather than guessing.

### Planner Agent Provenance

- Log every plan with timestamp, inputs, rationale, risk, approver, and outcome in the Knowledge Plane.
- Record intermediate analysis signals used in rationale to support future audits and learning.
- Example: “Planner proposed Plan #45 (update Library X) → approved by Alice → executed via PR #67.”

---

## Builder Agent

### Builder Agent Responsibilities

- Create a feature branch and implement the approved plan within declared scope.
- Modify code/config, add/update tests, and adjust documentation as needed.
- Self-check: run formatters/linters/type checks locally; iterate on failures.
- Open a PR referencing the plan; respond to CI feedback and human review.

### Builder Agent Contract (Expected Outputs)

- Correctness: implement the plan as specified without unintended behavior changes.
- Quality & Style: adhere to coding standards; introduce no new warnings/errors.
- Minimal Introduced Risk: keep diffs scoped; avoid unrelated changes and drift.
- Testing: ensure existing tests pass; add regression/feature tests when implied or specified.
- Documentation: update relevant docs/specs when behavior or interfaces change.
- PR Description: summarize change, reference plan/issue IDs, and call out validation.

### Builder Agent Governance & Constraints

- No Direct Commits to Main: changes flow via branch + PR under review gates.
- Resource Limits: bounded retries/attempts when using generative tools; escalate when churning.
- Scope Guardrails: only modify files/components within the plan scope (tolerate minimal enabling refactors).
- Security & Secrets: never introduce credentials or exfiltrate data; operate within sandboxed tooling.
- Policy Adherence: respect banned APIs/patterns and repository conventions; flag conflicting plans.

### Builder Agent Provenance and Feedback Handling

- Log diffs/commits and reasoning notes when decisions deviate from the plan.
- Reference plan IDs in commits/PRs for traceability; link CI artifacts.
- Address Verifier failures within bounded attempts; escalate to Planner/humans when plan appears incorrect.
- Incorporate human review feedback; avoid overriding human changes without explicit direction.
- Acknowledge limits; request guidance for unknown references or underspecified algorithms.

---

## Verifier Agent

### Verifier Agent Responsibilities

- Execute test suites (unit/integration), static analysis, linters, type checks, and security scans.
- Enforce contract-first interfaces by running Pact consumer/provider tests and Schemathesis fuzz/negative tests for OpenAPI/JSON Schema contracts.
- Enforce policy compliance (coverage thresholds, secrets scanning, license allowlists, auth requirements).
- Validate plan objectives where measurable (e.g., micro-benchmarks for performance claims).
- Aggregate results into a clear report for humans and agents; block on failures.

### Verifier Agent Contract (Expected Outputs)

- Test Results: pass/fail with logs; highlight newly introduced failures vs. known flakiness.
- Coverage & Quality Metrics: deltas against thresholds and baselines.
- Policy Compliance: checklist outcome for configured rules and guardrails; include contract test results (Pact/Schemathesis) for published APIs.
- Plan Success Criteria: targeted measurements verifying stated outcomes when applicable.
- Anomaly Detection: heuristic/AI hints on risky diffs (e.g., removed validations) to aid review.
- Recommendations: concrete next steps for minor gaps (e.g., add missing test).
- Model/Prompt Provenance: when AI outputs are involved, verify use of approved models via ModelKit and ensure prompts are versioned with recorded hashes/idempotency keys in spans/logs for determinism.

### Verifier Agent Governance & Constraints

- Strict by Default: fail-closed behavior; waivers require explicit human approval with justification.
- Independence: run in isolated environment; inputs are team-maintained standards that Builder cannot alter ad hoc.
- HITL Gate: failing checks route to Builder for fixes or to humans for adjudication when tests are disputed.
- Knowledge Updates: persist verification artifacts, coverage history, and waiver records.
- No Partial Pass: either meets bars or fails; no dynamic threshold adjustments without policy updates.
- Tooling Governance: checks are configured by the team; Verifier does not suppress configured rules.

### Verifier Agent Provenance

- Store verification artifacts keyed by commit/PR; retain failure history to identify flakiness and trends. Publish PR/build↔trace correlation to the Knowledge Plane when available.
- Log waivers with approver, timestamp, and rationale for audit readiness.
- Record model identifiers and prompt hashes (where applicable) to support reproducibility and audits; reject unverifiable model usage.

---

## Cross-Agent Governance and Collaboration

- Planner: enforces risk thresholds and routes high-impact plans to humans (HITL at planning).
- Builder: implements via PRs behind CI + human review (HITL at pre-merge).
- Verifier: gates merges with strict validation; humans may override via recorded waivers.
- Thin Control Plane (TS kits + CI gates): provides the shared guardrails (flags, policy checks, contract tests, observability baselines) that all agents must respect; violations fail‑closed and are surfaced for HITL decisions.

### Physical Mapping in the Polyglot Monorepo

- Control plane (TypeScript):
  - Planner/Builder/Verifier orchestrations are implemented via kits under `packages/kits/*` (for example, PlanKit, AgentKit, FlowKit, EvalKit, PolicyKit, TestKit).
  - These kits use contracts from the root `contracts/` registry to talk to HTTP APIs and the **platform runtime service** (exposed via contract‑first APIs such as `runtime-flows`), not to LangGraph internals directly.
- Control-plane runtimes (Python + TS hosts):
  - Agent processes run under `agents/*` (see `python-runtime-workspace.md`), with role-specific hosts (planner/builder/verifier/orchestrator) that plan, analyze, and orchestrate work. When they need to execute flows/graphs, they call the shared **platform flow runtime service** under `platform/runtimes/flow-runtime/**` using generated runtime clients and contracts from `contracts/`.
  - TypeScript apps under `apps/*` act as additional hosts but remain thin and call into kits and feature slices.
- Platform runtime services (runtime plane):
  - The LangGraph-based implementation of the platform flow runtime service lives under `platform/runtimes/flow-runtime/**` and is described in detail in `runtime-architecture.md`. It executes flows/graphs on behalf of apps, agents, and Kaizen using pluggable execution backends (for example, a LangGraph engine under `platform/runtimes/flow-runtime/langgraph/**`) and exposes only the contract-first APIs defined in the root `contracts/` registry (for example, `/flows/run`, `/flows/start`).
- Contracts and task graph:
  - Agents must respect the unified Turborepo+pnpm+uv task graph (`gen:contracts`, `ts:*`, `py:*`) and use generated TS/Py clients from `contracts/ts` and `contracts/py` instead of ad-hoc HTTP calls.

End-to-end provenance:

- “Planner (AI) proposed X, approved by Y (human).”
- “Builder (AI) implemented X; reviewed by Y; merged.”
- “Verifier (AI) validated X; deployed.”

This model scales teams by offloading routine analysis, implementation, and checks to agents while preserving human judgment for design, prioritization, and exceptions.

## Non‑Goals and Escalation

- Agents do not change architectural decisions, governance policy, or security posture.
- Agents do not bypass tests, lower quality gates, or merge without required approvals.
- Ambiguity, missing specifications, or out‑of‑scope requests must be escalated to human review rather than guessed.
- Default fail‑closed: on uncertainty or conflicting signals, prefer no change until clarified.

## References

- Accountability and provenance in AI decision-making contexts: arxiv.org
