---
title: Containerization Profile
description: Guidance for building, scanning, and running container images for Harmony apps, agents, and platform runtimes, including conventions and CI integration.
---

# Containerization Profile

This document defines how to **containerize Harmony runtime components**—apps, agents, and platform runtimes—so that they can be:

- Built and scanned consistently in CI (via `container_build` and security gates).
- Run in **sandbox environments** (local and CI) alongside supporting services.
- Promoted towards production using the same contracts, configs, and observability baselines.

It is intentionally **implementation‑agnostic**: concrete Dockerfiles and `docker compose` files live under `infra/` (see the infra sandbox recipes) and SHOULD follow the conventions in this profile.

Related docs:

- Methodology:
  - `docs/handbooks/harmony/methodology/implementation-guide.md`
  - `docs/handbooks/harmony/methodology/testing-strategy.md`
  - `docs/handbooks/harmony/methodology/sandbox-flow.md`
- Architecture:
  - `architecture/overview.md`
  - `architecture/monorepo-layout.md`
  - `architecture/repository-blueprint.md`
  - `architecture/nextjs-astro-vercel.md`
  - `architecture/layers.md`
  - `architecture/tooling-integration.md`
  - `architecture/runtime-architecture.md`
  - `architecture/observability-requirements.md`

---

## 1. Container Boundaries

Harmony’s monorepo layout already defines **runtime planes** which map directly to container boundaries:

- `apps/*` — **Deployable TypeScript apps and UIs** (thin adapters):
  - Examples: `apps/ai-console`, `apps/api`, `apps/web`.
  - Container role: HTTP/UI front doors and BFFs.
- `agents/*` — **Python agent runtimes**:
  - Examples: `agents/planner`, `agents/builder`, `agents/verifier`, `agents/orchestrator`.
  - Container role: control‑plane runtimes that call kits and platform runtimes.
- `platform/runtimes/*-runtime/**` — **Platform runtime services**:
  - Example: `platform/runtimes/flow-runtime/**` (platform flow runtime).
  - Container role: runtime‑plane services that execute flows/graphs on behalf of apps, agents, Kaizen, and CI.

Rule of thumb:

- Anything you **run** (HTTP servers, CLIs, runtimes) is a **container candidate**.
- Anything you **import** (slices in `packages/<feature>`, `packages/kits/*`, `packages/prompts`, etc.) remains a **library dependency** inside containers, not a container of its own.

---

## 2. Image Conventions (All Runtimes)

The following conventions SHOULD apply across all Harmony runtime images:

- **Base images**:
  - Node runtimes (apps): use official `node` images (e.g., `node:20-alpine`) with multi‑stage builds (builder + runtime).
  - Python runtimes (agents and `platform/runtimes/*-runtime/**`): use slim official images (e.g., `python:3.12-slim`) and rely on `uv` and `pyproject.toml` for dependency resolution.
- **User and filesystem**:
  - Run as a **non‑root user**; create a dedicated user and group for the service.
  - Keep container filesystems minimal; mount volumes only when necessary (e.g., for data or local development).
- **Configuration (12‑Factor)**:
  - All runtime configuration (secrets, URLs, flags, runtime profiles) MUST be provided via environment variables and/or external configuration (e.g., `platform/runtimes/config/**`).
  - Do not bake secrets into images.
- **Logging and observability**:
  - Write logs to **stdout/stderr** in structured JSON where practical.
  - Ensure OpenTelemetry exporters are configured via env vars (see `observability-requirements.md` and `infra/otel`).
  - Include standard labels/annotations (e.g., service name, environment, version) that align with OTel and Knowledge Plane records.
- **Health and readiness**:
  - Expose minimal **health** and **readiness** endpoints appropriate for the runtime:
    - Apps: HTTP health route (e.g., `/healthz`).
    - Runtimes: endpoints that confirm API tier and scheduler tier availability.
  - These endpoints are required to support both local sandbox `docker compose` and production orchestration (e.g., Vercel, Kubernetes).
- **Image naming and tagging**:
  - Use reproducible tags with commit SHA (and optionally branch):
    - Example: `<registry>/<project>/<component>:<git-sha>`.
  - Record image digests and tags in:
    - CI logs.
    - SBOMs and attestations (see `ci-cd-quality-gates.md`).
    - Knowledge Plane records when applicable.

---

## 3. Containerization by Component Type

### 3.1 Apps (`apps/*`)

Examples: `apps/ai-console`, `apps/api`, `apps/web`.

Key points:

- **Role**: HTTP/UI front doors and BFFs, thin over feature slices and kits.
- **Base image and build**:
  - Use Node multi‑stage builds:
    - Stage 1: dependencies installation and build (TypeScript/Next.js/Astro).
    - Stage 2: runtime (Node) with only production dependencies and compiled assets.
- **Environment**:
  - Respect Next.js and Astro environment conventions (e.g., `NODE_ENV`, `NEXT_PUBLIC_*` prefixes).
  - Configure flags and runtime endpoints via env vars, not baked values.
- **Health and metrics**:
  - Provide a simple health endpoint and ensure OTel instrumentation is enabled.
- **Usage in sandboxes**:
  - App images are used in:
    - **Preview deployments** (Vercel or equivalent).
    - **Local/CI sandboxes** via `docker compose` (see infra sandbox recipes).

### 3.2 Agents (`agents/*`)

Examples: `agents/planner`, `agents/builder`, `agents/verifier`, `agents/orchestrator`.

Key points:

- **Role**: control‑plane runtimes that orchestrate work using FlowKit, AgentKit, and other kits; call platform runtimes via contracts.
- **Base image and build**:
  - Use Python slim images with `uv` to manage dependencies as per `pyproject.toml` and `uv.lock`.
  - Keep images minimal; rely on workspace tooling for development and tests.
- **Environment**:
  - Configure:
    - Runtime endpoints for platform services (`platform/runtimes/*-runtime/**`).
    - Credentials and tokens for contracts and Knowledge Plane access.
  - Do not embed LangGraph engines directly; agents call platform runtimes via generated clients.
- **Health and metrics**:
  - Provide simple HTTP health endpoints where applicable, or equivalent health checks (e.g., liveness scripts).
  - Ensure OTel spans reflect caller metadata (`callerKind="agent"`, `callerId`, etc.).
- **Usage in sandboxes**:
  - Agent images are used in:
    - **Agent sandpit** sandboxes (see infra sandbox recipes).
    - CI jobs that need long‑running or orchestrated flows tied to contracts.

### 3.3 Platform Runtimes (`platform/runtimes/*-runtime/**`)

Example: `platform/runtimes/flow-runtime/**`.

Key points:

- **Role**: multi‑tenant **runtime‑plane services** that execute flows and graphs under policy and resource constraints.
- **Base image and build**:
  - Typically Python slim with `uv`, plus any engine dependencies (e.g., LangGraph).
  - Build artifacts MUST remain behind contract‑first APIs; engine internals (e.g., `langgraph/server.py`) are never exposed as public surfaces.
- **Environment and policy**:
  - Read **control‑plane configuration** from `platform/runtimes/config/**` (e.g., queue profiles, risk tiers, runtime policies) mounted or injected into the container.
  - Configure environment (`projectId`, `environment`, feature flags, risk tiers) via env vars.
- **Health and metrics**:
  - Health endpoints that verify API/gateway tier and basic scheduler health.
  - OTel traces and metrics with standard runtime attributes (`flow_id`, `run_id`, `caller_kind`, etc.).
- **Usage in sandboxes**:
  - Runtime images back:
    - Non‑production runtime environments (e.g., `development`, `staging`) used by apps, agents, Kaizen, and CI for sandbox runs.
    - Local/CI `docker compose` setups for minimal dev and agent sandpit sandboxes.

---

## 4. CI Integration: container_build and Security Gates

The containerization profile is enforced through CI gates described in:

- `ci-cd-quality-gates.md`
- `architecture/layers.md`
- `architecture/governance-model.md`

Key expectations:

- **container_build**:
  - For changes that touch `apps/*`, `agents/*`, or `platform/runtimes/*-runtime/**`, CI SHOULD:
    - Build corresponding images using this profile’s conventions.
    - Fail the pipeline if images cannot be built deterministically.
- **Security and compliance**:
  - Container images MUST be scanned for:
    - Vulnerabilities (e.g., via SCA tools).
    - Misconfigurations (e.g., root user, unnecessary capabilities).
    - License policy violations.
  - SBOMs SHOULD be generated (e.g., via Syft) and attached as artifacts.
- **Provenance and attestation**:
  - For deployable images, CI SHOULD:
    - Produce attestations (e.g., GitHub attestations or Sigstore) linking:
      - Image digest.
      - Git commit and PR.
      - Build environment details.
    - Publish or store these in the Knowledge Plane or an artifact registry.

---

## 5. Sandbox Recipes (Infra Touchpoints)

Concrete sandbox setups live under `infra/` and SHOULD follow this profile. At minimum:

- **Minimal dev sandbox**:
  - Uses app images (e.g., `apps/api`, `apps/ai-console` or `apps/web`) and the platform flow runtime image.
  - Includes supporting infra:
    - Datastore(s) (DB containers or emulators).
    - Queue/bus (e.g., NATS or Redis).
    - OTel collector.
  - Provides a `docker compose` file that:
    - Wires service dependencies via environment variables and networks.
    - Exposes app ports and basic health checks.
- **Agent sandpit sandbox**:
  - Uses agent images (`agents/*`), platform runtime image(s), and contracts clients.
  - May omit app images or replace them with stubs.
  - Suitable for:
    - Running Planner/Builder/Verifier flows.
    - Exercising Kaizen jobs.
    - Validating runtime changes in an isolated, disposable environment.

See `infra/sandbox/README.md` (and associated compose files) for concrete examples and commands (for example, `docker compose -f dev-sandbox.compose.yaml up`).

---

## 6. Relationship to the Methodology and Sandbox Flow

- The **Sandbox Flow** (`methodology/sandbox-flow.md`) describes how changes move through:
  - Specs and plans.
  - PRs, previews, and CI gates.
  - Manual promotion and rollback with flags.
- The **containerization profile** provides the **runtime packaging** that allows:
  - Previews and non‑production runtimes to be stood up consistently.
  - Local/CI sandboxes to mirror production‑like topology.
  - CI gates to enforce image and security standards in a repeatable way.

Together, they ensure that:

- Sandbox validations are not ad‑hoc; they reuse the same containers and contracts that underpin production.
- A small team can rely on clear, documented conventions for container builds, scans, and sandbox orchestration.


