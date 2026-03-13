---
title: Operating Model
description: Roles, RACI, cadence, and operating rules for Octon — who approves what, when, and how we ship safely.
---

# Operating Model

Status: Draft stub (confirm roles and cadence)

## Two‑Dev Scope

- Cadence: 1‑week cycles; async daily check‑ins (2 bullets: yesterday outcome, today intent).
- WIP: Ready ≤ 3; In‑Dev 1 per dev; In‑Review ≤ 2. If aging breaches, cut scope before pulling new work.
- Reviews: two‑person approvals only for High‑risk changes (auth, payments, data, infra). Keep others single‑reviewer to maintain flow.
- Ceremonies: ≤ 4 hours/week total meetings. Prefer async; cancel if no agenda/outcomes.

## Pillars Alignment

- Agent-First Purpose: Shared agent contracts and workflows standardize delivery across projects while humans provide governance oversight and escalation.
- Managed Complexity (Complexity Calibration): Favor minimal sufficient complexity and the smallest robust solution that meets constraints; increase ceremony only when risk or scale requires it.
- System-Governed Operations: Contracts, policy gates, and enforcement checks run by default; humans own policy authorship, exceptions, and escalation.
- Reliability and Auditability: Required checks and protected branches create predictable, auditable flow from PR to promote/rollback.
- Evolvable Modularity: Clear ownership boundaries and slice-aligned roles make it easy to evolve responsibilities, tools, and runtimes without large-scale reorgs or rewrites.

See `.octon/cognition/practices/methodology/README.md` for Octon's active six-pillar framing and methodology alignment.

## Roles (suggested)

- Tech Lead: architecture, high‑risk reviews, rollout/rollback decisions.
- Product Lead: user‑facing scope/priorities; approves risky user changes.
- Security Lead: security gates and waivers; incident liaison.
- Maintainers/Owners: slice ownership via CODEOWNERS; PR review.
- On‑call: runtime responses; promote/rollback execution.

## RACI (high‑level)

- Planning gate: TL/PdL approve non‑trivial plans.
- Pre‑merge: owners approve; extra reviewers by risk rubric.
- Pre‑prod: TL/on‑call approve high‑risk rollout.

## Cadence & Ceremonies

- Weekly kaizen digest; release notes review; incident/postmortem review when applicable.

## Freeze and Two‑Person Rule

- Freeze: kaizen runs suggest‑only; risky merges paused.
- Two‑person approvals required for high‑risk (auth/payments/core flows).

## Related Docs

- Governance model: `.octon/cognition/_meta/architecture/governance-model.md`
- Runtime policy: `.octon/cognition/_meta/architecture/runtime-policy.md`
- Methodology overview: `.octon/cognition/practices/methodology/README.md`
- Implementation guide: `.octon/cognition/practices/methodology/implementation-guide.md`
- Layers model: `.octon/cognition/_meta/architecture/layers.md`
- Improve layer: `.octon/cognition/_meta/architecture/layers.md#improve-layer`
- Architecture overview: `.octon/cognition/_meta/architecture/overview.md`
