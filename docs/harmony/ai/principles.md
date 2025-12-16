---
title: Harmony Principles
description: Concise, actionable principles that codify Harmony’s defaults — pillars, core/agentic principles, anti‑principles, and guardrails that guide everyday decisions.
---

# Harmony Principles

Status: Draft stub (confirm team‑specific thresholds and examples)

## Two‑Dev Scope

Default to the smallest viable process, design, and tooling that enforces the principles without burden. Prefer repo‑wide defaults, lightweight reviews, and short‑lived branches; escalate ceremony only for High‑risk changes.

## Pillars Alignment

This document codifies how Harmony's [six pillars](./pillars/README.md) translate into day‑to‑day decisions. The pillars are organized in three phases (PLAN → SHIP → LEARN) forming a complete feedback loop. For deeper operational mapping and examples across the lifecycle, see `docs/harmony/methodology/README.md`.

## Purpose

- Provide a compact, quotable set of principles that guide design and delivery.
- Connect day‑to‑day decisions to the six pillars and governance model.
- Keep choices simple, deterministic, testable, and reversible.

## The Six Pillars (non‑negotiable)

### PLAN Phase

1. **[Direction through Validated Discovery](./pillars/direction.md)** — Build the right thing because every feature is validated before investment. No code without a validated spec.
2. **[Focus through Absorbed Complexity](./pillars/focus.md)** — Build features, not infrastructure — Harmony handles the rest. Use kits, respect boundaries.

### SHIP Phase

3. **[Velocity through Agentic Automation](./pillars/velocity.md)** — Ship fast because AI automation removes bottlenecks and multiplies output. Speed serves purpose, not metrics.
4. **[Trust through Governed Determinism](./pillars/trust.md)** — Ship confidently because behavior is predictable, agents are bounded, security is enforced, and mistakes are reversible.

### LEARN Phase

5. **[Continuity through Institutional Memory](./pillars/continuity.md)** — Knowledge persists because decisions, traces, and context are captured durably. Write ADRs, document decisions.
6. **[Insight through Structured Learning](./pillars/insight.md)** — Improve continuously because every outcome teaches us something. Run evals, conduct postmortems, update from feedback.

## Core Principles

- Monolith‑first modulith: organize by vertical feature slices; keep domain pure; adapters implement ports.
- Contract‑first: define OpenAPI/JSON Schema up front; run Pact + Schemathesis in CI; avoid breaking changes.
- Small diffs, trunk‑based: short‑lived branches, tiny PRs, preview deploys, fast review.
- Flags by default: decouple deploy from release; default OFF; fail‑closed on resolution errors; clean up stale flags.
- Determinism: pin versions and AI configs; require idempotency keys for mutating operations; avoid non‑deterministic IO in tests.
- Observability as a contract: structured logs, distributed traces, and metrics with PR/build/trace correlation in the Knowledge Plane.
- Security & privacy baseline: least privilege; secrets via VaultKit only; GuardKit redaction at write boundaries; no PII/PHI in logs/traces.
- Accessibility baseline: run automated a11y checks in CI; treat failures as evaluation/policy violations.
- Documentation is code: spec‑first one‑pagers; ADRs for significant decisions; link artifacts in KP.
- Reversibility: expand/contract migrations; feature kill‑switches; rehearsed rollback.
- Ownership & boundaries: CODEOWNERS per slice; enforce import/architecture rules in CI.
- Learn continuously: blameless postmortems; Kaizen proposes tiny, evidence‑based improvements.

## Agentic Principles (AI‑Toolkit alignment)

- No silent apply: standard loop is Plan → Diff → Explain → Test; humans approve material changes.
- Determinism & provenance: pin provider/model/version; low temperature; record prompt hashes and parameters; capture run/trace IDs.
- Idempotency: all mutating kit calls accept and honor `idempotency_key`.
- Guardrails: agents respect policy and boundaries; produce evidence (plans, diffs, tests, reports) for review.
- HITL checkpoints: bots can open PRs; they never self‑approve or push to protected branches.

## Anti‑Principles (what we avoid)

- Early microservices or choreography that increases complexity without clear, measured need.
- Long‑lived branches, big‑bang PRs, or merges without green gates.
- Flaky tests and unbounded retries; non‑deterministic builds.
- Leaking secrets/PII into logs/traces or external services.
- Heavy/long‑running logic at the Edge; keep correctness paths on server runtimes.
- Implicit cross‑slice coupling and “reach‑in” imports across boundaries.

## Defaults and Guardrails

- Release posture: manual promote to production; instant rollback by re‑promote prior preview.
- Risk rubric: scale reviewers/tests by risk; two‑person rule for high‑risk (auth/payments/core flows).
- Waivers: time‑boxed, documented, and auditable with follow‑ups.
- Coverage & budgets: set thresholds per repo/slice; treat regressions as policy failures unless waived.
- API behavior: stable error envelope; pagination strategy is repo‑wide; timeouts and bounded retries.

## How To Use These

- Reference in PR templates and design notes; cite specific principles when making trade‑offs.
- When a principle conflicts, favor the six pillars and governance safety.
- If you need an exception, file a short waiver per governance and set an expiry.

## Related Docs

- **Pillars documentation: `docs/harmony/ai/pillars/README.md`**
- Methodology overview: `docs/harmony/methodology/README.md`
- Architecture overview: `docs/harmony/architecture/overview.md`
- Governance model: `docs/harmony/architecture/governance-model.md`
- Runtime policy: `docs/harmony/architecture/runtime-policy.md`
- Observability requirements: `docs/harmony/architecture/observability-requirements.md`
- Knowledge Plane: `docs/harmony/architecture/knowledge-plane.md`
- API guidelines: `docs/harmony/api-design-guidelines.md`
- ADR policy: `docs/harmony/adr-policy.md`
- Implementation guide: `docs/harmony/methodology/implementation-guide.md`
- Layers model: `docs/harmony/methodology/layers.md`
- Improve layer: `docs/harmony/methodology/improve-layer.md`
- Slices vs layers: `docs/harmony/architecture/slices-vs-layers.md`
- Repository blueprint: `docs/harmony/architecture/repository-blueprint.md`
