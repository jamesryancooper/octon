# Documentation Standards Guide

Here’s a **minimal set of docs** you’ll need for any future component/feature, with crisp purposes, “why this fits” (backed by Harmony), ultra-lean templates, and a simple “how they work together.”

---

## 1) Spec One-Pager (with a linked ADR) — *the technical overview*

**Purpose**
Crisply explain *what* we’re building and the key constraints so anyone can grasp scope and shape at a glance.

**Why this fits**
Harmony is explicitly **spec-first**: every meaningful change starts with a **specification one-pager + ADR** that captures problem, scope, contracts, non-functionals, and a **micro-STRIDE** mapped to **ASVS/SSDF**.

**Ultra-lean template (≤1 page):**

- **Problem & Outcome** (one paragraph)
- **Scope**: Must / Defer
- **Interfaces**: links to **OpenAPI + JSON-Schema** contracts
- **I/O & Artifacts (if applicable)**: key inputs/outputs and any on-disk artifacts with `schema_version`
- **Non-functionals**: SLIs/SLOs & perf budgets
- **Risks (STRIDE) & mitigations** (bulleted)
- **Architecture sketch**: ports & adapters / boundaries
- **Out of scope**
- **Decision(s) & link to ADR** (status, consequences)

---

## 1a) ADR (lightweight) — *the decision record*

**Purpose**
Record a consequential technical decision, its context, and trade-offs.

**Why this fits**
Harmony expects ADRs alongside the spec; they close the loop during “Learn” and guard future reversals.

**Ultra-lean template (½ page):**

- **Context** (constraints, drivers)
- **Decision** (what/where it applies)
- **Consequences** (trade-offs, follow-ups, reversal trigger)
- **Status** (Proposed | Accepted | Superseded by ADR-X)

---

## 2) Feature Story (execution plan) + Contracts — *the development guide*

**Purpose**
Turn the Spec into a small, concrete plan with acceptance criteria and tests—optimized for tiny, safe PRs behind flags.

**Why this fits**
Harmony prescribes converting the Spec into a **feature story** (context packets + agent plan + acceptance criteria) and shipping via tiny PRs, previews, feature flags, and **CI gates**.  

**Ultra-lean template (2–3 pages max):**

- **Context packets**: domain notes, examples, constraints
- **Agent plan**: ordered steps/files to touch; smallest viable diffs
- **Contracts**: link **OpenAPI/JSON-Schema** (+ Pact if used)
- **Artifacts** (if applicable): build reproducible snapshots/manifests; optional publish step
- **Acceptance criteria**: observable behaviors tied to contracts
- **Test plan**: unit + contract (negative cases from STRIDE) + smoke on Preview
- **Rollout**: feature flag name, initial audience, rollback plan
- **Definition of Done**: all required gates green (lint, typecheck, unit, contract diff, static scan, deps/license, secrets, SBOM, perf/bundles), preview smoke OK, docs updated.

---

## 3) Contracts (OpenAPI & JSON-Schema) — *the source of truth*

**Purpose**
Freeze boundaries at ports (API/UI/events) so teams can build independently and CI can stop breaking changes.

**Why this fits**
Harmony treats **contracts** as first-class and enforces **OpenAPI diff (oasdiff)** in CI; contract tests at ports (Hexagonal) are a core guardrail.  

**Ultra-lean template:**

- **OpenAPI**: only the operations in scope; examples required
- **JSON-Schema**: one file per payload/event; examples + negative cases
- **CI**: enable **oasdiff** + schema validation; add Pact if consumer/provider exists.

If your component emits on-disk artifacts (JSON/JSONL/manifests), also define JSON Schemas for those artifacts, include a `schema_version`, and document them in the Component Guide.

> **Repo hint:** keep these in `packages/contracts/` and link them from the Spec/Plan flow.

---

## 4) Component / Developer Guide — *the reference for a subsystem*

**Purpose**
Explain how to use/configure a component (modes, inputs/outputs, artifacts), with contracts, examples, and troubleshooting.

**Why this fits**
Harmony favors **flow over ceremony**: central specs + contracts, while detailed component usage lives in a focused **dev guide** that downstream features link to. (Your `indexkit/guide.md` already follows this pattern with contracts, emitted artifacts, and example configs.)  

**Ultra-lean template:**

- **Quick Snapshot**: modes/variants • capabilities (e.g., signals) • inputs/outputs • artifacts • optional publish/serve
- **What It Does**: primary responsibilities in brief
- **Wins**: key benefits for users/teams
- **Opinionated implementation choices**: libraries/engines/formats and rationale; link ADR for org‑wide/high‑impact choices
- **Core Responsibilities**: what it owns and guarantees
- **Ecosystem Integrations**: upstreams/downstreams in the AI toolkit
- **Operating Modes / Usage Recipes**: when to choose which mode
- **Signals/Capabilities (optional)**: feature toggles/signals and validation
- **I/O & Contracts**: link OpenAPI/JSON‑Schema; summarize inputs/outputs
- **Artifacts & Layout**: file formats, schema_version, and example tree
- **Versioning & Compatibility**: artifact schema semver, breaking-change policy, down‑conversion notes
- **Configuration & Tuning**: minimal and advanced knobs (JSON/YAML)
- **Sizing & Capacity (optional)**: typical sizes, CPU/RAM guidance, perf tips
- **Adapters (optional)**: in-memory/off-disk adapters and runtime knobs
- **Publishing/Serving (optional)**: DB adapters or serving backends
- **Validation & Health**: drift checks, parity checks, health probes
- **Observability (optional)**: logs/metrics/traces to emit; ObservaKit/EvalKit hooks
- **Harmony Alignment**: spec‑first, auditability, security, modular flow (link to ../methodology/README.md)
- **Why Teams Choose `<component-name>`**: concise value proposition
- **Minimal Interfaces**: copy‑paste config/function stubs
- **Contracts & Schemas**: artifact schemas and `schema_version` notes
- **Troubleshooting + Common Questions**: top issues and FAQs

---

## 5) Operations Runbook (1 page) — *how we run, roll back, and recover*

**Purpose**
Give on-call a quick path to validate, roll back, and fix.

**Why this fits**
Harmony’s reliability guardrails expect **SLOs, error-budget policy**, **preview-based rollbacks** (“promote a known-good preview”), and a lean incident flow.  

**Ultra-lean template:**

- **SLOs & alerts** (burn-rate thresholds, dashboards)
- **Validate** (preview smoke checklist for the feature)
- **Rollback** (exact command: `vercel promote <deployment-url>`)
- **Artifacts/Snapshots (if applicable)**: how to rebuild/promote or republish artifacts safely
- **Run / Repair** (common issues & fixes; links to component guide)
- **Postmortem** (blameless template link)

---

## How to use them together (and stay simple)

1. **Start with the Spec One-Pager**
   Write the spec + ADR, including contracts, non-functionals, and **STRIDE** with tests you’ll add. Keep scope tight (Must/Defer).

2. **Transform into the Feature Story**
   Add context packets, the agent plan (tiny diffs), acceptance criteria, and link the **contracts**. Keep PRs tiny, always behind a **feature flag**.

3. **Lean on Contracts as truth**
   Build to OpenAPI/JSON-Schema; let CI stop breaking changes with **oasdiff** and contract tests at hexagonal boundaries.  

4. **Use the Component/Developer Guide for depth**
   Don’t bloat the Spec—link to the component guide for configuration, artifacts, and troubleshooting (e.g., your `indexkit/guide.md`).

5. **Ship via flags, previews, and gates**
   Each PR gets a **Preview URL**; run smoke, then merge only when **required gates** (lint, typecheck, unit, contract, static, deps/license, secrets, SBOM, perf/bundles) are green. Release by enabling the flag gradually; **rollback** by promoting a prior preview.

6. **Operate to SLOs; learn via ADR updates**
   Alert on burn-rate, page sparingly, do blameless postmortems, and update ADRs when lessons change course.  

---

## Suggested repo locations (ready now)

- `docs/specs/<feature>/spec.md`, `docs/specs/<feature>/adr-<id>.md`, `docs/specs/<feature>/bmad-story.md`
- `packages/contracts/` (OpenAPI + JSON-Schema + Pact)
- `docs/components/<component>/guide.md` (dev guide)
- `docs/runbooks/<feature>.md` (runbook)

If you want, I can drop **filled-in Markdown stubs** for all five into your repo structure (matching the templates already in the canvas) and wire example OpenAPI/Schema placeholders so CI gates (oasdiff, contract tests) can be turned on immediately.

---

## Using the Starter Docs Stub Template

Use the ready-to-rename docs stubs starter bundle with all five docs, contracts, and placeholders wired up. The template lives at `docs/documentation-standards/template`.

### What’s inside (template structure)

Braces `{{ }}` indicate where you should rename with your real feature or component names.

```text
/docs/
  /specs/{{feature-name}}/
    spec.md
    adr-0001.md
    bmad-story.md
  /components/{{component-name}}/
    guide.md
  /runbooks/
    {{feature-name}}.md
/packages/
  /contracts/
    openapi.yaml
    README.md
    /schemas/
      {{feature-name}}.schema.json
README.md
```

### How to use

1. Rename `{{feature-name}}` / `{{component-name}}` to your real names.
2. Open `spec.md` first; use the template as guidance to create a new `spec.md` by filling out Problem/Outcome, Scope, Risks, and linking any real wireframes.
3. Create contracts in `packages/contracts/` to match your API/events using the template as guidance.
4. Fill `bmad-story.md` with your small, ordered Agent Plan and acceptance criteria using the template as guidance.
5. Use `docs/components/.../guide.md` as a guide for creating configuration, artifacts, and troubleshooting documentation.
6. Hook up CI for `oasdiff` + schema validation; keep the feature behind `flag.<your-feature>` until rollout.

---

## Kit Docs Checklist

When documenting kits in `docs/services`, include these data points where applicable:

- Quick Snapshot: modes/variants, capabilities/signals, inputs/outputs, artifacts, optional publish/serve
- Core Responsibilities and explicit non‑responsibilities (boundaries)
- Ecosystem Integrations: which other kits consume/produce its artifacts
- Operating Modes and selection guidance
- I/O contract summary and links to OpenAPI/JSON‑Schema
- Artifacts: schemas, `schema_version`, and example directory layout
- Configuration & Tuning knobs with safe defaults
- Opinionated implementation choices (with ADR links if consequential)
- Validation & Health checks (drift, parity, integrity)
- Versioning & Compatibility (schema semver, breaking changes)
- Sizing & Capacity (typical sizes, resource guidance)
- Observability (logs/metrics/traces; link to ObservaKit/EvalKit)
- Publishing to databases/serving adapters (if relevant) with minimal DDL/examples
- Harmony Alignment bullets mapping to spec‑first, auditability, security baselines, and modular CI/CD
- Minimal Interfaces (functions/config shapes) and FAQs

See `docs/services/knowledge-and-retrieval/indexkit/guide.md` for a good exemplar that follows this pattern.
