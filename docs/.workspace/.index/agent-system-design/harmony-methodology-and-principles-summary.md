---
title: Harmony Methodology and Principles — Synthesized Summary
description: Concise, agent-focused summary of Harmony’s lean AI-accelerated methodology, pillars, and system guarantees.
---

## Purpose of This Summary

- Provide a compact, opinionated overview of the **Harmony Methodology**, **Harmony Principles**, and **Glossary/Conventions** specifically for designing and evaluating an agentic system.
- Act as the primary “front door” for agents and humans instead of loading multiple long-form docs; underlying documents remain the authoritative source.

## Harmony’s Unifying Objective

- Enable a **tiny team (2–6 devs)** to ship **high‑quality software quickly and safely** on a monolith‑first stack with heavy AI assistance.
- Unify **Spec‑First**, **agentic agile (BMAD)**, **monorepo/Turborepo**, **Vercel previews/flags**, and **SRE/DevSecOps** so every change (human- or AI‑authored) is:
  - **Small**
  - **Deterministic**
  - **Testable**
  - **Reversible**
  - **Evolvable**

## The Five Harmony Pillars (Agent-Relevant View)

### 1. Speed with Safety

- Trunk‑based development, tiny PRs, and **Vercel Previews** for every change.
- **Feature flags** decouple deploy from release; production updates occur via guarded `vercel promote` from known‑good previews.
- CI/CD with strong gates (lint, types, tests, contracts, security scans, SBOM, preview smoke) is mandatory before merge.
- Agents accelerate work (planning, implementation, verification) but never bypass these gates.

### 2. Simplicity over Complexity

- **Monolith‑first modulith** with vertical slices and hexagonal boundaries; avoid premature microservices.
- Use the **simplest process, design, and tooling** that satisfies requirements; add complexity only when driven by SLOs, scale, or compliance.
- Kits should be **thin, single‑purpose libraries**; new kits or runtimes are justified only when they concretely lower complexity or capture a real cross‑cutting concern.

### 3. Quality through Determinism

- Contract‑first APIs (OpenAPI/JSON Schema) and **consumer‑driven contract tests** (Pact, Schemathesis).
- Strict type checking, reproducible builds, deterministic tests, and stability of interfaces over time.
- Observability is a contract: OpenTelemetry traces/logs/metrics, PR/build/trace correlation, SLOs and error budgets.
- AI determinism:
  - Pin provider/model/version/params; prefer low variance (temperature ≤ 0.3).
  - Use schema‑guarded “golden tests” for critical prompts and flows.
  - Record prompt hashes and run metadata for reproducibility and audits.

### 4. Guided Agentic Autonomy

- Standard agent loop: **Plan → Diff → Explain → Test** — **no silent apply**.
- AI agents are **tool‑assisted co‑workers**, not fully autonomous operators:
  - They propose plans, diffs, tests, reports, and evidence.
  - Humans retain control over merges, promotions, risk waivers, and incident decisions.
- Governance is **fail‑closed**:
  - PolicyKit/EvalKit/TestKit gates block if evidence or checks are missing.
  - High‑risk work uses explicit risk classifications and HITL checkpoints.

### 5. Evolvable Modularity

- Hexagonal ports/adapters and contract‑driven boundaries.
- Monolith‑first inside a Turborepo with clear slice ownership; later extractions use stable contracts and the Strangler pattern.
- Edges (models, providers, runtimes, external services) are **plug‑and‑play adapters**, not hard‑wired dependencies.
- Agents and kits must depend on **stable interfaces**, not internal implementation details of apps or runtimes.

## System Guarantees (Non‑Negotiables for Agents)

Agents and their ecosystems must uphold the following guarantees from the methodology:

- **Spec‑first changes**:
  - Every material change starts from a SpecKit one‑pager + ADR and BMAD story.
  - Specs include threat modeling (STRIDE), non‑functional requirements, and acceptance criteria.
- **No silent apply**:
  - Agents never push directly to protected branches, merge PRs, or change production flags.
  - Local/default mode is `--dry-run`; side‑effects require explicit opt‑in and HITL approval.
- **Deterministic AI**:
  - Provider/model/version pinned; parameters documented; prompt hash recorded.
  - Golden tests guard against drift; policy gates reject unpinned or unverifiable configs.
- **Observability required**:
  - Changed flows and agents emit OTel spans/logs; PRs link at least one relevant `trace_id`.
  - PR ↔ build ↔ trace correlation is recorded in the Knowledge Plane for provenance.
- **Idempotency and rollback**:
  - Mutating operations use idempotency keys; risky features ship behind flags and support instant rollback by promoting prior previews.
- **Fail‑closed governance**:
  - Missing evidence or failing checks block merges/promotions unless explicitly waived with documented scope, owner, and expiry.
  - Waivers are rare, time‑boxed, and non‑existent for secrets/PII, missing observability on changed flows, or broken rollback paths.

## Harmony Methodology Lifecycle (For Agent Design)

Harmony’s lifecycle, mapped to agent responsibilities:

- **Spec / Shape**:
  - SpecKit produces spec one‑pagers and ADRs with micro‑STRIDE.
  - Agents should treat these specs as the **source of truth** when planning.
- **Plan**:
  - PlanKit converts specs into BMAD plans (`plan.json`) with explicit steps and acceptance criteria.
  - Planner agents **refine and adapt** plans but do not override baseline constraints.
- **Implement**:
  - Builder agents and humans modify code/config/docs according to plans.
  - Implementation is done via small, reversible PRs; agents output diffs/tests/evidence only.
- **Verify**:
  - Verifier agents orchestrate TestKit/EvalKit/PolicyKit; CI enforces gates for contracts, security, coverage, and performance.
- **Ship**:
  - PatchKit opens PRs; ReleaseKit and FlagKit handle changelogs and progressive rollout.
  - Humans approve merges and promotions; agents may assist but not decide.
- **Operate**:
  - ObservaKit and BenchKit provide runtime SLO/error‑budget insight and performance telemetry.
  - Agents may propose mitigations or improvements based on these signals.
- **Learn**:
  - Dockit, postmortems, and the Knowledge Plane capture decisions, incidents, and improvements, feeding back into specifications and policies.

## Role of Glossary and Conventions (Agent-Specific)

- Shared definitions (pillars, slices, layers, Knowledge Plane, Kaizen, Thin Control Plane) reduce ambiguity for agents.
- Naming conventions and repo‑wide patterns (branch names, error codes, flag keys) give agents a **stable vocabulary**:
  - Agents should use these conventions when planning changes, generating diffs, or emitting reports.
  - Misaligned naming or ad‑hoc structures increase cognitive load and risk; agents should flag such drift as potential issues.

## What Agents Should Infer from This Summary

- Harmony expects **agentic systems to be conservative, transparent, and predictable**, not improvisational or opaque.
- Agents and their flows exist to **accelerate a disciplined engineering method**, not to replace it.
- When in doubt:
  - Prefer **smaller, spec‑referenced changes** with explicit tests and rollback.
  - Escalate ambiguity or conflict to humans and record open questions in the Knowledge Plane.



