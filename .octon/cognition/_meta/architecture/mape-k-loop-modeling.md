---
title: MAPE-K Loop Modeling
description: Application of the MAPE-K model with ACP gates to drive safe, continuous improvement via Planner/Builder/Verifier agents.
---

# MAPE-K Loop Modeling (Technical)

Related docs: [monorepo polyglot (normative)](./monorepo-polyglot.md), [agent roles](./agent-roles.md), [kaizen subsystem](./kaizen-subsystem.md), [knowledge plane](../../runtime/knowledge/knowledge.md), [contracts registry](./contracts-registry.md), [python runtime workspace example](/.octon/scaffolding/practices/examples/stack-profiles/python-runtime-workspace.md)

This document specifies how Octon applies the MAPE-K model with ACP gates to continuously improve the system while maintaining safety and alignment with governance policies.

## Summary

- Model: MAPE-K (Monitor, Analyze, Plan, Execute, Knowledge).
- Managed Element: the Octon SaaS monorepo/application.
- Managing Element: AI agents plus human operators.
- Core agents: Planner Agent, Builder Agent, Verifier Agent.
- ACP gates: plan approval and pre-merge review.
- Operation modes: continuous kaizen loop and event-driven loop.

## Audience and Scope

This is developer-facing documentation for engineers building, operating, and extending Octon’s autonomic loop. It covers responsibilities, data flows, checkpoints, and operational triggers. It does not prescribe CI/CD tooling specifics beyond required outcomes.

## System Context

- **Managed Element**: the production system and monorepo that changes over time, including:
  - TypeScript control plane and feature slices under `packages/*` and `packages/kits/*`.
  - Python agents under `agents/*` (control-plane runtimes) and **platform runtime services** under `platform/runtimes/*-runtime/` (for example, the LangGraph-based implementation of the **platform flow runtime service** under `platform/runtimes/flow-runtime/**`; see `runtime-architecture.md`).
- **Managing Element**: AI agents (Planner, Builder, Verifier) and humans who observe, decide, and act on the system.
- **Knowledge Plane (K)**: shared knowledge base storing architecture, specs, metrics, findings, plans, results, contract metadata (from `contracts/`), and policy context used across all phases.
- **Thin Control Plane**: repo-local flags, policy gates, contracts (via the root `contracts/` registry), and observability guardrails that constrain agent behavior and provide deterministic outcomes without introducing runtime complexity.

References: MAPE-K background from autonomic computing [arxiv.org](https://arxiv.org/html/2506.22185#:~:text=MAPE,itself%20includes%20the%20following%20steps).

## Phase Responsibilities (MAPE-K)

### Monitor (M)

Continuously collect signals about system health and development process:

- Runtime: latency, error rate, resource usage; logs and traces (observability).
- Quality: test results, coverage, linter/static-analysis findings, code complexity.
- Drift: unmet specifications (e.g., failing tests) or deviations from performance thresholds.
- Meta: dependency freshness and known vulnerabilities.

Instrumentation sends relevant events to the Knowledge Plane (e.g., feature flag toggles, unusual error patterns). Development tools feed code health signals for later analysis.

Outputs

- Aggregated metrics, logs, traces; code-quality reports.
- Normalized events written to the Knowledge Plane.

### Analyze (A)

Derive findings and opportunities from monitored data. Performed by the Planner Agent and supporting analyzers on a schedule or in response to triggers.

Examples

- Coverage for a module dropped below threshold.
- Memory usage increased after a deployment.
- A dependency has a known CVE.
- A function (e.g., `calculateTotal()`) exceeds performance budget.

Approaches include rule-based checks and AI summarization. Outputs are structured findings: anomalies, suspected root causes, and candidate actions.

Outputs

- Findings with context (what, where, suspected why), supporting evidence, and confidence/risk scoring when applicable.

### Plan (P)

Formulate proposals to address findings. The Planner Agent prepares changes with explicit rationale and constraints from the Knowledge Plane.

Plan contents

- Description of change and expected outcome(s).
- Affected components and dependencies.
- Validation criteria (tests, metrics, acceptance checks).
- Risk level aligned with governance thresholds.

Note: Analyze and Plan remain distinct for traceability, reflecting research guidance that conflating them obscures reasoning [arxiv.org](https://arxiv.org/html/2506.22185#:~:text=Donakanti%20et%20al.%20,system%20as%20the%20managed%20system).

Outputs

- Proposed plan(s) with rationale; status set to Pending Approval if risk ≥ threshold.

### Execute (E)

Implement approved plans. The Builder Agent (and humans for complex changes) applies code/config changes and moves them through the pipeline.

Typical flow

- Create a branch and implement modifications (add/edit/delete code; refactors; config updates).
- Open a pull request (PR) with linked plan context and validation steps.
- Verifier Agent and CI run tests and checks; results feed back to the Knowledge Plane.
- On success and human review, merge and deploy via CI/CD according to release policy.
- On failure, halt execution and return to Analyze/Plan with findings.

Outputs

- Code changes (PRs/commits), test and verification artifacts, deployment status.

### Knowledge (K)

Provide shared context and durable memory across all phases [arxiv.org](https://arxiv.org/html/2506.22185#:~:text=Knowledge%3A%20Maintain%20a%20repository%20of,KB).

Contents

- Architecture and specifications; policies and governance rules.
- Historical monitoring data and analysis findings.
- Plans and status; execution results and post-merge outcomes.

Example entry: “Plan #42 (optimize `calculateTotal`) executed 2025‑11‑15; success; latency improved 20%.” This history prevents repeating failed fixes and supports learning over time.

## Operation Modes

### Continuous Kaizen Loop

Runs on a regular cadence (e.g., daily/weekly):

- Gather metrics (M), analyze trends (A) such as error drift or code smells.
- Generate maintenance/refactoring plans (P).
- Execute low‑risk quick wins (E) automatically if allowed; otherwise queue for approval.
- Update Knowledge with results for traceability.

This acts as a “code gardener,” keeping docs, tests, and quality standards healthy under governance.

### Event-Driven Loop

Triggers start the loop outside the schedule:

- New feature request/spec added to Knowledge → Planner decomposes and drafts plan.
- Critical vulnerability announced → analyze impact and plan patch/upgrade.
- CI pipeline failure on main → analyze regression and plan fix or revert.
- Production anomaly (e.g., spike in errors) → analyze recent changes/logs and plan mitigation (e.g., feature-flag rollback).

## Autonomous Control Points

ACP ensures safety, prioritization, and policy alignment. We apply three oversight points:

- Plan approval: humans (e.g., tech lead/product owner) review proposed plans, rationale, and risk before execution.
- Pre-merge review: humans review PR diffs and test results even when automated checks pass, especially early to build trust; very low-risk changes may be streamlined over time.
- Analyze assistance: humans can annotate signals or provide hypotheses to guide analysis when uncertainty is high.

This aligns with the “Autonomic Threshold” concept [arxiv.org](https://arxiv.org/html/2506.22185#:~:text=management,39%20%2C%20%2035): routine, low-risk adjustments may proceed autonomously; higher-risk work requires explicit policy gating and escalation. Risk scoring and ACP requirements are enforced via the Governance and Risk model.
The Thin Control Plane provides the concrete guardrails (flags, policy checks, contract tests, and observability baselines) that agents must satisfy to advance between phases.

## Inputs and Outputs by Phase

- Monitor: inputs = telemetry and tooling outputs; outputs = normalized metrics/events in Knowledge.
- Analyze: inputs = monitoring data + specs/policy; outputs = structured findings with evidence.
- Plan: inputs = findings + constraints; outputs = proposed changes with validation and risk.
- Execute: inputs = approved plans; outputs = code/PRs, verification results, deployment status.
- Knowledge: inputs = artifacts from all phases; outputs = contextual memory and retrieval.

## Roles and Responsibilities

- Planner Agent: runs analysis, drafts plans, separates reasoning from actions, assigns risk.
- Builder Agent: implements approved plans, opens PRs, coordinates with CI.
- Verifier Agent: executes tests and checks; reports outcomes and gaps.
- Human reviewers: approve plans above threshold; perform pre-merge code review; provide analysis guidance.

## Operational Notes

- Branching: one branch per plan unless plans are explicitly batched.
- Traceability: link PRs to plan IDs and findings; record outcomes in Knowledge.
- Failure handling: any execution failure returns to Analyze/Plan with captured evidence.
- Scope control: Planner must respect policy constraints and priority; humans arbitrate conflicts.

## Example Workflow

1) Monitor detects increased latency; Analyze flags `calculateTotal()` as hotspot above threshold.
2) Planner proposes optimization with expected 20% improvement and validation tests; risk = medium.
3) Human approves the plan; Builder implements changes in a feature branch and opens PR.
4) Verifier/CI passes; human performs final review; PR merges; CI/CD deploys.
5) Knowledge records outcome and measured improvement; future analyses consider this history.

## References

- MAPE-K overview and roles: [arxiv.org](https://arxiv.org/html/2506.22185#:~:text=MAPE,itself%20includes%20the%20following%20steps)
- Separation of Analyze/Plan rationale: [arxiv.org](https://arxiv.org/html/2506.22185#:~:text=Donakanti%20et%20al.%20,system%20as%20the%20managed%20system)
- Knowledge base guidance: [arxiv.org](https://arxiv.org/html/2506.22185#:~:text=Knowledge%3A%20Maintain%20a%20repository%20of,KB)
