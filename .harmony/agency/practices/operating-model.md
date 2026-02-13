---
title: Operating Model
description: Roles, RACI, cadence, and operating rules for Harmony — who approves what, when, and how we ship safely.
---

# Operating Model

Status: Draft stub (confirm roles and cadence)

## Two‑Dev Scope

- Cadence: 1‑week cycles; async daily check‑ins (2 bullets: yesterday outcome, today intent).
- WIP: Ready ≤ 3; In‑Dev 1 per dev; In‑Review ≤ 2. If aging breaches, cut scope before pulling new work.
- Reviews: two‑person approvals only for High‑risk changes (auth, payments, data, infra). Keep others single‑reviewer to maintain flow.
- Ceremonies: ≤ 4 hours/week total meetings. Prefer async; cancel if no agenda/outcomes.

## Pillars Alignment

- Speed with Safety: Clear roles, WIP discipline, and review gates enable frequent, safe merges and guarded promotions.
- Simplicity over Complexity: Minimal ceremonies and a straightforward RACI reduce coordination overhead for a tiny team.
- Quality through Determinism: Required checks and protected branches create predictable, auditable flow from PR to promote/rollback.
- Guided Agentic Autonomy: Agents can suggest plans and diffs; humans approve changes and waivers. High‑risk changes require two‑person rule.
- Evolvable Modularity: Clear ownership boundaries and slice-aligned roles make it easy to evolve responsibilities, tools, and runtimes without large‑scale reorgs or rewrites.

See `.harmony/cognition/methodology/README.md` for Harmony’s five pillars.

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

- Governance model: `.harmony/cognition/architecture/governance-model.md`
- Runtime policy: `.harmony/cognition/architecture/runtime-policy.md`
- Methodology overview: `.harmony/cognition/methodology/README.md`
- Implementation guide: `.harmony/cognition/methodology/implementation-guide.md`
- Layers model: `.harmony/cognition/methodology/layers.md`
- Improve layer: `.harmony/cognition/methodology/improve-layer.md`
- Architecture overview: `.harmony/cognition/architecture/overview.md`
