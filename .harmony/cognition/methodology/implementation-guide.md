---
title: Harmony AI-Native, Human-Governed Methodology Implementation Guide
description: Detailed playbook for wiring Harmony’s Spec‑First (via SpecKit `speckit` wrapper for GitHub’s Spec Kit) + context-efficient planning (via PlanKit `plankit` wrapper for BMAD) + Flow orchestration (via FlowKit) methodology, tooling, and governance into a Turborepo + Vercel stack.
---

Below is a Harmony‑aligned implementation guide that shows exactly what you can wire up today, what needs a thin wrapper/kit, and what should stay in CI/Vercel. This guide aligns with the Harmony Methodology and Harmony's kit layer. Our approach:

- Wrap GitHub’s Spec Kit via our SpecKit (`speckit`) wrapper for Spec‑First flows and publishing.
- Wrap BMAD via PlanKit (our `plankit` kit) for ADRs and planning/feature story generation.
- Use FlowKit as the flow execution orchestrator between PlanKit and AgentKit, instantiating LangGraph flows from plans or canonical prompts.

This removes duplication, keeps us on the official GitHub’s Spec Kit semantics, and isolates BMAD API churn behind PlanKit while giving us a consistent, inspectable flow layer via FlowKit.

> Terminology note: “SpecKit” refers to our AI‑Toolkit kit (code `speckit`) that wraps GitHub’s Spec Kit. Mentions of the upstream tool explicitly use “GitHub’s Spec Kit”.
> **Sources** used for concrete behavior, commands, and integration details are cited inline where they matter most (Turborepo cache, Vercel previews/promote & flags, SLO/error budgets, OpenTelemetry for Next.js, OWASP ASVS & NIST SSDF, BMAD v6 alpha notes, plus AI‑Toolkit kit mappings). ([Turborepo][1])

---

## 1) Executive Summary

**Decision.** Use AI‑Toolkit kits:

- SpecKit (`speckit`) wraps GitHub’s Spec Kit for `specify → clarify → plan → tasks → analyze` and publishing via Dockit. Artifacts live under `docs/specs/<feature>/…` (or GitHub’s Spec Kit defaults).
- PlanKit (`plankit`) wraps BMAD to generate ADRs and a BMAD plan/story from the validated SpecKit outputs.
- FlowKit orchestrates long‑running, stateful flows (via LangGraph) from those plans or from canonical prompts, coordinating downstream kits.

This keeps Spec semantics authoritative (from GitHub’s Spec Kit), makes BMAD usage stable behind a single kit boundary (PlanKit), and gives us a standard way to turn plans/prompts into executable flows via FlowKit and the shared LangGraph runtime under `agents/runner/runtime/**`, without every agent owning its own runtime.

**Why wrappers?**

- **Upgrade safety.** BMAD v6 is active and evolving; encapsulating BMAD behind PlanKit shields calling sites from workflow/param churn. ([GitHub][3])
- **Spec‑first integrity.** We rely on GitHub’s Spec Kit instead of re‑implementing it; SpecKit adds validation, structure, and publishing only.
- **Harmony alignment.** Clean handoff: `SpecKit → PlanKit → FlowKit → AgentKit/TestKit/PolicyKit`, matching the Methodology and AI‑Toolkit READMEs and the canonical kit roles described in `docs/services/planning/service-roles.md`.

**Integration surface.**

- **Kits:** `speckit` (SpecKit kit; wraps GitHub’s Spec Kit), `plankit` (BMAD wrapper), and `flowkit` (flow orchestration), located under `packages/kits/*`. Contracts live under `packages/contracts/**` (e.g., `/v1/speckit/*` operations).
- **BMAD & agents:** Continue to use BMAD and BMB internally; PlanKit calls BMAD. If you need new personas, use BMB’s builder (`create-agent`). ([GitHub][2])
- **Monorepo & CI/CD:** Turborepo for **pipelines/remote cache**, Vercel for **branch previews & guarded promote to production**, **feature flags** using Vercel Flags SDK + Edge Config (or your provider), and **OpenTelemetry** via `@vercel/otel`. ([Turborepo][1])

**Reliability & Security guardrails baked in.**

- **SRE**: SLIs/SLOs/error budgets & postmortems per Google SRE workbook guidance. The SRE module produces `docs/sre/<feature>/…` and gates merges when error budgets would be exceeded. ([Google SRE][5])
- **DevSecOps**: CI gates include CodeQL, Semgrep, Gitleaks, SBOM (**Syft → SPDX preferred; CycloneDX optional**), OpenAPI lint (Spectral), OpenAPI diff (oasdiff), and Schemathesis fuzzing for APIs. ([GitHub Docs][6])
- **Framework mappings**: OWASP ASVS v5 (default; v4.0.3 for legacy cross-reference), NIST SSDF SP 800‑218, and STRIDE micro‑threat models per feature. ([GitHub][7])

**Expected impact.**

- **Lead time/DF**: Trunk‑based + Vercel previews + Turborepo cache → **smaller PRs**, **faster CI**, **1–n deploys/day**; DORA metrics will improve (deployment frequency, lead time) when gates go green. ([Trunk Based Development][8])
- **Change‑fail rate/MTTR**: Feature flags + preview smoke + canary + instant **promote/rollback** reduce CFR and MTTR. ([Vercel][9])
- **SLO attainment**: OTel traces + SLO alerts + error budgets enforce reliability ceilings (stop‑the‑line when budgets burn). ([Vercel][10])

---

## 2) Overview table — **Kits vs BMAD vs External**

| Method element / Lifecycle node              | Classification              | What/Where                                                                                                                                        |
| -------------------------------------------- | --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Spec‑First (GitHub’s Spec Kit via SpecKit)** | **AI‑Toolkit (SpecKit)**    | `speckit` wrapper around GitHub’s Spec Kit; CLI/HTTP/MCP ops (contracts in `packages/contracts/**`) for `init`, `validate`, `render`, `diagram`.   |
| **Plan/ADRs (BMAD)**                         | **AI‑Toolkit (PlanKit)**    | `plankit` wraps BMAD to produce ADRs and BMAD plans/stories from SpecKit outputs.                                                                 |
| **BMAD agents/workflows (BMM/BMB)**          | **Native (BMAD v6 alpha)**  | Use BMM and BMB internally; PlanKit calls BMAD. `bmad/bmb` builder (e.g., `create-agent`). ([GitHub][4])                                         |
| **SRE module** (SLOs, runbooks, postmortems) | **Custom BMAD**             | `src/modules/sre/…` with workflows `sre:define/validate/postmortem` → `docs/sre/<feature>/…`. References Google SRE. ([Google SRE][5])            |
| **Security module** (ASVS/SSDF/STRIDE)       | **Custom BMAD**             | `src/modules/sec/…` with `sec:threat-model/asvs-map/validate` → `docs/security/<feature>/…`. ASVS v4.0.3 + v5.0 note, SSDF 800‑218. ([GitHub][7]) |
| **QA module** (test strategy/contracts)      | **Custom BMAD**             | `src/modules/qa/…` with `qa:strategy/contracts/validate` → `docs/tests/<feature>/…`. Pact, Schemathesis, Playwright. ([Pact Docs][11])            |
| **Perf module** (budgets/load test)          | **Custom BMAD**             | `src/modules/perf/…` with `perf:budgets/load-test/validate` → `docs/performance/<feature>/…`.                                                     |
| **DevOps module** (CI/CD/infra)              | **Custom BMAD**             | `src/modules/devops/…` with `devops:pipeline/infra/validate` → `docs/devops/<feature>/…`.                                                         |
| **Twelve‑Factor / Hexagonal enforcement**    | **Custom BMAD + External**  | Encoded as **check files** + CI checks; structure enforced in repo layout and simple validations. 12‑Factor reference. ([12factor][12])           |
| **Monorepo + Turborepo**                     | **External (tooling)**      | `turbo.json` pipelines, remote cache with Vercel; CI uses cache. ([Turborepo][1])                                                                 |
| **Vercel previews & promote**                | **External**                | PR preview per branch; `vercel promote` for guarded prod. Feature flags via Vercel Flags SDK. ([Vercel][13])                                      |
| **OpenTelemetry + Observability**            | **External (+ ObservaKit)** | Bootstrap Node OTel via `infra/otel/instrumentation.ts` (repo) and record ObservaKit spans/logs; link `trace_id` in PRs. ([Next.js][14])         |
| **Security scans, SBOM**                     | **External (CI)**           | CodeQL, Semgrep, Gitleaks, **Syft/SPDX (preferred)** or CycloneDX. ([GitHub Docs][6])                                                             |

---

## 3) Lifecycle matrix (A→J): responsibilities, artifacts, commands, gates

```mermaid
flowchart LR
  A[Spec (GitHub’s Spec Kit via SpecKit) + ADR stub] --> B[Shape & Scope Cuts]
  B --> C[PlanKit (BMAD plan + ADR)]
  C --> D[Dev in AI IDE (human checkpoints)]
  D --> E[PR -> Vercel Preview (feature-flagged; ObservaKit trace linked)]
  E --> F[CI Gates: lint/type/test/scan/contract/SBOM]
  F -->|all green| G[Merge to Trunk]
  G --> H["Auto Deploy to Preview; Manual Promote to Prod (guarded)"]
  H --> I[Operate: SLOs, alerts, OTel, logs]
  I --> J[Learn: Postmortem & ADR updates]
  J -->|feedback| A
```

**Gates legend and runtime/caching defaults:**

- **S‑1** Spec coherence (SpecKit validated), **P‑1** PlanKit/BMAD alignment, **S‑2** Coverage (security/perf/tests), **I‑1** Plan saved, **I‑2** Post‑build drift.
- Next.js 15+/16: default `fetch`/GET handlers are `no-store`. Opt into caching explicitly (`force-static`, `revalidate`) with stable cache keys and record them in run records.
- Bundling & cold starts (Next.js 15/16): use bundling controls to externalize heavy packages from Edge surfaces; keep heavy/stateful work on Node/Serverless. Measure cold‑start and bundle deltas with ObservaKit spans/metrics before and after changes; only adopt bundling tweaks that materially reduce latency without raising complexity.
- Evaluate feature flags server‑side. Use Edge selectively (flags/headers); keep heavy/long‑running work in Node/serverless; schedule non‑blocking side‑effects via `next/after`.

> When BMAD is used under PlanKit, follow BMAD’s Node/version guidance (v6 alpha currently recommends Node 24+). ([GitHub][4])

### A — Spec (GitHub’s Spec Kit via SpecKit) + ADR intake

- **Mgmt**: **AI‑Toolkit (SpecKit)**.
- **Inputs → Outputs**:

  - In: intent/idea (issue), constraints.
  - Out: `docs/specs/<feature>/spec.md` and related GitHub’s Spec Kit docs; ADR is created in the next stage by PlanKit. (ASVS/SSDF per OWASP/NIST.) ([GitHub][7])
- **Commands & hooks**: `speckit init …` to author; `speckit validate …` to ensure structure; `speckit render …` to publish. See `docs/services/README.md` (SpecKit + PlanKit sections) and docs/services/planning/spec/guide.md for wrapper details and contracts.
- **Human checkpoint**: Driver & Navigator confirm problem, scope, non‑functionals (two passes if solo).
- **Integrations**: Open an ObservaKit trace at spec start and persist the `trace_id` for downstream linkage.
- **Gate**: **S‑1** passes when SpecKit validation succeeds and required fields are present.

### B — Shape & Scope cuts

- **Mgmt**: **AI‑Toolkit (SpecKit)** for clarify/plan/tasks, or keep shaping lightweight in the spec.
- **Outputs**: `docs/specs/<feature>/plan.md` (hexagonal plan; ports/adapters), updated `security.md` (ASVS), `sre.md` budgets.
- **Command**: `speckit plan …` (optional) or update plan.md manually as part of SpecKit flow.
- **Human**: Approve scope cuts.
- **Gate**: **I‑1** (plan saved & signed).

### C — Plan & Acceptance Criteria (PlanKit → BMAD)

- **Mgmt**: **AI‑Toolkit (PlanKit)** wraps BMAD.
- **Workflows**: PlanKit reads SpecKit outputs and emits ADR + BMAD plan/story.
- **Outputs**: `docs/implementation/<feature>.md`, `docs/alignment/<feature>.md`, `docs/stories/<feature>/story.md`, plus `plan.json` if you persist the machine‑readable plan.
- **Command**: `plankit plan --spec docs/specs/<feature>/spec.md --out plan.json`. (BMB `create-agent` available if you need a new agent persona.) ([GitHub][2])
- **Human**: Verify ACs & security/perf AC embedded; confirm AI determinism plan (pinned provider/model/version, temperature ≤ 0.3, prompt hash, golden tests).
- **Gate**: **P‑1** (PlanKit/BMAD alignment: ADR/plan ↔ spec/plan tie‑out).

### D — Dev in AI IDE (guided, HITL)

- **Planning mgmt**: PlanKit planning policies + AI IDE rules.
- **Artifacts**: `.cursorrules` seeds prompts with SpecKit + gates; AI IDE **Commands** for “spec‑to‑code”, “threat‑model”, “generate tests”. ([Cursor][15])
- **Command**: AI IDE custom command triggers SpecKit/PlanKit flows; or run `speckit …` / `plankit …` directly.
- **Human**: Approve agent plans & diffs; license‑safe suggestion check (ORT or license‑checker); record AI provenance (provider/model/version/params, prompt hash) and attach ObservaKit `trace_id` to PR. ([OSS Review Toolkit][16])
- **Determinism**: Follow AI‑Toolkit Deterministic Operation Policy — pin AI config, add golden tests guarded by JSON‑Schema, avoid new deps unless they materially reduce complexity.
- **Agentic execution boundary (no‑silent‑apply)**: Use **AgentKit** (with **ToolKit** wrappers) to produce proposed diffs, tests, and artifacts under `runs/**`. Local/dev runs default to `--dry-run`; mutating operations MUST use idempotency keys; GuardKit redacts at write/log boundaries. Required spans: `kit.agentkit.execute`, `kit.toolkit.call.*`. Run records include `run.id`, `stage=implement`, and determinism fields (`prompt_hash`, `idempotencyKey`). See “Alignment addenda (AI‑Toolkit v0.2)” for observability/run‑record details. AgentKit orchestration can be implemented atop frameworks like LangGraph while remaining runtime‑agnostic; keep orchestration choices hidden behind the kit boundary and preserve the no‑silent‑apply constraint.
- **Gate**: **S‑2** pre‑merge checks stubbed locally (lint/type/units/contracts); PolicyKit/EvalKit dry‑run pass.

### E — PR → Vercel Preview (feature‑flagged)

- **BMAD mgmt**: **External** (GitHub + Vercel).
- **Artifacts**: PR template comment prints preview URL; feature flags via **Vercel Flags SDK** (or provider). Attach `trace_id` and (if agents used) AI provenance. ([Vercel][13])
- **Command**: Open PR; Vercel auto‑creates preview per branch/PR. ([Vercel][13])
- **Governance**: PRs SHOULD use the **PatchKit PR Template** (see AI‑Toolkit) and include risk class, rollback/flag plan, ObservaKit `trace_id`, and pinned AI configuration (provider/model/version/params + prompt hash when applicable).
- **Gate**: **S‑2** CI gates must pass.

### F — CI Gates

- **BMAD mgmt**: **External** (GitHub Actions).
- **Checks**: ESLint/TS strict; unit + **contract tests** (Pact), **OpenAPI lint** (Spectral), **OpenAPI diff** (oasdiff), **Schemathesis** API fuzz, **CodeQL/Semgrep/Gitleaks**, **SBOM** (**Syft/SPDX preferred**), **Dependency Review (licenses)**, **bundle budgets** (Size‑Limit), and preview smoke (Playwright or `scripts/smoke-check.sh`). Enforce observability presence on changed flows (required spans/logs with `trace_id`). **PolicyKit** rulesets are fail‑closed; **EvalKit/TestKit** gates must pass or block the PR; **ComplianceKit** evidence is required for High‑risk changes. ([Pact Docs][11])
- **PR body governance**: Validate **PatchKit PR Template** fields (risk rubric, flags/rollback, ObservaKit trace URL/ID, AI determinism config). Validate kit run records against the AI‑Toolkit run‑record schema and fail if required determinism/observability fields are missing.
- **Gate**: **S‑2** passes when required checks are ✅.

### G — Merge to Trunk

- **BMAD mgmt**: **External** (GitHub, Trunk‑Based). Short‑lived branches only. ([Trunk Based Development][8])
- **Gate**: Protected branch requires all checks + 1 review.

### H — Deploy (guarded)

- **BMAD mgmt**: **External** (Vercel).
- **Artifacts**: Promote preview → production (`vercel promote`); instant rollback available. ([Vercel][17])
- **Gate**: “Flagged on” via Vercel flags; canary checklist; start a short watch window and link ObservaKit trace in PR notes; rollback path validated. When error budgets are burning (SLO burn‑rate), freeze risky merges/promotions until budgets recover.
- **Production policy**: In Vercel, disable **Auto Production Deployments** so Production is updated exclusively via `vercel promote <preview-url>`. This enforces Harmony’s guarded promote/rollback discipline and preserves a deterministic rollback path.

### I — Operate (SLOs, alerts, OTel)

- **BMAD mgmt**: **Custom BMAD (sre)** + **External** (observability).
- **Artifacts**: `docs/sre/<feature>/slo.md`, `runbook.md`, OTel traces via `infra/otel/instrumentation.ts` (Node SDK) and Next.js instrumentation; ObservaKit records spans/logs. ([Vercel][10])
- **Gate**: Error budget burn check; auto‑open incident.

### J — Learn (postmortem, ADR)

- **BMAD mgmt**: **Custom BMAD (sre)** + optional **SpecKit** analyze.
- **Artifacts**: `docs/sre/<feature>/postmortem.md`, updated `adr.md`, `docs/specs/<feature>/analysis.md`.
- **Gate**: **I‑2** (post‑build drift documented & back‑propagated).

---

## 4) File tree (new/changed files)

```text
/                      # monorepo root (Turborepo)
/apps/api              # monolith-first TS service (Hexagonal)
/apps/api/src/core     # domain
/apps/api/src/app      # use-cases/services
/apps/api/src/ports    # interfaces (ports)
/apps/api/src/adapters # http/db/queue (adapters)
/docs/specs/<feature>/ # GitHub’s Spec Kit artifacts (via SpecKit)
/docs/implementation/<feature>.md
/docs/alignment/<feature>.md
/docs/sre/<feature>/{slo.md,runbook.md,postmortem-template.md}
/docs/security/<feature>/{asvs.md,stride.md,ssdf.md}
/docs/tests/<feature>/{strategy.md,contracts.md,e2e.md}
/docs/performance/<feature>/{budgets.md,load-test.md}
/docs/devops/<feature>/{pipeline.md,infra.md}
/packages/contracts/**  # HTTP/MCP contracts for SpecKit wrapper (and other kits)
/packages/kits/speckit/**  # SpecKit kit implementation (`speckit`) — wraps GitHub’s Spec Kit
/packages/kits/plankit/**  # PlanKit implementation (wrapper around BMAD)
/src/modules/{sre,sec,qa,perf,devops}/(README.md,workflows/*.yaml,agents/*.md)
/scripts/{speckit.ts,plan.ts,validate-gates.ts}
/.cursorrules
turbo.json
tsconfig.base.json
pnpm-workspace.yaml
apps/api/vercel.json
.github/workflows/ci.yml
.github/workflows/security.yml
.spectral.yaml
scripts/flags-stale-report.js
```

---

## 5) Concrete snippets (minimal but runnable)

### 5.1 Turborepo config (`turbo.json`)

```json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["pnpm-lock.yaml", "package.json", "tsconfig.base.json"],
  "tasks": {
    "lint": {
      "dependsOn": ["^lint"],
      "outputs": ["reports/eslint-*.json"]
    },
    "typecheck": {
      "dependsOn": ["^typecheck"],
      "outputs": ["tsconfig.tsbuildinfo"]
    },
    "build": {
      "dependsOn": ["^build", "typecheck"],
      "outputs": [
        "dist/**",
        "build/**",
        ".next/**",
        ".vercel/output/**",
        "!.next/cache/**"
      ],
      "env": ["NODE_ENV", "NEXT_PUBLIC_*"]
    },
    "test": {
      "dependsOn": ["^test", "build"],
      "outputs": ["coverage/**", "reports/junit-*.xml"]
    },
    "contracts:check": {
      "dependsOn": ["^build"],
      "inputs": ["packages/contracts/**"],
      "outputs": ["packages/contracts/reports/**"],
      "env": ["OPENAPI_BASE_REF", "PACT_BROKER_BASE_URL"]
    },
    "sbom": {
      "outputs": ["sbom/**"]
    },
    "secrets:scan": {
      "cache": false
    },
    "preview:vercel": {
      "dependsOn": ["build"],
      "cache": false,
      "env": [
        "VERCEL_ORG_ID",
        "VERCEL_PROJECT_ID",
        "VERCEL_TOKEN",
        "NEXT_PUBLIC_*"
      ]
    }
  }
}
```

> Enable **remote cache** in CI by setting `TURBO_TOKEN` & `TURBO_TEAM` (or your custom cache), per Turborepo docs. ([Turborepo][1])

### 5.2 Minimal **vercel.json** for `apps/api`

```json
{
  "functions": {
    "api/index.ts": {
      "runtime": "nodejs24.x",
      "maxDuration": 10
    }
  },
  "crons": [
    { "path": "/api/cron", "schedule": "0 5 * * *" }
  ]
}
```

> Vercel **cron** uses `vercel.json` with `crons` array; **promote** previews to production with dashboard or CLI `vercel promote`. Use **Flags SDK** for feature‑gated rollout. ([Vercel][18])

### 5.3 Node / Next.js **OpenTelemetry & ObservaKit** – `infra/otel/instrumentation.ts` (bootstrap) and app usage

```ts
// infra/otel/instrumentation.ts is already provided in this repo.
// Usage in a Node entrypoint (e.g., apps/api/src/server.ts)
import initializeInstrumentation from '@infra/otel/instrumentation';
await initializeInstrumentation(); // before creating HTTP server
```

> Bootstrap via `infra/otel/instrumentation.ts` (Node SDK). For Next.js App Router, see `apps/ai-console/instrumentation.ts` which guards Node runtime and dynamically imports the initializer. Attach `trace_id` to PRs for changed flows. ([Vercel][10])
>
> ObservaKit alignment (required telemetry fields):
>
> - Resource attributes: `service.name` (e.g., `harmony.kit.<kitName>` or app service), `service.version`, `deployment.environment`.
> - Span attributes on lifecycle/action spans: `run.id`, `kit.name`, `kit.version`, `stage`, `git.sha`, `repo`, `branch` (and AI params when applicable).
> - Keep attribute cardinality low and never log secrets/PII; pair with GuardKit redaction.
>
> Security headers (Next.js surfaces): enforce CSP and core headers via `next-safe-middleware` for SSR; prefer platform-level headers on Vercel for SSG and avoid duplicative/conflicting policies.

### 5.3b Next.js 15/16 bundling controls (cold starts)

- Prefer Node/Serverless for heavy/stateful dependencies; keep Edge handlers read‑mostly and small.
- Use Next.js bundling controls to externalize large packages from Edge bundles; avoid shipping heavy crypto/ORM/tooling on the Edge.
- Measure impact with ObservaKit: emit spans/metrics for cold start and bundle deltas; only adopt changes that materially reduce latency without adding operational complexity.
- Document bundling choices in the PR using the PatchKit template (perf deltas + rollback plan).

### 5.3c ObservaKit offline/local‑first telemetry (buffered export)

- When `--dry-run` is set or the OTLP endpoint is unavailable, buffer spans/logs to `runs/{timestamp}-{kit}-{runId}/otel-buffer.ndjson` and flush later.
- Still include required resource attributes and span/log fields; never serialize secrets/PII (GuardKit redaction at write/log boundaries).
- Add a buffered‑export summary event to the parent lifecycle span upon later flush to preserve provenance.

### 5.3a Feature Flags (server‑side) — provider registration and resolution

```ts
// packages/config/src/flags.ts (already in repo)
// Register your provider during app startup (API and SSR surfaces).
import { setFlagProvider, isFlagEnabled, listFlags } from '@harmony/config';
import { vercelFlagsProvider } from './your-vercel-flags-adapter'; // implement adapter to FlagProvider

setFlagProvider(vercelFlagsProvider);

// Resolution order: Provider → Env (HARMONY_FLAG_*) → Defaults.
// Evaluate on the server (Node/Edge). Do not expose secrets or provider internals to clients.
const enabled = isFlagEnabled('enableNewNav');
const snapshot = listFlags();
```

> Keep flags short‑lived; run `scripts/flags-stale-report.js` weekly and remove stale flags. Default OFF; enable for internal cohorts first.

### 5.4 SpecKit + PlanKit — minimal usage and artifacts

SpecKit (`speckit`) wraps GitHub’s Spec Kit and provides consistent CLI/HTTP/MCP operations; PlanKit wraps BMAD to produce ADRs and plans from the validated SpecKit outputs.

Examples

```bash
# Author and scaffold a new spec
speckit init --feature oauth-billing --owner you@org --out docs/specs/oauth-billing

# Validate required artifacts and structure
speckit validate --path docs/specs/oauth-billing

# Render/publish docs via Dockit
speckit render --path docs/specs/oauth-billing --publish

# Create ADR and BMAD plan/story from the spec
plankit plan --spec docs/specs/oauth-billing/spec.md --out plan.json
```

See `docs/services/README.md` (SpecKit + PlanKit sections) for wrapper details.

### 5.4a Contracts Registry & Kit Metadata (normative)

- Place kit input/output JSON‑Schemas under `packages/contracts/schemas/kits/` with versioned names:
  - `speckit.inputs.v1.json`, `speckit.outputs.v1.json`
  - `plankit.inputs.v1.json`, `plankit.outputs.v1.json`
- Add kit metadata files under each kit, conforming to AI‑Toolkit KitMetadata v0.2:
  - `packages/kits/<kit>/metadata/kit.metadata.json` declaring `pillars`, `lifecycleStages`, `inputsSchema`, `outputsSchema`, required spans, determinism/HITL/idempotency.
- Update `packages/contracts/src/index.ts` (barrel) to re‑export schemas for programmatic consumers; include schema diffs in PRs when interfaces change.
- Validate kit run records against the AI‑Toolkit run‑record schema (v0.2). Runs MUST include: `runId`, `kit`, `stage`, `risk`, `telemetry.trace_id`, determinism (`prompt_hash`, `idempotencyKey`, optional `cacheKey`), `status`, and `summary`.
- Enforce OpenAPI diffs (oasdiff) for API changes and JSON‑Schema diffs for kit contracts as CI gates.

### 5.5 Spec templates (under `docs/specs/<feature>/`)

`spec.md`

```md
# <Feature> — One-pager
Problem
Constraints (users, data, legal, PII/PHI?)
API/UI Contracts (OpenAPI path stubs, UI states)
Non-functionals (perf SLOs, scalability, availability)
Acceptance Criteria (testable, flag-gated)
```

`risk.md` (STRIDE micro‑worksheet)

```md
Spoofing | Tampering | Repudiation | Information Disclosure | DoS | Elevation
Risks:
Mitigations:
Tests:
```

> STRIDE categories are Microsoft SDL canon. ([learn.microsoft.com][19])

`security.md` (ASVS + SSDF)

```md
ASVS Level: L2 (update if L3)
Controls mapped: Authn/Session, Access Control, Input Validation, Crypto, Logging, Errors, Config/Hardening
SSDF evidence planned: secure design review, static analysis, dependency & license scans, SBOM
```

> ASVS v4.0.3 and v5 landing; SSDF SP 800‑218. ([GitHub][7])

`sre.md`

```md
SLIs: availability, p95 latency, error rate, saturation
SLOs: web TTFB p95<=200ms; API p95<=300ms; avail 99.9%
Error budget: 0.1% monthly
Alert policy: page on budget burn > 2%/h; ticket otherwise
Runbook link: ../sre/<feature>/runbook.md
```

> Error budget & SLO constructs per Google SRE workbook. ([Google SRE][5])

`plan.md`

```md
Hexagonal plan:
- Domain objects
- Use cases (app/)
- Ports (interfaces)
- Adapters: http (REST), db (Postgres), queue (optional)
```

> Hexagonal guidance from Cockburn. ([Alistair Cockburn][20])

`tasks.md`

```md
Story shards (DOR/DOD, QA hooks):
- Port: AuthPort, BillingPort
- Adapter tasks: Next.js routes, Prisma repo, Stripe webhook
- Tests: unit (core), contract (Pact), OpenAPI lint (Spectral), fuzz (Schemathesis), e2e smoke (Playwright)
```

> Pact/Schemathesis/Playwright docs. ([Pact Docs][11])

`analysis.md`

```md
What worked/failed, drift vs. plan, follow-ups to ADRs, debt backlog
```

### 5.6 **CI** (GitHub Actions) — core gates

`.github/workflows/ci.yml` (excerpt)

```yaml
name: CI
on: [pull_request, push]
jobs:
  build-test:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      security-events: write
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
        with: { version: 10 }
      - uses: actions/setup-node@v4
        with: { node-version: '24' }
      - run: pnpm install --frozen-lockfile
      - name: Lint & typecheck
        run: pnpm turbo run lint typecheck --cache-dir=.turbo
      - name: Unit tests
        run: pnpm turbo run test
      - name: Contract tests (Pact)
        run: pnpm turbo run contracts:check
      - name: OpenAPI lint (Spectral)
        run: npx spectral lint ./packages/contracts/openapi.yaml
      - name: OpenAPI diff (oasdiff)
        run: |
          git fetch origin "${{ github.base_ref }}" --depth=1
          npx @redocly/oasdiff breaking-changes "origin/${{ github.base_ref }}:packages/contracts/openapi.yaml" "packages/contracts/openapi.yaml"
      - name: API fuzz (Schemathesis)
        run: pipx run schemathesis run ./packages/contracts/openapi.yaml --checks all --hypothesis-derandomize
      - name: Bundle budgets
        run: npx size-limit
      - name: Generate SBOM (Syft → SPDX)
        run: syft dir:. -o spdx-json=sbom/sbom.spdx.json
      - name: Dependency Review (licenses)
        uses: actions/dependency-review-action@v4
        with:
          fail-on-severity: high
          allow-licenses: Apache-2.0,BSD-2-Clause,BSD-3-Clause,MIT
      - name: Preview smoke (if PREVIEW_URL provided by Vercel App or prior step)
        if: env.PREVIEW_URL != ''
        env:
          PREVIEW_URL: ${{ env.PREVIEW_URL }}
        run: bash scripts/smoke-check.sh "$PREVIEW_URL"
```

`.github/workflows/security.yml` (excerpt)

```yaml
name: Security Scans
on: [pull_request]
jobs:
  sast:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
    steps:
      - uses: actions/checkout@v4
      - uses: github/codeql-action/init@v3
        with: { languages: 'javascript' }
      - uses: github/codeql-action/analyze@v3
      - uses: MetaMask/semgrep-action@main
      - uses: gitleaks/gitleaks-action@v2
```

> CodeQL, Semgrep, Gitleaks & SBOM references. ([GitHub Docs][6])
> Size-Limit is a pragmatic **bundle budget** tool; Next.js bundle analysis actions are also available. ([GitHub][21])

### 5.7 **Monorepo skeleton** (TypeScript; monolith‑first; Hexagonal)

```plaintext
/apps/api
  /src/core            # domain entities, value objects
  /src/app             # use-cases/services orchestrating core
  /src/ports           # ports/interfaces (AuthPort, BillingPort, etc.)
  /src/adapters/http   # Fastify/Hono/Next route handlers as adapters
  /src/adapters/db     # Prisma repo implementations
  /src/adapters/queue  # (optional)
  index.ts             # bootstraps http adapter
```

> Turborepo + monorepo on Vercel is standard; see monorepo/Next guides. ([Turborepo][22])

### 5.8 **Cursor** integration: `.cursorrules` (excerpt)

```json
{
  "project": "saaS-monolith",
  "rules": [
    { "when": "writing code", "then": "respect ports/adapters; change only adapter unless test requires port change" },
    { "when": "creating tests", "then": "use Pact for contracts; Schemathesis against openapi.yaml; Playwright smoke on Vercel preview" },
    { "when": "security", "then": "map ASVS L2 controls into acceptance criteria; use OWASP input validation guidance; do not store secrets" }
  ],
  "contextFiles": [
    "docs/specs/**",
    "docs/security/**",
    "docs/sre/**",
    "docs/tests/**"
  ]
}
```

> Cursor **Rules** & **Commands** docs for project rules & custom commands. ([Cursor][23])

---

## 6) Command cookbook (copy‑paste)

**Day‑0 bootstrap (empty repo)**:

```bash
# 1) Init monorepo
pnpm dlx create-turbo@latest my-saas && cd my-saas
# 2) Ensure Node 20+ (24.x if using BMAD v6 alpha under PlanKit)
node -v
# 3) Add kits and contracts (repo-specific)
#    - SpecKit wrapper contracts live in packages/contracts/**
#    - Implement speckit/plankit or vendor as needed
git add .
# 4) First Spec run (GitHub’s Spec Kit via SpecKit)
speckit init --feature oauth-billing --out docs/specs/oauth-billing
speckit validate --path docs/specs/oauth-billing
# 5) Plan/ADRs (PlanKit → BMAD)
plankit plan --spec docs/specs/oauth-billing/spec.md --out plan.json
# 6) Push branch -> PR -> Vercel Preview
git checkout -b feat/oauth-billing && git commit -am "feat: init oauth billing" && git push -u origin HEAD
# 7) CI gates -> merge -> guarded promote
# in Vercel dashboard or CLI:
vercel promote  # promote preview to production
```

> PR previews & promote are built‑in to Vercel. If using BMAD v6 alpha under PlanKit, follow BMAD’s Node/version guidance. ([GitHub][4])

**Useful npm scripts (add to root `package.json`):**

```json
{
  "scripts": {
    "speckit:init": "speckit init",
    "speckit:validate": "speckit validate",
    "speckit:render": "speckit render",
    "plankit:plan": "plankit plan",
    "check:openapi": "spectral lint ./packages/contracts/openapi.yaml",
    "check:contracts": "pnpm --filter @api test:contracts",
    "check:sbom": "syft dir:. -o spdx-json=sbom/sbom.spdx.json",
    "check:bundle": "size-limit"
  }
}
```

---

## 7) Operating Rules (one page)

- **When to run phases**

  - **specify/plan**: anytime a new feature/epic is started; re‑run on scope change.
  - **tasks**: before coding; outputs AC + contracts + test strategy.
  - **analyze**: after release; record drift, update ADR.
- **Exit criteria**

  - **S‑1**: SpecKit artifacts validated; completeness checklist passes.
  - **P‑1**: PlanKit/BMAD ADR/plan/story align with the Spec; AC includes security/perf and AI determinism (pinned model/params, prompt hash, golden tests).
  - **S‑2**: CI **all green** (lint/type/unit/contract/openapi lint+diff/schemathesis/size/CodeQL/Semgrep/Gitleaks/SBOM/preview smoke). PolicyKit/EvalKit pass; ObservaKit present on changed flows.
  - **I‑1**: Tasks split to ports/adapters; DOR/DOD present.
  - **I‑2**: Postmortem & ADR updated when incidents occur.
- **Feature flags**: all user‑visible work behind flags; enable canary checks on preview first. ([Vercel][24])
- **SLOs & alerts**: maintain SLO files per feature; if **error budget** exhausted, freeze flag rollout until remediation; link ObservaKit trace IDs in PRs. ([Google SRE][5])

### CacheKit TTL & Validity Policy (summary)

- Pure fetches with low volatility: TTL ≈ 15 minutes; derived indexes/stores: content‑addressed and invalidated on input hash change; provider metadata: ≈ 24 hours.
- TTLs must never leak into artifact names or outputs; declare and record stable cache keys in run records when caching is used.
- Provide `--cache-key` for pure/expensive operations; raise a `CacheIntegrityError` (exit 8) on integrity failures and block in CI.

---

## SpecKit + PlanKit (SpecKit wraps GitHub’s Spec Kit; PlanKit wraps BMAD)

### Minimal wiring

```plaintext
packages/contracts/
  openapi.yaml             # SpecKit wrapper HTTP contract (/v1/speckit/*)
packages/kits/
  speckit/**               # SpecKit kit (`speckit`) — wraps GitHub’s Spec Kit
  plankit/**               # PlanKit kit (BMAD wrapper)
scripts/
  speckit.ts               # thin CLI to call SpecKit (`speckit`), which calls GitHub’s Spec Kit
  plan.ts                  # thin CLI that calls PlanKit (and PlanKit calls BMAD)
docs/specs/<feature>/      # SpecKit artifacts
```

### Flows

- **`speckit init`** → writes: `spec.md`, `risk.md`, `security.md`, optional `data-model.md`, `quickstart.md` → **Gate S‑1** when validated.
- **`speckit plan/tasks/analyze`** (optional) → updates plan/tasks and post‑build analysis.
- **`plankit plan`** → generates ADR + BMAD plan/story from the validated SpecKit outputs → **Gate P‑1** when aligned with scope and constraints.

> PlanKit encapsulates BMAD APIs. Keep callers bound to PlanKit so BMAD workflow renames/param shifts don’t leak.

### Scripts & commands (optional wrappers)

- Prefer invoking `speckit` and `plankit` directly. If you add local wrappers, keep them thin and declarative; do not re‑implement SpecKit.

### Wiring to PlanKit & BMAD/BMB

- **BMB agent(s):** If you need a new persona (e.g., “Security Architect”), scaffold via `bmb/workflows/create-agent`. ([GitHub][2])
- **PlanKit orchestration:** PlanKit wraps BMAD. Keep a thin local CLI/HTTP boundary for PlanKit so callers don’t depend on BMAD’s internal workflow names/params.

---

## Custom modules (other methodology areas)

### a) **SRE module** (`src/modules/sre/`)

- **Purpose:** Define SLIs/SLOs, error budgets, runbooks, postmortems.
- **Workflows:** `sre:define` (create `docs/sre/<feature>/slo.md`, `runbook.md`), `sre:validate` (assert SLO syntax), `sre:postmortem` (create `postmortem.md`).
- **Agent:** `agents/sre-engineer.md`.
- **Gate ownership:** `sre:validate` contributes to **S‑1** (SLO presence) and **I‑2** (postmortems).
- **Refs:** Google SRE policies & Art of SLOs handbook. ([Google SRE][5])

### b) **Security module** (`src/modules/sec/`)

- **Purpose:** STRIDE + ASVS + SSDF mapping per feature.
- **Workflows:** `sec:threat-model` → `docs/security/<feature>/stride.md`, `sec:asvs-map` → `asvs.md`, `sec:validate` (ASVS level + SSDF evidence present).
- **Agent:** `agents/security-engineer.md`.
- **Refs:** ASVS v5 (default; v4.0.3 legacy mapping), SSDF SP 800‑218. ([GitHub][7])

### c) **Quality (QA) module** (`src/modules/qa/`)

- **Purpose:** Test strategy, contract tests, QA gates.
- **Workflows:** `qa:strategy`, `qa:contracts` (Pact), `qa:validate` (coverage thresholds).
- **Agent:** `agents/test-architect.md`.
- **Refs:** Pact & Schemathesis docs. ([Pact Docs][11])

### d) **Performance module** (`src/modules/perf/`)

- **Purpose:** Perf budgets + load tests.
- **Workflows:** `perf:budgets` → `docs/performance/<feature>/budgets.md`, `perf:load-test`, `perf:validate` (p95 thresholds).
- **Agent:** `agents/perf-engineer.md`.
- **Refs:** Use **Size‑Limit** for bundle budgets; define API p95 budgets in `sre.md`. ([GitHub][21])

### e) **DevOps module** (`src/modules/devops/`)

- **Purpose:** CI/CD pipelines, deploy strategy, IaC notes.
- **Workflows:** `devops:pipeline`, `devops:infra`, `devops:validate`.
- **Artifacts:** `docs/devops/<feature>/pipeline.md`, `infra.md`.

**Cross‑module integration:** `speckit analyze` (optional) or a simple validate script calls each module’s `:validate` to ensure coherence; PlanKit then updates ADR/plan if needed. Use PolicyKit to enforce fail‑closed gates and ComplianceKit to assemble evidence (eval/policy outcomes, traces, contracts, SBOM).

---

## Coverage classification (what runs where)

**Practices & controls**:

- **XP/TDD/refactor** → **Custom** (Cursor rules + unit test targets).
- **Kanban flow/WIP** → **Custom** (board policy docs + automation on PR labels).
- **Trunk‑Based + CD** → **External** (GitHub + Vercel). ([Trunk Based Development][8])
- **SRE (SLI/SLO)** → **Custom** (`sre` module) + **External** (OTel). ([Vercel][10])
- **OWASP ASVS/NIST SSDF/STRIDE** → **Custom** (`sec` module) + **External** (CI scans). ([GitHub][7])
- **12‑Factor** → **Custom** (checklist validation + CI) + **External** (Vercel env). ([12factor][12])
- **Hexagonal** → **Custom** (repo layout + lint rule + Spec templates). ([Alistair Cockburn][20])
- **Monorepo/Turborepo** → **External** (turbo pipelines, remote cache). ([Turborepo][1])

---

## Enforcing architecture & practices with BMAD

- **Twelve‑Factor**: add a **checklist validator** in `validate-gates.js` that ensures `config via env`, `logs as streams`, and `build-release-run` split (CI build artifact vs deploy). Reference 12‑Factor doc; ensure Vercel envs set via dashboard/CLI. ([12factor][12])
- **Monolith‑first in Turborepo**: verify repo layout (`apps/api/src/{core,app,ports,adapters}`) and enforce directional imports across hexagonal boundaries with ESLint (e.g., forbid `core` importing from `adapters`).
- **Hexagonal boundaries**: add a simple ESLint rule set that forbids adapters importing from adapters, or core depending on adapters; allow only `core <- app <- adapters`.
- **Gates**:

  - **S‑1** requires validated SpecKit artifacts (via SpecKit).
  - **P‑1** requires PlanKit/BMAD plan to include AC reflecting ASVS/SSDF & perf budgets, plus AI determinism (pinned model, low variance, golden tests).
  - **S‑2** requires all CI checks (lint, types, **Pact**, **Spectral**, **oasdiff**, **Schemathesis**, **CodeQL**, **Semgrep**, **Gitleaks**, **SBOM**, **Size‑Limit**, preview smoke) to pass. ([GitHub][25])

---

## CI/CD quality gates (diagram + checklist)

```mermaid
flowchart TD
  L[Lint/Format] --> T[Types (TS --strict)]
  T --> U[Unit Tests]
  U --> C1[Contract Tests (Pact)]
  C1 --> OA[OpenAPI Lint (Spectral)]
  OA --> FZ[Schemathesis Fuzz]
  FZ --> SZ[Bundle Budgets (Size-Limit)]
  SZ --> SB[SBOM (Syft/SPDX)]
  SB --> SC[Security Scans (CodeQL/Semgrep/Gitleaks)]
  SC --> OK[All green?]
  OK -->|yes| MERGE[Merge]
  OK -->|no| FIX[Fix PR]
```

- **Required checks** (PR must be ✅):

  - ESLint + Prettier; **TS `--strict`**
  - Unit coverage floor
  - **Pact** provider/consumer ✅; **Spectral** lint of `openapi.yaml` ✅; **oasdiff** non‑breaking ✅; **Schemathesis** no new criticals ✅
  - **CodeQL**, **Semgrep**, **Gitleaks** → no high/critical
  - **SBOM** produced & uploaded artifact
  - **Size‑Limit** budgets respected
  - Preview smoke (Playwright or `scripts/smoke-check.sh`) against Vercel preview
  - Observability present on changed flows (span/log with `trace_id` linked in PR)

> Tooling references: Pact/Schemathesis, Spectral, CodeQL/Semgrep/Gitleaks, Size‑Limit, Syft (SPDX) or CycloneDX. ([Pact Docs][11])

---

## Metrics & improvement (solo-friendly)

- **DORA**: deployment frequency, lead time, change‑fail rate, MTTR (collect via simple PR/Actions logs; optional use “Four Keys” pipeline). ([Dora][26])
- **SRE**: error‑budget burn; p95/availability on OTel traces/metrics. ([Vercel][10])
- Weekly 15‑min retro: review SLO variance; tighten/relax gates if error budget is healthy.

---

## 30/60/90 Adoption plan (high‑level)

- **30 days**: SpecKit + PlanKit in place; QA/security gates (Spectral, Schemathesis, Gitleaks); Vercel previews; Feature flags SDK.
- **60 days**: CodeQL/Semgrep; SBOM flow; OTel basic traces; SLOs for top endpoints.
- **90 days**: Incident process; postmortems; perf budgets; automated promote/rollback guardrails; PolicyKit fail‑closed profiles; ComplianceKit evidence packs.

---

## Worked example — “OAuth login + org billing”

1. `speckit init --feature oauth-billing --out docs/specs/oauth-billing` → creates `spec.md` (auth flows), `risk.md` (STRIDE on OAuth callback/CSRF), `security.md` (ASVS auth/session controls), optional `data-model.md`, `quickstart.md`. ([GitHub][7])
2. `speckit validate --path docs/specs/oauth-billing` → structure/required fields validated.
3. `plankit plan --spec docs/specs/oauth-billing/spec.md --out plan.json` → ADR + BMAD plan/story; define contracts: `/api/auth/callback` schema, `/billing/webhook` Pact.
4. Dev in AI IDE: use `.cursorrules` snippets “spec‑to‑code”, generate adapters & tests; human approves diffs. ([Cursor][23])
6. Open PR → Vercel preview; Playwright smoke (`/login` happy path); Spectral lint; Schemathesis runs against `openapi.yaml`; SBOM & scans pass. ([Vercel][13])
7. Merge → `vercel promote` when flag‑on canary looks good; instant rollback if error budget spikes. ([Vercel][17])

---

## Alignment addenda (AI‑Toolkit v0.2)

### Risk & HITL policy (Harmony default)

| Risk | Required gates | HITL | Flags & rollback |
| --- | --- | --- | --- |
| Trivial | Lint, typecheck | Optional Navigator pass | Not required |
| Low | + Unit/contract; Policy/Eval pass | Navigator pass | Optional flag; rollback note |
| Medium | + Preview smoke; ObservaKit trace link | Navigator pass (time-separated if solo) | Feature flag required; rollback plan |
| High | + Security + license + SBOM; watch window | Navigator pass + security checklist | Feature flag required; rollback rehearsed |

Waivers are exceptional; scope/timebox (≤ 7 days) with Navigator approval (review pass); disallowed for secrets/PII exposure, missing observability/flag/rollback, or active SLO burn.

### Observability & run records (minimal contract)

- Required spans on changed flows and kits: `kit.speckit.specify`, `kit.plankit.plan`, `kit.agentkit.execute`, `kit.toolkit.call.*`, `kit.evalkit.verify`, `kit.policykit.check`, `kit.patchkit.open_pr`.
- Logs include `trace_id` and `span_id`; attributes keep low cardinality (include `run.id`, `kit.name`, `kit.version`, `stage`, `git.sha`, `repo`, `branch`).
- Run records (stored under `runs/**`) include: `runId`, `kit`, `stage`, `risk`, `telemetry.trace_id`, determinism (`prompt_hash`, `idempotencyKey`, optional `cacheKey`), `status`, `summary`. Never serialize secrets/PII; GuardKit redacts at write/log boundaries.
- Resource attributes & log fields MUST follow ObservaKit’s standard: `service.name`, `service.version`, `deployment.environment` as resources; and structured logs with `trace_id`, `span_id`, severity, and summary. Keep attribute cardinality bounded.

### Deterministic operation (short)

1) Pin AI provider/model/version; temperature ≤ 0.3; record prompt hash.  
2) Validate outputs against JSON‑Schema or contracts; add golden tests for critical prompts.  
3) Idempotency keys on mutations; Cache keys for pure expensive ops.  
4) PolicyKit/EvalKit/TestKit gates are fail‑closed; attach outcomes and ObservaKit trace links in PRs.  
5) License/provenance via Dependency Review; avoid new deps unless materially reducing complexity.

### Node vs Edge & Next.js 15 caching (clarified)

- Defaults for `fetch`/GET handlers are `no-store`. Opt‑in to caching (`force-static`, `revalidate`) only with stable cache keys; record keys in run records.  
- Evaluate feature flags server‑side; Edge (short, read‑mostly) for flags/headers; heavy or stateful work (AI/indexing/long I/O) in Node/serverless; schedule follow‑ups with `next/after`.

### PolicyKit rulesets (versioned, fail‑closed)

- Ruleset identity and versioning are explicit: `policy.ruleset = <framework>|<profile>@<version>` (e.g., `ASVS@5.0`, `SSDF@1.1`, or `Harmony-Minimal@2025-11-01`).  
- Default is fail‑closed: any missing evidence or provider error blocks progression with a typed `PolicyViolationError`.  
- Evidence linking: record `policy.checked[]` IDs (e.g., `ASVS-2.1.1`) and `policy.result` in run records and span attributes.  
- PatchKit SHOULD render a ruleset summary in PR bodies and require navigator acknowledgement for deviations.

### HITL states & semantics (operational)

- States: `planned` → `requested` → `approved` | `rejected` | `waived`.  
- Required fields in run records/telemetry:  
  - `hitl.checkpoint` (`pre-implement`, `pre-merge`, `pre-promote`, `post-promote`)  
  - `hitl.approver` (handle/email), `hitl.approvedAt` (ISO8601)  
  - For waivers: `hitl.justification` and PR comment/link  
- Emit span events: `hitl.requested`, `hitl.approved`, `hitl.rejected`, `hitl.waived` on the parent lifecycle span to preserve auditability.

### Kit exit codes & HTTP mapping (standard v0.2)

- Exit codes:  
  - `0` Success; `1` Generic failure; `2` Policy violation; `3` Evaluation/test failure; `4` Guard/redaction violation;  
  - `5` Invalid inputs/schema; `6` Upstream/provider error; `7` Idempotency conflict; `8` Cache integrity error.  
- HTTP mapping for Route/HTTP wrappers:  
  - `0`→200; `1`→500; `2`→403/422; `3`→422; `4`→400; `5`→400; `6`→502; `7`→409; `8`→500.  
- Errors MUST be typed (e.g., `PolicyViolationError`) and logged as structured errors with `error.type`, `error.code`, `trace_id`, `span_id`.

### Kit metadata & contracts registry (harmonized)

- Kits MUST include metadata (`metadata/kit.metadata.json`) conforming to AI‑Toolkit KitMetadata v0.2, declaring `pillars`, `lifecycleStages`, `inputsSchema`, `outputsSchema`, required spans, determinism, safety (HITL), and idempotency.  
- Contracts live under `packages/contracts` with kit JSON‑Schemas at `packages/contracts/schemas/kits/<kit>.{inputs|outputs}.v<MAJOR>.json`.  
- Observe semantic versioning: breaking contract changes bump MAJOR and include migration notes; additive changes bump MINOR.  
- Update `packages/contracts/src/index.ts` (barrel) when schemas change; PatchKit PRs MUST link schema diffs when interfaces are touched.

### Astro (SSG/SSR) integration (guidance)

- Prefer SSG for content‑first surfaces (docs/marketing). For SSR adapters, follow the same caching defaults as Next.js (`no-store` by default; opt‑in with stable cache keys).  
- Evaluate feature flags server‑side. For SSG, inject flag values at build time or fetch via Edge/API—do not rely on `process.env` in the browser.  
- Enforce CSP and core security headers at the platform for SSG; use SSR middleware only when necessary. Never expose secrets client‑side.

### Partial Prerendering (PPR) & Streaming

- Opt pages/layouts into PPR selectively to combine static shells with dynamic data behind `Suspense`.  
- Keep dynamic islands bounded by clear spans; measure TTFB/TTI before/after. Maintain `no-store` defaults unless stability justifies caching with recorded `cacheKey`.

---

# Limits, risks, workarounds

- **BMAD v6 alpha workflow names** may change (active issues indicate ongoing changes). **Workaround:** keep PlanKit as the boundary so calling sites remain stable. ([GitHub][3])
- **Spec semantics** come from GitHub’s Spec Kit. Use SpecKit to orchestrate and validate, rather than re‑implementing GitHub’s Spec Kit.
- **OTel exporter/backend** choice is external; bootstrap via `infra/otel/instrumentation.ts` and wire to your APM later. ([Vercel][10])

---

# Quick-Start Page (tomorrow morning)

- **Cadence & Roles**: 1‑week cycle; switch hats between **Driver** and **Navigator** per PR; async daily in PR thread.
- **Board columns**: **Backlog → Spec (SpecKit) → Plan (PlanKit) → Dev → PR/Preview → Ready to Merge → Released → Analyze** (WIP: 1 per person; PRs ≤ ~200 LOC).
- **Spec → Plan flow**: `speckit init/validate` → `plankit plan`.
- **CI required checks**: lint, types, unit, Pact, Spectral, oasdiff, Schemathesis, SBOM, CodeQL, Semgrep, Gitleaks, Size‑Limit, Playwright smoke; ObservaKit trace present on changed flows.
- **SLOs**: API p95 ≤ 300ms; avail 99.9%; error budget 0.1%/month.
- **Release behind flag**: define with Vercel Flags SDK; enable on preview; then `vercel promote`. ([Vercel][24])
- **Rollback**: **Promote** previous preview or use **instant rollback** in Vercel. ([Vercel][9])
- **Top 10 security/perf checks**: ASVS v5 auth/session, input validation, output encoding, TLS, secrets scan, dep scan & SBOM, OpenAPI lint+diff, contract tests, fuzz, bundle budget. ([GitHub][7])
- **Incident hotline**: page on **error‑budget burn >2%/h**; follow runbook; file **blameless postmortem** same day. ([Google SRE][5])

## Stop‑the‑line triggers (enforced)

- Secret exposure or prohibited data in artifacts/logs → block/rollback; scrub artifacts and rotate credentials as needed.
- License/provenance violations → block until resolved; document in PR.
- Security regressions or critical ASVS/STRIDE failures → block; Navigator/security pass required.
- SLO burn‑rate breach → freeze risky merges/promotions; rollback if needed.
- Missing rollback path/feature flag or missing observability on changed flows → block until provided.
- AI provenance not pinned (provider/model/version/params) when agents were used → block until recorded.

---

## References (selected)

- **BMAD v6 alpha** structure & install; **BMB create-agent** path. ([GitHub][4])
- **Turborepo** caching & monorepo on Vercel. ([Turborepo][1])
- **Vercel** previews/promote/flags/env/OTel. ([Vercel][13])
- **OpenTelemetry** for Next.js/Node. ([Next.js][14])
- **ASVS v5**, **SSDF SP 800‑218**, **STRIDE**. ([GitHub][7])
- **SRE** error budgets & SLOs. ([Google SRE][5])
- **Spectral, Pact, Schemathesis, CodeQL, Semgrep, Gitleaks, SBOM**. ([GitHub][25])
- **12‑Factor**, **Hexagonal architecture**. ([12factor][12])

---

### Appendix — Definitions of Ready/Done (abbrev)

- **DOR (Spec)**: GitHub’s Spec Kit artifacts validated (via SpecKit); ASVS/SSDF/STRIDE mapped; SLOs stated.
- **DOD (Code)**: unit + contracts + Spectral + fuzz + scans + SBOM + bundle budgets + preview smoke all green; flags staged; runbook updated.

---

### Appendix — Minimal monorepo code stubs

**`apps/api/src/ports/AuthPort.ts`**

```ts
export interface AuthPort {
  startOAuth(orgId: string): Promise<{ url: string }>;
  handleCallback(query: Record<string,string>): Promise<{ sessionId: string }>;
}
```

**`apps/api/src/adapters/http/routes/auth.ts`**

```ts
import type { FastifyInstance } from 'fastify';
import type { AuthPort } from '../../ports/AuthPort';

export async function authRoutes(app: FastifyInstance, auth: AuthPort) {
  app.get('/api/auth/start', async (req,res) => res.send(await auth.startOAuth('org-1')));
  app.get('/api/auth/callback', async (req,res) => res.send(await auth.handleCallback(req.query as any)));
}
```

---

If you want, I can package these files as a starter repo in your structure.

[1]: https://turborepo.com/docs/crafting-your-repository/caching?utm_source=chatgpt.com "Caching | Turborepo"
[2]: https://github.com/bmad-code-org/BMAD-METHOD/blob/v6-alpha/src/modules/bmb/workflows/create-agent/README.md "BMAD-METHOD/src/modules/bmb/workflows/create-agent/README.md at v6-alpha · bmad-code-org/BMAD-METHOD · GitHub"
[3]: https://github.com/bmad-code-org/BMAD-METHOD/issues/759?utm_source=chatgpt.com "[v6 Alpha] Solution Architecture workflow doesn't load Phase 1 ... - GitHub"
[4]: https://github.com/bmad-code-org/BMAD-METHOD/tree/v6-alpha "GitHub - bmad-code-org/BMAD-METHOD at v6-alpha"
[5]: https://sre.google/workbook/error-budget-policy/?utm_source=chatgpt.com "Google SRE - Error Budget Policy for Service Reliability"
[6]: https://docs.github.com/en/code-security/code-scanning/introduction-to-code-scanning/about-code-scanning-with-codeql?utm_source=chatgpt.com "About code scanning with CodeQL - GitHub Docs"
[7]: https://raw.githubusercontent.com/OWASP/ASVS/v4.0.3/4.0/OWASP%20Application%20Security%20Verification%20Standard%204.0.3-en.pdf?utm_source=chatgpt.com "Application Security Verification Standard 4.0"
[8]: https://trunkbaseddevelopment.com/?utm_source=chatgpt.com "Trunk Based Development"
[9]: https://vercel.com/docs/deployments/promoting-a-deployment?utm_source=chatgpt.com "Promoting Deployments - vercel.com"
[10]: https://vercel.com/docs/otel?utm_source=chatgpt.com "Quickstart for using the Vercel OpenTelemetry Collector"
[11]: https://docs.pact.io/?utm_source=chatgpt.com "Introduction | Pact Docs"
[12]: https://12factor.net/?utm_source=chatgpt.com "The Twelve-Factor App"
[13]: https://vercel.com/docs/deployments/environments?utm_source=chatgpt.com "Environments - Vercel"
[14]: https://nextjs.org/docs/app/guides/open-telemetry?utm_source=chatgpt.com "Guides: OpenTelemetry | Next.js"
[15]: https://cursor.com/docs/agent/chat/commands?utm_source=chatgpt.com "Commands | Cursor Docs"
[16]: https://oss-review-toolkit.org/ort/docs/getting-started/installation?utm_source=chatgpt.com "Installation - OSS Review Toolkit"
[17]: https://vercel.com/docs/cli/promote?utm_source=chatgpt.com "vercel promote"
[18]: https://vercel.com/guides/how-to-setup-cron-jobs-on-vercel?utm_source=chatgpt.com "How to Setup Cron Jobs on Vercel"
[19]: https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats?utm_source=chatgpt.com "Threats - Microsoft Threat Modeling Tool - Azure"
[20]: https://alistair.cockburn.us/hexagonal-architecture?utm_source=chatgpt.com "hexagonal-architecture - Alistair Cockburn"
[21]: https://github.com/ai/size-limit?utm_source=chatgpt.com "GitHub - ai/size-limit: Calculate the real cost to run your JS app or ..."
[22]: https://turborepo.com/docs/guides/frameworks/nextjs?utm_source=chatgpt.com "Next.js | Turborepo"
[23]: https://cursor.com/docs/context/rules?utm_source=chatgpt.com "Rules - Cursor Docs"
[24]: https://vercel.com/docs/feature-flags?utm_source=chatgpt.com "Feature Flags - Vercel"
[25]: https://github.com/stoplightio/spectral-action?utm_source=chatgpt.com "GitHub - stoplightio/spectral-action: GitHub Action wrapper for ..."
[26]: https://dora.dev/guides/dora-metrics-four-keys/?utm_source=chatgpt.com "DORA | DORA’s software delivery metrics: the four keys"
