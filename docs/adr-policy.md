---
title: ADR Policy
description: When and how to write ADRs, lightweight vs full, indexing and provenance via the Knowledge Plane.
---

# ADR Policy

Status: Draft stub (adopt templates and numbering)

## Two‑Dev Scope

- Keep ADRs lightweight by default (≤ 1 page, ≤ 30 minutes to draft). Escalate to a full ADR only for High‑risk changes (auth, payments, data, infra).
- Required fields only: context, decision, consequences, rollback plan, links (PR/build/trace IDs). Defer extensive alternatives and deep analysis.
- Ownership and flow: Driver drafts; Navigator approves. One ADR per PR to avoid parallel decision threads.
- Evidence discipline: link a single ObservaKit trace or PR comment; avoid separate systems and duplicate summaries.

## Pillars Alignment

- Speed with Safety: Favor lightweight ADRs to document decisions quickly and make changes reversible. Keep decisions linked to flags and rollback notes so promotion/rollback remains safe and fast.
- Simplicity over Complexity: Default to concise ADRs that record only context, decision, and consequences. Avoid ceremony; escalate to full ADRs only for high‑risk changes.
- Quality through Determinism: Require provenance (PR/build/trace IDs) and consistent numbering so decisions are auditable and reproducible across environments.
- Guided Agentic Autonomy: Allow agents to draft ADR summaries and diffs, but require human approval. Record pinned AI configuration and link ObservaKit traces for runs that influenced the ADR.

See `docs/methodology/README.md` for Harmony’s five pillars.

## When to write an ADR

- Architectural decisions, technology choices, cross‑cutting policies, data model changes, and notable trade‑offs.
- For small/routine decisions, add a section to the spec or PR with context.

## Lightweight vs Full ADRs

- Lightweight: 1–2 pages; context, decision, consequences, links.
- Full: for high‑risk decisions; include alternatives, risks, rollback.

## Location & Numbering

- Store under `docs/specs/ADR/` or project‑specific ADR folder; `adr-0001.md` style numbering.
- Link ADRs from specs and PRs; capture IDs in KP.

## Provenance

- Include PR/build IDs; link to traces where relevant.

## Related Docs

- Knowledge Plane: `docs/architecture/knowledge-plane.md`
- Governance model: `docs/architecture/governance-model.md`
- Methodology overview: `docs/methodology/README.md`
- Implementation guide: `docs/methodology/implementation-guide.md`
- Layers model: `docs/methodology/layers.md`
- Improve layer: `docs/methodology/improve-layer.md`
- Architecture overview: `docs/architecture/overview.md`
- Repository blueprint: `docs/architecture/repository-blueprint.md`
