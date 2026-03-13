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

- Direction through Validated Discovery: ADRs make consequential decisions explicit before implementation drift can spread.
- Focus through Absorbed Complexity: Keep ADRs concise by default and escalate depth only when risk or scope requires it.
- Velocity through Agentic Automation: Lightweight ADR templates preserve delivery speed while keeping changes reviewable and reversible.
- Trust through Governed Determinism: Require provenance (PR/build/trace IDs), consistent numbering, and ACP-compatible evidence linkage.
- Continuity through Institutional Memory and Insight through Structured Learning: ADRs preserve durable decision memory and provide structured inputs for future improvement.

See `.octon/cognition/practices/methodology/README.md` for Octon's six pillars.

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

- Knowledge Plane: `.octon/cognition/runtime/knowledge/knowledge.md`
- Governance model: `.octon/cognition/_meta/architecture/governance-model.md`
- Methodology overview: `.octon/cognition/practices/methodology/README.md`
- Implementation guide: `.octon/cognition/practices/methodology/implementation-guide.md`
- Layers model: `.octon/cognition/_meta/architecture/layers.md`
- Improve layer: `.octon/cognition/_meta/architecture/layers.md#improve-layer`
- Architecture overview: `.octon/cognition/_meta/architecture/overview.md`
- Repository blueprint: `.octon/cognition/_meta/architecture/repository-blueprint.md`
