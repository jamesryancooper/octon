---
title: Harmony Principles
description: Production principles that translate Harmony’s pillars into concrete engineering decisions, thresholds, and governance defaults.
---

# Harmony Principles

Status: Active (Production)
Last updated: 2026-02-11

## Purpose

Harmony principles are the decision layer between pillars and methodology. They define how day-to-day technical choices preserve the six pillars while optimizing for velocity, maintainability, scalability, reliability, security, and simplicity.

## Two-Dev Scope

Default to the smallest viable process, design, and tooling that preserves quality and governance. Escalate ceremony only for higher-risk changes.

## Pillars Alignment

This document codifies how Harmony’s [Six Pillars](./pillars/README.md) translate into operating behavior. Pillars are the *what*; principles are the *how*; methodology is the *when*.

## Principle Catalog

### Foundational Principles

These principles already have mature guides and remain active because they directly support methodology behavior (especially context and decision quality).

| Principle | One-sentence definition | Pillar mapping | Quality attributes promoted |
|---|---|---|---|
| Progressive Disclosure | Present information in layers so most work can proceed from concise context before drilling deeper. | Focus, Insight | Velocity, Maintainability, Simplicity |
| Simplicity Over Complexity | Choose the smallest viable solution and add complexity only when evidence demands it. | Focus, Velocity | Velocity, Maintainability, Reliability, Simplicity |
| Single Source of Truth | Keep each important fact, contract, and decision authoritative in exactly one place. | Continuity, Trust | Maintainability, Reliability, Security, Simplicity |
| Locality | Keep context, ownership, and artifacts close to where they are used and maintained. | Focus, Continuity | Velocity, Maintainability, Scalability, Simplicity |
| Deny by Default | Default all permissions and dangerous actions to denied unless explicitly authorized. | Trust | Security, Reliability, Simplicity |

### Core Delivery Principles

These principles define Harmony’s baseline engineering and delivery behavior.

| Principle | One-sentence definition | Pillar mapping | Quality attributes promoted |
|---|---|---|---|
| Monolith-first Modulith | Start with a modular monolith organized by vertical slices and split only when measured constraints require it. | Focus, Velocity | Maintainability, Scalability, Reliability, Simplicity |
| Contract-first | Define OpenAPI/JSON Schema contracts before implementation and enforce compatibility in CI. | Direction, Trust | Maintainability, Scalability, Reliability, Security |
| Small Diffs, Trunk-based | Integrate tiny, single-purpose changes on short-lived branches to sustain high deployment cadence. | Velocity, Trust | Velocity, Maintainability, Reliability, Simplicity |
| Flags by Default | Decouple deployment from release with server-evaluated flags, default-off for risky behavior, and explicit cleanup. | Velocity, Trust | Velocity, Reliability, Security, Simplicity |
| Governed Determinism | Pin versions and control variance so repeated inputs produce predictable outcomes across code, tests, and AI runs. | Trust, Insight | Reliability, Maintainability, Security |
| Observability as a Contract | Treat traces, logs, and metrics as required outputs of changed behavior, not optional instrumentation. | Continuity, Trust, Insight | Reliability, Maintainability, Security, Scalability |
| Security and Privacy Baseline | Apply least privilege, fail-closed defaults, secret hygiene, and PII/PHI redaction on every path by default. | Trust | Security, Reliability, Maintainability |
| Accessibility Baseline | Ship inclusive UX by enforcing automated and manual accessibility checks as release gates. | Direction, Trust | Reliability, Maintainability, Simplicity |
| Documentation is Code | Keep specs, ADRs, and operational notes versioned with changes so intent and decisions remain auditable. | Direction, Continuity | Maintainability, Reliability, Velocity |
| Reversibility | Design code, schema, and rollout paths so changes can be safely rolled back quickly. | Trust, Velocity | Reliability, Velocity, Maintainability, Security |
| Ownership and Boundaries | Make ownership explicit per slice and enforce architectural boundaries in code review and CI. | Focus, Continuity, Trust | Maintainability, Scalability, Reliability, Security |
| Learn Continuously | Use postmortems, evals, and Kaizen loops to turn outcomes into small, evidence-backed improvements. | Insight, Continuity | Velocity, Maintainability, Reliability, Scalability |

### Agentic Principles

These principles govern AI autonomy inside human-owned direction and risk boundaries.

| Principle | One-sentence definition | Pillar mapping | Quality attributes promoted |
|---|---|---|---|
| No Silent Apply | Agents propose plans, diffs, and tests; humans gate material side effects. | Trust, Direction | Security, Reliability, Maintainability |
| Determinism and Provenance | Record model/prompt/runtime provenance so AI-assisted outputs are reproducible and auditable. | Trust, Insight, Continuity | Reliability, Security, Maintainability |
| Idempotency | All mutating operations must safely handle retries using explicit idempotency keys. | Trust, Velocity | Reliability, Scalability, Security |
| Guardrails | Enforce policy, permission, and evidence checks fail-closed at runtime and in CI. | Trust | Security, Reliability, Maintainability |
| HITL Checkpoints | Apply risk-tiered human approvals at meaningful decision boundaries, not uniformly everywhere. | Direction, Trust | Security, Reliability, Velocity |

## Concrete Threshold Defaults

These defaults are now normative unless a documented waiver applies:

- Branch lifetime: `<= 1 working day`.
- PR size: `<= 400 changed lines` (adds + deletes; generated/lock files excluded).
- One PR, one concern: no mixed refactor + feature + migration in a single diff.
- First human review response: `<= 4 working hours` for active PRs.
- AI deterministic settings: `temperature <= 0.3` for code/spec changes; higher values require explicit PR justification.
- Waiver duration: `<= 7 days` or until merge (whichever is sooner).
- Flag hygiene: each flag must have owner + expiry and be removed within `<= 2 release cycles` after GA.
- Rollback-first rule: if safe fix-forward is not possible within `15 minutes`, execute rollback.
- Incident postmortem SLA: publish within `48 hours` of incident mitigation.
- Mutating APIs and kit calls: `idempotency_key` is mandatory.
- Observability evidence: changed flows must emit OTel spans + structured logs and include a representative `trace_id` in PR evidence.
- Contract drift threshold: generated implementations are valid only when all required fixtures pass.
- Validation cache policy: content-hash keyed; invalidate immediately on relevant file change.
- Tier 1 validator compliance: required input/output fields and exit-code semantics (`0/1/2/3`) must be preserved.
- Reproducibility minimum: generated implementation manifests must include pinned provenance metadata (contract/rule/fixture hashes, agent/model identifiers, prompt hash, tool surface, timestamp).

## Anti-Principles (What We Explicitly Avoid)

- Early microservices/choreography without measured need.
- Long-lived branches and big-bang PRs.
- Flaky tests, unbounded retries, and non-deterministic builds.
- Secret or PII/PHI leakage to logs, traces, or third-party tooling.
- Heavy correctness-critical logic at the Edge when server runtimes are required.
- Implicit cross-slice coupling and reach-in imports.

## Related Docs

- `docs/pillars/README.md`
- `docs/principles/README.md`
- `docs/methodology/README.md`
- `docs/architecture/governance-model.md`
- `docs/architecture/runtime-policy.md`
- `docs/architecture/observability-requirements.md`
- `docs/architecture/knowledge-plane.md`
- `docs/api-design-guidelines.md`
- `docs/adr-policy.md`
