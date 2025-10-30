---
title: Lean AI-Accelerated Methodology Implementation Guide
description: Detailed playbook for wiring Harmony’s BMAD-focused methodology, tooling, and governance into a Turborepo + Vercel stack.
---

Below is a **BMAD v6–focused implementation guide** that shows exactly what you can wire into BMAD today, what needs a thin custom module/agent/workflow, and what should stay in CI/Vercel. I also give you a runnable **SDD sidecar** (spec‑driven development loop) that replicates Spec Kit semantics **without installing Spec Kit**, hands off to **BMM** for PRD/Architecture/Stories, and fits a **Turborepo + Vercel** monorepo.

> **Sources** used for concrete behavior, commands, and integration details are cited inline where they matter most (Turborepo cache, Vercel previews/promote & flags, SLO/error budgets, OpenTelemetry for Next.js, OWASP ASVS & NIST SSDF, BMAD v6 alpha module layout & BMB workflow path, etc.). ([Turborepo][1])

---

## 1) Executive Summary

**Decision.** Implement the Spec Kit loop **inside BMAD** as a **separate “SDD” sidecar module** that orchestrates:
`specify → plan → tasks → analyze`, writes artifacts under `docs/specs/<feature>/…`, then **hands off to BMM** to generate **PRD → Architecture → Stories**. Keeping SDD separate isolates churn from the evolving **BMM v6 workflows**, while still using BMAD’s module conventions and the **BMB builder** to standardize agents. (BMB `create-agent` lives at `src/modules/bmb/workflows/create-agent/` in v6‑alpha.) ([GitHub][2])

**Why separate (not merged with BMM)?**

* **API stability & upgrade safety.** BMM v6 is active and evolving; issues like *solution‑architecture workflow changes* indicate ongoing adjustments. SDD as a sidecar preserves your internal templates and gates even if BMM’s workflow names/params change. ([GitHub][3])
* **Spec-first rigor.** The sidecar makes SDD artifacts **first-class** (spec, risks, security, SRE, plan, tasks, analysis), validated by **thin BMAD workflows** and **CLI scripts** before BMM consumes them.

**Integration surface.**

* **BMAD Core + BMM + BMB** supply the foundation (agents, workflows). Project installs BMAD v6 alpha (`npx bmad-method@6.0.0-beta.0 install`, Node 24+ per repo guidance). We keep SDD custom workflows in `src/modules/sdd`. ([GitHub][4])
* **Monorepo & CI/CD:** Turborepo for **pipelines/remote cache**, Vercel for **branch previews & guarded promote to production**, **feature flags** using Vercel Flags SDK + Edge Config (or your provider), and **OpenTelemetry** via `@vercel/otel`. ([Turborepo][1])

**Reliability & Security guardrails baked in.**

* **SRE**: SLIs/SLOs/error budgets & postmortems per Google SRE workbook guidance. The SRE module produces `docs/sre/<feature>/…` and gates merges when error budgets would be exceeded. ([Google SRE][5])
* **DevSecOps**: CI gates include CodeQL, Semgrep, Gitleaks, SBOM (CycloneDX via `cyclonedx-node-npm` or Syft), OpenAPI lint (Spectral), Schemathesis fuzzing for APIs. ([GitHub Docs][6])
* **Framework mappings**: OWASP ASVS (v4.0.3; note that 5.0 has released/RC—template accounts for both), NIST SSDF SP 800‑218, and STRIDE micro‑threat models per feature. ([GitHub][7])

**Expected impact.**

* **Lead time/DF**: Trunk‑based + Vercel previews + Turborepo cache → **smaller PRs**, **faster CI**, **1–n deploys/day**; DORA metrics will improve (deployment frequency, lead time) when gates go green. ([Trunk Based Development][8])
* **Change‑fail rate/MTTR**: Feature flags + preview smoke + canary + instant **promote/rollback** reduce CFR and MTTR. ([Vercel][9])
* **SLO attainment**: OTel traces + SLO alerts + error budgets enforce reliability ceilings (stop‑the‑line when budgets burn). ([Vercel][10])

---

## 2) Overview table — **Native vs Custom vs External**

| Method element / Lifecycle node              | Classification              | What/Where                                                                                                                                        |
| -------------------------------------------- | --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| **BMAD agents/workflows (BMM/BMB)**          | **Native (BMAD v6 alpha)**  | `bmad/bmm` (method workflows), `bmad/bmb` (builder, e.g., `create-agent`) in repo. Use CLI `bmad-method`. ([GitHub][4])                           |
| **SDD sidecar** (Spec Kit loop replica)      | **Custom BMAD**             | `src/modules/sdd/…` with workflows `specify/plan/tasks/analyze` that write to `docs/specs/<feature>/…` and call BMM.                              |
| **SRE module** (SLOs, runbooks, postmortems) | **Custom BMAD**             | `src/modules/sre/…` with workflows `sre:define/validate/postmortem` → `docs/sre/<feature>/…`. References Google SRE. ([Google SRE][5])            |
| **Security module** (ASVS/SSDF/STRIDE)       | **Custom BMAD**             | `src/modules/sec/…` with `sec:threat-model/asvs-map/validate` → `docs/security/<feature>/…`. ASVS v4.0.3 + v5.0 note, SSDF 800‑218. ([GitHub][7]) |
| **QA module** (test strategy/contracts)      | **Custom BMAD**             | `src/modules/qa/…` with `qa:strategy/contracts/validate` → `docs/tests/<feature>/…`. Pact, Schemathesis, Playwright. ([Pact Docs][11])            |
| **Perf module** (budgets/load test)          | **Custom BMAD**             | `src/modules/perf/…` with `perf:budgets/load-test/validate` → `docs/performance/<feature>/…`.                                                     |
| **DevOps module** (CI/CD/infra)              | **Custom BMAD**             | `src/modules/devops/…` with `devops:pipeline/infra/validate` → `docs/devops/<feature>/…`.                                                         |
| **Twelve‑Factor / Hexagonal enforcement**    | **Custom BMAD + External**  | Encoded as **check files** + CI checks; structure enforced in repo layout and simple validations. 12‑Factor reference. ([12factor][12])           |
| **Monorepo + Turborepo**                     | **External (tooling)**      | `turbo.json` pipelines, remote cache with Vercel; CI uses cache. ([Turborepo][1])                                                                 |
| **Vercel previews & promote**                | **External**                | PR preview per branch; `vercel promote` for guarded prod. Feature flags via Vercel Flags SDK. ([Vercel][13])                                      |
| **OpenTelemetry**                            | **External (+ small code)** | Next.js OTel guide and `@vercel/otel` to enable traces/metrics. ([Next.js][14])                                                                   |
| **Security scans, SBOM**                     | **External (CI)**           | CodeQL, Semgrep, Gitleaks, CycloneDX/Syft. ([GitHub Docs][6])                                                                                     |

---

## 3) Lifecycle matrix (A→J): responsibilities, artifacts, commands, gates

```mermaid
flowchart LR
  A[Spec (SDD) + ADR] --> B[Shape & Scope Cuts]
  B --> C[BMAD Story (context packets + agent plan + AC)]
  C --> D[Dev in Cursor (human checkpoints)]
  D --> E[PR -> Vercel Preview (feature-flagged)]
  E --> F[CI Gates: lint/type/test/scan/contract/SBOM]
  F -->|all green| G[Merge to Trunk]
  G --> H[Auto Deploy to Preview/Prod (guarded)]
  H --> I[Operate: SLOs, alerts, OTel, logs]
  I --> J[Learn: Postmortem & ADR updates]
  J -->|feedback| A
```

**Gates legend**

* **S‑1** Spec coherence, **P‑1** BMM alignment, **S‑2** Coverage (security/perf/tests), **I‑1** Plan saved, **I‑2** Post‑build drift.

> *Where you see `bmad` below, use `npx bmad-method@6.0.0-beta.0 …` (Node 24+) as recommended in v6 alpha docs.* ([GitHub][4])

### A — Spec (SDD) + ADR intake

* **BMAD mgmt**: **Custom BMAD** (SDD sidecar).
* **Modules/Workflows**: `src/modules/sdd/workflows/specify.yaml`
* **Inputs → Outputs**:

  * In: intent/idea (issue), constraints.
  * Out: `docs/specs/<feature>/spec.md`, `risk.md` (STRIDE), `security.md` (ASVS/SSDF mapping), `sre.md` (SLIs/SLOs), `plan.md`, `adr.md`. (ASVS/SSDF per OWASP/NIST.) ([GitHub][7])
* **Commands & hooks**: `npm run sdd:specify -- --feature <name>` → wraps `bmad run sdd:specify`.
* **Human checkpoint**: Driver & Navigator confirm problem, scope, non‑functionals.
* **Integrations**: None yet.
* **Gate**: **S‑1** passes when all SDD templates exist & minimal completeness checklist passes.

### B — Shape & Scope cuts

* **BMAD mgmt**: **Custom BMAD** (`sdd:plan`), optional BMM shape workflow if you enable it later.
* **Workflows**: `src/modules/sdd/workflows/plan.yaml`.
* **Outputs**: `docs/specs/<feature>/plan.md` (hexagonal plan; ports/adapters), updated `security.md` (ASVS), `sre.md` budgets.
* **Command**: `npm run sdd:plan -- --feature <name>`.
* **Human**: Approve scope cuts.
* **Gate**: **I‑1** (plan saved & signed).

### C — BMAD Story (context packets + agent plan + AC)

* **BMAD mgmt**: **Native + Custom** — SDD hands off to **BMM**.
* **Workflows**: `bmm:prd`, `bmm:architecture`, `bmm:stories` (names abstracted; wire via wrapper scripts that read SDD files).
* **Outputs**: `docs/implementation/<feature>.md`, `docs/alignment/<feature>.md`, `docs/stories/<feature>/story.md`.
* **Command**: `npm run bmm:stories -- --feature <name>` (wrapper calls BMAD run). (BMB `create-agent` available if you need a new agent persona.) ([GitHub][2])
* **Human**: Verify ACs & security/perf AC embedded.
* **Gate**: **P‑1** (BMM alignment: PRD ↔ spec/plan tie-out).

### D — Dev in Cursor (guided, HITL)

* **BMAD mgmt**: **Custom BMAD** *policy files* + **Cursor rules**.
* **Artifacts**: `.cursorrules` seeds prompts with SDD + gates; Cursor **Commands** for “spec‑to‑code”, “threat‑model”, “generate tests”. ([Cursor][15])
* **Command**: Cursor custom command triggers SDD/BMM scripts; or run `npm run sdd:*` directly.
* **Human**: Approve agent plans & diffs; license‑safe suggestion check (ORT or license‑checker). ([OSS Review Toolkit][16])
* **Gate**: **S‑2** pre‑merge checks stubbed locally (lint/type/units/contracts).

### E — PR → Vercel Preview (feature‑flagged)

* **BMAD mgmt**: **External** (GitHub + Vercel).
* **Artifacts**: PR template comment prints preview URL; feature flags via **Vercel Flags SDK** (or provider). ([Vercel][13])
* **Command**: Open PR; Vercel auto‑creates preview per branch/PR. ([Vercel][13])
* **Gate**: **S‑2** CI gates must pass.

### F — CI Gates

* **BMAD mgmt**: **External** (GitHub Actions).
* **Checks**: ESLint/TS strict; unit + **contract tests** (Pact), **OpenAPI lint** (Spectral), **Schemathesis** API fuzz, **CodeQL/Semgrep/Gitleaks**, **SBOM** (CycloneDX/Syft), **bundle budgets** (Size‑Limit). ([Pact Docs][11])
* **Gate**: **S‑2** passes when required checks are ✅.

### G — Merge to Trunk

* **BMAD mgmt**: **External** (GitHub, Trunk‑Based). Short‑lived branches only. ([Trunk Based Development][8])
* **Gate**: Protected branch requires all checks + 1 review.

### H — Deploy (guarded)

* **BMAD mgmt**: **External** (Vercel).
* **Artifacts**: Promote preview → production (`vercel promote`); instant rollback available. ([Vercel][17])
* **Gate**: “Flagged on” via Vercel flags; canary checklist.

### I — Operate (SLOs, alerts, OTel)

* **BMAD mgmt**: **Custom BMAD (sre)** + **External** (observability).
* **Artifacts**: `docs/sre/<feature>/slo.md`, `runbook.md`, OTel traces via `@vercel/otel` + Next.js instrumentation guide. ([Vercel][10])
* **Gate**: Error budget burn check; auto‑open incident.

### J — Learn (postmortem, ADR)

* **BMAD mgmt**: **Custom BMAD (sre)** + **SDD analyze**.
* **Artifacts**: `docs/sre/<feature>/postmortem.md`, updated `adr.md`, `docs/specs/<feature>/analysis.md`.
* **Gate**: **I‑2** (post‑build drift documented & back‑propagated).

---

## 4) File tree (new/changed files)

```
/                      # monorepo root (Turborepo)
/apps/api              # monolith-first TS service (Hexagonal)
/apps/api/src/core     # domain
/apps/api/src/app      # use-cases/services
/apps/api/src/ports    # interfaces (ports)
/apps/api/src/adapters # http/db/queue (adapters)
/docs/specs/<feature>/ # SDD artifacts (sidecar writes here)
/docs/implementation/<feature>.md
/docs/alignment/<feature>.md
/docs/sre/<feature>/{slo.md,runbook.md,postmortem-template.md}
/docs/security/<feature>/{asvs.md,stride.md,ssdf.md}
/docs/tests/<feature>/{strategy.md,contracts.md,e2e.md}
/docs/performance/<feature>/{budgets.md,load-test.md}
/docs/devops/<feature>/{pipeline.md,infra.md}
/src/modules/sdd/{README.md,workflows/*.yaml,agents/*.md,templates/*}
/src/modules/{sre,sec,qa,perf,devops}/(README.md,workflows/*.yaml,agents/*.md)
/scripts/{sdd.ts,bmm-handlers.ts,validate-gates.ts}
/.cursorrules
turbo.json
tsconfig.base.json
pnpm-workspace.yaml
apps/api/vercel.json
.github/workflows/ci.yml
.github/workflows/security.yml
.spectral.yaml
```

---

## 5) Concrete snippets (minimal but runnable)

### 5.1 Turborepo config (`turbo.json`)

```json
{
  "$schema": "https://turbo.build/schema.json",
  "pipeline": {
    "lint": { "outputs": [] },
    "typecheck": { "outputs": [] },
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**"]
    },
    "test": { "outputs": ["coverage/**"] },
    "check:contracts": { "outputs": [] },
    "check:openapi": { "outputs": [] },
    "check:sbom": { "outputs": ["sbom/**"] },
    "check:bundle": { "outputs": [] }
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

### 5.3 Next.js / Node **OpenTelemetry** (if you add a web app) – `apps/api/src/instrumentation.ts`

```ts
import { registerOTel } from "@vercel/otel";
export function register() {
  registerOTel({ serviceName: "api", instrumentationConfig: {} });
}
```

> `@vercel/otel` provides a simplified setup; Next.js docs cover OTel instrumentation. ([Vercel][10])

### 5.4 SDD sidecar — **module manifests**

`src/modules/sdd/README.md` (excerpt)

```md
# SDD (Spec-Driven Development) Sidecar
Workflows: `specify` → `plan` → `tasks` → `analyze`
Writes to: `docs/specs/<feature>/…`
Hand-off: Calls BMM to generate PRD/Architecture/Stories
```

`src/modules/sdd/workflows/specify.yaml`

```yaml
name: sdd:specify
inputs:
  feature: string
steps:
  - run: node ./scripts/sdd.js specify --feature ${{ inputs.feature }}
outputs:
  - docs/specs/${{ inputs.feature }}/spec.md
  - docs/specs/${{ inputs.feature }}/risk.md
  - docs/specs/${{ inputs.feature }}/security.md
  - docs/specs/${{ inputs.feature }}/sre.md
  - docs/specs/${{ inputs.feature }}/plan.md
  - docs/specs/${{ inputs.feature }}/adr.md
gate: S-1
```

`src/modules/sdd/workflows/plan.yaml`

```yaml
name: sdd:plan
inputs:
  feature: string
steps:
  - run: node ./scripts/sdd.js plan --feature ${{ inputs.feature }}
outputs:
  - docs/specs/${{ inputs.feature }}/plan.md
  - docs/specs/${{ inputs.feature }}/security.md
  - docs/specs/${{ inputs.feature }}/sre.md
gate: I-1
```

`src/modules/sdd/workflows/tasks.yaml`

```yaml
name: sdd:tasks
inputs:
  feature: string
steps:
  - run: node ./scripts/sdd.js tasks --feature ${{ inputs.feature }}
outputs:
  - docs/specs/${{ inputs.feature }}/tasks.md
  - docs/tests/${{ inputs.feature }}/strategy.md
  - docs/tests/${{ inputs.feature }}/contracts.md
gate: S-2
```

`src/modules/sdd/workflows/analyze.yaml`

```yaml
name: sdd:analyze
inputs:
  feature: string
steps:
  - run: node ./scripts/sdd.js analyze --feature ${{ inputs.feature }}
  - run: node ./scripts/validate-gates.js --feature ${{ inputs.feature }}
outputs:
  - docs/specs/${{ inputs.feature }}/analysis.md
gate: I-2
```

**Agent instructions** (BMB-compatible), e.g., `src/modules/sdd/agents/spec-writer.md`

```md
# Role: Spec Writer
Goal: From a short problem statement & constraints, produce {spec.md, risk.md (STRIDE), security.md (ASVS/SSDF), sre.md, plan.md, adr.md}
Constraints: Follow Hexagonal boundaries; 12-Factor; Monolith-first; OWASP ASVS; NIST SSDF; STRIDE; SLO templates.
```

> BMB `create-agent` workflow path in v6‑alpha repo confirms agent scaffolding pattern. ([GitHub][2])

### 5.5 SDD templates (under `docs/specs/<feature>/`)

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
        run: pnpm turbo run check:contracts
      - name: OpenAPI lint (Spectral)
        run: npx spectral lint ./apps/api/openapi.yaml
      - name: API fuzz (Schemathesis)
        run: pipx run schemathesis run ./apps/api/openapi.yaml --checks all --hypothesis-derandomize
      - name: Bundle budgets
        run: npx size-limit
      - name: Generate SBOM (CycloneDX)
        run: npx @cyclonedx/cyclonedx-npm --output-file sbom/bom.json
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

```
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

**Day‑0 bootstrap (empty repo)**

```bash
# 1) Init monorepo
pnpm dlx create-turbo@latest my-saas && cd my-saas
# 2) Node 24.x recommended for BMAD v6 alpha
node -v  # ensure >=24
# 3) Install BMAD v6 alpha core
npx bmad-method@6.0.0-beta.0 install
# 4) Add SDD sidecar & modules (copy /src/modules/*, /scripts/*, templates)
git add .
# 5) First SDD run
npm run sdd:specify -- --feature oauth-billing
npm run sdd:plan -- --feature oauth-billing
npm run sdd:tasks -- --feature oauth-billing
# 6) Generate PRD/Architecture/Stories with BMM via wrappers
npm run bmm:stories -- --feature oauth-billing
# 7) Push branch -> PR -> Vercel Preview
git checkout -b feat/oauth-billing && git commit -am "feat: init oauth billing" && git push -u origin HEAD
# 8) CI gates -> merge -> guarded promote
# in Vercel dashboard or CLI:
vercel promote  # promote preview to production
```

> BMAD v6 alpha repo shows install via `npx bmad-method …`; PR previews & promote are built‑in to Vercel. ([GitHub][4])

**Useful npm scripts (add to root `package.json`):**

```json
{
  "scripts": {
    "sdd:specify": "node ./scripts/sdd.js specify",
    "sdd:plan": "node ./scripts/sdd.js plan",
    "sdd:tasks": "node ./scripts/sdd.js tasks",
    "sdd:analyze": "node ./scripts/sdd.js analyze",
    "bmm:stories": "node ./scripts/bmm-handlers.js stories",
    "check:openapi": "spectral lint ./apps/api/openapi.yaml",
    "check:contracts": "pnpm --filter @api test:contracts",
    "check:sbom": "cyclonedx-npm --output-file sbom/bom.json",
    "check:bundle": "size-limit"
  }
}
```

---

## 7) Operating Rules (one page)

* **When to run phases**

  * **specify/plan**: anytime a new feature/epic is started; re‑run on scope change.
  * **tasks**: before coding; outputs AC + contracts + test strategy.
  * **analyze**: after release; record drift, update ADR.
* **Exit criteria**

  * **S‑1**: `spec.md`, `risk.md`, `security.md`, `sre.md`, `plan.md`, `adr.md` exist; completeness checklist passes.
  * **P‑1**: BMM PRD/Architecture/Stories align with SDD; AC includes security/perf.
  * **S‑2**: CI **all green** (lint/type/unit/contract/openapi/schemathesis/size/CodeQL/Semgrep/Gitleaks/SBOM).
  * **I‑1**: Tasks split to ports/adapters; DOR/DOD present.
  * **I‑2**: Postmortem & ADR updated when incidents occur.
* **Feature flags**: all user‑visible work behind flags; enable canary checks on preview first. ([Vercel][24])
* **SLOs & alerts**: maintain SLO files per feature; if **error budget** exhausted, freeze flag rollout until remediation. ([Google SRE][5])

---

# SDD sidecar (Spec Kit loop replicated inside BMAD)

### Module & structure

```
src/modules/sdd/
  README.md
  workflows/
    specify.yaml
    plan.yaml
    tasks.yaml
    analyze.yaml
  agents/
    spec-writer.md
    planner.md
    task-splitter.md
    analyst.md
  templates/
    spec.md
    risk.md
    security.md
    sre.md
    plan.md
    tasks.md
    analysis.md
scripts/
  sdd.js
  bmm-handlers.js
  validate-gates.js
```

`src/modules/sdd/README.md` explains inputs/outputs, gates, and **handoff to BMM**.

### Workflows

* **`sdd:specify`** → writes: `spec.md`, `risk.md`, `security.md`, `sre.md`, `plan.md`, `adr.md` → **Gate S‑1**.
* **`sdd:plan`** → updates `plan.md`, `security.md`, `sre.md` (budgets & SLIs) → **Gate I‑1**.
* **`sdd:tasks`** → `tasks.md`, test strategy/contracts → **Gate S‑2 (local)**.
* **`sdd:analyze`** → `analysis.md`, post‑build drift → **Gate I‑2**.

### Handoff to **BMM**

`bmm-handlers.js` reads `docs/specs/<feature>/*` and invokes BMM workflows (via `bmad-method run …`) to produce:

* `docs/implementation/<feature>.md` (PRD)
* `docs/alignment/<feature>.md` (architecture tie-outs)
* `docs/stories/<feature>/story.md` (context packets, agent plan, AC)

> BMM and BMB layout is present in v6‑alpha branch; use wrapper funcs pending concrete workflow names stabilizing. ([GitHub][4])

### Scripts & commands

`/scripts/sdd.js` (excerpt)

```js
#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

const feature = process.argv.at(-1).replace('--feature','').trim() || process.env.FEATURE;
const phase = process.argv[2]; // specify|plan|tasks|analyze
const base = `docs/specs/${feature}`;
fs.mkdirSync(base, { recursive: true });

const TPL = (name)=>fs.readFileSync(`src/modules/sdd/templates/${name}`,'utf8');

if (phase === 'specify') {
  const files = ['spec.md','risk.md','security.md','sre.md','plan.md','tasks.md'];
  for (const f of files) {
    const p = path.join(base, f);
    if (!fs.existsSync(p)) fs.writeFileSync(p, TPL(f));
  }
  const adr = path.join(base, 'adr.md');
  if (!fs.existsSync(adr)) fs.writeFileSync(adr, '# ADR: Initial decision\n');
  process.exit(0);
}

if (phase === 'plan') {
  // mutate plan.md with scope cuts markers if needed...
  process.exit(0);
}

if (phase === 'tasks') {
  // ensure tasks.md exists and has DOR/DOD stubs
  process.exit(0);
}

if (phase === 'analyze') {
  const p = path.join(base, 'analysis.md');
  if (!fs.existsSync(p)) fs.writeFileSync(p, '# Analysis\nOutcomes, drift, lessons.');
  process.exit(0);
}
```

`/scripts/bmm-handlers.js` (excerpt)

```js
#!/usr/bin/env node
import { spawnSync } from 'node:child_process';
const feature = process.argv.at(-1).replace('--feature','').trim() || process.env.FEATURE;
const story = process.argv[2]; // "stories"
spawnSync('npx', ['bmad-method@6.0.0-beta.0', 'run', 'bmm:stories', '--feature', feature], { stdio:'inherit' });
```

`/scripts/validate-gates.js` (excerpt)

```js
#!/usr/bin/env node
import fs from 'fs';
const feature = process.argv.at(-1).replace('--feature','').trim() || process.env.FEATURE;
const base = `docs/specs/${feature}`;
const must = ['spec.md','risk.md','security.md','sre.md','plan.md','tasks.md','analysis.md'];
for (const f of must) { if (!fs.existsSync(`${base}/${f}`)) { console.error('Missing', f); process.exit(1); } }
console.log('SDD artifacts present. Gates S-1/I-1/S-2/I-2 satisfied preliminarily.');
```

### Wiring to BMM & BMB

* **BMB agent(s):** If you need a new persona (e.g., “Security Architect”), scaffold via `bmb/workflows/create-agent`. ([GitHub][2])
* **BMM workflows:** wrapper script calls `bmm:prd`, `bmm:architecture`, `bmm:stories` (names are placeholders, wrap them in your repo so you can update once when BMM renames; the wrapper preserves your SDD API).

---

## Custom sidecar modules (other methodology areas)

### a) **SRE module** (`src/modules/sre/`)

* **Purpose:** Define SLIs/SLOs, error budgets, runbooks, postmortems.
* **Workflows:** `sre:define` (create `docs/sre/<feature>/slo.md`, `runbook.md`), `sre:validate` (assert SLO syntax), `sre:postmortem` (create `postmortem.md`).
* **Agent:** `agents/sre-engineer.md`.
* **Gate ownership:** `sre:validate` contributes to **S‑1** (SLO presence) and **I‑2** (postmortems).
* **Refs:** Google SRE policies & Art of SLOs handbook. ([Google SRE][5])

### b) **Security module** (`src/modules/sec/`)

* **Purpose:** STRIDE + ASVS + SSDF mapping per feature.
* **Workflows:** `sec:threat-model` → `docs/security/<feature>/stride.md`, `sec:asvs-map` → `asvs.md`, `sec:validate` (ASVS level + SSDF evidence present).
* **Agent:** `agents/security-engineer.md`.
* **Refs:** ASVS v4.0.3, 5.0 updates, SSDF SP 800‑218. ([GitHub][7])

### c) **Quality (QA) module** (`src/modules/qa/`)

* **Purpose:** Test strategy, contract tests, QA gates.
* **Workflows:** `qa:strategy`, `qa:contracts` (Pact), `qa:validate` (coverage thresholds).
* **Agent:** `agents/test-architect.md`.
* **Refs:** Pact & Schemathesis docs. ([Pact Docs][11])

### d) **Performance module** (`src/modules/perf/`)

* **Purpose:** Perf budgets + load tests.
* **Workflows:** `perf:budgets` → `docs/performance/<feature>/budgets.md`, `perf:load-test`, `perf:validate` (p95 thresholds).
* **Agent:** `agents/perf-engineer.md`.
* **Refs:** Use **Size‑Limit** for bundle budgets; define API p95 budgets in `sre.md`. ([GitHub][21])

### e) **DevOps module** (`src/modules/devops/`)

* **Purpose:** CI/CD pipelines, deploy strategy, IaC notes.
* **Workflows:** `devops:pipeline`, `devops:infra`, `devops:validate`.
* **Artifacts:** `docs/devops/<feature>/pipeline.md`, `infra.md`.

**Cross‑module integration:** `sdd:analyze` calls each module’s `:validate` to ensure coherence, then hands off to **BMM** for final story generation.

---

## Coverage classification (what runs where)

**Practices & controls**

* **XP/TDD/refactor** → **Custom** (Cursor rules + unit test targets).
* **Kanban flow/WIP** → **Custom** (board policy docs + automation on PR labels).
* **Trunk‑Based + CD** → **External** (GitHub + Vercel). ([Trunk Based Development][8])
* **SRE (SLI/SLO)** → **Custom** (`sre` module) + **External** (OTel). ([Vercel][10])
* **OWASP ASVS/NIST SSDF/STRIDE** → **Custom** (`sec` module) + **External** (CI scans). ([GitHub][7])
* **12‑Factor** → **Custom** (checklist validation + CI) + **External** (Vercel env). ([12factor][12])
* **Hexagonal** → **Custom** (repo layout + lint rule + SDD templates). ([Alistair Cockburn][20])
* **Monorepo/Turborepo** → **External** (turbo pipelines, remote cache). ([Turborepo][1])

---

## Enforcing architecture & practices with BMAD

* **Twelve‑Factor**: add a **checklist validator** in `validate-gates.js` that ensures `config via env`, `logs as streams`, and `build-release-run` split (CI build artifact vs deploy). Reference 12‑Factor doc; ensure Vercel envs set via dashboard/CLI. ([12factor][12])
* **Monolith‑first in Turborepo**: verify repo layout (`apps/api/src/{core,app,ports,adapters}`) and prevent cross‑layer imports with ESLint rules.
* **Hexagonal boundaries**: add a simple ESLint rule set that forbids adapters importing from adapters, or core depending on adapters; allow only `core <- app <- adapters`.
* **Gates**:

  * **S‑1** requires existence of SDD files.
  * **P‑1** requires BMM story to include AC reflecting ASVS/SSDF & perf budgets.
  * **S‑2** requires all CI checks (lint, types, **Pact**, **Spectral**, **Schemathesis**, **CodeQL**, **Semgrep**, **Gitleaks**, **SBOM**, **Size‑Limit**) to pass. ([GitHub][25])

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
  SZ --> SB[SBOM (CycloneDX/Syft)]
  SB --> SC[Security Scans (CodeQL/Semgrep/Gitleaks)]
  SC --> OK[All green?]
  OK -->|yes| MERGE[Merge]
  OK -->|no| FIX[Fix PR]
```

* **Required checks** (PR must be ✅):

  * ESLint + Prettier; **TS `--strict`**
  * Unit coverage floor
  * **Pact** provider/consumer ✅; **Spectral** lint of `openapi.yaml` ✅; **Schemathesis** no new criticals ✅
  * **CodeQL**, **Semgrep**, **Gitleaks** → no high/critical
  * **SBOM** produced & uploaded artifact
  * **Size‑Limit** budgets respected
  * Preview smoke (Playwright) against Vercel preview

> Tooling references: Pact/Schemathesis, Spectral, CodeQL/Semgrep/Gitleaks, Size‑Limit, CycloneDX. ([Pact Docs][11])

---

## Metrics & improvement (2‑dev friendly)

* **DORA**: deployment frequency, lead time, change‑fail rate, MTTR (collect via simple PR/Actions logs; optional use “Four Keys” pipeline). ([Dora][26])
* **SRE**: error‑budget burn; p95/availability on OTel traces/metrics. ([Vercel][10])
* Weekly 15‑min retro: review SLO variance; tighten/relax gates if error budget is healthy.

---

## 30/60/90 Adoption plan (high‑level)

* **30 days**: SDD sidecar + QA/security gates (Spectral, Schemathesis, Gitleaks); Vercel previews; Feature flags SDK.
* **60 days**: CodeQL/Semgrep; SBOM flow; OTel basic traces; SLOs for top endpoints.
* **90 days**: Incident process; postmortems; perf budgets; automated promote/rollback guardrails.

---

## Worked example — “OAuth login + org billing”

1. `npm run sdd:specify -- --feature oauth-billing` → creates `spec.md` (auth flows), `risk.md` (STRIDE on OAuth callback/CSRF), `security.md` (ASVS auth/session controls), `sre.md` (p95 login under 300ms), `plan.md` (ports: AuthPort, BillingPort). ([GitHub][7])
2. `npm run sdd:plan -- --feature oauth-billing` → scope cuts (passwordless later).
3. `npm run sdd:tasks -- --feature oauth-billing` → defines contracts: `/api/auth/callback` schema, `/billing/webhook` Pact.
4. `npm run bmm:stories -- --feature oauth-billing` → produces PRD + stories with AC (flag `auth.oauth`).
5. Dev in Cursor: use `.cursorrules` snippets “spec‑to‑code”, generate adapters & tests; human approves diffs. ([Cursor][23])
6. Open PR → Vercel preview; Playwright smoke (`/login` happy path); Spectral lint; Schemathesis runs against `openapi.yaml`; SBOM & scans pass. ([Vercel][13])
7. Merge → `vercel promote` when flag‑on canary looks good; instant rollback if error budget spikes. ([Vercel][17])

---

# Limits, risks, workarounds

* **BMAD v6 alpha workflow names** may change (active issues indicate ongoing changes). **Workaround:** keep thin wrapper scripts (`bmm-handlers.js`) so calling sites remain stable. ([GitHub][3])
* **Spec Kit** not installed by decision/constraint — **SDD** replicates semantics with templates and BMAD agents.
* **OTel exporter/backend** choice is external; use `@vercel/otel` starter then wire to your APM later. ([Vercel][10])

---

# Quick-Start Page (tomorrow morning)

* **Cadence & Roles**: 1‑week cycle; **Driver** / **Navigator** rotate weekly; async daily in PR thread.
* **Board columns**: **Backlog → SDD:Specify → Plan → Tasks → Dev → PR/Preview → Ready to Merge → Released → Analyze** (WIP: 1 per person; PRs ≤ ~200 LOC).
* **Spec → BMM flow**: `npm run sdd:specify/plan/tasks` → `npm run bmm:stories`.
* **CI required checks**: lint, types, unit, Pact, Spectral, Schemathesis, SBOM, CodeQL, Semgrep, Gitleaks, Size‑Limit, Playwright smoke.
* **SLOs**: API p95 ≤ 300ms; avail 99.9%; error budget 0.1%/month.
* **Release behind flag**: define with Vercel Flags SDK; enable on preview; then `vercel promote`. ([Vercel][24])
* **Rollback**: **Promote** previous preview or use **instant rollback** in Vercel. ([Vercel][9])
* **Top 10 security/perf checks**: ASVS auth/session, input validation, output encoding, TLS, secrets scan, dep scan & SBOM, OpenAPI lint, contract tests, fuzz, bundle budget. ([GitHub][7])
* **Incident hotline**: page on **error‑budget burn >2%/h**; follow runbook; file **blameless postmortem** same day. ([Google SRE][5])

---

## References (selected)

* **BMAD v6 alpha** structure & install; **BMB create-agent** path. ([GitHub][4])
* **Turborepo** caching & monorepo on Vercel. ([Turborepo][1])
* **Vercel** previews/promote/flags/env/OTel. ([Vercel][13])
* **OpenTelemetry** for Next.js/Node. ([Next.js][14])
* **ASVS v4.0.3/v5**, **SSDF SP 800‑218**, **STRIDE**. ([GitHub][7])
* **SRE** error budgets & SLOs. ([Google SRE][5])
* **Spectral, Pact, Schemathesis, CodeQL, Semgrep, Gitleaks, SBOM**. ([GitHub][25])
* **12‑Factor**, **Hexagonal architecture**. ([12factor][12])

---

### Appendix — Definitions of Ready/Done (abbrev)

* **DOR (Spec)**: all SDD files exist; ASVS/SSDF/STRIDE mapped; SLOs stated.
* **DOD (Code)**: unit + contracts + Spectral + fuzz + scans + SBOM + bundle budgets + preview smoke all green; flags staged; runbook updated.

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
