---
title: Lean AI-Accelerated Methodology Overview
description: Summary of the Harmony methodology combining BMAD, Cursor, Turborepo, Vercel, and compliance guardrails for fast delivery.
---

# Harmony Methodology

Harmony is a lean, **opinionated**, AI-accelerated methodology you can adopt tomorrow with two developers, optimized for **speed and quality with safety** on your stated stack and hosting. It integrates **Spec‑First (via SpecKit) +  Agentic agile (BMAD) + AI-driven IDE (Cursor) + Monorepo Workflow (Turborepo) + Deployment Platform (Vercel)** end‑to‑end, while baking in **SRE, DevSecOps, OWASP ASVS, NIST SSDF, STRIDE, 12‑Factor, Monolith‑First, Hexagonal**.

---

## Harmony’s Unifying Objective

Harmony unifies speed, safety, and simplicity so a tiny team can ship high‑quality software quickly, safely, and predictably. Every framework and tool listed above reinforces one of Harmony’s three pillars and closes the loop from secure specification → agentic implementation → observable operations → postmortem learning.

### The Three Pillars

1. **Speed with Safety** — Fast flow (trunk-based development, small PRs), automated quality/security gates, and frequent integration deliver quick results without sacrificing reliability.
2. **Simplicity over Complexity** — Monolith-first and 12-Factor patterns keep architecture lean, Kanban and Shape Up focus work and limit scope, and spec-driven changes minimize dependencies and overhead.
3. **Quality through Determinism** — Rigorous, measurable gates (OWASP ASVS, NIST SSDF, STRIDE threat modeling, SLOs/DORA metrics) plus contract and property-based tests ensure every change is observable, testable, and reversible.

Together these pillars create a self‑reinforcing system that makes changes small, deterministic, testable, and reversible.

---

## Where the AI‑Toolkit Fits

The AI‑Toolkit provides the kit‑level building blocks that implement Harmony’s gates and flows. For a concise mapping from Harmony’s principles to specific kits, see “Harmony Alignment” in docs/handbook/ai-toolkit/README.md#harmony-alignment-lean-ai-accelerated-methodology. In practice, use FlagKit for feature gating and progressive delivery (Vercel Flags via Edge Config), ObservaKit for telemetry, EvalKit/PolicyKit/GuardKit for gates, and PatchKit for PRs.

### Stage‑to‑Kit Map (operational)

- Spec → Plan → Implement → Verify → Ship → Learn
  - Spec/Shape: SpecKit, PlanKit
  - Implement (agentic): AgentKit, DevKit, CodeModKit (as needed)
  - Verify/Govern: EvalKit (structure/hallucination), PolicyKit (ASVS/SSDF policy), GuardKit (redaction), TestKit (unit/contract/e2e), ComplianceKit (evidence)
  - Ship: PatchKit (PRs), Vercel Previews (promotion), ReleaseKit (changelog)
  - Observe/Learn: ObservaKit (OTel traces + logs), BenchKit (perf), Dockit (docs/ADR), ScheduleKit (jobs)

### Deterministic Agent Loops & Provenance (AI‑Toolkit alignment)

- Standard agent loop: Plan → Diff → Explain → Test (no direct apply). Each step produces an artifact (plan, proposed edits, risk/explain notes, tests) that is reviewable.
- Pin and record AI configuration whenever agents are used for code or content:
  - Provider, model and version; temperature/top_p, max_tokens; seed (if supported) and region.
  - Record the system prompt and inputs (minus secrets) and persist via ObservaKit traces.
  - Attach the ObservaKit trace URL (and EvalKit run ID when applicable) to the PR description.
- Require reproducibility:
  - Add or update AI “golden tests” guarded by JSON‑Schema via EvalKit/TestKit; fail on schema or material output drift.
  - Prefer low‑variance settings (temperature ≤ 0.3) for deterministic outputs; justify higher variance in PR.
- License and provenance:
  - Run GitHub Dependency Review and include a license/provenance note in the PR.
  - Avoid adding new dependencies unless they materially reduce complexity; prefer permissive licenses (MIT/BSD/Apache).

---

## Harmony's Components

Here’s an explanation of each framework, method, and tool in the **Harmony Methodology** — and *why* it aligns with the **Harmony Methodology** for Lean AI-Accelerated development. Together, these ensure that every change — human or AI-generated — is **traceable, testable, and reversible**, fulfilling Harmony’s “lean AI-accelerated” promise.

### Frameworks & Standards

| Item                       | Role                                       | Why it aligns with Harmony                                                                                                                                                                                                                   |
| -------------------------- | ------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **OWASP ASVS v5**          | Application Security Verification Standard | Provides clear, testable security requirements (auth, input validation, crypto, logging) that integrate directly into Harmony’s **spec-first + CI gates** (CodeQL, Semgrep, SBOM). Maps 1-to-1 with Harmony’s “security by default” policy.  |
| **NIST SSDF (SP 800-218)** | Secure Software Development Framework      | Defines secure development activities (planning, coding, reviewing, releasing) that Harmony automates and embeds into each lifecycle stage. The SSDF “plan-protect-produce-respond” phases align with Harmony’s BMAD → CI → Postmortem loop. |
| **OpenTelemetry (OTel)**   | Observability Standard                     | Harmony mandates OTel for **structured logs, traces, and metrics**, ensuring reliable AI observability and root cause analysis (tied to **ObservaKit** and **BenchKit**).                                                                    |

### Methods & Practices

| Item                        | Role                               | Why it aligns with Harmony                                                                                                                         |
| --------------------------- | ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Google SRE**              | Reliability Engineering discipline | Introduces SLIs, SLOs, and **error budgets**, the backbone of Harmony’s reliability guardrails and postmortems.                                    |
| **DORA Metrics**            | DevOps performance metrics         | Harmony explicitly targets DORA’s four keys—lead time, deploy frequency, MTTR, and change-fail rate—to measure improvement in automation and flow. |
| **Trunk-Based Development** | Integration practice               | Core to Harmony’s “flow over ceremony”: small, frequent PRs to a single trunk with instant **Vercel previews** and feature flags for safe rollout. |
| **12-Factor App**           | Cloud-native design principles     | Ensures stateless, portable, and disposable services—Harmony’s **Turborepo monolith-first stack** adheres to this for simplicity and speed.        |
| **Kanban / Little’s Law**   | Flow optimization principle        | Harmony’s WIP limits (Ready=3, In-Dev=1 per dev) derive directly from Little’s Law to maximize throughput and reduce cycle time.                   |
| **Shape Up**                | Product shaping method             | Used to size “appetites” and cut scope before development—Harmony’s BMAD step #2 (“Shape”) implements this to define crisp, buildable features.    |
| **STRIDE**                  | Threat-modeling methodology        | Harmony mandates STRIDE per feature in the spec phase, linking threats → mitigations → tests, enforced by **PolicyKit** and **GuardKit**.          |
| **Monolith-First**          | Architectural strategy             | Harmony advocates a **modular monolith** in **Turborepo** before microservices—maximizing speed and minimizing ops overhead for small teams.       |

### Architectural Patterns

| Item                       | Role                           | Why it aligns with Harmony                                                                                                                                                      |
| -------------------------- | ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Hexagonal Architecture** | Domain-driven ports & adapters | Core pattern of Harmony: keeps business logic isolated from infrastructure. Enables testability, AI-generated adapters, and contract testing via **Pact** and **Schemathesis**. |

### Platforms & Platform Controls

| Item       | Role                           | Why it aligns with Harmony                                                                                                                                                |
| ---------- | ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Vercel** | Deployment platform            | Implements Harmony’s **safe deploys**: PR previews, feature flags, and instant rollback (`vercel promote`)—turning SLO-based release gating into a one-command operation. |
| **GitHub** | Source of truth and guardrails | Provides branch protection, CODEOWNERS, and built-in secret scanning—Harmony integrates all into its CI/CD quality gates.                                                 |

### Build & Repo Tooling

| Item          | Role                | Why it aligns with Harmony                                                                                                                              |
| ------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Turborepo** | Monorepo build tool | Central to Harmony’s **modular monolith** design: enables incremental builds, shared caching, and parallel CI pipelines for both Python and TypeScript. |

### Security Analysis Tooling

| Item        | Role                       | Why it aligns with Harmony                                                                                                    |
| ----------- | -------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **CodeQL**  | Semantic static analysis   | Integrated into CI for code scanning, enforcing ASVS/NIST controls for code-level vulnerabilities.                            |
| **Semgrep** | Rule-based static analysis | Fast, rule-driven checks for style and security; Harmony uses it alongside CodeQL for coverage and custom policy enforcement. |

### Testing & Contract Tools

| Item             | Role                       | Why it aligns with Harmony                                                                                                        |
| ---------------- | -------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| **Playwright**   | End-to-end testing         | Powers preview smoke tests to validate deployments in **Vercel previews** before promotion.                                       |
| **Pact**         | Contract testing           | Enforces boundary contracts across adapters (Hexagonal pattern) and aligns with Harmony’s **ports/adapters testing discipline**.  |
| **Schemathesis** | Property-based API testing | Tests OpenAPI contracts automatically; enforces correctness and prevents drift—Harmony mandates this for APIs with OpenAPI specs. |

### Specifications & Schemas

| Item            | Role                     | Why it aligns with Harmony                                                                                 |
| --------------- | ------------------------ | ---------------------------------------------------------------------------------------------------------- |
| **OpenAPI**     | API description standard | Foundation of Harmony’s **spec-first** model; drives contract testing, diff checks, and schema validation. |
| **JSON Schema** | Data validation schema   | Used across Harmony kits to validate AI and API payloads, including “golden test” outputs for determinism. |

### Guidance

| Item                                   | Role                       | Why it aligns with Harmony                                                                                                                         |
| -------------------------------------- | -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| **OWASP Cheat Sheets (CSP/CSRF/SSRF)** | Targeted security guidance | Harmony integrates these directly into the **Spec → Threat Model → Tests** flow; Cursor prompts even reference them by name during implementation. |

---

## How Harmony’s Components Reinforce Each Other

Methods (SRE, DORA, Shape Up) define how work flows. Frameworks and standards (ASVS, SSDF, STRIDE) define what “safe” means. Tools and platforms (Vercel, GitHub, OTel, Turborepo) ensure speed and safety coexist. This alignment makes Harmony lean, agent‑ready, and safe by default—so AI‑accelerated teams can move fast without breaking trust.

### 1) Security and Compliance (Defense‑in‑Depth)

- OWASP ASVS and NIST SSDF establish baseline security and development controls; specs and CI gates map directly to them.
- STRIDE injects threat modeling at design time (spec‑first), translating risks → mitigations → tests.
- CodeQL, Semgrep, and OWASP cheat sheets operationalize controls as automated CI checks and developer guidance.
- Outcome: security and compliance are built in, not bolted on after the fact.

### 2) Speed and Flow (Lean Delivery)

- Trunk‑Based Development, Kanban/Little’s Law, and Shape Up synchronize scope, WIP, and integration cadence.
  - Shape Up defines appetites and trims scope.
  - Kanban limits WIP to keep cycle times low.
  - Trunk‑based flow yields tiny, frequent integrations.
- Monolith‑First and 12‑Factor keep the architecture lean, reducing coordination and operational overhead.
- Outcome: delivery is continuous, reversible, and predictable.

### 3) Reliability and Observability (Continuous Feedback)

- Google SRE introduces SLIs/SLOs and error budgets; DORA metrics measure speed versus stability to guide release decisions.
- OpenTelemetry powers the observability stack (via ObservaKit) for traces, metrics, and structured logs.
- Vercel and GitHub provide controlled deployment and governance surfaces that enforce reliability goals.
- Outcome: reliability is measurable, and feedback loops are fast.

### 4) Architecture and Maintainability

- Hexagonal architecture, Turborepo, OpenAPI, and JSON Schema form Harmony’s structural backbone.
  - Contracts/schemas define boundaries and expectations.
  - Pact and Schemathesis ensure adapters remain compatible.
  - Turborepo enforces modularity and fast iteration.
- Outcome: systems are deterministic, testable, and easy to evolve—aligned with spec‑first and simplicity‑first rules.

### 5) Testing and Quality Assurance

- Playwright, Pact, and Schemathesis span the testing pyramid (E2E, contract, property‑based layers).
- Combined with JSON Schema validations and EvalKit, they produce verifiable AI and code outputs.
- Outcome: agent‑assisted changes are safe, observable, and reversible.

### In Short

- Not random best practices: each fills a clear gap (security, flow, observability, architecture) with minimal overlap.
- Mutual reinforcement: DORA depends on trunk flow; trunk flow depends on safe CI gates (ASVS, SSDF); SLOs depend on observability (OTel).
- Shared philosophy: prioritize small, deterministic, testable, reversible changes—the core of Harmony.

---

## Harmony in Practice

**Goal.** Ship small, quality, safe, and frequent changes with **enterprise‑grade** security, reliability, and performance using **agent‑assisted** workflows. Humans own correctness, security, and licensing.

**Guiding principle.** **Simplicity first**: prefer the smallest viable process, design, and tooling that satisfy the requirement. Add complexity only when SLOs, scale, or compliance clearly require it; avoid unnecessary dependencies.

**Methodology**:

- **Simplicity‑first**: choose the simplest process, design, and tooling that meets the requirement. Defer advanced patterns until justified by SLOs/scale/compliance. Default to no new dependency unless it materially reduces complexity.
- **Spec‑first**: every meaningful change starts with a **Specification one‑pager** + **ADR** capturing problem, scope, API/UI contracts, SLIs/SLOs, **non‑functionals**, and a **micro‑threat model (STRIDE)** mapped to **OWASP ASVS** & **NIST SSDF** tasks.
- **Agentic agile (BMAD)**: Convert the Spec to a **BMAD story** (context packets + agent plan + acceptance criteria). Use **Cursor** to generate plans/diffs/tests from the Spec, but enforce human checkpoints and license checks.
- **Flow over ceremony**: **Trunk‑Based Development** (+ short‑lived branches), tiny PRs, gated **Vercel Preview** per PR, **feature‑flagged** releases with guarded manual promote to prod; rollbacks are instant by promoting a prior preview.
- **Reliability guardrails**: Define **SLIs/SLOs**, manage via **error budgets**, alert on budget burn, run blameless postmortems with action items.
- **Security by default**: **OWASP ASVS** controls + **NIST SSDF** activities embedded in **CI/CD** quality gates: static analysis (**CodeQL/Semgrep**), dependency & **license** scan, **secret scanning**, SBOM, and contract tests.
- **Architecture**: **12‑Factor** monolith‑first in a **Turborepo** monorepo with **Hexagonal** boundaries enforced by **contract tests**, and observability via **OpenTelemetry** + structured logs.

**Expected impact (for a 2‑dev team after 60–90 days)**:

- **Lead time**: hours → sub‑day for small changes via trunk flow, preview environments, and tiny PRs. **DORA** research supports doing speed *with* stability.
- **Change‑fail rate**: drops via feature flags, previews, contract tests, and error‑budget‑driven discipline.
- **MTTR**: minutes–hours via instant rollback (promote a known‑good preview) and clear runbooks.
- **SLO attainment**: measurable improvement by alerting on **burn‑rate** and holding code until budget recovers.

### Human–AI Roles & HITL Checkpoints

- Roles
  - Driver (Dev A): owns implementation, risk call, and rollout plan.
  - Navigator/Reviewer (Dev B): owns review, security/license checks, and rollout readiness.
  - Agents (Cursor + AI‑Toolkit): propose plans/diffs/tests; never approve risk or production changes.
- Two‑person rule: High‑risk changes require Driver + Navigator involvement end‑to‑end from spec to promotion.

- Non‑negotiables (AI)
  - Cannot commit directly to protected branches; cannot approve PRs; cannot handle secrets or long‑lived credentials.
  - Must produce artifacts (plan, diffs, tests) for human review; no silent apply.
  - Must operate with pinned provider/model/version and documented parameters (temperature, top_p, max_tokens, seed if supported).

- Non‑negotiables (Humans)
  - Classify PR risk (Trivial/Low/Medium/High) and confirm rollback/flag plan.
  - Verify license/provenance and secret hygiene; check OpenAPI/JSON‑Schema diff where applicable.
  - Confirm observability for changed flows (trace + structured logs) and attach a representative trace or trace_id in the PR.
- Required human‑in‑the‑loop checkpoints
  1. Before implementation: SpecKit one‑pager + micro‑STRIDE + acceptance criteria approved by Navigator.
  2. Before merge: PR review using the risk rubric (below) with license/provenance note and OpenAPI diff.
  3. Before promotion: Feature behind a flag, Preview e2e smoke green, rollback noted, owner on‑call.
  4. After promote: 30‑minute watch window; check SLO burn‑rate and key SLIs; document in PR thread.
- Stop‑the‑line triggers (any → block or rollback)
  - Secret exposure, license violation, security regression (ASVS high/critical), SLO burn‑rate breach.
  - Missing rollback path or flag; Preview e2e red; OpenAPI breaking change without consumer sign‑off.
  - Missing observability on changed flows; missing PR risk rubric; AI model/provider/params not pinned when agents were used.
- Decision log
  - Dockit auto‑prompts an ADR summary on merge; link PR, preview URL, post‑deploy notes, and (when agents were used) AI provider/model/version + parameters and ObservaKit/EvalKit run links.

---

## Method Lifecycle Overview

```mermaid
flowchart LR
  A["SpecKit Spec + ADR"] --> B[Shape & Scope Cuts]
  B --> C["BMAD Story (context packets + agent plan + AC)"]
  C --> D["Dev in Cursor (human checkpoints)"]
  D --> E["PR -> Vercel Preview (feature-flagged)"]
  E --> F[CI Gates: lint/type/test/scan/contract/SBOM]
  F -->|all green| G[Merge to Trunk]
  G --> H["Auto Deploy to Preview; Manual Promote to Prod (guarded)"]
  H --> I[Operate: SLOs, alerts, OTel, logs]
  I --> J[Learn: Postmortem & ADR updates]
  J -->|feedback| A
```

Note: Schedule non‑blocking tasks (e.g., notifications, cache invalidation, analytics enrichment) with `next/after` where applicable so responses are fast and side‑effects are reliable without blocking the user path.

---

## Operating Cadence for 2 devs

**Cycle**: 1‑week mini‑cycles.
**Roles**: rotate weekly: **Driver (Dev A)**, **Navigator/Reviewer (Dev B)**.

- **Async daily check‑in (2 bullets)**: Yesterday outcome, Today intent (+ block).
- **Pairing**: Ping‑pong for risky changes and critical boundaries (auth, billing, data).
- **Weekly retro (≤15 min)**: 3 questions: What slowed flow? What broke gates? What SLO budget burned? Adjust WIP/gates accordingly (error‑budget policy).

### Sustainable Pace Policy

- Focus hours: two 2‑hour deep‑work blocks per day; async by default outside those blocks.
- No after‑hours work except incidents; incidents follow rollback‑first policy and postmortem within 48h.
- Daily Kaizen: 10 minutes to remove one friction (tooling, doc, test); track as a tiny PR.
- If WIP limits are exceeded for >24h, pause new work, swarm to restore flow, then resume.
- No mid‑cycle scope increases; new asks go to Backlog/Ready. Descoping is allowed to protect the appetite.
- Reserve 10% weekly capacity for maintenance (deps, tests, docs) to prevent debt accumulation.

---

## Flow & WIP Policy (Kanban for 2 people)

**Board columns**: *Backlog → Ready → In‑Dev → In‑Review → Preview → Release → Done → Blocked.*

**Explicit WIP limits (hard)**:

- Ready: 3 cards max; In‑Dev: 1 per dev; In‑Review: 2 total; Preview: 2.
  **Pull policies**: A card moves **only** when Definition of Ready/Done is satisfied.

- **Definition of Ready (DoR)**: BMAD spec one‑pager + ADR present; acceptance criteria + contracts; **STRIDE** threats & mitigations listed; flags plan; perf budget; test outline.

- **Definition of Ready (DoR) addenda**: PR risk class selected (Trivial/Low/Medium/High) with rollback and flag plan noted.

- **Definition of Done (DoD)**: All **CI gates** pass; coverage & budgets OK; **preview e2e smoke** OK; **SLO guard** no regression; docs/runbook updated; **DoS satisfied**; feature behind a flag; default OFF; PR includes risk rubric and (if agents used) AI provenance. Enable only when the error budget is healthy; disable or halt rollout on burn‑rate alerts.

### Definition of Safe (DoS)

- License and provenance approved (no policy‑blocked licenses; note in PR).
- Secrets absent; CSP/CSRF/SSRF defenses in place per surface; outbound allow‑list enforced.
- Rollback path validated (previous preview ready) and feature flag kill‑switch documented.
- SLOs unchanged or improved; p95 latency and error rate within budgets on Preview.
- Observability present: trace/span coverage on the changed flow; structured logs include trace IDs.

### Tech Debt Budget & Risk Classifier

- Maintain a lightweight debt ledger (issues labeled `debt`) capped at a small, fixed budget (e.g., 10 items).
- If the budget is exceeded, freeze feature work and burn down debt until under the cap.
- Classify changes in PRs: Trivial, Low, Medium, High risk. High risk requires: flag, preview e2e, navigator approval, and rollback plan.
  **Why strict WIP?** Keep WIP tiny to reduce cycle time per **Little’s Law** (WIP = Throughput × Cycle Time).
- Debt freeze policy: if debt budget is exceeded or error‑budget burn is high, pause new feature work and restore system health first. Daily Kaizen items (tiny PRs removing friction) do not count toward the debt budget.

### Lightweight PR Risk Rubric (template)

- Trivial: Copy, docs, or non‑functional comment/style only; no code paths executed at runtime. Gates: lint + typecheck.
- Low: Small change, covered by unit/contract tests; no security surface; instant rollback available. Gates: standard CI; optional preview smoke.
- Medium: User‑visible change or boundary touch (API/UI/adapter) with tests; moderate blast radius. Gates: standard CI + preview smoke; flag required; navigator review.
- High: Auth/billing/data/security/infra changes; migration; high blast radius. Gates: standard CI + preview smoke; flag required; navigator + security review; rollback path validated; watch window post‑promote.

---

## Spec‑First + BMAD (step‑by‑step)

1. **Write the SpecKit spec one‑pager** (template below): problem, constraints, **API/UI contracts (OpenAPI/JSON‑Schema)**, non‑functionals (perf, reliability, privacy), **ASVS** controls and **SSDF** tasks, **STRIDE** risks & tests.
2. **Shape**: Cut scope (“must”, “defer”). Pull useful parts of **Shape Up** (appetite, scopes).
3. **Transform into BMAD story**: add **context packets** (domain, constraints, examples), the **agentic plan** (ordered steps Cursor can execute), clear acceptance criteria.
4. **Cursor workflow**:
   - Paste Spec → generate **plan** and **checklist**; **pause**.
   - Ask Cursor to propose **diffs** *with* tests and contracts; **pause** again for a **human review** (security, correctness, licensing).
   - Pin **AI config** (provider, model/version, temperature/top_p, max_tokens, seed if supported); record in PR description and in ObservaKit traces; attach a trace URL.
   - Add/update **AI golden tests** (EvalKit/TestKit) for deterministic outputs; guard with JSON‑Schema.
   - Record **license status** via GitHub **Dependency Review** + **SBOM (Syft)**. Optionally run Node `license-checker` or Python `pip-licenses` locally and attach notes to the PR.
   - Run **threat-model from spec** prompt to produce test cases (XSS/CSRF/SSRF/IDOR). Use **OWASP cheat sheets** for CSP/CSRF/SSRF while coding.

---

## Branching & Release Model

- **Trunk‑Based**: short‑lived branches (≤1 day). One small change per PR. Use **feature flags** for any risky behavior.
- **Vercel Previews**: every PR gets a live URL for acceptance and e2e smoke. **Promote** a known‑good preview to production (instant rollback path).
- **Environment naming & Production policy**: Use **PR Preview** (per PR), **Trunk Preview** (on `main`), and **Production** (manual promote only). In Vercel, disable **Auto Production Deployments** so Production is updated exclusively via `vercel promote <preview-url>`.
- **Feature flags**: use **Vercel Flags** (Edge Config‑backed) as the provider (server‑evaluated). The in‑repo `packages/config/flags.ts` reads flag values from the Vercel provider (registered at app startup) and falls back to env overrides (`HARMONY_FLAG_*`) for local/dev. Call `setFlagProvider(vercelFlagsProvider)` during application startup — for this repo, register in `apps/api/src/server.ts` (API) and in the SSR entry when adding SSR surfaces. For **Astro SSG/static** pages, evaluate flags server‑side and inject values at build time or via Edge middleware; avoid using `process.env` in the browser. Otherwise, evaluation uses env (`HARMONY_FLAG_*`) and defaults. Clean up flags within 2 cycles.
- **Environments & secrets**: use **Vercel envs** + CLI to manage; never commit secrets; rely on **GitHub secret scanning** + **TruffleHog** in CI.
- **Preview smoke (fast path)**: Use Playwright or the provided helper `scripts/smoke-check.sh` to verify the PR Preview URL for core routes; link results in the PR.
- **Flags hygiene automation**: Run `scripts/flags-stale-report.js` weekly and remove or consolidate stale flags; each flag must have an owner and explicit expiry.

---

## CI/CD Quality Gates

The pipeline supports **TypeScript and Python**. CI runs language-specific linters, type checks, and tests per package using Turbo filters. Python gates run conditionally—only when a package contains Python (detected by a `pyproject.toml` or `.py` files). TypeScript **`strict`** is enforced via tsconfig; the Type Check stage runs `tsc --noEmit` as a dedicated gate.

**Mermaid view of gates**:

```mermaid
flowchart TB
  A[PR Opened] --> B[Turbo cache restore]
  B --> C[Lint/Format: ESLint (type-aware), Ruff/Black]
  C --> D["Unit Tests (Vitest default; pytest)"]
  D --> E[Type Check: TypeScript (tsc --noEmit with strict), mypy]
  E --> F[Contract Tests: OpenAPI/JSON-Schema + Pact]
  F --> G[E2E Smoke: Playwright vs Preview URL]
  G --> H[Static Analysis: CodeQL + Semgrep]
  H --> I[Dependencies: Dependabot/SCA + License scan]
  I --> J[Secrets Scan: GitHub + Gitleaks]
  J --> K[SBOM: Syft → artifact]
  K --> L[Perf/Bundle Budgets]
  L --> M[Turbo cache save; PR comment with Preview URL]
  M -->|all required checks| N[Merge Allowed]
```

**Checklist (required to merge unless marked optional/adopt incrementally)**:

- [] **Lint/format**: ESLint (type-aware) + `typescript-eslint`; add Ruff/Black when Python is added (optional).
- [] **Type Check**: TypeScript (`tsc --noEmit` with strict); add mypy when Python is added (optional).
- [] **Tests**: unit. OpenAPI breaking-change check (**oasdiff**) enforced. Pact/Schemathesis and preview **e2e smoke** (Playwright) are recommended (optional).
- [] **Static analysis**: **CodeQL** (GitHub code scanning) + **Semgrep** rules; fail on high‑sev.
- [] **Dependencies**: **Dependabot alerts** + SCA (e.g., OWASP Dependency‑Check); license policy via GitHub **Dependency Review**.
- [] **Secret scan**: GitHub **secret scanning** + **TruffleHog**.
- [] **SBOM**: **Syft** (SPDX by default) uploaded as artifact (e.g., `sbom/sbom.spdx.json`).
- [] **Contracts & bundles**: OpenAPI/JSON‑Schema present; enforce OpenAPI diff (**oasdiff**). **Bundle size** budgets are recommended; add CI enforcement later.
- [] **Preview URL** comment: linked from Vercel integration; feature **flag off by default**.
- [] **PR template & risk rubric**: include risk class, rollback plan, flag name(s), license/provenance note, and threat‑model link.
- [] **HITL gate**: High‑risk PRs require navigator review and security review before merge.
- [] **SPDX/REUSE headers**: adopt incrementally; add SPDX identifiers to new/changed files (optional).
- [] **Observability**: changed flows emit traces/logs; trace IDs visible in logs and in a PR comment (**required for changed flows**).
- [] **AI provenance** (when agents used): pin provider/model/version and parameters (temperature/top_p, max_tokens, seed if supported); include ObservaKit trace URL and EvalKit run links in PR.

---

## Test Strategy (pyramid + contracts)

- **Unit** close to logic (pure TS/Python).
- **Contract tests** at **ports** (API/UI) to freeze **Hexagonal** boundaries: Pact for consumer/provider; validate OpenAPI with Schemathesis; Prism mocks for dev.
- **AI “golden” tests**: snapshot expected model outputs for critical prompts and guard with **JSON‑Schema**.
- **Golden test stability**: prefer deterministic fixtures and schema-based assertions; allow bounded tolerances for token variance. Fail on schema or material output drift, not minor wording differences.
- **E2E smoke** on Preview (Playwright) for core flows (login, pay, CRUD) — recommended.
- **Canary/flag validation checklist** before enabling flags for a % of users.

---

## Security Baseline (mapped to frameworks)

**OWASP ASVS** (sample of included controls):

- **Auth/session/access control**, **input validation**, **error handling**, **logging/monitoring**, **config/hardening**, **crypto at rest/in transit**; map to Spec’s **ASVS IDs**; include a minimal evidence record per PR.

**NIST SSDF** (SP 800‑218) baked into lifecycle:

- **Plan/Organize**: threat modeling (STRIDE), SBOM plan, SLO/SLA doc.
- **Protect Software**: SCA, secret scanning, signed releases, protected branches.
- **Produce Well‑Secured Software**: code review, fuzz/negative tests, CodeQL/Semgrep, unit/contract/e2e.
- **Respond to Vulnerabilities**: triage SOP, patch SLAs, postmortems, SBOM updates.

**STRIDE per feature** (micro‑threat model in Spec): identify risks → mitigations → tests → checklist items. (Use OWASP cheat sheets for CSP/CSRF/SSRF; for **Next.js** use **next-safe-middleware**. Use **Helmet** only when running a custom Node/Express server. For **Astro**, set security headers at the platform (e.g., Vercel project headers) for SSG; use SSR middleware only when using an SSR adapter.)

**Secrets, headers, defenses**:

- **Secrets** only in Vercel envs; CI blocks leaks. **CSP/HSTS/X‑Frame‑Options/Referrer‑Policy** via framework middleware or platform headers; for Astro static sites, configure headers at the hosting layer (e.g., Vercel) and prefer platform‑level headers for SSG. For SSR (Next.js or Astro adapters), enforce headers in middleware; platform‑level headers take precedence, and SSR middleware should complement, not conflict. CSRF protections for mutations; SSRF‑hardening on outbound calls.
- **SBOM** in releases; **license policy** gates (ban GPL if incompatible).
  - **Data classification & PII**: classify data touched by a change; ensure appropriate handling (encryption, redaction, access controls) and avoid logging sensitive content.

---

## Reliability & Ops (Google SRE)

- **SLIs**: availability, p95 latency, error rate, saturation (CPU/DB connections/queue depth).
- **SLOs (starter)**:
  - API availability ≥ **99.9%** (monthly).
  - p95 API latency ≤ **300 ms** (warm), ≤ **600 ms** (includes cold starts).
  - p95 page **TTFB ≤ 400 ms** for top route.
  - 5xx error rate ≤ **0.5%**.
- **Error budgets**: 43m/month at 99.9%; if burned, freeze feature flags and focus on reliability until recovered. Alert on **burn‑rate** (multi‑window).
- **On‑call (2‑dev rotation)**: 1 week each; no 24/7 pages for low‑impact; page only for SLO threats.
- **Incidents**: severities, **rollback first** (Vercel promote), then fix‑forward; blameless **postmortem** template below.
- **Observability**: **OpenTelemetry** for traces/metrics + structured logs (**pino**) wired to your vendor. Next.js supports OTel and `@vercel/otel`; Astro can emit server traces when using SSR adapters. Bootstrap OTel early from `infra/otel/instrumentation.ts` (default OTLP endpoint `http://localhost:4318`, override with `OTEL_EXPORTER_OTLP_ENDPOINT`).
  - Coverage: target trace/span coverage for the top 5 user flows; add spans around new/changed paths.
  - Safety: use GuardKit to redact PII in logs by default; only log IDs and non‑sensitive metadata.
  - Hygiene: include `trace_id`/`span_id` in all logs; set retention appropriate to data policies; link a representative trace in the PR comment for High‑risk changes.

---

## Performance & Scalability

- **Perf budgets & SLIs**: TTFB, p95 route/API latencies, error rate, bundle size, **cold start** limits (see Vercel guidance). Use **Edge** for ultra‑low‑latency reads; use **Serverless** for short, bursty compute. Move sustained/heavy or long‑running work to background queues/workers; minimize cold starts.
- **Caching**: at app (**React cache for Next.js surfaces**; for **Astro**, rely on SSG + CDN or adapter SSR caching), CDN (Vercel), and data (Upstash Redis) with **cache‑key discipline**.
- **Queues/backpressure**: Default: **QStash** for serverless simplicity; alternative: **BullMQ + Upstash (Redis)** for heavier workloads or long‑running tasks; **Vercel Cron** for scheduled jobs.
- **DB basics**: indexes on read paths, batched writes, pagination, idempotency keys, soft limits and rate limiting.
- **Load test plan**: quick repeatables (k6/Artillery/autocannon) on Preview. Run against **PR Preview** for risky changes or **Trunk Preview** for broader regressions; minimum 2 minutes or ≥1,000 requests. Recommended policy: consider gating merges if p95 exceeds budget by >10%.

---

## Architecture & Repository Structure

- **12‑Factor**: configs in env, stateless processes, logs as streams, disposability, build‑release‑run.
- **Monolith‑First (modular monolith)** in **Turborepo**: deployable apps (`apps/web`, `apps/api`) + shared libs (`packages/…`). **Remote caching** accelerates CI.
- **Hexagonal** (**Ports & Adapters**): isolate edges (web, API, db, external) with interfaces and **contract tests**.

Framework strategy: **Next.js** is the default for SaaS/dynamic web apps; **Astro** is used for content‑first properties (blogs/docs/marketing). The current `apps/web` is Astro; additional Next.js apps will be added for dynamic surfaces as the project grows.

- **Feature flags implementation**: flags are declared in `packages/config/flags.ts`. At app startup, register the **Vercel Flags provider** (Edge Config‑backed) so `isFlagEnabled()` and `listFlags()` read from it by default, with local env (`HARMONY_FLAG_*`) as fallback for development. On **SSR** surfaces (Next.js, Astro adapters), flags are server‑evaluated by the provider. On **Astro SSG/static** pages, use `isFlagEnabled` only on the server; inject flag values at build time or fetch via Edge/API — do not rely on `process.env` in the browser.

**Example layout & ownership (CODEOWNERS)**:
Note: Illustrative example; `apps/app` (Next.js) may not exist yet. Add Next.js surfaces as needed.

```plaintext
repo/
  ├── apps/
  │   ├── web/        # Astro (docs/marketing, content-first)
  │   ├── app/        # Next.js (SaaS app, dynamic content)
  │   └── api/        # Node API (or Next API routes)
  ├── packages/
  │   ├── domain/     # core business logic (pure TS/Python)
  │   ├── adapters/   # db, http clients
  │   ├── contracts/  # OpenAPI/JSON Schemas, Pact files
  │   └── ui-kit/     # shared React UI
  ├── infra/
  │   ├── ci/         # GH Actions workflows
  │   └── otel/       # OTel config
  ├── docs/
  │   └── specs/      # Specs, ADRs
  ├── turbo.json
  └── CODEOWNERS
```

Use **CODEOWNERS** to enforce review by area (e.g., `packages/domain` → both devs; `adapters/db` → primary owner). Protect `main` with required checks.

## Scaling Policy (2→6 developers)

- Keep the modular monolith in a single Turborepo; split ownership by surface (web, api, adapters, domain) using CODEOWNERS and review rotation.
- Introduce a weekly “release train” for production promotions; keep PR‑per‑change and preview smoke tests per PR.
- Maintain WIP limits per pair; add a second pair (Dev C/D) mirroring the Driver/Navigator roles.
- Require High‑risk changes to add a short canary (internal flag cohort) for ≥1 hour before general enablement.
- Run daily trunk Preview e2e smoke against top flows; gate promotions on failures.
- Keep flags short‑lived: set owner and expiry, and automate weekly stale‑flag reports.

---

## Cursor‑Native Playbook (ready prompts)

> Use these **verbatim** in Cursor. Keep prompts (suggested filenames) under `/docs/prompts/`. Paste into PRs as evidence.

- **Spec‑to‑code**:
  *“Given the spec below, propose a minimal design and file‑by‑file diff (TypeScript/Python). Include contract types, tests, and a step‑by‑step plan. Flag any security, privacy, or licensing concerns. Do NOT add new deps without justification.”*
- **Refactor‑safely**:
  *“Refactor `<path>` to match the Hexagonal boundary. Preserve public contracts and ensure existing tests pass. Propose additional tests for risky branches.”*
- **Generate tests from spec**:
  *“From this Spec + OpenAPI/JSON‑Schema, generate unit + contract tests. Include negative tests derived from STRIDE threats.”*
- **Schema & contract tests**:
  *“Validate responses against `<schema>` using AJV/Zod. Add tests that fail on schema drift.”*
- **Explain diff & risks**:
  *“Summarize this diff: intent, surface area, security/perf risks, rollback plan, and flags to guard.”*
- **License‑safe suggestion**:
  *“Recommend libraries with permissive licenses only (MIT/BSD/Apache). Provide license matrix and bundle impact. Avoid GPL.”*
- **Threat‑model from spec**:
  *“Enumerate STRIDE threats for this feature. For each, propose mitigations and tests (unit/contract/e2e).”*
- **Perf budget enforcement**:
  *“Check this change against our perf budgets. Identify bundle increases and server latency risks. Suggest reductions.”*
- **PR risk rubric (summarize & gate)**:
  *“Classify this PR as Trivial/Low/Medium/High using the lightweight rubric. List gating steps met (flag, rollback, preview smoke, navigator/security review) and any missing gates.”*
- **Observability scaffolding**:
  *“Add OTel spans and structured logs to `<path/function>`. Ensure `trace_id` is logged on errors and key events. Show before/after snippets and a sample trace outline.”*

---

## Tooling Map (GitHub/Vercel/Turborepo)

- **GitHub Projects**: board columns above; templates for Spec/BMAD/bug; Insights for cycle time. Protect `main` with **required checks**.
- **Actions matrix per package**: `turbo run lint test build --filter=...` using remote cache.
- **Required checks**: the gates configured in `infra/ci/pr.yml` (subset of §7); adopt additional gates incrementally.
- **Vercel**: previews on every PR; **promote** for instant rollback; env & secret management; **feature flags** via Vercel Flags/Toolbar; **cron** for schedules.
- **Scripts**: `scripts/smoke-check.sh` for quick PR preview smoke checks; `scripts/flags-stale-report.js` for weekly flag hygiene reports.

---

## Metrics & Improvement

- **Minimal DORA**: lead time (PR open→merge), deployment frequency, change‑fail %, MTTR. Track automatically via PR & Actions timestamps; correlate with SLO burn.
- **SRE targets**: publish current SLOs, weekly error‑budget report; adjust gates when burn is high (e.g., freeze features, raise test thresholds).
- **Weekly retro prompts**:

  - *What blocked flow?*
  - *What broke gates?*
  - *Which SLI/SLO regressed?*
  - *What 1 guardrail to tighten/loosen?*

---

## 30/60/90 Adoption Plan

- **Day 1–30 (Foundations)**: set up **board, Spec/ADR, CODEOWNERS, branch protection**, Turbo pipelines, minimal CI (lint, unit, typecheck, preview). Enable **Vercel previews/envs**, **secret scanning**, **Dependabot**.
- **Day 31–60 (Security/Reliability)**: add **CodeQL, Semgrep, SBOM**, Pact/Schemathesis, Playwright smoke; define **SLOs**, alerts on burn rate; OTel + pino; require **Observability** for changed flows.
- **Day 61–90 (Perf & Flags)**: set **perf/bundle budgets**, feature flag process, load tests on preview, postmortems template, error‑budget policy in README.
  - Automate **flags hygiene** with `scripts/flags-stale-report.js`; adopt `scripts/smoke-check.sh` for fast preview validation.

---

## Worked Example — “OAuth login + org billing” (sketch)

**Spec extract (abbrev)**:

- Problem: Add OAuth (Google) login + org billing (Stripe).
- Contracts: `/api/auth/callback`, `/api/billing/webhook` (OpenAPI).
- Non‑functionals: p95 auth callback ≤ 600 ms; availability ≥ 99.9%.
- Security: ASVS V2 (authentication), V3 (session), V4 (access control), V10 (errors/logging). **STRIDE**: spoofing (OAuth state), tampering (webhook sig), info disclosure (PII), DoS (webhook storms), elevation (role mapping). Mitigations: state+nonce, Stripe signature verify, PII minimization, rate limit, RBAC checks.

**BMAD story → Cursor**:

- Context packets: OAuth sequence, Stripe events (`checkout.session.completed`, `invoice.paid`).
- Agent plan: add adapters (`adapters/oauth-google.ts`, `adapters/stripe.ts`), domain services (`AuthService`, `BillingService`), routes, tests (unit + Pact for webhook), e2e smoke on Preview.
- Acceptance: user can sign‑in → org created/linked; paid plan toggles flag `billing.active`; webhook retries idempotent.

**PR flow**:

- Tiny PR 1: contracts + stub adapters + tests (failing) → green.
- Tiny PR 2: OAuth implementation behind `flag.oauth_google`, CSRF/state checks, contract tests pass.
- Tiny PR 3: Stripe webhook with signature verify + idempotent store; Pact verifies; Playwright smoke passes on Preview.
- Release: enable `flag.oauth_google` to internal org only → monitor SLO/error rate → widen.

---

## Cursor Prompt Snippets Library

```plaintext
/docs/prompts/spec-to-code.md
/docs/prompts/refactor-safely.md
/docs/prompts/threat-model-from-spec.md
/docs/prompts/perf-budget-enforcement.md
/docs/prompts/license-safe-suggestion.md
```

---

## Extras

**Data migrations & rollback**:

- Forward‑only schema; write‑compat via dual‑write/dual‑read when needed; **feature flag** gates migration usage; keep backfill idempotent; have a `rollback.md` with `vercel promote` to prior deployment.

**Feature flags cleanup cadence**: tag flags by owner & expiry; automate weekly report; remove within 2 cycles.

**AI license‑safety tips**: prefer permissive deps; add **license scan gates**; Cursor diff review must include license notes (`license-checker`, `pip-licenses`).

**Day‑in‑the‑life (Driver/Navigator)**:

- **Mon**: Spec/BMAD → small PR #1.
- **Tue**: Tests/contracts; PR #2.
- **Wed**: Feature + flags; preview smoke.
- **Thu**: Security scans & perf budgets; PR #3.
- **Fri**: Enable flag for internal; retro (15m); plan next cycle.

---

## Quick‑Start Page (tomorrow morning)

**Cadence & roles**: 1‑week cycle; rotate **Driver/Navigator**; async daily check‑ins.

**Simplicity‑first**: Ship the smallest viable change that meets the requirement; avoid new dependencies unless they clearly reduce complexity or meet a non‑functional requirement.

**Board & WIP**: Backlog → Ready (3) → In‑Dev (1 per dev) → In‑Review (2) → Preview (2) → Release → Done → Blocked.

**Spec → BMAD → PR flow**:

1. Write **BMAD spec one‑pager** + **ADR**.
2. Convert to **BMAD story**.
3. Use **Cursor** to propose plan/diffs/tests with checkpoints.
4. Open tiny PR → **Vercel Preview** → run e2e smoke → merge if gates pass.

**Required CI checks**: lint/format; TS `--strict`; unit; typecheck; **OpenAPI diff (oasdiff)**; **CodeQL + Semgrep**; **Dependabot/SCA + Dependency Review (license)**; **secret scanning + TruffleHog**; **SBOM**; Preview URL comment; **Observability for changed flows** (trace/logs + trace_id in PR). Recommended: Pact/Schemathesis and **e2e smoke (Playwright or `scripts/smoke-check.sh`)**; publish **bundle/perf budgets** (CI enforcement optional).

**SLOs (starter)**: Availability 99.9%; p95 API ≤300 ms warm (≤600 ms incl. cold); p95 TTFB ≤400 ms; 5xx ≤0.5%. **Error budget** gates releases.

**Release behind a flag**: ship with `flag.<feature>=off` → enable for internal → ramp; **rollback** = *promote prior preview to production*.

**How to rollback**: Vercel dashboard/CLI: `vercel promote <deployment-url>`.

**Top 10 security/perf checks**:

1. STRIDE threats covered;
2. CSRF tokens on mutations;
3. CSP set;
4. SSRF outbound allow‑list;
5. Secrets in env only;
6. CodeQL/Semgrep clean;
7. SBOM present;
8. License policy OK;
9. p95 latency within budget;
10. bundle under budget.

**Incident hotline**: page only for **SLO burn** or **customer impact**; **rollback first**, then fix; blameless **postmortem** within 48h.

---

## Authoritative References

- **Standards**: OWASP ASVS v5 (canonical); NIST SSDF SP 800‑218 (v1.1)
- **Practices**: Google SRE (SLIs/SLOs, error budgets, postmortems); DORA metrics; Trunk‑Based Development; 12‑Factor App; Hexagonal architecture; Kanban/WIP (Little’s Law); Shape Up
- **Tooling & governance**: GitHub (branch protection, CODEOWNERS, secret scanning)
- **Static analysis & SCA**: CodeQL; Semgrep; Dependabot; OWASP Dependency‑Check; SBOM: Syft; Secret scanning: GitHub, TruffleHog
- **Testing & contract**: Playwright; Pact; Schemathesis
- **Observability**: OpenTelemetry (Next.js/Astro SSR + Node); pino
- **Delivery platform**: Turborepo (caching/monorepo); Vercel (previews, envs, promote/rollback, feature flags, cron)
- **OWASP cheat sheets**: CSP, CSRF, SSRF

---

### Final notes

- This method intentionally **minimizes ceremony and complexity**: few meetings, tiny PRs, clear gates, strong **Spec‑first + BMAD** with **Cursor** as a power tool and **humans as the safety system**.
- It **scales with your risk**: tighten gates when error budget burns, loosen when healthy.
- It is **fully compatible** with your stack and hosting, and gives you **enterprise‑grade** security and reliability from day one.
