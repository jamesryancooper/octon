---
title: Sandbox Flow
description: Canonical end-to-end flow for safely validating changes in sandbox environments using previews, feature flags, CI/CD gates, and observability before production rollout.
---

# Sandbox Flow

This document defines the **canonical Sandbox Flow** for Harmony. It explains how changes move from idea to **sandbox environments** (preview deployments and trunk previews), how they are validated behind **feature flags**, and how they are **promoted** to production with **manual control and instant rollback**.

It is a focused, narrative view that stitches together the lifecycle and tooling described in:

- Methodology:
  - `implementation-guide.md` (A→J lifecycle and Harmony's kit layer).
  - `ci-cd-quality-gates.md` (pipeline and gates).
  - `performance-and-scalability.md` (perf budgets and load testing).
  - `reliability-and-ops.md` (SLOs, error budgets, incidents, and rollback policy).
- Architecture:
  - `architecture/overview.md` (HSP, modular monolith, and Evolution Path).
  - `architecture/nextjs-astro-vercel.md` (Next.js/Astro/Vercel profile, previews, flags, and promotion).
  - `architecture/tooling-integration.md` (CI as control plane, planes and flows).
  - `architecture/observability-requirements.md` (trace/log/metric baselines).
  - `architecture/runtime-architecture.md` and `architecture/runtime-policy.md` (platform runtime behavior and runtime flags).

When in doubt, this page SHOULD be read together with those documents; it does not supersede them.

---

## 1. Goals and Non‑Goals

**Goals**

- Provide a **clear, step-by-step flow** for how changes are validated in sandboxes before production.
- Make it easy for a solo developer to:
  - Spin up and use **preview environments** as sandboxes.
  - Use **feature flags** and **runtime configuration** to guard risky paths.
  - Rely on **CI/CD gates** and **observability** as central, auditable validation mechanisms.
- Give agents and humans a shared mental model for where sandbox checks live in the lifecycle.

**Non‑Goals**

- This document does NOT define Docker images or compose setups. Those live in the Architecture **Containerization Profile** and infra sandbox recipes.
- This document does NOT redefine gate semantics or policies; see `ci-cd-quality-gates.md`, `governance-model.md`, and `runtime-policy.md` for normative rules.

---

## 2. Surfaces and Sandboxes

In Harmony, “sandbox” is not a single environment; it is a **pattern** applied across several surfaces:

- **Preview deployments (per PR)**:
  - For `apps/*` (Next.js and Astro apps), Vercel creates a **preview deployment** for each PR or branch.
  - This preview is the default **sandbox surface for UI and HTTP behavior**, including flags and runtime interactions.
- **Trunk preview deployment**:
  - A stable preview for `main` (or equivalent) can be used as a **long‑lived sandbox** for trunk‑level validation, load tests, and experiments.
- **Runtime previews**:
  - Platform runtime services under `platform/runtimes/*-runtime/**` (for example, flow runtime) have **non‑production environments** (e.g., `development`, `staging`) that act as sandboxes for flows and agents.
  - Callers (apps, agents, Kaizen, CI) route test traffic to these environments using environment-specific endpoints and credentials.
- **CI pipelines**:
  - CI itself is part of the sandbox: tests, contract checks, and static analysis all run **before promotion** and can exercise preview or dedicated test environments.

The Sandbox Flow describes how these surfaces are used consistently across the A→J lifecycle.

---

## 3. A→J Lifecycle (Sandbox-Focused View)

This section maps the lifecycle stages from the Implementation Guide to the sandbox pattern. For full details, see `implementation-guide.md`; here we focus on where and how sandbox validation happens.

### A — Spec (SpecKit / GitHub’s Spec Kit)

- **Inputs**: Problem statement, constraints, non‑functionals.
- **Outputs**:
  - `docs/specs/<feature>/spec.md` and supporting artifacts produced via SpecKit.
  - Initial notes about **flags** (what will be guarded, kill switches) and **sandbox validation** (which flows must be exercised in preview).
- **Sandbox angle**:
  - Identify which flows MUST be validated in sandbox:
    - Critical user journeys (login, checkout, etc.).
    - High‑risk runtime behaviors (writes, destructive actions).
  - Record these as acceptance criteria to be enforced later by CI and your review pass (Navigator).

### B — Shape & Scope Cuts

- **Outputs**:
  - `docs/specs/<feature>/plan.md` with scope cuts, risk notes, and non‑functional targets (SLOs, perf budgets).
- **Sandbox angle**:
  - Decide **which sandboxes** will be used:
    - Per‑PR preview only.
    - Trunk preview plus PR previews.
    - Additional runtime sandboxes (e.g., dedicated staging flows).
  - Mark any **required sandbox checks** (load tests, contract tests, a11y) for this work.

### C — Plan & Acceptance Criteria (PlanKit planning kernel)

- **Outputs**:
  - ADR(s), feature story/context packet, implementation notes such as `docs/implementation/<feature>.md`.
- **Sandbox angle**:
  - Make sandbox requirements explicit:
    - “Feature is dark‑launched behind `<flag-name>` in preview.”
    - “Run Schemathesis against `/api/<path>` in preview.”
    - “Exercise representative flow via `/flows/run` in runtime sandbox before promote.”
  - Ensure acceptance criteria include:
    - Flag behavior (defaults OFF, safe fallback).
    - Observability (spans/logs/metrics present and visible in preview).

### D — Dev in AI IDE (Guided Implementation)

- **Work**:
  - Implement code changes in slices (`packages/<feature>`), apps (`apps/*`), agents (`agents/*`), and runtimes, guided by SpecKit and PlanKit.
- **Sandbox angle**:
  - Developers and agents work **locally** but prepare code and tests so they will run deterministically in CI and preview environments.
  - Local runs SHOULD mimic preview behavior where practical (e.g., using the same flags, env variables, and contracts).

### E — PR → Preview Sandbox

- **Trigger**: Open a PR or push to a branch.
- **Behavior**:
  - CI (via Turbo, pnpm, and uv) runs lint/type/test and other gates.
  - Vercel (or equivalent) deploys a **preview** for each `apps/*` app changed by the PR.
- **Sandbox responsibilities**:
  - **Developers / Reviewers**:
    - Validate behavior in the preview:
      - Confirm feature is gated by the intended flags.
      - Exercise key flows and verify expected spans/logs/metrics.
    - Run any **manual exploratory tests** that are not yet automated.
  - **Agents / Automation** (optional):
    - Run scripted smoke tests or a11y checks against the preview URLs.

### F — CI Gates (Automated Sandbox Validation)

See `ci-cd-quality-gates.md` for full details. From a sandbox perspective:

- **CI runs against code and, where needed, preview sandboxes**:
  - Unit and integration tests (often in‑process or using emulators/containers).
  - Contract tests (Pact, Schemathesis) which may target:
    - Local/test instances.
    - Preview environments for HTTP surfaces when configured.
  - Static analysis, SBOM, secrets scanning, and other quality/security gates.
  - Optional: performance smoke and bundle budgets.
- **Observability gates**:
  - Jobs like `otel_coverage` and `contracts_drift` verify that changed flows:
    - Emit required spans/logs/metrics.
    - Maintain contract compatibility.
- **Outcome**:
  - PR CANNOT merge unless **all required gates are green** or a permitted waiver is recorded per governance.

### G — Merge to Trunk

- When CI is green and reviews are complete, the PR merges to trunk (e.g., `main`).
- **Sandbox angle**:
  - Trunk previews for `apps/*` act as a **long‑lived sandbox**:
    - Automated smoke tests may run continuously or on schedule.
    - Load tests and chaos experiments SHOULD run against trunk preview rather than production for most scenarios.

### H — Deploy: Promote and Roll Back

- **Promotion**:
  - Production is updated via **manual promote** (e.g., `vercel promote <preview-url>`), not auto‑deploy, as described in `nextjs-astro-vercel.md`.
- **Flags and rollout**:
  - New behavior remains behind flags; initial production state mirrors the preview’s safe configuration (usually flags OFF or limited cohort).
  - Progressive rollout (internal → small % → majority) is managed via flags and runtime configuration.
- **Rollback**:
  - If SLOs or error budgets are threatened, production changes are rolled back first:
    - Either revert to the previous deployment.
    - Or disable flags / kill switches for the affected feature.

### I — Operate: Monitor, SLOs, and Incidents

- **SLOs and budgets**:
  - As defined in `reliability-and-ops.md`, SLOs and error budgets apply to both sandbox and production.
  - Burn‑rate alerts can trigger freezes on promotion and flag changes.
- **Sandbox flows**:
  - Continuous checks (smoke tests, Kaizen jobs) may run against previews and runtime sandboxes.
  - Telemetry from these runs is recorded in the Knowledge Plane for later analysis.

### J — Learn: Postmortems and Kaizen

- **Postmortems**:
  - For material incidents, run blameless postmortems and record follow‑ups.
- **Kaizen / Autopilot**:
  - Kaizen agents may propose:
    - Additional sandbox checks.
    - Improved test coverage.
    - Observability fixes on critical flows.
  - These proposals still go through the same Sandbox Flow (PR → preview → CI gates → promote).

---

## 4. Responsibilities: Humans, Agents, and CI

The Sandbox Flow is successful only if responsibilities are clear:

- **Humans**:
  - Own **specs, plans, and risk decisions** (A–C).
  - Implement or approve code and configuration changes (D–G).
  - Decide when to promote, roll back, or freeze (H–I).
  - Run and interpret postmortems (J).
- **Agents (Planner/Builder/Verifier/Kaizen)**:
  - Help author specs, plans, code changes, and tests.
  - Produce evidence for CI gates (e.g., test runs, coverage reports).
  - Propose PRs and improvements but **never self‑approve** protected branches.
- **CI**:
  - Enforces gates described in `ci-cd-quality-gates.md` and architecture docs.
  - Treats **previews and runtime sandboxes as targets** for:
    - Smoke tests.
    - Contract tests.
    - Observability and hygiene evaluators.
  - Publishes results and correlations to the Knowledge Plane as immutable records.

---

## 5. Sandbox Patterns by Change Type

This section provides concrete sandbox patterns for common change types. Teams MAY refine these, but SHOULD keep the general shape.

### 5.1 Feature change in a Next.js app (apps/ai-console, apps/web)

1. Author or update SpecKit spec and PlanKit plan for the feature.
2. Implement the feature behind a new or existing flag in `apps/*`, delegating logic to `packages/<feature>/domain`.
3. Open a PR:
   - CI runs; a preview is created.
   - Manual checks and automated smoke tests exercise the feature in the preview.
4. Merge once CI and reviews are green.
5. Manually promote the preview to production and roll out the flag progressively.

### 5.2 Adapter or API change (packages/<feature>/adapters, apps/api)

1. Update contracts in `contracts/openapi` / `contracts/schemas` and regenerate clients.
2. Adjust adapters and/or `apps/api` controllers.
3. Open a PR:
   - CI runs unit, integration, and contract tests.
   - Optional: run Schemathesis against preview or test instances of the API.
4. Validate behavior in preview; merge and promote when gates are green.

### 5.3 Runtime change (platform/runtimes/flow-runtime/**)

1. Update flow definitions or runtime configuration using contracts in `contracts/openapi/runtime-*.yaml`.
2. Use a **runtime sandbox environment** and targeted tests (including `/flows/run` calls) to validate behavior.
3. Open a PR:
   - CI validates contracts, tests, and runtime‑focused gates.
4. Promote new runtime build/configuration to production only after sandbox validation passes and observability confirms expected behavior.

---

## 6. Audibility and Knowledge Plane Integration

For each Sandbox Flow run, the following SHOULD be recorded in the Knowledge Plane (see `knowledge-plane.md` and `tooling-integration.md`):

- PR metadata: commit SHA, branch, PR number, risk class.
- CI runs and gate results, including coverage, contract tests, and security scans.
- Preview URLs and deployment identifiers.
- Trace IDs linking CI, preview traffic, and runtime executions.
- Flags and runtime configuration in effect for the tested flows.

These records make it possible to answer questions like:

- “Which sandbox tests ran before we promoted this feature?”
- “Which flows were exercised in preview before the incident?”
- “Which runtime configuration and flag states were present during the sandbox validation?”

---

## 7. Summary

- Sandboxes in Harmony are realized through **preview deployments**, **runtime non‑production environments**, and **CI gates**.
- The Sandbox Flow provides a single mental model that connects specs, plans, code, previews, flags, tests, and promotion.
- Feature flags, CI/CD gates, and observability are **central, not optional**: they make sandbox validations repeatable, auditable, and safe for both humans and agents.
