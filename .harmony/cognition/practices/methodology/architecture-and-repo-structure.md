---
title: Architecture and Repository Structure
description: Harmony’s 12-Factor, monolith-first, Hexagonal architecture and Turborepo repo structure, including feature flags implementation and Next.js/Astro/Vercel strategy.
---

# Architecture and Repository Structure

This document expands the architecture and repo structure sections from the Harmony Methodology. Use it as a high-level, practical guide to the Harmony Structural Paradigm (HSP) — the modular monolith layout, ports/adapters boundaries, and how feature flags and the thin control plane fit into the stack.

The **normative source of truth** for architectural decisions lives under `.harmony/cognition/_meta/architecture/` (for example, `overview.md`, `monorepo-layout.md`, `repository-blueprint.md`, `runtime-architecture.md`, and `contracts-registry.md`). Stack-specific implementation profiles live under `.harmony/scaffolding/practices/examples/stack-profiles/` and are non-normative examples.

## Structural Basics

- **Harmony Structural Paradigm (HSP)**: a modular monolith (“Hexa‑Modulith”) with vertical feature slices and a thin control plane (flags, contracts, observability, policy). See `.harmony/cognition/_meta/architecture/overview.md`.
- **12‑Factor**: configs in env / runtime config, stateless processes where possible, logs as streams, disposability, clear build‑release‑run separation.
- **Monolith‑First in Turborepo**: a single logical system in one workspace, organized as:
  - **Runtime planes** — things you **run**: `apps/*` (TypeScript apps and UIs), `agents/*` (Python control‑plane runtimes), and platform runtimes under `platform/runtimes/*-runtime/**` (for example, the LangGraph‑based flow runtime described in `runtime-architecture.md`).
  - **Knowledge / control planes** — things you **import**: `packages/*` (feature slices, kits, prompts), the root `contracts/` registry, `platform/knowledge-plane`, `kaizen/`, and `ci-pipeline/`.
  - Rule of thumb (aligned with `monorepo-layout.md` and `repository-blueprint.md`): anything you run lives under `apps/*`, `agents/*`, or `platform/runtimes/*-runtime/**`; anything you import lives under `packages/*` or `contracts/`.
- **Vertical slices with Hexagonal boundaries**: runtime code is organized by **feature slice**, not classic n‑tier layers:
  - Each feature lives in `packages/<feature>/` with subfolders such as `domain/`, `adapters/`, `api/`, and `tests/` as described in `repository-blueprint.md`.
  - Hexagonal (Ports & Adapters) boundaries keep **pure domain logic** inward and infrastructure (DB/HTTP/cache) outward.
  - “Layers” in Harmony refer only to cross‑cutting governance/control‑plane concerns (e.g., Kaizen, quality gates, docs). See `architecture/slices-vs-layers.md` and `architecture/layers.md`.

## Framework Strategy (Next.js, Astro, Vercel, Python)

Canonical framework constraints come from `.harmony/cognition/_meta/architecture/*`. A concrete stack profile example is available at `.harmony/scaffolding/practices/examples/stack-profiles/nextjs-astro-vercel.md`. This repo applies that example profile as follows:

- **Next.js (App Router, React 19)**:
  - `apps/ai-console` is the canonical example: use Server Components and Server Actions as **thin controllers** that orchestrate flows and delegate to `packages/<feature>/domain` or to platform runtimes via contracts (for example, `runtime-flows` clients from `contracts/ts`).
  - Prefer Node runtime for heavy/AI or IO‑intensive work; reserve Edge for read‑mostly, low‑latency endpoints (for example, health, lightweight flag evaluation).
- **Astro**:
  - `apps/web` is a content‑first Astro app (docs/marketing). It can read flags and telemetry on the server but SHOULD treat most content as static and use build‑time data where possible.
- **API / BFF surfaces**:
  - `apps/api` (or equivalent HTTP apps) host OpenAPI‑defined ports and import DTOs/clients from the root `contracts/` registry (see `contracts-registry.md`), not from ad‑hoc `packages/contracts`.
- **Python agents and platform runtimes**:
  - Python agents under `agents/*` (Planner, Builder, Verifier, Orchestrator, Kaizen agents) are control‑plane runtimes that call the shared **platform runtime service** under `platform/runtimes/flow-runtime/**` via generated clients from `contracts/py`, as described in `runtime-architecture.md`.

For day‑to‑day work: treat Next.js and Astro apps as **thin edges** over slices (`packages/<feature>`) and platform runtimes, not as places to house core business logic.

## Feature Flags and Thin Control Plane

Harmony’s **feature flag strategy** is defined in `architecture/runtime-policy.md` and illustrated in `.harmony/scaffolding/practices/examples/stack-profiles/nextjs-astro-vercel.md`. This repo applies that strategy with a thin flag client in `packages/config` and platform-level configuration under `platform/runtimes/config/**` (canonical in `repository-blueprint.md` and `runtime-architecture.md`):

- **Flag contract in TypeScript**:
  - `packages/config/src/flags.ts` exposes a `FlagProvider` contract plus helpers like `isFlagEnabled()` and `listFlags()`.
  - Resolution order is: provider → `HARMONY_FLAG_*` env vars → defaults. This matches the “provider‑agnostic, fail‑closed” contract (`flagClient.get(name, default)`) described in `runtime-policy.md`.
- **Provider integration**:
  - At app startup, register a concrete provider (for example, a Vercel Edge Config adapter) so flags can be evaluated server‑side in Next.js and Astro.
  - Providers SHOULD be configured from control‑plane config (for example, under `platform/runtimes/config/**` for runtime‑related flags) rather than hard‑coding flag behavior in app code.
- **SSR and SSG usage**:
  - On **SSR** surfaces (Next.js App Router, Astro server endpoints), evaluate flags on the server and pass decisions into components/handlers as props or configuration; do not re‑resolve flags deep in domain logic.
  - On **Astro SSG/static** pages, treat flags as **build‑time inputs** or fetch them via a server/Edge endpoint; do not rely on `process.env` directly in browser code.
- **Python agents and platform runtime**:
  - For flows executed by the **platform runtime service** (`platform/runtimes/flow-runtime/**`), evaluate flags in the TypeScript control plane and pass decisions into runtime requests (for example, as part of the `runtime-flows` payload or caller metadata), instead of re‑implementing flag resolution in Python. This keeps cross‑language behavior deterministic and auditable.
- **Caching and Next.js 16 semantics**:
  - Dynamic data (including flag-dependent paths) should default to `no-store`; opt into caching explicitly with stable keys and tests, aligning with the Next.js 16 behavior shown in the stack profile example.
  - Fix hydration issues before turning on aggressive caching or Partial Prerendering (PPR); treat caching as an optimization backed by observability, not a correctness mechanism.

For more detailed runtime flag policy, see `architecture/runtime-policy.md` (“Feature Flag Strategy” and “Runtime Policy for Platform Flows”).

## Example Layout and Ownership

```plaintext
HarmonyMonorepo
  ├── apps/                     # Deployable TypeScript applications and UIs (thin adapters)
  │   ├── app                   # Next.js app (controllers, server actions)
  │   ├── api                   # HTTP ports (OpenAPI/BFFs, webhooks)
  │   └── web                   # Astro/docs/marketing
  ├── packages/                 # Reusable libraries organized by feature slices and control-plane kits
  │   ├── <feature>/            # Vertical feature slice
  │   │   ├── domain/           # Pure domain/use-cases (functional core)
  │   │   ├── adapters/         # DB/HTTP/cache integrations (outbound adapters)
  │   │   ├── api/              # Inbound API surface (interfaces/contracts)
  │   │   ├── tests/            # Unit/integration/contract tests for the slice
  │   │   └── docs/spec.md      # Brief slice spec (scope, contracts, risks)
  │   ├── common/               # Cross-cutting helpers and canonical DTOs
  │   ├── kits/                 # AI-Toolkit control-plane libs (FlowKit, PlanKit, EvalKit, etc.)
  │   └── prompts/              # Prompt suites imported by kits and agents
  ├── platform/
  │   ├── knowledge-plane/      # Specs, policies, SBOM, traces (authoritative knowledge)
  │   ├── observability/        # OTel bootstrap, dashboards, rules
  │   └── runtimes/             # Platform runtime services and their control-plane config
  │       ├── config/           # Runtime config (flags, rollout descriptors, policy bundles, queues, risk tiers)
  │       └── flow-runtime/     # LangGraph-based shared flow runtime service (see runtime-architecture.md)
  ├── agents/                   # Python control-plane runtimes (Planner, Builder, Verifier, Orchestrator, Kaizen agents)
  ├── kaizen/                   # Kaizen/Autopilot layer (policies, evaluators, codemods, agents, reports)
  ├── contracts/                # Contracts registry (OpenAPI/JSON Schema + generated TS/Python clients)
  ├── ci-pipeline/              # CI workflows and gates (build/test/scan/policy)
  ├── .github/
  │   └── workflows/            # CI definitions (including kaizen.yaml)
  ├── docs/                     # Architecture docs, ADRs, handbooks, guides
  ├── turbo.json
  └── CODEOWNERS
```

This is the **canonical blueprint** described in `architecture/monorepo-layout.md` and `architecture/repository-blueprint.md`. Individual repos may start with a subset (for example, no `platform/` or `kaizen/` yet), but new work SHOULD align to this structure so that:

- Apps and agents stay thin and call **published interfaces** (feature slices, kits, platform runtimes).
- Shared contracts live in the root `contracts/` registry (superseding older `packages/contracts` conventions).
- Platform services (`platform/runtimes/*-runtime/**`) and Kaizen stay clearly separated from product slices.

Use **CODEOWNERS** and the layer model in `architecture/layers.md` to enforce review by area (for example, apps/agents, core domain & adapters, contracts, infra/platform, docs/governance, Kaizen). Protect `main` with required checks mapped to those layers (see `layers.md` and `governance-model.md`).

## Scaling Policy (Solo → 2 Developers)

- Keep the modular monolith in a single Turborepo; introduce CODEOWNERS so every risky surface has an explicit reviewer.
- Use a simple two-person operating model: **Owner/Driver** opens PRs; **Navigator** reviews. Rotate weekly or per PR to distribute context.
- Adjust flow for 2 people: keep WIP tiny (suggested: **In‑Dev = 1 per dev**, **In‑Review ≤ 2**, **Preview ≤ 2**) and keep PRs small.
- Make elevated changes explicitly two-person: T2/T3 require Navigator review; high-risk requires spec approval before build and a post-promote watch window.
- Keep promotions controlled: PR previews per change, manual promote/rollback; set a predictable promotion window if promotions become noisy.
- Keep flags short‑lived: set owner + expiry, and automate weekly stale‑flag reports.

This scaling policy is intentionally lightweight and SHOULD be read together with:

- `architecture/overview.md` (Harmony Structural Paradigm objectives and evolution path).
- `architecture/governance-model.md` (ACP gates, waiver policy, risk rubric).
- `architecture/runtime-policy.md` (feature flags, rollback, runtime expectations).
- `docs/testing-strategy.md` (test pyramid, preview smoke, and contract test gates).

Together, these documents keep solo developers and 2-person teams fast while preserving **Speed with Safety**, **Simplicity over Complexity**, and **Quality through Determinism**.
