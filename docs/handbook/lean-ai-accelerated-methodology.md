Below is a lean, **opinionated** methodology you can adopt tomorrow with two developers, optimized for **speed with safety** on your stated stack and hosting. It integrates **Spec Kit + BMAD + Cursor + Turborepo + Vercel** end‑to‑end, while baking in **SRE, DevSecOps, OWASP ASVS, NIST SSDF, STRIDE, 12‑Factor, Monolith‑First, Hexagonal**.

> **Sources (select)**
> OWASP **ASVS** (v5.0.0 / 4.0.3), **NIST SSDF** (SP 800‑218), **Google SRE** (SLIs/SLOs, error budgets, postmortems), **DORA** metrics, **Trunk‑Based Development**, **12‑Factor App**, **Hexagonal architecture**, **Kanban/Little’s Law**, **Shape Up**, **Turborepo** (caching/monorepo/Vercel), **Vercel** (previews, envs, promote/rollback, feature flags, cron), **CodeQL/Semgrep**, **GitHub** (branch protection, CODEOWNERS, secret scanning), **OTel** (Next.js + Node), **Playwright/Pact/Schemathesis**, **OWASP cheat sheets** (CSP/CSRF/SSRF). Citations are sprinkled where load‑bearing.

---

## 1) Executive Summary (≤2 pages)

**Goal.** Ship small, safe, and frequent changes with **enterprise‑grade** security, reliability, and performance using **agent‑assisted** workflows. Humans own correctness, security, and licensing.

**Method (one view):**

* **Spec‑first:** every meaningful change starts with a **Spec Kit one‑pager** + **ADR** capturing problem, scope, API/UI contracts, SLIs/SLOs, **non‑functionals**, and a **micro‑threat model (STRIDE)** mapped to **OWASP ASVS** & **NIST SSDF** tasks.
* **Agentic agile (BMAD):** Convert the Spec to a **BMAD story** (context packets + agent plan + acceptance criteria). Use **Cursor** to generate plans/diffs/tests from the Spec, but enforce human checkpoints and license checks.
* **Flow over ceremony:** **Trunk‑Based Development** (+ short‑lived branches), tiny PRs, gated **Vercel Preview** per PR, **feature‑flagged** releases with guarded auto‑promote to prod; rollbacks are instant by promoting a prior preview.
* **Reliability guardrails:** Define **SLIs/SLOs**, manage via **error budgets**, alert on budget burn, run blameless postmortems with action items.
* **Security by default:** **OWASP ASVS** controls + **NIST SSDF** activities embedded in **CI/CD** quality gates: static analysis (**CodeQL/Semgrep**), dependency & **license** scan, **secret scanning**, SBOM, and contract tests.
* **Architecture:** **12‑Factor** monolith‑first in a **Turborepo** monorepo with **Hexagonal** boundaries enforced by **contract tests**, and observability via **OpenTelemetry** + structured logs.

**Expected impact (for a 2‑dev team after 60–90 days):**

* **Lead time:** hours → sub‑day for small changes via trunk flow, preview environments, and tiny PRs. **DORA** research supports doing speed *with* stability.
* **Change‑fail rate:** drops via feature flags, previews, contract tests, and error‑budget‑driven discipline.
* **MTTR:** minutes–hours via instant rollback (promote a known‑good preview) and clear runbooks.
* **SLO attainment:** measurable improvement by alerting on **burn‑rate** and holding code until budget recovers.

---

## 2) Method Lifecycle Overview (Mermaid)

```mermaid
flowchart LR
  A[Spec Kit + ADR] --> B[Shape & Scope Cuts]
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

---

## 3) Operating Cadence for 2 devs

**Cycle:** 1‑week mini‑cycles.
**Roles:** rotate weekly: **Driver (Dev A)**, **Navigator/Reviewer (Dev B)**.

* **Async daily check‑in (2 bullets):** Yesterday outcome, Today intent (+ block).
* **Pairing:** Ping‑pong for risky changes and critical boundaries (auth, billing, data).
* **Weekly retro (≤15 min):** 3 questions: What slowed flow? What broke gates? What SLO budget burned? Adjust WIP/gates accordingly (error‑budget policy).

---

## 4) Flow & WIP Policy (Kanban for 2 people)

**Board columns:** *Backlog → Ready → In‑Dev → In‑Review → Preview → Release → Done → Blocked.*

**Explicit WIP limits (hard):**

* Ready: 3 cards max; In‑Dev: 1 per dev; In‑Review: 2 total; Preview: 2.
  **Pull policies:** A card moves **only** when Definition of Ready/Done is satisfied.

* **Definition of Ready (DoR):** Spec Kit + ADR present; acceptance criteria + contracts; **STRIDE** threats & mitigations listed; flags plan; perf budget; test outline.

* **Definition of Done (DoD):** All **CI gates** pass; coverage & budgets OK; **preview e2e smoke** OK; **SLO guard** no regression; docs/runbook updated; feature behind flag (default off) unless allowed by error budget.
  **Why strict WIP?** Keep WIP tiny to reduce cycle time per **Little’s Law** (WIP = Throughput × Cycle Time).

---

## 5) Spec‑First + BMAD (step‑by‑step)

1. **Write the Spec Kit one‑pager** (template below): problem, constraints, **API/UI contracts (OpenAPI/JSON‑Schema)**, non‑functionals (perf, reliability, privacy), **ASVS** controls and **SSDF** tasks, **STRIDE** risks & tests.
2. **Shape**: Cut scope (“must”, “defer”). Pull useful parts of **Shape Up** (appetite, scopes).
3. **Transform into BMAD story**: add **context packets** (domain, constraints, examples), the **agentic plan** (ordered steps Cursor can execute), clear acceptance criteria.
4. **Cursor workflow**:

   * Paste Spec → generate **plan** and **checklist**; **pause**.
   * Ask Cursor to propose **diffs** *with* tests and contracts; **pause** again for a **human review** (security, correctness, licensing).
   * Run **license checks** (Node `license-checker`, Python `pip-licenses`) and attach to PR.
   * Run **threat-model from spec** prompt to produce test cases (XSS/CSRF/SSRF/IDOR). Use **OWASP cheat sheets** for CSP/CSRF/SSRF while coding.

---

## 6) Branching & Release Model

* **Trunk‑Based:** short‑lived branches (≤1 day). One small change per PR. Use **feature flags** for any risky behavior.
* **Vercel Previews:** every PR gets a live URL for acceptance and e2e smoke. **Promote** a known‑good preview to production (instant rollback path).
* **Feature flags:** start simple with **Vercel Flags SDK** or your provider; keep flags **server‑evaluated**; clean up within 2 cycles.
* **Environments & secrets:** use **Vercel envs** + CLI to manage; never commit secrets; rely on **GitHub secret scanning** + **Gitleaks** in CI.

---

## 7) CI/CD Quality Gates

**Mermaid view of gates:**

```mermaid
flowchart TB
  A[PR Opened] --> B[Turbo cache restore]
  B --> C[Lint/Format: ESLint, TS --strict, Ruff/Black]
  C --> D[Unit Tests (Vitest/pytest)]
  D --> E[Type Check: tsc --noEmit, mypy]
  E --> F[Contract Tests: OpenAPI/JSON-Schema + Pact]
  F --> G[E2E Smoke: Playwright vs Preview URL]
  G --> H[Static Analysis: CodeQL + Semgrep]
  H --> I[Dependencies: Dependabot/SCA + License scan]
  I --> J[Secrets Scan: GitHub + Gitleaks]
  J --> K[SBOM: Syft → artifact]
  K --> L[Perf/Bundlesize Budgets]
  L --> M[Turbo cache save; PR comment with Preview URL]
  M -->|all required checks| N[Merge Allowed]
```

**Checklist (required to merge):**

* **Lint/format:** ESLint + `typescript-eslint`, TS **`strict`**, Ruff + Black.
* **Tests:** unit (Vitest/Jest/pytest), **contract tests** (Pact), OpenAPI schema checks (**Schemathesis**), preview **e2e smoke** (Playwright).
* **Static analysis:** **CodeQL** (GitHub code scanning) + **Semgrep** rules; fail on high‑sev.
* **Dependencies:** **Dependabot alerts** + SCA (e.g., OWASP Dependency‑Check), **license** scan (`license-checker`, `pip-licenses`).
* **Secret scan:** GitHub **secret scanning** + **Gitleaks**.
* **SBOM:** **Syft** (CycloneDX/SPDX) uploaded as artifact.
* **Contracts & bundles:** OpenAPI/JSON‑Schema present; enforce **bundle size** budgets (`size-limit`/`bundlesize`).
* **Preview URL** comment: linked from Vercel integration; feature **flag off by default**.

---

## 8) Test Strategy (pyramid + contracts)

* **Unit** close to logic (pure TS/Python).
* **Contract tests** at **ports** (API/UI) to freeze **Hexagonal** boundaries: Pact for consumer/provider; validate OpenAPI with Schemathesis; Prism mocks for dev.
* **AI “golden” tests:** snapshot expected model outputs for critical prompts and guard with **JSON‑Schema**.
* **E2E smoke** on every Preview (Playwright) for core flows (login, pay, CRUD).
* **Canary/flag validation checklist** before enabling flags for a % of users.

---

## 9) Security Baseline (mapped to frameworks)

**OWASP ASVS** (sample of included controls):

* **Auth/session/access control**, **input validation**, **error handling**, **logging/monitoring**, **config/hardening**, **crypto at rest/in transit**; map to Spec’s **ASVS IDs**; include a minimal evidence record per PR.

**NIST SSDF** (SP 800‑218) baked into lifecycle:

* **Plan/Organize:** threat modeling (STRIDE), SBOM plan, SLO/SLA doc.
* **Protect Software:** SCA, secret scanning, signed releases, protected branches.
* **Produce Well‑Secured Software:** code review, fuzz/negative tests, CodeQL/Semgrep, unit/contract/e2e.
* **Respond to Vulnerabilities:** triage SOP, patch SLAs, postmortems, SBOM updates.

**STRIDE per feature** (micro‑threat model in Spec): identify risks → mitigations → tests → checklist items. (Use OWASP cheat sheets for CSP/CSRF/SSRF; consider **Helmet**/**next-safe-middleware** for headers/CSP in Next.js.)

**Secrets, headers, defenses:**

* **Secrets** only in Vercel envs; CI blocks leaks. **CSP/HSTS/X‑Frame‑Options/Referrer‑Policy** via middleware; CSRF protections for mutations; SSRF‑hardening on outbound calls.
* **SBOM** in releases; **license policy** gates (ban GPL if incompatible).

---

## 10) Reliability & Ops (Google SRE)

* **SLIs:** availability, p95 latency, error rate, saturation (CPU/DB connections/queue depth).
* **SLOs (starter):**

  * API availability ≥ **99.9%** (monthly).
  * p95 API latency ≤ **300 ms** (warm), ≤ **600 ms** (includes cold starts).
  * p95 page **TTFB ≤ 400 ms** for top route.
  * 5xx error rate ≤ **0.5%**.
* **Error budgets:** 43m/month at 99.9%; if burned, freeze feature flags and focus on reliability until recovered. Alert on **burn‑rate** (multi‑window).
* **On‑call (2‑dev rotation):** 1 week each; no 24/7 pages for low‑impact; page only for SLO threats.
* **Incidents:** severities, **rollback first** (Vercel promote), then fix‑forward; blameless **postmortem** template below.
* **Observability:** **OpenTelemetry** for traces/metrics + structured logs (**pino**) wired to your vendor. Next.js supports OTel and `@vercel/otel`.

---

## 11) Performance & Scalability

* **Perf budgets & SLIs:** TTFB, p95 route/API latencies, error rate, bundle size, **cold start** limits (see Vercel guidance). Edge for ultra‑low‑latency, Serverless for heavy compute; minimize cold starts.
* **Caching:** at app (React cache), CDN (Vercel), and data (Upstash Redis) with **cache‑key discipline**.
* **Queues/backpressure:** **BullMQ + Upstash (Redis)** or **QStash** for async work; **Vercel Cron** for scheduled jobs.
* **DB basics:** indexes on read paths, batched writes, pagination, idempotency keys, soft limits and rate limiting.
* **Load test plan:** quick repeatables (k6/Artillery/autocannon) on preview; gate merges if p95 > budget.

---

## 12) Architecture & Repository Structure

* **12‑Factor**: configs in env, stateless processes, logs as streams, disposability, build‑release‑run.
* **Monolith‑First (modular monolith)** in **Turborepo**: one deployable app (`apps/web`, `apps/api`) + shared libs (`packages/…`). **Remote caching** accelerates CI.
* **Hexagonal** (**Ports & Adapters**): isolate edges (web, API, db, external) with interfaces and **contract tests**.

**Example layout & ownership (CODEOWNERS):**

```
repo/
  apps/
    web/            # Next.js
    api/            # Node API (or Next API routes)
  packages/
    domain/         # core business logic (pure TS/Python)
    adapters/       # db, http clients
    contracts/      # OpenAPI/JSON Schemas, Pact files
    ui-kit/         # shared React UI
  infra/
    ci/             # GH Actions workflows
    otel/           # OTel config
  docs/
    specs/          # Spec Kits, ADRs
  turbo.json
  CODEOWNERS
```

Use **CODEOWNERS** to enforce review by area (e.g., `packages/domain` → both devs; `adapters/db` → primary owner). Protect `main` with required checks.

---

## 13) Cursor‑Native Playbook (ready prompts)

> Use these **verbatim** in Cursor. Keep prompts in `/docs/prompts/` and paste into PRs as evidence.

* **Spec‑to‑code:**
  *“Given the Spec Kit below, propose a minimal design and file‑by‑file diff (TypeScript/Python). Include contract types, tests, and a step‑by‑step plan. Flag any security, privacy, or licensing concerns. Do NOT add new deps without justification.”*
* **Refactor‑safely:**
  *“Refactor `<path>` to match the Hexagonal boundary. Preserve public contracts and ensure existing tests pass. Propose additional tests for risky branches.”*
* **Generate tests from spec:**
  *“From this Spec + OpenAPI/JSON‑Schema, generate unit + contract tests. Include negative tests derived from STRIDE threats.”*
* **Schema & contract tests:**
  *“Validate responses against `<schema>` using AJV/Zod. Add tests that fail on schema drift.”*
* **Explain diff & risks:**
  *“Summarize this diff: intent, surface area, security/perf risks, rollback plan, and flags to guard.”*
* **License‑safe suggestion:**
  *“Recommend libraries with permissive licenses only (MIT/BSD/Apache). Provide license matrix and bundle impact. Avoid GPL.”*
* **Threat‑model from spec:**
  *“Enumerate STRIDE threats for this feature. For each, propose mitigations and tests (unit/contract/e2e).”*
* **Perf budget enforcement:**
  *“Check this change against our perf budgets. Identify bundle increases and server latency risks. Suggest reductions.”*

---

## 14) Tooling Map (GitHub/Vercel/Turborepo)

* **GitHub Projects**: board columns above; templates for Spec/BMAD/bug; Insights for cycle time. Protect `main` with **required checks**.
* **Actions matrix per package:** `turbo run lint test build --filter=...` using remote cache.
* **Required checks**: all **CI gates** from §7.
* **Vercel**: previews on every PR; **promote** for instant rollback; env & secret management; **feature flags** via Vercel Flags/Toolbar; **cron** for schedules.

---

## 15) Metrics & Improvement

* **Minimal DORA**: lead time (PR open→merge), deployment frequency, change‑fail %, MTTR. Track automatically via PR & Actions timestamps; correlate with SLO burn.
* **SRE targets**: publish current SLOs, weekly error‑budget report; adjust gates when burn is high (e.g., freeze features, raise test thresholds).
* **Weekly retro prompts:**

  * *What blocked flow?*
  * *What broke gates?*
  * *Which SLI/SLO regressed?*
  * *What 1 guardrail to tighten/loosen?*

---

## 16) 30/60/90 Adoption Plan

* **Day 1–30 (Foundations):** set up **board, Spec/ADR, CODEOWNERS, branch protection**, Turbo pipelines, minimal CI (lint, unit, typecheck, preview). Enable **Vercel previews/envs**, **secret scanning**, **Dependabot**.
* **Day 31–60 (Security/Reliability):** add **CodeQL, Semgrep, SBOM**, Pact/Schemathesis, Playwright smoke; define **SLOs**, alerts on burn rate; OTel + pino.
* **Day 61–90 (Perf & Flags):** set **perf/bundle budgets**, feature flag process, load tests on preview, postmortems template, error‑budget policy in README.

---

## 17) Worked Example — “OAuth login + org billing” (sketch)

**Spec extract (abbrev)**

* Problem: Add OAuth (Google) login + org billing (Stripe).
* Contracts: `/api/auth/callback`, `/api/billing/webhook` (OpenAPI).
* Non‑functionals: p95 auth callback ≤ 600 ms; availability ≥ 99.9%.
* Security: ASVS V2 (authentication), V3 (session), V4 (access control), V10 (errors/logging). **STRIDE:** spoofing (OAuth state), tampering (webhook sig), info disclosure (PII), DoS (webhook storms), elevation (role mapping). Mitigations: state+nonce, Stripe signature verify, PII minimization, rate limit, RBAC checks.

**BMAD story → Cursor:**

* Context packets: OAuth sequence, Stripe events (`checkout.session.completed`, `invoice.paid`).
* Agent plan: add adapters (`adapters/oauth-google.ts`, `adapters/stripe.ts`), domain services (`AuthService`, `BillingService`), routes, tests (unit + Pact for webhook), e2e smoke on Preview.
* Acceptance: user can sign‑in → org created/linked; paid plan toggles flag `billing.active`; webhook retries idempotent.

**PR flow:**

* Tiny PR 1: contracts + stub adapters + tests (failing) → green.
* Tiny PR 2: OAuth implementation behind `flag.oauth_google`, CSRF/state checks, contract tests pass.
* Tiny PR 3: Stripe webhook with signature verify + idempotent store; Pact verifies; Playwright smoke passes on Preview.
* Release: enable `flag.oauth_google` to internal org only → monitor SLO/error rate → widen.

---

# TEMPLATES (copy‑ready)

### A) **Spec Kit One‑Pager** (with ASVS/NIST/STRIDE)

```md
# Spec Kit — <Feature/Change> (One Page)
## Problem & Goal
- Problem statement (1–2 sentences)
- Business goal & appetite (days)

## Scope & Cuts
- In-scope:
- Out-of-scope (cuts):

## Contracts (APIs/UI)
- OpenAPI path(s): ...
- UI contracts/states: ...
- Data model changes: ...

## Non-Functionals
- Perf budgets (API/UI): ...
- Reliability: initial SLOs/SLIs: ...
- Privacy & data retention: ...

## Security (OWASP ASVS / STRIDE)
- ASVS levels/sections touched: (e.g., v4.0.3 V2, V3, V10)
- STRIDE table:

| Threat | Risk | Mitigation | Test |
|---|---|---|---|
| Spoofing | OAuth state steal | state+nonce, sameSite cookies | neg. test |
| Tampering | Webhook body | sign verification | unit+contract |
| ... | ... | ... | ... |

## NIST SSDF Activities (SP 800-218)
- Plan: threat model done; SBOM impact noted.
- Protect: branch protection; secret mgmt plan.
- Produce: CodeQL/Semgrep rules; tests planned.
- Respond: rollback plan; postmortem criteria.

## Flags & Rollout
- Flag keys: ...
- Rollout plan & guardrails: ...

## Observability
- OTel spans, key logs, dashboards.

## Acceptance Criteria
- ...

## ADR link
- ADR-###: ...
```

### B) **BMAD Story**

```md
# BMAD — <Feature>
## Background
- Context packets: domain, edge-cases, examples, constraints.

## Mission
- Clear outcome states (incl. flags default=off).

## Actions (Agentic Plan)
1) Generate adapters and contracts.
2) Implement domain services.
3) Wire routes; add guards.
4) Tests: unit → contract → preview e2e.
5) Observability & budgets.

## Decision Points (human-in-the-loop)
- Plan review, Diff review(s), Pre-release go/no-go.

## Acceptance Criteria
- ... (from Spec)
```

### C) **ADR (one‑page)**

```md
# ADR-<id> — <Decision>
- Status: Proposed/Accepted/Deprecated
- Context: (constraints, trade-offs)
- Decision: (what & why)
- Consequences: (pros/cons, follow-ups)
- Links: Spec, PRs, SLOs impacted
```

### D) **Threat Model Micro‑Checklist (STRIDE)**

```md
- [ ] Entry points identified (API/UI)
- [ ] STRIDE table completed
- [ ] Data classification done (PII? PCI?)
- [ ] Abuse cases considered (ASVS V11)
- [ ] Negative tests added for each threat
```

### E) **Security Baseline (ASVS items) & NIST SSDF Evidence Matrix**

```md
| Area | Control/Activity | Evidence (PR links) |
|---|---|---|
| Auth/Session | ASVS V2, V3 | ... |
| Access Control | ASVS V4 | ... |
| Input Validation | ASVS V5 | ... |
| Error/Logging | ASVS V10 | ... |
| Threat Modeling | SSDF PO.1 | ... |
| Code Review/Testing | SSDF PS.2 | ... |
| SBOM | SSDF PW.4 | Syft artifact#... |
| Vuln Response | SSDF RV.* | Postmortem#... |
```

### F) **Perf Budget Table**

```md
| Surface | Metric | Budget | Method |
|---|---|---|---|
| API /foo | p95 latency | ≤300ms warm / ≤600ms cold | OTel + SLO panel |
| Homepage | TTFB p95 | ≤400ms | Vercel Analytics |
| Bundle | JS (app) | ≤250kB gz | size-limit CI |
```

### G) **PR Checklist**

```md
- [ ] Spec/ADR linked
- [ ] Feature behind flag (default off)
- [ ] Lint/format/typecheck passed
- [ ] Unit + contract tests added/updated
- [ ] CodeQL & Semgrep clean (no high)
- [ ] SCA/Dependabot addressed
- [ ] Secrets scan clean (GitHub + Gitleaks)
- [ ] SBOM uploaded
- [ ] Perf/bundle budgets observed
- [ ] Preview URL tested; e2e smoke passed
- [ ] Rollback plan described
```

### H) **Release Checklist**

```md
- [ ] Error budget OK for this service
- [ ] Runbook updated; dashboards/alerts exist
- [ ] Canary: enable flag for internal org
- [ ] Monitor SLIs 30–60 minutes
- [ ] Gradual ramp; halt on burn-rate alerts
- [ ] Create cleanup task for flag (≤2 cycles)
```

### I) **Definition of Ready/Done**

```md
**Ready:** Spec, ADR, contracts, STRIDE, flags, budgets, tests plan
**Done:** All CI gates green; docs/runbook; preview smoke; SLO guard pass; clean SBOM; flag default governed
```

### J) **Incident Postmortem (SRE, blameless)**

```md
# Postmortem <INC-YYYYMMDD-#>
- Summary/Impact: ...
- Timeline: ...
- Root Causes (5-Whys): ...
- Detection & Response: ...
- What went well/poorly: ...
- Action Items (owner/date): ...
- SLO/Error budget effect: ...
```

### K) **Cursor Prompt Snippets Library**

```md
/spec-to-code.md
/refactor-safely.md
/threat-model-from-spec.md
/perf-budget-enforcement.md
/license-safe-suggestion.md
```

---

## Extras

**Data migrations & rollback:**

* Forward‑only schema; write‑compat via dual‑write/dual‑read when needed; **feature flag** gates migration usage; keep backfill idempotent; have a `rollback.md` with `vercel promote` to prior deployment.

**Feature flags cleanup cadence:** tag flags by owner & expiry; automate weekly report; remove within 2 cycles.

**AI license‑safety tips:** prefer permissive deps; add **license scan gates**; Cursor diff review must include license notes (`license-checker`, `pip-licenses`).

**Day‑in‑the‑life (Driver/Navigator):**

* **Mon:** Spec/BMAD → small PR #1.
* **Tue:** Tests/contracts; PR #2.
* **Wed:** Feature + flags; preview smoke.
* **Thu:** Security scans & perf budgets; PR #3.
* **Fri:** Enable flag for internal; retro (15m); plan next cycle.

---

# Quick‑Start Page (tomorrow morning)

**Cadence & roles:** 1‑week cycle; rotate **Driver/Navigator**; async daily check‑ins.

**Board & WIP:** Backlog → Ready (3) → In‑Dev (1 per dev) → In‑Review (2) → Preview (2) → Release → Done → Blocked.

**Spec → BMAD → PR flow:**

1. Write **Spec Kit** + **ADR**.
2. Convert to **BMAD story**.
3. Use **Cursor** to propose plan/diffs/tests with checkpoints.
4. Open tiny PR → **Vercel Preview** → run e2e smoke → merge if gates pass.

**Required CI checks:** lint/format; TS `--strict`; unit; typecheck; **contract tests**; **e2e smoke (Preview)**; **CodeQL + Semgrep**; **Dependabot/SCA + license**; **secret scanning + Gitleaks**; **SBOM**; **bundle/perf budgets**.

**SLOs (starter):** Availability 99.9%; p95 API ≤300 ms warm (≤600 ms incl. cold); p95 TTFB ≤400 ms; 5xx ≤0.5%. **Error budget** gates releases.

**Release behind a flag:** ship with `flag.<feature>=off` → enable for internal → ramp; **rollback** = *promote prior preview to production*.

**How to rollback:** Vercel dashboard/CLI: `vercel promote <deployment-url>`.

**Top 10 security/perf checks:**

1. STRIDE threats covered; 2) CSRF tokens on mutations; 3) CSP set; 4) SSRF outbound allow‑list; 5) Secrets in env only; 6) CodeQL/Semgrep clean; 7) SBOM present; 8) License policy OK; 9) p95 latency within budget; 10) bundle under budget.

**Incident hotline:** page only for **SLO burn** or **customer impact**; **rollback first**, then fix; blameless **postmortem** within 48h.

---

## Short appendix of authoritative references

* **OWASP ASVS** (v5 latest / v4.0.3 prior) and items mapping.
* **NIST SSDF SP 800‑218** (SSDF 1.1).
* **Google SRE** (SLIs/SLOs, error budgets, postmortems).
* **DORA** four keys.
* **Trunk‑Based Development**.
* **12‑Factor** app.
* **Hexagonal Architecture**.
* **Kanban/WIP (Little’s Law)**.
* **Turborepo** (caching/monorepos) + **Vercel** (previews, promote, envs, flags, cron).
* **Static analysis & SCA**: CodeQL, Semgrep, Dependabot, OWASP Dependency‑Check; **SBOM**: Syft; **secret scanning**: GitHub + Gitleaks.
* **Observability**: Next.js OTel + Node OTel + pino.

---

### Final notes

* This method intentionally **minimizes ceremony**: few meetings, tiny PRs, clear gates, strong **Spec‑first + BMAD** with **Cursor** as a power tool and **humans as the safety system**.
* It **scales with your risk**: tighten gates when error budget burns, loosen when healthy.
* It is **fully compatible** with your stack and hosting, and gives you **enterprise‑grade** security and reliability from day one.
