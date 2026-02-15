# AI Services Platform — The AI-Powered, Opinionated, Unified Service Layer for Small Teams

A modular, local-first platform that lets a tiny team ship outsized results with AI. It's opinionated where it matters (interfaces, safety, structure) and flexible everywhere else. Everything is a **service** with a crisp purpose, clear inputs/outputs, and predictable integration points.

> Terminology note: "Spec" refers to our AI Services Platform service (code `spec`) that wraps GitHub's Spec Kit. Mentions of the upstream tool explicitly use "GitHub's Spec Kit".

---

## Runtime Compatibility (Node vs Edge)

Choose the runtime that preserves determinism, safety, and performance while keeping complexity low.

- Node (default)
  - Recommended for: Agent, Tool (non‑trivial ops), Eval, Test, Compliance, Patch/Release integrations.
  - Rationale: richer I/O, longer execution windows, broader library support, predictable export of OTel.
- Edge (selective)
  - Recommended for: Flag evaluation, Headers, minimal Observe correlation on request boundaries.
  - Constraints: avoid heavy dependencies; keep attribute cardinality low; prefer short synchronous spans.
- Telemetry
  - Edge → OTLP HTTP is supported; fall back to buffered export when offline per Observe offline mode.
  - Always include `run.id`, `service.name`, `service.version`, `stage` to correlate across runtimes.
- Caching & Next.js 15+/16
  - Defaults: Next.js 15+/16 sets `no-store` for `fetch` and GET Route Handlers. Services MUST opt‑in explicitly to caching (`force-static`, `default-cache`, or headers) and pair with stable `cacheKey` derivation.
  - Do not leak TTLs into outputs or filenames; TTL only influences validity, never content. Record `determinism.cacheKey` and, when applicable, `cache.ttl` in the run record.
  - Edge surfaces should remain read‑mostly and short‑lived; long or stateful work belongs in Node/worker with spans covering the job lifecycle.
- Background work
  - Schedule non‑blocking side‑effects using Next.js `next/after` (or platform jobs) to keep user paths fast and reliable.
  - Long‑running work belongs in Node (or a worker) with Observe spans covering the job lifecycle.

---

## Where Services Live in the Monorepo

Services are **control‑plane capabilities** that live under `.harmony/capabilities/services/*` and are reused across the entire repo.

- **Primary placement (services):**
  - `.harmony/capabilities/services/<domain>/<service-id>/...`
  - Source of truth for:
    - Service config and contracts (types, schemas, interfaces).
    - Public APIs used by `apps/*`, `agents/*`, `kaizen/*`, and `ci-pipeline/*`.
    - Any "local dev tool" commands that operate on the repo (for example, CLIs that help improve docs or code).
- **Secondary placements (runtimes/adapters) are consumers of services:**
  - `apps/*` — thin HTTP/CLI adapters that call services in `.harmony/capabilities/services/*`.
  - `agents/*` — agent flows that use services as tools during planner/builder/verifier work.
  - `kaizen/*` — hygiene/improvement jobs that call services for analysis and patch proposals.
  - `ci-pipeline/*` — quality gates that import service APIs (for example, Eval/Flow checks).

For Flow and Agent specifically:

- **Flow (service contract interface):**
  - `.harmony/capabilities/services/planning/flow/` exposes typed input/output contracts and runtime semantics to launch flows (for example, via a Python runner, HTTP, or subprocess).
  - Flow integrates with other services in TS (Spec, Plan, Agent) at the type level.
- **Shared Python LangGraph runtime:**
  - Lives outside `apps/*` under `agents/runner/runtime/` and is treated as a shared runtime implementation behind Flow, not the service itself.
  - It consumes prompts and workflow YAML and exposes a small HTTP API/CLI (for example, `/flows/run`) that the Flow service calls.
- **Agent (plan‑driven agents on top of Flow):**
  - Uses Plan `plan.json` plans, Flow `FlowConfig`/`FlowRunner` helpers, and the shared LangGraph runtime to run durable agent graphs with retries/resume/HITL.
  - Does not implement its own separate runtime; it always reuses the shared runtime under `agents/runner/runtime/**`.
- **Apps (web, api, ai-console, ai-gateway)** can depend on Flow and Agent via the TS packages, not vice versa.

This keeps the monorepo aligned with the Architecture blueprint:

- Architecture: services = control‑plane capabilities under `.harmony/capabilities/services`; the LangGraph runtime is infrastructure under `agents/runner/runtime/**`.
- Methodology: services = concrete tools used to implement the Spec → Plan → Flow → Run lifecycle; see also `.harmony/capabilities/services/planning/service-roles.md` for canonical roles.

### Next.js 15+/16 & React 19 Integration (Guidance)

- Server Actions (React 19):
  - Use for deterministic, typed mutations invoked from UI surfaces. Keep business logic in services and call Server Actions as thin controllers.
  - Emit `service.<service>.execute` spans inside the action; propagate `run.id` via headers or form data; print one‑line JSON result to logs.
  - Prefer `useActionState` for form state; pair with optimistic UI using `useOptimistic` only for clearly idempotent updates.
- Partial Prerendering (PPR) and Streaming:
  - Opt pages/layouts into PPR selectively. Keep dynamic islands behind `Suspense` with clear span boundaries around data fetches.
  - Respect caching defaults (`no-store`); when opting into caching (`force-static`, `revalidate`), derive a stable `cacheKey` and record it in run records.
- Edge vs Node boundaries:
  - Evaluate feature flags at the Edge (Vercel Flags/Edge Config) and keep Edge handlers read‑mostly with low‑cardinality attributes.
  - Keep heavy or stateful work (AI calls, indexing, long I/O) in Node/worker; schedule follow‑ups using `next/after`.
- Data fetching:
  - Use React 19 `use` with the extended Next.js `fetch` where appropriate; memoize per‑request; avoid cross‑request mutable caches.
  - Default to `no-store`; explicitly opt in to caching and revalidation policies when stability is guaranteed.
- Hydration and security:
  - Heed improved hydration error messages; fix server/client mismatches before enabling caching.
  - Enforce security headers via platform or middleware; never expose secrets to the client; evaluate flags server‑side.
  - For Next.js SSR/Route Handlers, prefer `next-safe-middleware` for CSP and core headers; complement with platform-level headers on Vercel and avoid duplicative/conflicting policies.

- Bundling & cold starts:
  - Use Next.js 15+/16 bundling controls to externalize or prebundle heavy packages where appropriate. Avoid bundling large libraries on the Edge; default heavy or stateful libs to Node/Serverless surfaces.
  - Measure cold starts and bundle size deltas with Observe spans/metrics; only introduce bundling changes when they materially reduce latency without increasing operational complexity.

#### Astro (SSG/SSR) Integration (Guidance)

- Surfaces:
  - Prefer SSG for content‑first properties (docs/marketing); use SSR adapters only when runtime dynamics are required.
  - Evaluate feature flags server‑side (build‑time injection for SSG; Edge/API for SSR). Avoid client‑side `process.env`.
- Caching & data:
  - Treat SSG pages as static; pair dynamic islands with API routes and `Cache` for memoized reads. Do not embed secrets in generated assets.
  - For SSR, follow the same defaults as Next.js 15+/16 (no‑store by default); opt‑in to caching explicitly and record `determinism.cacheKey` in run records.
- Observability:
  - Emit OTel spans from SSR adapters or API routes; for pure SSG, rely on platform logs and downstream traces originating from invoked APIs.
  - Keep attribute cardinality low; include `run.id` where requests are tied to service executions.
- Security:
  - Enforce CSP and core headers at the platform level for SSG; complement with SSR middleware only when necessary. Route secret access exclusively via **Vault**.

#### UI & Collaboration Surfaces (Guidance)

- Surfaces:
  - Use **UI** for lightweight review/approval/search surfaces. Compose small, deterministic views that call Server Actions as thin controllers over services.
  - Keep UI components stateless where possible; move orchestration and validation to Application Use Cases that call services.
- Interactions:
  - Wire actions through Server Actions with `useActionState` and optimistic updates only when the operation is idempotent and safely reversible.
  - Always emit Observe spans around user-triggered actions and include `run.id` for correlation.
- Safety & accessibility:
  - Never expose secrets or flag values to the client; evaluate flags server-side and inject only non-sensitive booleans as needed.
  - Adopt **A11y** checks; ensure semantic HTML and ARIA where appropriate; treat accessibility violations as policy/eval failures for surfaces subject to review.

## The Problem with Multi-Agent Workflows

In today’s software-development landscape, small teams are under pressure to deliver ever more features, faster, and with higher reliability. At the same time, the rise of multi-agent AI workflows brings enormous promise — but also significant, often unaddressed risks.

- When multiple AI agents coordinate without strong structure, teams often encounter duplication of effort, circular loops or dead-locks in reasoning.
- The lack of clear role definitions, shared memory/context, and orchestration leads to brittle systems that break under pressure.
- Agents can complete tasks but still fail to resolve the correct intent, or produce technically plausible but contextually inappropriate results.
- Without guardrails and observability, multi-agent systems magnify risks of misalignment, cascading errors, non-deterministic outcomes, and reduced trust in AI-powered workflows.
- Complexity often dominates: tool proliferation, tangled interfaces, scattered data flows — resulting in slower development, harder debugging, and compromised speed or safety.

### Delivering on the Promise of Multi-Agent Workflows and AI-Native Development

We envision a modular, local-first platform that empowers a tiny team to ship outsized results with AI. This vision rests on delivering **clear, predictable building blocks (services)** that enforce structure where necessary, yet remain flexible elsewhere. Every element is aligned with the broader Harmony Framework — prioritising simplicity, safety-by-default, spec-first design, and rapid iteration. By transforming agentic workflows from fragile experiments into predictable, observable components, teams can scale AI-assisted development with confidence.

---

## The Purpose of the AI Services Platform

The **AI Services Platform** exists to accelerate software development through AI-powered automation, enabling small teams to deliver high-quality, safe, and reliable software at speed. It does this by equipping AI agents with deterministic, **guard-railed tools** — called **services** — that bring structure, visibility, and repeatability into what would otherwise be loosely-controlled workflows.

Each service embodies a single, crisp purpose, with clear inputs, outputs, and well-defined integration points. This ensures that AI agents operate in a **transparent, reproducible, and controlled** environment rather than drifting into undocumented or unpredictable behaviour. By guiding agents down **guarded paths**, the platform ensures safety, accuracy, quality, and speed — all while reducing cognitive and operational load for developers.

In alignment with Harmony's principles of **simplicity over complexity**, **spec-first rather than ceremony**, and **flow over fluff**, the AI Services Platform is opinionated where it matters (interfaces, safety, structure) and flexible everywhere else. It favours minimal viable complexity — only introducing additional layers when required by SLOs, compliance, or scale.

The AI Services Platform addresses the core pitfalls encountered when implementing multiple AI agents within an automated workflow: ambiguous hand-offs, uncontrolled tool invocation, context fragmentation, cascading hallucinations or mis-reasoning, and difficulty in debugging or observing inter-agent interactions. By enforcing **deterministic tool boundaries**, **human checkpoints**, and **observability across all runs**, the platform transforms multi-agent complexity into measurable, predictable progress rather than uncontrolled autonomous behaviour.

In short: the AI Services Platform is the **practical backbone** of Harmony's promise — a modular, local-first framework that lets a tiny team ship outsized results, without sacrificing simplicity, safety, or correctness. It turns multi-agent chaos into structured, safe, high-velocity development — **fast, safe, and aligned by design**.

---

## How the services are grouped

- **Core Workflows:** Do the work (docs, code, stack, retrieval)
- **Planning & Orchestration:** Decide *what* to do and *how* to run it
- **Knowledge & Retrieval:** Organize and query your knowledge base
- **Quality & Governance:** Keep outputs correct, consistent, and compliant
- **Automation & Delivery:** Ship changes and keep things moving
- **Development & Architecture Accelerators:** Move faster with safer scaffolds and refactors
- **Observability & Ops:** See what happened and learn
- **UI & Collaboration:** Lightweight surfaces for humans

> Notation: "Integrates with" lists the primary nearby services; all services log runs to **Observe** and can be scheduled by **Schedule**.

---

## System Invariants (Non‑Negotiables)

These invariants apply to every service and workflow so the Platform operates as a cohesive, deterministic, and governable system across Harmony's lifecycle (Spec → Plan → Implement → Verify → Ship → Operate → Learn).

- Crisp purpose and contracts
  - Each service has a single, clear purpose and publishes typed inputs/outputs (JSON‑Schema) with observable artifacts.
- Spec‑first, no silent apply
  - Implement using Plan → Diff → Explain → Test; agents produce artifacts only. Side‑effects run behind `--dry-run` by default; no direct apply in local/dev flows.
- Determinism by default
  - Pin AI provider/model/version/params; compute and record a stable `prompt_hash`. Use idempotency keys for mutating ops and cache keys for pure/expensive ops. Use content‑addressed artifact naming under `runs/`.
- Observability everywhere
  - Emit OTel traces/logs with required resource attributes; keep attributes low‑cardinality; include `trace_id` in PRs. Support offline buffering and an explicit `service.observe.flush`.
- Governance and typed failures
  - Policies are fail‑closed; violations block progression. Use typed errors with actionable summaries; assemble evidence with Compliance.
- Safety and secret hygiene
  - Redact by default (Guard). All secret access flows through Vault. Never serialize secrets/PII in artifacts, logs, or span attributes.
- Human‑in‑the‑Loop (HITL)
  - Map risk (Trivial/Low/Medium/High) to gates and approvals; require flags and rollback plans; Preview smoke for Medium/High; navigator/security reviewers per rubric.
- Local‑first operation
  - All services support `--dry-run` and function without network for validation/plan flows. Telemetry may buffer to disk and flush later.
- Simplicity‑first ergonomics
  - Prefer platform features (Vercel envs/cron/flags) over new deps. Monolith‑first with clear ports/adapters. One small change per PR. Consistent CLI flags across all services.

## Harmony Alignment

Harmony is an AI-native, human-governed methodology for solo builders — lean in ceremony and rich in capability. It pairs spec-led intent capture, context-efficient planning, autonomous AI execution loops, and risk-tiered human governance while staying stack-, host-, and environment-agnostic. Harmony aligns with OWASP ASVS, NIST SSDF, and STRIDE, and adopts architectural principles from 12‑Factor, Monolith‑First, and Hexagonal—so you can ship fast, ship safe, and ship with confidence. For the full methodology and lifecycle overview, see .harmony/cognition/methodology/README.md.

This platform maps directly to Harmony. Use the services as ready‑to‑run building blocks with AI‑driven quality, security, and reliability built in.

- **Spec‑first agentic agile, ADRs** → **Spec** + **Plan** + **Doc**
- **Trunk‑Based Development, tiny PRs, previews** → **Patch** + **Vercel Previews**
- **Security by default** (OWASP ASVS v5, NIST SSDF, STRIDE) → **Policy** + **Eval** + **Guard** + **Vault**
- **Architecture** (12‑Factor, Monolith‑First, Hexagonal) → **Stack** + **Scaffold** (+ contract tests via **Test**)
- **SRE guardrails** (SLIs/SLOs, error budgets) → **Observe** + **Bench** (+ policies in **Policy**)
- **Observability** (OpenTelemetry + structured logs) → **Observe** (default instrumentation hooks)
- **Testing and contracts** (Playwright, Pact, Schemathesis) → **Test** (gates in CI)
- **Monorepo developer experience** → **Turborepo** (caching) + **Scaffold** (monolith‑first template)

Harmony alignment notes are called out inline below in the relevant services.

Alignment stamp (2025‑11‑07): PASS — AI Services Platform covers all four Harmony pillars and every lifecycle stage. This revision clarifies Next.js bundling/security guidance and UI collaboration patterns; see "Pillars Coverage Matrix" and "Lifecycle Alignment Map" for systemic coverage.

---

## System Coherence: Harmony's Pillars Implemented by the AI Services Platform

The AI Services Platform is designed as a cohesive, self-reinforcing system aligned to Harmony's five pillars. Each pillar is made concrete by specific services, artifacts, and gates that create a closed-loop from Spec → Plan → Implement → Verify → Ship → Operate → Learn.

- **Speed with Safety**
  - Trunk-based flow with tiny PRs via **Patch** and **Vercel Previews**; controlled rollout via **Flag**.
  - Fast, repeatable runs with **Cache** and minimal service interfaces; background tasks via **Schedule**.
  - Release confidence and instant rollback: promote prior Preview; changes are always small, observable, and reversible.
- **Simplicity over Complexity**
  - Monolith-first (Turborepo) boundaries with clear ports/adapters; services expose small, predictable contracts.
  - "One way to do it" discipline: standard service inputs/outputs, shared run records under `/runs`, single observability surface via **Observe**.
  - Local-first by default; avoid new dependencies and prefer platform features unless SLOs/compliance demand otherwise.
- **Quality through Determinism**
  - Pinned AI config (provider/model/version/params) and low-variance defaults, plus **golden tests** via **Dataset** + **Eval**.
  - **Policy** enforces ASVS/SSDF/STRIDE policies; **Test** covers contracts (OpenAPI/JSON‑Schema, Pact, Schemathesis).
  - All runs traced (OTel) and explainable; every material output is verifiable and reproducible.
- **Guided Agentic Autonomy**
  - AI systems autonomously self‑build, self‑heal, and self‑tune within deterministic, observable, and reversible bounds—while humans retain ultimate authority, oversight, and accountability.
  - Deterministic agent loops (Plan → Diff → Explain → Test) with HITL checkpoints; no silent apply.
  - Pinned AI config (provider/model/version/params) and stable prompt hash; golden tests guard outputs.
  - Observability and provenance: OTel traces for runs; PRs include trace links and Eval/Policy outcomes.
 - **Evolvable Modularity**
  - Hexagonal ports/adapters and service‑level contracts keep edges (models, providers, tools, runtimes) loosely coupled and hot‑swappable.
  - Modular monolith defaults (Turborepo + Stack) and stable OpenAPI/JSON‑Schema contracts allow adopting new technologies as plug‑and‑play adapters instead of rewrites.

### Pillars Coverage Matrix (Services ↔ Pillars)

| Pillar | Primary Services | Reinforcement Mechanisms |
| --- | --- | --- |
| Speed with Safety | Patch, Flag, Cache, Schedule, Observe | Tiny PRs with previews; progressive rollout via flags; cached/idempotent runs; scheduled non-blocking tasks; traces tie changes to outcomes |
| Simplicity over Complexity | Stack, Scaffold, Tool, Cache | Monolith-first boundaries with clear ports/adapters; minimal, predictable service interfaces; reuse via small wrappers; memoization to avoid recomputation |
| Quality through Determinism | Eval, Policy, Test, Compliance, Observe | Contract tests, policy gates, schema-guarded outputs, evidence packs; OTel spans/logs for explainability and postmortems |
| Guided Agentic Autonomy | Agent, Guard, Policy, Eval, Observe, Patch/Notify (HITL) | Deterministic agent loops (Plan → Diff → Explain → Test); pinned AI config + prompt hash; golden tests; HITL checkpoints; traces/provenance; fail‑closed governance; no silent apply |
| Evolvable Modularity | Stack, Tool, Agent, adapters across services | Hexagonal ports/adapters and stable contracts make databases, models, providers, and surfaces plug‑and‑play; new capabilities can be added or retired without destabilizing core flows |

Note: Each service declares the pillar(s) it reinforces in its metadata and run records. This ensures systemic coherence and enables policy- and evidence-driven adoption.

---

### Core Service Catalog (Pillars ↔ Lifecycle ↔ Spans)

This catalog clarifies how the essential services reinforce Harmony's pillars and lifecycle, and which canonical spans they must emit.

| Service | Pillars | Lifecycle | Required Spans (minimum) |
| --- | --- | --- | --- |
| Spec | simplicity_over_complexity, quality_through_determinism | spec | `service.spec.specify` |
| Plan | speed_with_safety, quality_through_determinism | plan | `service.plan.plan` |
| Agent | speed_with_safety, guided_agentic_autonomy | implement | `service.agent.execute` |
| Tool | speed_with_safety, simplicity_over_complexity | implement | `service.tool.call.<action>` |
| Eval | quality_through_determinism | verify | `service.eval.verify` |
| Policy | quality_through_determinism | spec·plan·verify·ship | `service.policy.check` |
| Test | quality_through_determinism | verify | `service.test.run` |
| Patch | speed_with_safety | ship | `service.patch.open_pr` |
| Release | speed_with_safety | ship | `service.release.tag` |
| Flag | speed_with_safety | ship·operate | `service.flag.evaluate`, `service.flag.toggle` |
| Observe | quality_through_determinism | all | `service.observe.flush` + required attributes |
| Compliance | quality_through_determinism | verify·ship·learn | `service.compliance.assemble` |
| Cache | speed_with_safety, simplicity_over_complexity | implement | `service.cache.hit`, `service.cache.miss` |
| Parse | simplicity_over_complexity, speed_with_safety | implement | `service.parse.run` |

Notes:

- Service metadata MUST include `pillars`, `lifecycleStages`, and `observability.requiredSpans` as defined below.
- Services may participate in multiple lifecycle stages; spans should encode `stage` as an attribute for filtering.

### Service Contracts Summary (Harmonized)

This table standardizes each core service's purpose, lifecycle coverage, schemas, spans, and default gates. Schema paths are normative and live under the Contracts Registry (see section below). If a schema is not yet present, add it when the service is implemented or materially updated.

| Service | Purpose | Stage(s) | Inputs Schema (normative) | Outputs/Artifacts (normative) | Required Spans | Gates (default) |
| --- | --- | --- | --- | --- | --- | --- |
| Spec | Produce spec one‑pager + ADR | spec | `.harmony/capabilities/services/planning/spec/schema/input.schema.json` | `docs/specs/*.md`, `docs/specs/adr-*.md` | `service.spec.specify` | Policy preflight (ASVS/SSDF), Observe trace open |
| Plan | Produce plan (BMAD) from spec | plan | `.harmony/capabilities/services/planning/plan/schema/input.schema.json` | `plan.json` | `service.plan.plan` | Policy ruleset selected; dry‑run OK |
| Agent | Execute plan (produce artifacts only) | implement | `.harmony/capabilities/services/planning/agent/schema/input.schema.json` | Proposed diffs, tests, notes under `runs/**` | `service.agent.execute` | Guard redaction; idempotency required on mutating ops |
| Tool | Deterministic action wrappers (Git/HTTP/Shell) | implement | `.harmony/capabilities/services/operations/tool/schema/input.schema.json` | Structured logs, proposed changes | `service.tool.call.<action>` | Guard + Cache; fail closed on secret/redaction errors |
| Eval | Verify structure/grounding/style | verify | `.harmony/capabilities/services/quality/eval/schema/input.schema.json` | `runs/eval/*.json` | `service.eval.verify` | Thresholds enforced; fail‑closed on miss |
| Policy | Evaluate policy rulesets (ASVS/SSDF/STRIDE) | spec·plan·verify·ship | `.harmony/capabilities/services/governance/policy/schema/input.schema.json` | `runs/policy/*.json` | `service.policy.check` | Fail‑closed by default (`policy.failClosed = true`) |
| Test | Contract/unit/e2e invoker | verify | `.harmony/capabilities/services/quality/test/schema/input.schema.json` | `runs/test/*.json` | `service.test.run` | OpenAPI diff fail‑closed; contract tests required on changed surfaces |
| Patch | Open PR + changelog | ship | `.harmony/capabilities/services/delivery/patch/schema/input.schema.json` | PR number, preview URL | `service.patch.open_pr` | Feature flag OFF by default; preview smoke recommended |
| Release | Tag and release | ship | `.harmony/capabilities/services/delivery/release/schema/input.schema.json` | Tag, changelog | `service.release.tag` | Requires green policy/eval gates |
| Flag | Server‑side flag evaluation/toggles | ship·operate | `.harmony/capabilities/services/delivery/flag/schema/input.schema.json` | Flag states/rollout plan | `service.flag.evaluate`, `service.flag.toggle` | Progressive delivery; rollback path ready |
| Observe | Telemetry (traces/logs/metrics) | all | n/a | `runs/**` links + vendor traces | `service.observe.flush` | Never log secrets; redaction on by default |
| Compliance | Assemble evidence pack | verify·ship·learn | `.harmony/capabilities/services/governance/compliance/schema/input.schema.json` | Evidence pack manifest under `runs/**` | `service.compliance.assemble` | Required for high‑risk changes |
| Cache | Idempotency + memoization | implement | `.harmony/capabilities/services/operations/cache/schema/input.schema.json` | Cache hit/miss records | `service.cache.hit`, `service.cache.miss` | Pure ops must declare `--cache-key` |
| Parse | Convert PDFs to Markdown (tables/figures) | implement | `.harmony/capabilities/services/retrieval/parse/schema/input.schema.json` | `docs_out/parsed/*.md`, `runs/**/parse-*.json` | `service.parse.run` | Guard redaction; dry‑run OK |
| Prompt | Manage prompt templates, variables, variants, and fixtures | implement·verify | `.harmony/capabilities/services/modeling/prompt/schema/input.schema.json` | `prompts_out/**` compiled prompts, `prompt_tests/**` fixtures, `runs/**/prompt-*.json` prompt metadata | `service.prompt.compile` | Eval/Test/Policy gates on prompt drift and schema violations |

Notes:

- "Inputs Schema" and "Outputs/Artifacts" identify contract locations to keep interfaces crisp and consistent across services.
- If a service spans multiple lifecycle stages, set `stage` on spans and record the stage in the run record.

### LLMOps & ContextOps responsibilities (service map)

The following clarifies how services participate in **LLMOps** (logging, evaluation, governance, cost, reliability) and **ContextOps** (RAG pipelines, context design), and how **Prompt** fits into that picture:

- **Prompt (PromptOps, design-time)**
  - Owns **prompt templates, variable schemas, variants, and fixtures**.
  - Compiles templates (often from `packages/prompts/**`) into **canonical prompts** with `prompt_hash` and metadata.
  - Produces **prompt test fixtures** consumed by Eval/Test and records prompt metadata in Prompt run records.
  - Does **not** own retrieval, logging/metrics, dashboards, or evaluation logic; it is a **compile-time/template contract service**, not a full LLMOps platform.

- **LLMOps responsibilities (runtime, evaluation, governance)**
  - **Observe**: central LLM observability (traces, logs, metrics, cost/latency) for all model calls, including those that use Prompt-compiled prompts.
  - **Eval**: runs structured evaluation suites over model outputs; can consume Prompt fixtures to evaluate behavior per template/variant.
  - **Dataset**: maintains golden datasets for prompts/flows; used by Eval to compare prompt variants and model choices.
  - **Policy**: applies policy rules to LLM behavior (e.g., determinism, redaction, safety thresholds) and blocks on violations.
  - **Cache**: records cache hits/misses for pure LLM calls and RAG operations; pairs with deterministic `cacheKey` derivation.
  - **Model / Cost** (when present): define model routing, allowed providers, and cost guardrails for LLM calls.
  - **Flow / Agent / Tool**: orchestrate and execute flows that *use* prompts; they call Prompt to obtain compiled prompts, then call providers under Observe instrumentation.
  - **UI**: provides dashboards and playground surfaces over the above (e.g., trying prompt variants, inspecting traces/evals).

- **ContextOps responsibilities (RAG / context design)**
  - **Ingest**: ingests and normalizes documents into canonical forms with provenance.
  - **Index**: builds and updates indexes over ingested content.
  - **Search** (optional): fetches external documents when external knowledge materially improves outcomes.
  - **Query**: executes deterministic retrieval over indexes; emits evidence and usage metadata.
  - **Prompt**: defines **context slots and schemas** inside prompt templates (e.g., `{retrieved_docs}`, `{policy_snippets}`) and ensures context variables conform to schema before rendering.
  - **Observe + Eval + Dataset**: observe and evaluate retrieval quality and answer grounding; Prompt does not manage indexes or retrieval strategy.

In practice:

- Treat **Prompt** as your **PromptOps service for templates/contracts/fixtures**.
- Treat **Observe, Eval, Dataset, Policy, Cache, Model/Cost, Flow, Agent, Tool, and UI** as the primary **LLMOps and ContextOps surface area**.
- Leave concrete prompt content and flow manifests in `packages/prompts/**` or slice-specific packages; Prompt reads from those locations but does not own their domain semantics.

## Lifecycle Alignment Map (Harmony ⇄ Services)

| Harmony Stage | Primary Services | Artifacts (evidence) | Guards (gates) |
| --- | --- | --- | --- |
| Spec / Shape | Spec, Stack, Diagram, Doc | Spec one‑pager, ADR, `stack.yml`, architecture diagrams | Policy preflight (ASVS/SSDF), Observe trace |
| Plan | Plan | `plan.json` (BMAD), checklists | Policy rules (scope/risks), Compliance checklists |
| Implement | Agent, Tool, Dev, CodeMod | Proposed diffs, unit tests, adapters | Guard (redaction), Cache (idempotency), Observe spans |
| Verify | Eval, Test, Policy, Compliance | Eval reports, contract test results, policy outcomes | CI gates (CodeQL, Semgrep, SBOM, OpenAPI diff), fail-closed |
| Ship | Patch, Release, Flag, Notify | PR, Preview URL, CHANGELOG, rollout plan | Preview e2e smoke, risk rubric, manual promote-only to prod |
| Operate | Observe, Bench | Traces, metrics, structured logs, perf deltas | SLO/error‑budget guardrails, alerts |
| Learn | Doc | ADR updates, postmortem, decision logs | Compliance evidence links, Observe trace links |

Notes:

- All stages emit **Observe** traces and write run records under `/runs`. **Compliance** assembles evidence across stages for audits.
- Harmony's WIP and risk policies are enforced through **Policy** rules and Patch PR templates (risk rubric, rollback, flags).

### Lifecycle Conformance Checklist (per change)

- [ ] Spec/Shape: Spec one‑pager + ADR; micro‑STRIDE with mitigations/tests; contracts present (OpenAPI/JSON‑Schema where applicable).
- [ ] Plan: `plan.json` (BMAD) with explicit steps and HITL checkpoints; risk class chosen; rollback and flag plan drafted.
- [ ] Implement: Proposed diffs (no silent apply); tests included; AI config pinned and recorded; idempotency keys for mutating ops.
- [ ] Verify: Eval/Test/Policy pass; OpenAPI diff checked; license/provenance noted; secret scans clean.
- [ ] Ship: PR opened with Preview URL; feature behind a flag by default; promote only from known‑good preview.
- [ ] Operate: Observe trace/logs present; SLIs within budgets; alert policies configured when relevant surfaces change.
- [ ] Learn: ADR updated; evidence pack linked (run records, traces, eval/policy outcomes); postmortem if incident triggered.

---

## Canonical Lifecycle Flow Contract (System Integration v0.2)

This contract makes the end‑to‑end flow deterministic, observable, and governable. Each step emits required artifacts and spans, and gates are fail‑closed by default.

1. Spec → Plan
   - Services: Spec → Plan
   - Inputs: approved Spec one‑pager + ADR; micro‑STRIDE
   - Artifacts: `docs/specs/*.md`, `plan.json`
   - Required spans: `service.spec.specify`, `service.plan.plan`
   - Gate: Policy preflight (ASVS/SSDF), Observe trace opened

2. Implement (Agentic)
   - Services: Agent → Tool (+ Cache) producing proposed diffs only
   - Artifacts: proposed diffs, tests, notes; no direct apply
   - Required spans: `service.agent.execute`, `service.tool.call.*`
   - Gates: Guard redaction; idempotency keys attached to mutating ops

3. Verify (Quality & Security)
   - Services: Eval, Test, Policy, Compliance
   - Artifacts: eval reports, test results, policy outcomes, evidence pack links
   - Required spans: `service.eval.verify`, `service.policy.check`
   - Gates: fail‑closed on threshold/policy violations

4. Ship
   - Services: Patch → Release (optional) + Flag
   - Artifacts: PR, CHANGELOG, rollout/rollback plan
   - Required spans: `service.patch.open_pr`, `service.release.tag` (optional)
   - Gates: Preview smoke (recommended), feature off by default

5. Operate → Learn
   - Services: Observe, Bench → Doc (+ Schedule for cadence)
   - Artifacts: traces/logs/metrics, perf deltas, ADR/postmortem updates
   - Required spans: `service.observe.flush`, domain spans around changed flows

Required run record additions for this flow (see schema v0.2 below): `stage`, `risk`, `hitl.checkpoint`, `prompt_hash` (if AI used), `idempotencyKey`, `cacheKey`, `policy.ruleset` and outcome.

### Service Lifecycle State Machine (standard v0.2)

Define consistent states and transitions across all services to improve determinism, observability, and governance. These states are orthogonal to Harmony stages and are represented in spans as attributes (`service.state`) and as span events for transitions.

- States (string enum): `idle` → `planning` → `executing` → `verifying` → `completed` | `failed`
- Transitions (event names emitted on the active lifecycle span):
  - `state.enter`: `{ from, to }`
  - `inputs.validated`: `{ schema, result }`
  - `artifact.write`: `{ path, kind }`
  - `gate.pass` / `gate.block`: `{ gate, reason }`
  - `hitl.requested` / `hitl.approved` / `hitl.rejected` / `hitl.waived`: `{ checkpoint, approver }`
  - `error`: `{ error_type, message }` (no secrets/PII)

Recommended spans per state:

- `planning` → `service.<service>.plan` (e.g., `service.plan.plan`)
- `executing` → `service.<service>.execute` or `service.tool.call.<action>`
- `verifying` → `service.eval.verify`, `service.policy.check`, `service.test.run`
- Terminal states: add `service.state` attribute to the parent lifecycle span and include `status` in the run record

Mermaid state sketch:

```mermaid
stateDiagram-v2
  [*] --> idle
  idle --> planning: start
  planning --> executing: plan_ready
  executing --> verifying: outputs_ready
  verifying --> completed: gates_pass
  verifying --> failed: gates_block
  executing --> failed: error
  planning --> failed: invalid_inputs
  completed --> [*]
  failed --> [*]
```

## Governance & Guardrails Matrix (ASVS • SSDF • STRIDE)

- **OWASP ASVS v5**: mapped to Policy rules; enforced via Eval/Test/CI scanners.
  - Examples: authentication/session controls → Test + CodeQL; input validation → Eval checks; logging/monitoring → Observe presence.
- **NIST SSDF (SP 800‑218)**: lifecycle activities tied to services and CI stages (plan/protect/produce/respond).
  - Produce well‑secured software: CodeQL, Semgrep, unit/contract/e2e; Respond: incidents → Doc + postmortem + guardrail updates in Policy.
- **STRIDE** per feature: Spec micro‑threat model → mitigations/tests/policies. Guard provides redaction; Headers sets CSP/headers; Vault/Policy ensure secrets hygiene.

### Evidence & Retention (Compliance)

- Evidence packs are assembled by **Compliance** per PR and per release: run records (`/runs/**`), Observe trace links, Eval/Policy outcomes, OpenAPI/JSON‑Schema diffs, SBOM, license notes, preview smoke results.
- Retain evidence for the lifetime of the release (or per policy). Store only non‑sensitive data; link out to traces/logs by `trace_id`.
- Map evidence items to frameworks (ASVS/SSDF IDs) to enable fast audits and postmortems. See Appendices B–D for schema and ADR templates.

---

### Policy Rulesets (naming, versioning, fail‑closed)

To align with Harmony governance, Policy rules MUST be explicit and versioned:

- Ruleset identity: `policy.ruleset = <framework>|<profile>@<version>` (e.g., `ASVS@5.0`, `SSDF@1.1`, `Harmony-Minimal@2025-11-01`).
- Versioning: prefer calendar versions for policy bundles consumed by multiple services; semantic versions are acceptable for library-style policies.
- Fail‑closed: when `policy.failClosed = true`, any missing evidence, parse error, or provider failure MUST block the gate and be surfaced with a typed `PolicyViolationError`.
- Evidence linking: include `policy.checked[]` IDs (e.g., `ASVS-2.1.1`) and `policy.result` in the run record and as OTel attributes.
- PR integration: Patch SHOULD render a ruleset summary and outcomes in the PR body and require navigator acknowledgement for deviations.

#### Example risk‑based gating profile (Policy default)

```json
{
  "policy": {
    "ruleset": "Harmony-Minimal@2025-11-01",
    "failClosed": true,
    "riskProfile": {
      "trivial": {
        "gates": ["lint", "typecheck"],
        "hitl": "optional"
      },
      "low": {
        "gates": ["lint", "typecheck", "unit", "openapi-diff?", "contracts?"],
        "hitl": "reviewer"
      },
      "medium": {
        "gates": [
          "lint",
          "typecheck",
          "unit",
          "contracts",
          "openapi-diff",
          "preview-smoke",
          "security-scan",
          "observability"
        ],
        "hitl": "navigator",
        "flags": { "required": true }
      },
      "high": {
        "gates": [
          "lint",
          "typecheck",
          "unit",
          "contracts",
          "openapi-diff",
          "preview-smoke",
          "security-scan+license",
          "observability",
          "sbom"
        ],
        "hitl": "navigator+security",
        "flags": { "required": true, "canary": true }
      }
    }
  }
}
```

## Example Workflows

### 1) Daily Doc Refresh

1. **Schedule** triggers → **Plan** builds "Doc Refresh".
2. **Agent** runs: Parse → Ingest → Index → Doc (Prompt + Query grounding).
3. **Eval** verifies structure/links/grounding/security; **Test** runs code blocks/contracts.
4. **Patch** opens PR; **Notify** posts summary; **Observe** stores traces.

### 2) Safe Refactor/Migration

1. Goal → **Plan** (analyze → codemod → validate → PR).
2. **Agent** executes: Query (impact) → **CodeMod** (AST changes) → Dev (edge fixes/tests).
3. **Eval** runs tests/style/security (CodeQL/Semgrep/SBOM/secrets); **Patch** opens PR with Vercel Preview; **Bench** posts perf deltas; Notify alerts.

### 3) New Service (from Stack Profile)

1. **Stack** profile chosen/updated.
2. **Scaffold** generates monolith-first service skeleton (Turborepo), CI, observability hooks.
3. **Dev** implements endpoints; **Seed** seeds sample data.
4. **Doc** writes how-tos; **Diagram** generates architecture diagrams.
5. **Eval** gates (contracts + security); **Patch** ships (preview → promote); **Release** updates CHANGELOG.

### 4) Architecture Decision (ADR)

1. **Search** pulls external evidence; **Query** surfaces internal usage.
2. **Stack** proposes decision; **Diagram** updates diagrams.
3. **Doc** writes ADR; **Patch** opens PR; **Policy/Eval/Compliance** gate.

### 5) Incident → Postmortem

1. Incident logs collected in **Observe** (OTel + structured logs).
2. **Doc** drafts postmortem; **Query** fetches timelines/PRs.
3. **Playbook** runs remediation steps; **Policy** adds guardrails (ASVS/SSDF tasks).
4. **Patch** ships fixes; **Release** tags hotfix.

---

## Human‑in‑the‑Loop (HITL) Checkpoints

Harmony mandates human governance with minimal ceremony:

1. **Before implementation**: Spec one‑pager + ADR approved; micro‑STRIDE present; acceptance criteria clear.
2. **Before merge**: PR review with risk rubric (Trivial/Low/Medium/High), license/provenance note, OpenAPI diff where applicable, Preview e2e smoke (recommended), Observe trace URL.
3. **Before promotion**: Feature behind a flag; navigator approval; rollback path validated (promote prior Preview).
4. **After promotion**: Short watch window; check SLO burn‑rate and key SLIs; document in PR.

Agent constraints:

- Agents cannot commit to protected branches or approve PRs; secrets are never exposed.
- Agents must pin provider/model/version/params; record Observe trace URL and Eval run IDs in PRs.

---

### Risk & HITL Policy (standard v0.2)

Map risk to mandatory gates and human checkpoints. All gates are fail‑closed unless explicitly waived by navigator with rationale in PR.

| Risk | Required Gates | HITL | Flags & Rollback |
| --- | --- | --- | --- |
| Trivial | Lint/typecheck only | Optional reviewer | Not required |
| Low | Unit/contract tests; Policy/Eval pass | One reviewer | Optional flag; rollback note |
| Medium | + Preview smoke; Observe trace link | Navigator review | Feature flag required; rollback plan required |
| High | + Security review; license note; watch window | Navigator + security reviewer | Feature flag required; rollback path validated; promote‑back rehearsed |

Role responsibilities:

- Driver: implementation, risk classification, rollback/flag plan.
- Navigator: review and gating decisions; approves deviations.
- Agents: produce artifacts only; never approve/merge or handle secrets.
- Two‑person rule (High risk): High‑risk changes require Driver + Navigator involvement end‑to‑end (from spec approval to promotion/rollback). Agents never approve or promote; humans own correctness, security, licensing, and rollout safety.

Enforcement:

- Policy encodes the rubric; Patch blocks merge on missing gates.
- Compliance aggregates evidence (`/runs`, trace links, policy/eval outcomes) per PR.

### HITL States & Semantics

HITL checkpoints are represented in run records and telemetry with explicit states to preserve determinism and auditability:

- States: `planned` → `requested` → `approved` | `rejected` | `waived`
- Required fields
  - `hitl.checkpoint`: human gate (e.g., `pre-implement`, `pre-merge`, `pre-promote`, `post-promote`).
  - `hitl.approver`: GitHub handle or email of approver.
  - `hitl.approvedAt`: ISO8601 timestamp.
  - For waivers: include `hitl.justification` and link to PR comment.
- Operational note: use **Notify** to request and record approvals; include PR URLs and link the approval event to the active `run.id`.
- Telemetry events (see Observe): emit span events `hitl.requested`, `hitl.approved`, `hitl.rejected`, `hitl.waived` on the parent lifecycle span.

### Stop‑the‑Line Triggers (Platform enforcement)

The platform enforces immediate block or rollback when any of the following occur. These conditions map to explicit service gates and exit codes to preserve safety and determinism:

- Secret exposure or prohibited data in artifacts/logs
  - Gate: **Guard** (exit 4). Action: scrub artifacts, rotate credentials if applicable, re‑run with redaction on.
- License or provenance violation
  - Gate: **Policy** rules + Dependency Review. Action: replace/justify dependency; document license note in PR.
- Security regression or critical ASVS/STRIDE failure
  - Gate: **Policy/Eval/Test** (exits 2/3). Action: fix failing controls/tests; navigator/security review required.
- SLO burn‑rate breach or reliability regression
  - Gate: **Observe** SLO guard. Action: freeze risky flags; prioritize reliability; rollback if needed.
- Missing rollback path or feature flag for risky change
  - Gate: **Patch** PR checks. Action: add flag + rollback plan; keep OFF by default until preview smoke is green.
- Missing observability on changed flows (no trace/logs)
  - Gate: **Policy** observability rule. Action: add required spans/logs and a representative `trace_id` in PR.
- AI provenance not pinned (provider/model/version/params)
  - Gate: **Policy** determinism rule. Action: pin config and include `prompt_hash` and run links in PR.

### Patch PR Template (minimal default)

Patch SHOULD generate (or validate) a minimal PR body conforming to Harmony's governance and determinism rules. Use this as the default template; Patch fills placeholders and appends links/evidence.

```markdown
## Summary
- Intent:
- Scope:
- Risk: <Trivial|Low|Medium|High>

## Determinism & Provenance (AI)
- AI used: <yes|no>
- Provider/Model/Version: <e.g., openai gpt-4.1 2025-10-01>
- Params: temperature=<≤0.3>, top_p=<>, seed=<if supported>
- Prompt hash: <sha256>
- Observe trace: <URL or trace_id>
- Eval/Test runs: <links or IDs>

## Governance
- Policies checked: <e.g., ASVS@5.0, SSDF@1.1> → result: <pass|fail>
- Contracts: <OpenAPI/JSON‑Schema diff link>
- Security checks: CodeQL/Semgrep/Secrets/SBOM → <pass|notes>

## Flags & Rollback
- Feature flag(s): <flag.name> (default: OFF)
- Rollback: `vercel promote <prev-preview-url>`

## Acceptance
- Checklist: tests green; preview smoke (if Medium/High); navigator approval (if required)

## Notes
- License/provenance: <Dependency Review notes>
```

## Minimal, Small-Team Setup (Directory Layout)

```plaintext
/services
  /doc          /dev           /stack
  /plan         /agent         /tool
  /spec         /test          /search
  /ingest       /index         /query
  /prompt       /eval          /observe
  /guard        /policy        /cache
  /compliance   /a11y          /headers
  /notify       /schedule      /cost
  /codemod      /scaffold      /playbook
  /diagram      /dep           /bench
  /dataset      /model         /release
  /migration    /flag          /ui
  /i18n         /seed          /vault
  /parse
/docs         (source)
/docs_out     (proposed outputs)
/ingest       (normalized sources)
/indexes      (search stores)
/runs         (traces + artifacts)
/policy       (yaml rules)
/prompts      (prompt templates)
/stack        (stack profiles)
/datasets     (goldens for RAG/eval)
```

In the Harmony monorepo, this conceptual `/prompts` node is realized as a workspace package (for example `packages/prompts`) rather than a separate root-level folder. Prompt suites are treated as **shared knowledge-plane libraries** that apps, services, and agents import; by contrast, agent runtimes themselves live under the root `agents/` plane because they are long-running processes invoked via Flow or CLIs rather than importable libraries.

---

## Service Template & Turbo Integration (Developer Ergonomics)

Standardize the on‑disk layout and commands for each service to keep developer flow fast and predictable in a Turborepo.

### Service directory skeleton (normative)

```plaintext
/.harmony/capabilities/services/<domain>/<service-id>/
  README.md
  package.json
  tsconfig.json
  src/
    index.ts           # programmatic API (pure; no side‑effects)
    cli.ts             # CLI entrypoint (parses flags/env; calls `src/index`)
    observability.ts   # Observe bootstrap (exports tracer/logger)
    errors.ts          # typed error classes (maps to standard exit codes)
  schema/
    input.schema.json
    output.schema.json
  metadata/
    service.metadata.json  # conforms to ServiceMetadata v0.2
  runs/                # local artifacts during dev (gitignored)
  __tests__/           # unit + contract tests (Eval/Test/Policy fixtures)
```

### Turbo pipelines (convention)

Add or align pipelines in `turbo.json` so all services expose the same verbs:

```json
{
  "pipeline": {
    "build": { "dependsOn": ["^build"], "outputs": ["dist/**"] },
    "lint": { "outputs": [] },
    "typecheck": { "outputs": [] },
    "test": { "dependsOn": ["build"], "outputs": ["runs/test/**"] },
    "service:run": { "cache": false }
  }
}
```

Recommended `package.json` scripts per service:

```json
{
  "scripts": {
    "build": "tsup src/cli.ts --format cjs,esm --dts --out-dir dist",
    "lint": "eslint .",
    "typecheck": "tsc --noEmit",
    "test": "vitest run",
    "service:run": "node dist/cli.js --dry-run --stage implement"
  }
}
```

Notes:

- CLI flags and outputs MUST match the Service Interface Contract and the standard exit codes. Tests should cover schema validation (inputs/outputs), typed errors, and policy/eval wiring.
- Keep `src/index.ts` pure and side‑effect free; perform IO and process exits only in `cli.ts`. This separation improves testability and reuse from other services.

## Service Interface Contract (Standard)

Every service implements a minimal, deterministic contract so runs are reproducible, observable, and easy to govern.

Required elements:

- **Purpose**: single, crisp verb/noun (“improve docs”, “verify structure”, “open PR”).
- **Inputs**: typed DTO or JSON‑Schema; must document defaults and env requirements.
- **Outputs**: artifact file paths, PR numbers, report IDs; must include success/failure status and summary.
- **Side‑effects**: file edits, network calls, PRs/releases; all side‑effects must be logged.
- **Determinism**: `ai.provider`, `ai.model`, `ai.version`, `ai.temperature`, `ai.top_p`, `ai.seed` (if supported), `idempotencyKey`, `cacheKey`.
- **Observability**: OTel spans with required attributes (see Observe guide), structured logs with `trace_id` and `span_id`.
- **Governance**: policy IDs evaluated (ASVS/SSDF/STRIDE), eval suites and thresholds.
- **Errors**: typed errors (e.g., `AuthenticationError`, `PolicyViolationError`) with actionable messages.

### CLI & Config Contract (applies to all services)

Run interfaces are standardized to maximize determinism and ease orchestration. All services SHOULD implement these flags and envs:

- Required flags
  - `--dry-run` (boolean; default true in local): perform all validation and emit artifacts with side-effects suppressed.
  - `--idempotency-key <string>`: overrides derived key; required for mutating ops.
  - `--cache-key <string>`: declare cache identity for pure/expensive ops.
  - `--stage <spec|plan|implement|verify|ship|operate|learn>`: lifecycle stage for telemetry/governance.
  - `--risk <trivial|low|medium|high>`: risk class to bind gates/HITL policy.
  - `--ai.provider <name>` `--ai.model <name>` `--ai.version <semver|date>` `--ai.temperature <0..1>` `--ai.top_p <0..1>` `--ai.seed <int>` (when AI is used).
- Optional flags
  - `--inputs <path>` and `--outputs <dir>`: explicit I/O boundaries (schema-validated).
  - `--policy.ruleset <id>` `--policy.version <semver|date>` `--policy.fail-closed`.
  - `--trace` `--trace-parent <trace_id>`: link runs to upstream traces.
- Standard envs
  - `OTEL_EXPORTER_OTLP_ENDPOINT` (default `http://localhost:4318`) and `OTEL_SERVICE_NAME` (auto: `harmony.service.<service>`).
  - `HARMONY_ENV` (`local|preview|prod`) mapped to `deployment.environment`.
  - Provider-specific envs are read only through **Vault**; secrets must never be logged or serialized to run records.

All services MUST print a one-line JSON summary to stdout on success/failure, matching the run-record schema keys `status` and `summary` at minimum.

### Service Implementation Quality Checklist (quick)

- Purpose is a single crisp verb/noun; inputs/outputs documented and schema‑validated.
- AI config pinned (provider/model/version/temperature/top_p/seed when supported); prompt hash recorded.
- Idempotency key derived for mutating ops; cache key declared for pure/expensive ops.
- Policy ruleset selected and recorded; fail‑closed behavior exercised locally (`--dry-run`).
- Observability present: lifecycle/action spans with required attributes; structured logs with `trace_id`/`span_id`.
- Artifacts written to `runs/{timestamp}-{service}-{runId}/` with low‑cardinality names; `artifact.write` span events emitted.
- Typed errors used with exit codes (0–8); one‑line JSON summary printed on failure with actionable message.
- Secrets/PII never serialized; Guard redaction on by default; Vault for secret reads.
- Contracts updated in the service-local schema path (`.harmony/capabilities/services/<domain>/<service>/schema`); registry references refreshed; diffs linked in PR.
- HITL checkpoints encoded when risk ≥ medium; PR body includes risk rubric, flags, rollback, trace URL.

Reference run record (stored under `/runs/<timestamp>-<service>-<runId>.json`):

```json
{
  "runId": "2025-11-07T12-00-01Z-plan-9f2c",
  "service": { "name": "plan", "version": "0.2.0" },
  "inputs": { "goal": "Doc Refresh", "scope": ["/docs"] },
  "ai": {
    "provider": "openai",
    "model": "gpt-4.1",
    "version": "2025-10-01",
    "temperature": 0.2,
    "top_p": 1,
    "seed": 12345
  },
  "artifacts": [
    { "path": "docs_out/changes.md", "type": "markdown" },
    { "path": "runs/eval/summary.json", "type": "report" }
  ],
  "policy": { "checked": ["ASVS-2.1.1", "SSDF-PO.1"], "result": "pass" },
  "eval": { "suite": "basic-docs", "score": 0.94, "threshold": 0.9 },
  "telemetry": {
    "trace_id": "f3a0b1c2d3e4f5a6",
    "spans": ["service.plan.plan", "service.agent.execute"]
  },
  "summary": "Planned and executed doc refresh; eval passed; PR #123 opened.",
  "status": "success"
}
```

### Run Record JSON‑Schema (minimal)

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "ServiceRunRecord",
  "type": "object",
  "required": ["runId", "service", "inputs", "status", "summary", "telemetry"],
  "properties": {
    "runId": { "type": "string" },
    "service": {
      "type": "object",
      "required": ["name", "version"],
      "properties": {
        "name": { "type": "string" },
        "version": { "type": "string" }
      }
    },
    "inputs": { "type": "object" },
    "ai": {
      "type": "object",
      "properties": {
        "provider": { "type": "string" },
        "model": { "type": "string" },
        "version": { "type": "string" },
        "temperature": { "type": "number" },
        "top_p": { "type": "number" },
        "seed": { "type": ["integer", "string"] }
      }
    },
    "artifacts": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["path", "type"],
        "properties": {
          "path": { "type": "string" },
          "type": { "type": "string" }
        }
      }
    },
    "policy": { "type": "object" },
    "eval": {
      "type": "object",
      "properties": {
        "suite": { "type": "string" },
        "score": { "type": "number" },
        "threshold": { "type": "number" }
      }
    },
    "telemetry": {
      "type": "object",
      "required": ["trace_id"],
      "properties": {
        "trace_id": { "type": "string" },
        "spans": { "type": "array", "items": { "type": "string" } }
      }
    },
    "status": { "type": "string", "enum": ["success", "failure"] },
    "summary": { "type": "string" }
  }
}
```

Notes:

- Never store secrets in run records or logs; redact with **Guard** by default.
- Run records must link to Observe traces and PRs where applicable.

### Service Exit Codes & Error Taxonomy (standard v0.2)

Standardize exit codes and error types so CI and governance gates behave deterministically. Services MUST return one of the following exit codes and include a one-line JSON summary (`status`, `summary`) on stdout; details go to run records and Observe.

- 0: Success (`status=success`)
- 1: Generic failure (unexpected)
- 2: Policy violation (`PolicyViolationError`)
- 3: Evaluation/test failure (`EvaluationFailureError`)
- 4: Guard/redaction failure or prohibited secret detected (`GuardViolationError`)
- 5: Invalid inputs/schema (`InputValidationError`)
- 6: Provider/integration error (e.g., AI/HTTP/IO) (`UpstreamProviderError`)
- 7: Idempotency conflict (`IdempotencyConflictError`)
- 8: Cache integrity error (`CacheIntegrityError`)

Typed errors MUST:

- Extend `Error`, set `name`, and include a `code` matching the exit code
- Provide structured context (no secrets/PII) and Suggested Action text
- Log as structured error with `error.type`, `error.code`, `error.message`, `trace_id`, `span_id`

Example JSON summary (stdout):

```json
{"status":"failure","summary":"Policy blocked: ASVS-2.1.1 unmet; see run record."}
```

Example structured error log (pino-like):

```json
{"level":"error","msg":"Policy violation","error.type":"PolicyViolationError","error.code":2,"policy.ruleset":"ASVS@5.0","policy.checked":["ASVS-2.1.1"],"policy.result":"fail","trace_id":"<id>","span_id":"<id>"}
```

#### HTTP mapping (for API/Route wrappers)

When exposing service invocations via HTTP (Route Handlers, API routes), map exit codes to HTTP statuses:

- `0` → 200 OK
- `1` → 500 Internal Server Error
- `2` → 403 Forbidden (policy blocked) or 422 Unprocessable Entity when gate failures are user‑correctable
- `3` → 422 Unprocessable Entity (evaluation/test failed)
- `4` → 400 Bad Request (guard/redaction violation)
- `5` → 400 Bad Request (input/schema invalid)
- `6` → 502 Bad Gateway (upstream/provider failure)
- `7` → 409 Conflict (idempotency conflict)
- `8` → 500 Internal Server Error (cache integrity)

---

## Service Metadata Standard (v0.2)

Define service‑level metadata to make responsibilities, governance, and observability explicit and machine‑readable.

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "ServiceMetadata",
  "type": "object",
  "required": [
    "name",
    "version",
    "pillars",
    "lifecycleStages",
    "inputsSchema",
    "outputsSchema",
    "observability",
    "determinism",
    "safety",
    "idempotency"
  ],
  "properties": {
    "name": { "type": "string" },
    "version": { "type": "string" },
    "description": { "type": "string" },
    "pillars": {
      "type": "array",
      "items": { "enum": [
        "speed_with_safety",
        "simplicity_over_complexity",
        "quality_through_determinism",
        "guided_agentic_autonomy"
      ]}
    },
    "lifecycleStages": {
      "type": "array",
      "items": { "enum": [
        "spec",
        "plan",
        "implement",
        "verify",
        "ship",
        "operate",
        "learn"
      ]}
    },
    "inputsSchema": { "type": "string" },
    "outputsSchema": { "type": "string" },
    "policy": {
      "type": "object",
      "properties": {
        "rules": { "type": "array", "items": { "type": "string" } },
        "rulesetVersion": { "type": "string" },
        "failClosed": { "type": "boolean" }
      }
    },
    "observability": {
      "type": "object",
      "required": ["serviceName", "requiredSpans", "logRedaction"],
      "properties": {
        "serviceName": { "type": "string" },
        "requiredSpans": { "type": "array", "items": { "type": "string" } },
        "logRedaction": { "type": "boolean" }
      }
    },
    "determinism": {
      "type": "object",
      "properties": {
        "ai": {
          "type": "object",
          "properties": {
            "provider": { "type": "string" },
            "model": { "type": "string" },
            "temperatureMax": { "type": "number" },
            "supportsSeed": { "type": "boolean" },
            "promptHashAlgorithm": { "type": "string" }
          }
        },
        "artifactNaming": { "type": "string" }
      }
    },
    "safety": {
      "type": "object",
      "properties": {
        "hitl": { "type": "object", "properties": { "requiredFor": { "type": "array", "items": { "enum": ["medium", "high"] } } } }
      }
    },
    "idempotency": {
      "type": "object",
      "properties": {
        "required": { "type": "boolean" },
        "idempotencyKeyFrom": { "type": "array", "items": { "type": "string" } }
      }
    },
    "compatibility": {
      "type": "object",
      "properties": {
        "contracts": { "type": "array", "items": { "type": "string" } },
        "services": { "type": "array", "items": { "type": "string" } },
        "breakingChangePolicy": { "type": "string" },
        "deprecatedSince": { "type": "string" }
      }
    },
    "dryRun": { "type": "object", "properties": { "supported": { "type": "boolean" } } }
  }
}
```

Example metadata:

```json
{
  "name": "plan",
  "version": "0.2.0",
  "pillars": ["speed_with_safety", "quality_through_determinism"],
  "lifecycleStages": ["plan", "implement"],
  "inputsSchema": "schema/plan.inputs.json",
  "outputsSchema": "schema/plan.outputs.json",
  "policy": { "rules": ["ASVS-2.1.1", "SSDF-PO.1"], "rulesetVersion": "2025-11-01", "failClosed": true },
  "observability": {
    "serviceName": "harmony.service.plan",
    "requiredSpans": ["service.plan.plan"],
    "logRedaction": true
  },
  "determinism": {
    "ai": { "provider": "openai", "model": "gpt-4.1", "temperatureMax": 0.3, "supportsSeed": true, "promptHashAlgorithm": "sha256" },
    "artifactNaming": "runs/{timestamp}-{service}-{runId}/"
  },
  "safety": { "hitl": { "requiredFor": ["medium", "high"] } },
  "idempotency": { "required": true, "idempotencyKeyFrom": ["inputs.goal", "git.sha"] },
  "compatibility": {
    "contracts": ["plan.inputs.v1", "plan.outputs.v1"],
    "services": ["agent@>=0.2.0"],
    "breakingChangePolicy": "semver-major-only"
  },
  "dryRun": { "supported": true }
}
```

### Run Record JSON‑Schema (standard v0.2)

Extends the minimal schema with lifecycle metadata, HITL checkpoints, and determinism fields.

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "ServiceRunRecordV0_2",
  "type": "object",
  "required": ["runId", "service", "inputs", "status", "summary", "telemetry", "stage", "risk"],
  "properties": {
    "runId": { "type": "string" },
    "service": { "$ref": "#/definitions/ServiceRef" },
    "inputs": { "type": "object" },
    "ai": { "type": "object" },
    "artifacts": { "type": "array" },
    "policy": { "type": "object" },
    "eval": { "type": "object" },
    "telemetry": { "type": "object" },
    "status": { "type": "string", "enum": ["success", "failure"] },
    "summary": { "type": "string" },
    "stage": { "type": "string", "enum": ["spec", "plan", "implement", "verify", "ship", "operate", "learn"] },
    "risk": { "type": "string", "enum": ["trivial", "low", "medium", "high"] },
    "hitl": {
      "type": "object",
      "properties": {
        "checkpoint": { "type": "string" },
        "approver": { "type": "string" },
        "approvedAt": { "type": "string" }
      }
    },
    "determinism": {
      "type": "object",
      "properties": {
        "prompt_hash": { "type": "string" },
        "idempotencyKey": { "type": "string" },
        "cacheKey": { "type": "string" }
      }
    }
  },
  "definitions": {
    "ServiceRef": {
      "type": "object",
      "required": ["name", "version"],
      "properties": {
        "name": { "type": "string" },
        "version": { "type": "string" }
      }
    }
  }
}
```

#### Run ID Format (recommended)

- Use a stable, low‑cardinality identifier to correlate artifacts, spans, and PRs without leaking sensitive data:
  - `runId = <ISO8601-UTC-with-dashes>Z-<serviceName>-<short-stable-id>`
  - Example: `2025-11-07T12-00-01Z-plan-9f2c`
- The short ID should be derived from stable inputs (e.g., git SHA fragment + inputs hash), not timestamps alone. Do not include PII or secrets in `runId`.

## Contracts Registry & Schema Conventions (Harmonized)

Centralize all service contracts in a single registry to keep interfaces deterministic and discoverable.

- Location: `.harmony/capabilities/services`
  - OpenAPI: service-specific files as needed in each service folder.
  - JSON Schemas (services): `.harmony/capabilities/services/<domain>/<service>/schema/`
    - Naming: `input.schema.json` and `output.schema.json`.
    - Draft: JSON Schema 2020‑12.
- Versioning:
  - Breaking contract changes → bump MAJOR and provide migration notes; backward‑compatible additions → bump MINOR.
  - Each service's metadata (`inputsSchema`, `outputsSchema`) MUST reference the current versioned files.
- CI/Governance:
  - OpenAPI diffs are required (oasdiff) for API‑touching changes.
  - JSON‑Schema changes SHOULD include a schema diff summary and updated tests/goldens.
  - Patch PRs MUST link the contract diffs when a service interface changes.
- Registry exports: update `.harmony/capabilities/services/registry.yml` (or service-local docs) to expose new or updated contracts to consumers.

This registry is the single source of truth for inter‑service interfaces and aligns with Harmony's spec‑first, contract‑driven flow.

Interoperability promise:

- Services depend only on normative contracts in `.harmony/capabilities/services/**/schema` and respect semantic versioning boundaries. Breaking changes require a MAJOR bump with migration notes; MINOR additions must be backward-compatible. Cross‑service integration tests (via Test/Pact/Schemathesis where applicable) verify forward/backward compatibility. Use service metadata `compatibility` and `deprecatedSince` fields to signal support windows and orchestrate safe upgrades.

## Deterministic Operation Policy (Agents & Tools)

These defaults make outputs reproducible and reviewable:

1. **Pin AI config**: provider/model/version; temperature ≤ 0.3; prefer deterministic decoding; record `seed` when supported.
2. **Schema‑guarded outputs**: validate material outputs against JSON‑Schema or contract tests; add golden tests for critical prompts.
3. **Fail closed**: policy/eval/test failures block **Patch**; explain deviations in PR with navigator approval.
4. **License/provenance**: include Dependency Review note; avoid new deps unless they materially reduce complexity.
5. **Explainability**: attach Observe trace URL + Eval run IDs to PRs; include risk class and rollback/flag plan.

### Local‑First & Privacy‑First Defaults

- Run services locally by default; prefer on‑device or self‑hosted providers where feasible. Never require internet access for dry‑runs, planning, or schema validation.
- Redact by default via **Guard**; disallow secrets in prompts, artifacts, and logs. Route all secret access through **Vault**.
- Enforce idempotency on mutating ops (idempotency keys); require `--dry-run` for any file or network changes when running locally.
- When remote AI is required, pin region and model; record provider/model/version/params in the run record; fail closed on provider errors.

### Deterministic Prompts & Artifact Naming

- Prompt hashing (when AI used):
  - `prompt_hash = sha256(canonicalize(system_prompt, user_prompt, inputs_without_secrets))`
  - Canonicalize by JSON‑stringifying with sorted keys; omit secrets or replace with stable placeholders.
  - `inputs_without_secrets` MUST exclude tokens/keys and any user data classified as sensitive; replace with stable placeholders (e.g., `<REDACTED:EMAIL>`), and record the redaction strategy in the run record `determinism.prompt_hash` notes when needed.
- Artifact and directory naming:
  - Directory: `runs/{timestamp}-{service}-{runId}/`
  - Files: include `{stage}-{artifactKind}-{stableName}.{ext}`; avoid high‑cardinality filenames.
- Idempotency keys:
  - Derive from stable inputs + git SHA + stage (e.g., `sha256(plan.inputs + git.sha + stage)`), persisted in `determinism.idempotencyKey`.
- Cache keys:
  - Pure operations declare a `cacheKey` based on content hash of inputs; do not include timestamps or non‑deterministic values.

#### Cache TTL & Validity Policy

- Default TTLs (guidelines):
  - Pure network fetches with low volatility: 15 minutes.
  - Derived indexes/stores (content‑addressed): no TTL; invalidate on content hash change.
  - Provider metadata (models/prices): 24 hours unless otherwise specified.
- Invalidation triggers:
  - Content hash or contract version bump; policy ruleset version change; environment change (`HARMONY_ENV`).
  - Explicit `--cache-bust` or `CACHEKIT_BUST=1` for emergency invalidation.
- Safety:
  - Cache integrity failures MUST raise `CacheIntegrityError` (exit code 8) and block in CI.
  - Never cache secrets/PII; cache entries MUST exclude sensitive data or use stable placeholders.
- Determinism:
  - TTLs must not leak into artifact names or outputs; only keys/metadata control validity.
  - Record `determinism.cacheKey` and (when applicable) `cache.ttl` in the run record.

### PR‑Ready Determinism Checklist

- [ ] AI configuration pinned and recorded (provider, model, version, temperature/top_p, max_tokens, seed if supported; include a stable prompt hash if full prompt cannot be stored).
- [ ] Inputs and outputs validated against JSON‑Schema or contracts; golden tests updated when material outputs change.
- [ ] Idempotency keys used on all mutating operations; cache keys declared for expensive pure operations.
- [ ] Local `--dry-run` available and exercised for any file/network side‑effects; fail‑closed on policy/eval/test errors.
- [ ] Observe spans/logs present with `trace_id` linked in the PR; errors include structured metadata without secrets.
- [ ] Policy/Test/Eval outcomes attached (or linked) in the PR; license/provenance note included.
- [ ] Human‑in‑the‑loop approvals recorded per risk class; feature behind a flag by default.

---

## Simplicity & Scalability Rules

Keep the platform lean and scalable for tiny teams:

- Prefer platform capabilities (Vercel envs/headers/cron, Edge Config flags) over new dependencies.
- Monolith-first (Turborepo) with clear ports/adapters; split only when SLOs or ownership boundaries truly require it.
- One small change per PR; feature‑flag risky behavior; preview e2e smoke before merge (recommended).
- Avoid client‑side secrets; evaluate flags server‑side; redact logs by default; block promotions on secret scan failures.
- Maintain a small debt ledger and a hard WIP policy per Harmony; protect flow and reverse quickly when needed.

### Adoption Tiers (simplicity‑first)

- Core (Day 1): Doc + Query + Index; Patch + Notify; Observe + Cache.
- Plus (Day 30): Guard + Policy + Eval; Flag; Schedule.
- Advanced (Day 60+): Test contracts (Pact/Schemathesis), CodeMod, Bench, Compliance evidence packs.

### Service Versioning & Release Policy

- Services follow Semantic Versioning (`MAJOR.MINOR.PATCH`). The `service.version` in run records must reflect the released version.
- Backward‑compatible changes to inputs/outputs increment MINOR; breaking contract changes increment MAJOR and must include migration notes and updated schemas.
- Each service maintains `schema/` for inputs/outputs and a `CHANGELOG.md` summarizing notable changes and required actions.
- PRs that modify a service must update its version, schemas, and documentation, and include OpenAPI/JSON‑Schema diffs where contracts are affected.
- Compliance assembles evidence linking service versions to PRs/releases to support audits and postmortems.

#### Deprecation & Compatibility

- Declare deprecations in service metadata (`compatibility.deprecatedSince`) and document support windows. Provide an upgrade path and migration notes for every MAJOR bump.
- Use `compatibility.contracts` and `compatibility.services` to state interoperable versions; CI should verify matrices for critical cross‑service pairs (e.g., Plan ↔ Agent).
- Avoid churn: prefer additive MINOR changes; batch breaking changes behind a single MAJOR with clear migration steps.

---

## What to Build First (90/10 impact)

1. **Doc + Query + Index** → instant doc quality w/ citations.
2. **Eval (basic)** → structure/style/links/hallucination checks.
3. **Patch + Notify** → painless approvals and shipping (PR previews on Vercel).
4. **Observe + Cache** → debuggability and speed; add OTel hooks early.
5. Add **Search** (external docs) and **Guard** (redaction) next.
6. Then **Dev** (code) and **CodeMod** (safe refactors) with **Cursor**.
7. Finally **Stack** + **Scaffold** to productize architecture decisions (Turborepo + monolith-first + hexagonal).

---

## Quick Summary of Roles

| Service      | Focus                       | Example Output             |
| ------------ | --------------------------- | -------------------------- |
| Doc          | Docs improvement            | Markdown diffs, changelog  |
| Dev          | Code-level assistance       | Refactors, tests, comments |
| Stack        | Architecture & stack        | `stack.yml`, ADRs          |
| Plan         | Plans (bmad)                | `plan.json`                |
| Spec         | Spec-first + ADR            | Specs, ADRs                |
| Agent        | Execute plans               | Artifacts, run logs        |
| Tool         | Action wrappers             | Shell/Git/HTTP actions     |
| Ingest       | Normalize                   | `ingest/*.jsonl`           |
| Search       | External sources            | Fetched docs/evidence      |
| Index        | Build stores                | `indexes/*`                |
| Query        | Answers + evidence          | Citations, evidence pack   |
| Prompt       | Prompts                     | Templates                  |
| Parse        | PDF parsing to Markdown     | Markdown files             |
| Test         | Tests & contracts           | Reports, PR checks         |
| Eval         | Verification                | Reports, PR checks         |
| Policy       | Guardrails                  | Policy YAML outcomes       |
| Compliance   | Standards & evidence        | Coverage reports           |
| Guard        | Safety/PII                  | Redacted logs              |
| Headers      | Security headers/CSP        | CSP/headers config         |
| Cache        | Memoization/artifacts       | Cached runs                |
| Observe      | Telemetry & artifacts       | Traces, logs               |
| Patch        | PRs & changelog             | PRs, RELEASE notes         |
| Schedule     | Cadence                     | Job runs                   |
| Notify       | Approvals                   | Slack/email summaries      |
| CodeMod      | AST codemods                | Diffs, migration reports   |
| Scaffold     | Project/feature skeletons   | New service repos          |
| Diagram      | Diagrams                    | .mmd/.puml/.svg            |
| Dep          | Dependency mgmt             | Upgrade PRs                |
| Bench        | Performance                 | Benchmark deltas           |
| Dataset      | Goldens for RAG/eval        | `datasets/*.jsonl`         |
| Model        | Model policy                | `models.yml`               |
| Release      | Releases                    | CHANGELOG, GitHub release  |
| Migration    | Schema/data migrations      | Migrations, reports        |
| Flag         | Feature flags               | Flags, rollout plans       |
| i18n         | Localization                | Locale files               |
| UI           | Review UI                   | Approvals/search UI        |
| Seed         | Fixtures                    | Seeds/data                 |
| Vault        | Secrets                     | Masked env                 |

---

## Observe: OTel, DORA/SLOs, and Required Telemetry

Standardize instrumentation across all services:

- **Service identity**: `service.name = "harmony.service.<serviceName>"`; `service.version` from git SHA or package version; `deployment.environment` set (e.g., `local`, `preview`, `prod`).
- **Span names**: `service.<service>.<action>` (e.g., `service.eval.verify`, `service.patch.open_pr`).
- **Required span attributes**:
  - `service.name`, `service.version`, `run.id`, `git.sha`, `repo`, `branch`
  - If AI used: `ai.provider`, `ai.model`, `ai.version`, `ai.temperature`, `ai.top_p`, `ai.seed`
  - Policy/Eval: `policy.ruleset`, `policy.result`, `eval.suite`, `eval.score`, `eval.threshold`
- **Structured logs**: include `trace_id`, `span_id`, severity, and summary; default redaction via Guard; never log PII/PHI.
- **DORA metrics mapping** (computed by Observe or downstream analytics):
  - Lead time: PR opened → merged (from Vercel/GitHub events)
  - Deploy frequency: merges promoted to prod
  - Change‑fail rate: rollbacks/promote‑back events or hotfix tags
  - MTTR: incident opened → resolved timestamps
- **SLO guardrails**: surface burn‑rate alerts; **Policy** may block promotions if budgets exceed thresholds.

Implementation notes:

- Bootstrap OTel from `infra/otel/instrumentation.ts` (defaults to `http://localhost:4318`; override with `OTEL_EXPORTER_OTLP_ENDPOINT`).
- Treat Observe as the single pane for traces/logs/metrics; compute DORA from PR/platform events correlated by `trace_id` and git SHA.
- See Appendices C for starter SLO templates and cardinality guardrails.

### Required Resource Attributes & Log Fields (standard v0.2)

All services MUST set these OpenTelemetry Resource attributes and log fields to enable consistent correlation, DORA, and governance:

- Resource (set once per process):
  - `service.name = "harmony.service.<serviceName>"`
  - `service.version = <semver|git-sha>`
  - `deployment.environment = <local|preview|prod>`
  - `telemetry.distro.name = "observe"` (optional), `telemetry.distro.version`
  - `harmony.repo`, `harmony.branch`

- Span attributes (on lifecycle/action spans):
  - `run.id`, `service.name`, `service.version`, `stage`, `git.sha`, `repo`, `branch`
  - If AI used: `ai.provider`, `ai.model`, `ai.version`, `ai.temperature`, `ai.top_p`, `ai.seed`, `prompt_hash`
  - Policy/Eval/Test: `policy.ruleset`, `policy.result`, `eval.suite`, `eval.score`, `eval.threshold`

- Structured log shape (pino-like recommended):

```json
{
  "level": "info",
  "msg": "artifact written",
  "trace_id": "<id>",
  "span_id": "<id>",
  "service": {"name": "plan", "version": "0.2.0"},
  "run": {"id": "2025-11-07T12-00-01Z-plan-9f2c"},
  "artifact": {"path": "runs/…/verify-report.json", "type": "report"}
}
```

Sampling policy:

- Head-based sampling for low traffic; tail-based (or always-on) for long traces or high-value flows
- Never drop error spans; prefer sampling decisions at the root span
- Keep attribute cardinality bounded; prefer IDs/enums over free text

### Span Map & Cardinality Guardrails

Canonical spans (minimum):

- `service.spec.specify` → `service.plan.plan` → `service.agent.execute` → `service.tool.call.<action>` →
  `service.eval.verify` → `service.policy.check` → `service.patch.open_pr` → (`service.release.tag`)

Guardrails:

- Keep attribute cardinality bounded; prefer enums/IDs over free‑text.
- Always include `run.id`, `service.name`, `service.version`, `stage`, `git.sha`, `repo`, `branch`.
- Log errors with a typed `error.type` and `error.message` (no secrets/PII); attach `trace_id`.
- Derive `prompt_hash` once per run (if AI used); attach it as an attribute to the parent span only.
- Sampling: head‑based for low‑traffic; tail‑based for long traces; never drop error spans.

#### Span Event Semantics (recommended)

Emit low-cardinality span events on the active lifecycle span to improve explainability without inflating attributes:

- `artifact.write` with `{ path, kind }` when material artifacts are produced.
- `policy.fail` with `{ ruleset, id }` for each violated rule; pair with an error log.
- `eval.fail` with `{ suite, score, threshold }` on evaluation failure.
- `gate.block` / `gate.pass` with `{ gate, reason }` when CI/policy gates block or pass.
- `hitl.requested` / `hitl.approved` / `hitl.rejected` / `hitl.waived` with `{ checkpoint, approver }`.
- `flag.toggle` with `{ flag, from, to }` when **Flag** changes rollout state.

#### Offline/Local‑First Telemetry Mode

To preserve local‑first operation and determinism without network access:

- When `--dry-run` is true or `OTEL_EXPORTER_OTLP_ENDPOINT` is unreachable, Observe SHOULD buffer telemetry to disk and defer export.
- Buffer file (NDJSON): `runs/{timestamp}-{service}-{runId}/otel-buffer.ndjson` containing spans and logs with `trace_id`/`span_id`.
- Flushing rules:
  - Auto‑flush on `service.observe.flush` span end (best‑effort).
  - Manual flush allowed via a CLI mode or a service‑provided utility that replays buffered spans to the configured OTLP endpoint.
- Redaction still applies to buffered logs; never include secrets/PII.
- Include a buffered‑export summary event on the parent lifecycle span (when later flushed) to keep provenance intact.

### Sensitive Data Classes & Redaction Policy (standard v0.2)

- Data classes (enumerated):
  - SECRET (API tokens/keys, credentials), AUTH (session/cookies), PII (names, emails, addresses), KEY_MATERIAL (encryption keys), PAYMENT (non‑PCI tokens only), HEALTH (HIPAA‑like), OTHER_SENSITIVE (free‑text classified by policy).
- Redaction:
  - Never serialize sensitive values in run records, logs, or artifacts. Replace with `<REDACTED:<CLASS>>` placeholders.
  - Guard performs redaction at log/write boundaries; Observe assumes inputs are pre‑redacted.
- Disallowed:
  - Secrets in prompts, artifacts, or span attributes. Do not include PII in `trace_id`/`span_id` or filenames.
- Provenance:
  - When redaction occurs, add `redaction=true` to logs and emit a `artifact.write` or `error` event with context (no secrets).
- Validation:
  - Policy MAY enforce evidence of redaction for medium/high risk changes; CI should block on detected leaks.

### Common Failure Modes & Fixes (operational)

- Missing spans/logs:
  - Ensure each service calls its `observability` bootstrap and sets required resource attributes; verify `service.<service>.<action>` spans appear with `run.id`.
- Policy blocks with "missing evidence":
  - Attach links to Eval/Test outputs and run records; ensure `policy.checked[]` IDs are present in the run record and span attributes.
- Idempotency conflicts (exit 7):
  - Provide a stable `--idempotency-key`; avoid reusing keys across different inputs or stages.
- Cache integrity errors (exit 8):
  - Regenerate caches, verify keys don’t include timestamps, and avoid caching sensitive data.
- Secrets in outputs/logs:
  - Route secret access through **Vault**; enable Guard redaction at write/log boundaries; scrub artifacts and re‑run with `--dry-run`.
- Preview gate failures:
  - Run fast smoke (`scripts/smoke-check.sh`), fix contract/test drift, and verify feature is behind a flag with a rollback plan.

---

## Who Calls What

- **Plan** calls **Agent** with a plan (from **Spec**), recording a run and opening a trace.
- **Agent** calls **Tool** wrappers and leverages **Cache** for idempotency and memoization.
- **Doc/Dev/Stack** call **Query** for grounding; **Query** reads **Index** stores; **Index** builds from **Ingest**, which ingests from **Search**.
- **Parse** converts raw PDFs into Markdown artifacts that feed **Ingest** and downstream indexing/query workflows.
- **Eval**, **Test**, **Policy**, and **Compliance** gate outputs and **Patch** PRs; **Compliance** assembles evidence and links Observe traces; **Headers** and **A11y** contribute checks.
- **Release** coordinates with **Flag** for progressive delivery and rollback; flags via **Vercel Flags** (Edge Config).
- **Search** feeds **Ingest** with external content.
- **Diagram**, **Bench**, **Dep**, **Migration**, **i18n** hang off the main flows as needed.
- **Schedule** triggers **Plan → Agent**; **Notify** informs humans; **Observe** records everything; **Guard/Vault** enforce redaction and secret hygiene.

Notes:

- Prefer non‑blocking side‑effects using Next.js `next/after` or platform jobs where applicable. Long‑running work should run off the critical path and be traced.
- Feature flags provider registration: register the Vercel Flags provider at app startup (API and SSR surfaces) via the repo’s flag config (e.g., `packages/config/flags.ts`) and evaluate flags server‑side. Local/dev may fall back to `HARMONY_FLAG_*` envs.

---

## Ports & Adapters (Hexagonal) Conventions (Harmonized)

Keep domain logic isolated from infrastructure and UI, and freeze boundaries with contracts/tests:

- Ports (interfaces) live in `packages/domain` and describe capabilities (e.g., `UserRepository`, `PaymentService`).
- Adapters live in `packages/adapters` and implement ports (e.g., `DatabaseUserRepository`, `HttpPaymentService`).
- Contracts live alongside services under `.harmony/capabilities/services/<domain>/<service>/schema` (OpenAPI + JSON‑Schema where applicable).
- Naming (alignment with Harmony):
  - Interfaces: `PascalCase` (e.g., `UserRepository`).
  - Implementations: descriptive prefix/suffix (e.g., `DatabaseUserRepository`, `InMemoryUserRepository`).
  - DTOs: `PascalCase` with `DTO` suffix and context (e.g., `CreateUserDTO`).
- Tests:
  - Pact for adapter contracts (consumer/provider), Schemathesis for OpenAPI (property‑based), unit tests for domain logic.
  - Place adapter contract tests adjacent to adapters; keep service contract references under `.harmony/capabilities/services/**/schema`.
- CI gates:
  - Contract diffs (oasdiff) fail‑closed on breaking changes; service schema diffs accompany PRs that touch inter‑service interfaces.

This convention ensures services compose cleanly around stable, testable ports, improving determinism and maintainability.

## ASCII Overview

```mermaid
[Schedule] ─► [Plan] ─► [Agent] ─► [Tool] ─┬─► Doc
                                             ├─► Dev ─┬─► CodeMod
                                             ├─► Stack ─► Scaffold ─► Diagram
                                             ├─► Patch ─► Release
                                             └─► Eval, Policy & Compliance (gates)
Search ─► Ingest ─► Index ◄─ Query ◄────────────┘
Observe (traces) • Guard/Vault (safety) • Notify (HITL) • Cost/Model (routing)
```

---

If you want, I can generate a **starter repo** scaffold with the directory layout, stubbed CLI commands, and minimal JSON schemas so you can run a full “Doc Refresh → PR” flow on day one.
