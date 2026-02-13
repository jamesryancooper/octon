---
title: Self-Contained Modules and Extraction to Separate Repos
description: Guidance on which Harmony modules can become self-contained, forkable repos and how to extract them safely when autonomy, scale, or boundaries require it.
---

# Self‑Contained Modules and Extraction to Separate Repos

This document explains **which parts of the Harmony monorepo are practical candidates** for becoming self‑contained, forkable units (including separate repositories) and provides a **high‑level extraction playbook** for when scale, autonomy, or organizational boundaries warrant it.

It complements:

- `architecture/overview.md` (HSP and Evolution Path).
- `architecture/monorepo-layout.md` and `architecture/repository-blueprint.md` (canonical layout and boundaries).
- `architecture/monorepo-polyglot.md` (TS + Python modular monolith with Turborepo and uv).
- `architecture/runtime-architecture.md` and `architecture/runtime-policy.md` (platform runtimes).
- `../methodology/implementation-guide.md` and `../methodology/migration-playbook.md`.

The goal is to preserve HSP’s **monolith‑first, modular monolith** strategy while making the path to **Self‑Contained Systems (SCS)**, BFFs, or cells predictable when needed.

---

## 1. Principles

Harmony’s Hexa‑Modulith and monorepo layout are designed so that:

- **Vertical slices** encapsulate domain, adapters, API, and tests.
- **Kits** provide thin, reusable control‑plane libraries.
- **Platform runtimes** expose contract‑first APIs.

This combination allows selected modules to be:

- Cloned or replicated (e.g., for cell‑style deployments).
- Extracted into their own repositories or services.

without large, cross‑cutting refactors.

However, some parts of the repo are intentionally **centralized and cross‑cutting** and SHOULD NOT be cloned or extracted lightly (e.g., `contracts/`, `platform/knowledge-plane/**`, `kaizen/**`).

---

## 2. Practical Candidates vs Poor Candidates

### 2.1 Practical Candidates (Good)

These modules are designed to be **self‑contained, forkable units** when needed:

- **Feature slices under `packages/<feature>`**:
  - Encapsulate:
    - `domain/` — pure domain/use‑cases (no framework or adapter dependencies).
    - `adapters/` — infrastructure (DB/HTTP/queue) implementations of ports.
    - `api/` — inbound interfaces/contracts.
    - `tests/` — unit, integration, and contract tests.
    - Optional `docs/spec.md` — brief slice spec.
  - Can be:
    - Extracted into their own repo or service (SCS/BFF) if autonomy or SLOs warrant it.
    - Cloned into cell‑specific variants for per‑tenant or per‑region deployments.

- **Selected kits under `packages/kits/*`**:
  - Examples: FlowKit, PlanKit, EvalKit, PolicyKit, GuardKit, TestKit.
  - Are **control‑plane libraries** with stable contracts and explicit responsibilities.
  - Can be promoted to standalone library repos/packages without changing the HSP core, as long as their contracts and versioning practices remain aligned.

- **Runtime services under `platform/runtimes/*-runtime/**`**:
  - Example: `platform/runtimes/flow-runtime/**` (platform flow runtime).
  - Are already treated as **runtime‑plane services** with contract‑first APIs and generated clients for TS/Python.
  - Can be housed in their own repo if:
    - Contracts are preserved in `contracts/` or an equivalent registry.
    - Callers (`apps/*`, `agents/*`, Kaizen, CI) continue to interact via generated clients, not engine internals.

### 2.2 Poor Candidates (Impractical)

The following areas are **intentionally centralized** and generally NOT good candidates for self‑contained, forkable repos:

- **`contracts/` registry**:
  - Canonical source of truth for:
    - `contracts/openapi/*.yaml` — OpenAPI specs.
    - `contracts/schemas/*.json` — shared JSON Schemas.
    - `contracts/ts/*` and `contracts/py/*` — generated TS and Python clients.
  - Splitting `contracts/` across repos breaks the **single contracts registry** model and increases drift risk.

- **Knowledge Plane (`platform/knowledge-plane/**`)**:
  - Aggregates specs, contracts, traces, SBOMs, and other knowledge across the entire system.
  - Intended to be **global** so agents and humans share a unified view.

- **Kaizen (`kaizen/**`) and CI/gates (`ci-pipeline/**`, `.github/workflows/**`)**:
  - Implement the **thin, shared control plane** (quality gates, policies, hygiene jobs).
  - Forking them per feature undermines centralized governance and consistency.

- **Deeply shared libraries in `packages/common/*`**:
  - Designed as small, curated sets of primitives and models.
  - Forking them leads to duplication and coupling problems; prefer to keep them minimal and shared.

---

## 3. Extraction Playbook (High Level)

This section outlines a high‑level, **tool‑agnostic** process for extracting practical candidates into self‑contained units, including separate repos or services.

### 3.1 Prerequisites (All Candidates)

Before extracting a module, ensure:

- **Contracts**:
  - Public APIs and cross‑module boundaries are expressed in `contracts/openapi` and/or `contracts/schemas`.
  - Generated clients exist in `contracts/ts` and/or `contracts/py` and are used by callers.
- **Tests and gates**:
  - The module has unit, integration, and contract tests in place.
  - CI gates (lint, typecheck, tests, contract checks) run reliably for the module.
- **Observability and SLOs**:
  - Key flows are instrumented with OTel.
  - Baseline SLOs and error budgets are defined (even if simple).

These prerequisites ensure that extraction does not degrade correctness or observability.

### 3.2 Extracting a Feature Slice (`packages/<feature>`)

Use this path when a feature slice needs to become a **Self‑Contained System or BFF**.

1. **Stabilize contracts and tests**:
   - Confirm the slice’s public APIs and events are defined in `contracts/` with tests.
   - Ensure in‑repo callers rely on these contracts, not on internal types or DB schemas.
2. **Create a new repo or service skeleton**:
   - Mirror the slice’s layout:
     - `domain/`, `adapters/`, `api/`, `tests/`, `docs/spec.md`.
   - Add local build/test scaffolding (TypeScript configs, package metadata) based on `monorepo-polyglot.md`.
   - Define a Dockerfile aligned with the **Containerization Profile**.
3. **Move implementation**:
   - Copy or move the slice’s code into the new repo, preserving structure and contracts.
   - Update imports to reference local equivalents where necessary.
4. **Replace in‑process calls in the monorepo**:
   - In the original repo, replace direct imports of the slice with:
     - HTTP or RPC calls using generated clients from `contracts/ts` or `contracts/py`.
   - Keep the same OpenAPI/JSON Schema contracts to minimize consumer impact.
5. **Align CI/CD and observability**:
   - Add gates for the new service mirroring previous slice gates (lint, type, test, contracts, SBOM, etc.).
   - Ensure traces and logs include identifiers that allow correlation with the original monorepo flows (e.g., `feature`, `service`, `environment`).
6. **Decommission or demote the old slice**:
   - Remove or reduce the original implementation once callers have migrated.
   - Retain any shared types or DTOs in `contracts/` or `packages/common/*` as appropriate.

### 3.3 Extracting a Kit (`packages/kits/*`)

Use this path when a kit should become a **standalone library** or shared artifact across multiple repos.

1. **Confirm boundaries and contracts**:
   - Ensure the kit:
     - Has clear public APIs and types.
     - Is consumed only through those APIs (no deep internals from other packages).
2. **Create a new library repo or package**:
   - Set up the kit as a standalone library:
     - Package metadata, TypeScript configs, tests, and CI.
   - Align with the monorepo’s build/test patterns where possible.
3. **Publish and consume**:
   - Publish the kit to a package registry or internal artifact store.
   - Update monorepo imports to resolve the kit from the published artifact rather than the local workspace.
4. **Manage versions and compatibility**:
   - Follow semantic versioning.
   - Document compatibility with other kits and consumers (e.g., supported versions of FlowKit, AgentKit).
5. **Optionally keep a shim in the monorepo**:
   - For a transition period, keep a thin wrapper package that re‑exports the published kit, easing migration.

### 3.4 Extracting a Platform Runtime (`platform/runtimes/*-runtime/**`)

Use this path when a platform runtime needs to live in its own repo or deployment pipeline.

1. **Treat runtime APIs as contracts**:
   - Ensure runtime APIs (e.g., `runtime-flows`) are defined in `contracts/openapi` with generated clients in `contracts/ts` and `contracts/py`.
2. **Create a runtime repo**:
   - Move runtime code (API tier, scheduler, executors, engine integration) into a new repo.
   - Maintain the same OpenAPI/JSON Schema definitions and DTOs.
   - Add a Dockerfile and CI per the **Containerization Profile**.
3. **Update callers**:
   - Ensure apps, agents, Kaizen, and CI continue to:
     - Use generated clients only.
     - Route to the new runtime deployment via configuration (e.g., env vars).
4. **Align config and observability**:
   - Decide whether `platform/runtimes/config/**` remains in the original repo, moves to the runtime repo, or becomes its own config source of truth.
   - Preserve:
     - Standard runtime telemetry attributes (`flow_id`, `run_id`, `caller_kind`, etc.).
     - SLOs and error budgets for the runtime.

---

## 4. Cells, Clones, and Forks

Harmony’s **Evolution Path** in `architecture/overview.md` includes:

- Extracting hot or independently evolving slices behind stable contracts (e.g., BFF or SCS).
- Adopting **cell‑style boundaries** (per tenant/region) while preserving monorepo cohesion.

Practical notes:

- **Cells**:
  - Cells can be implemented as:
    - Multiple deployments of the same monorepo (with per‑cell config).
    - Multiple instances of extracted services, each tied to a cell.
  - In both cases, contracts and kits remain shared; only configuration and routing differ.
- **Clones / forks**:
  - For feature slices or runtimes that must diverge for specific tenants or regions, cloning may be an option.
  - Cloning SHOULD be:
    - Scoped and intentional (documented via ADRs).
    - Governed by contracts and shared tests to prevent silent drift.

---

## 5. Integration with Architecture and Methodology

- **Architecture overview and blueprint**:
  - Continue to treat the monorepo and Hexa‑Modulith as the **default**.
  - Use this document as the normative guidance when:
    - Evaluating whether to extract a slice, kit, or runtime.
    - Planning migration steps and assessing impact.
- **Methodology migration playbook**:
  - Extraction can appear as a later‑stage (e.g., Day 61–90+) step once:
    - Contracts and gates are stable.
    - SLOs or organizational boundaries justify service decomposition.
- **Governance and SLOs**:
  - Any extraction MUST:
    - Preserve or improve SLOs and observability.
    - Preserve contract expectations for downstream consumers.
    - Be captured in ADRs and the Knowledge Plane for traceability.

---

## 6. Summary

- Harmony is intentionally **monolith‑first**, but not monolith‑forever.
- Vertical slices, kits, and platform runtimes are structured so that:
  - Some modules are practical candidates for becoming **self‑contained, forkable repos** when justified.
  - Cross‑cutting control‑plane and knowledge‑plane components remain centralized for consistency.
- This document provides a **high‑level, contracts‑first extraction playbook**; concrete implementations (repos, pipelines, Dockerfiles) SHOULD follow the patterns in `monorepo-polyglot.md`, `containerization-profile.md`, and the Methodology/Architecture guides.


