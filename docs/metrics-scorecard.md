---
title: Harmony Scorecard and Metrics
description: Minimal scorecard for flow, reliability, quality, observability, security, and hygiene — how we measure and improve.
---

# Harmony Scorecard and Metrics

Status: Draft stub (establish thresholds and owners)

## Two‑Dev Scope

- Track a small set of metrics only (DORA 4 + 2–3 SLO indicators). Avoid dashboards that require ongoing curation.
- Automation: generate a weekly digest from CI/PR timestamps and ObservaKit; no manual data entry.
- Review: ≤ 15 minutes weekly; select one improvement with an owner and due date.
- Thresholds: start pragmatic; tighten only when signal is stable and actions are sustainable.

## Pillars Alignment

- Speed with Safety: Track DORA and release health to enable frequent yet safe deploys; freeze risky changes when budgets burn.
- Simplicity over Complexity: A minimal, high‑signal scorecard avoids analysis paralysis and focuses improvements.
- Quality through Determinism: Deterministic sources (CI artifacts, ObservaKit, KP) ensure metrics are reproducible and auditable.
- Guided Agentic Autonomy: Improve layer agents compile the weekly digest; humans select and own actions.
- Evolvable Modularity: Metrics and scorecards are defined over stable contracts and flows, so you can swap tools, vendors, or runtimes without losing historical comparability.

See `docs/methodology/README.md` for Harmony’s five pillars.

## Categories (initial)

- Flow: DORA (lead time, deployment frequency, change failure rate, MTTR).
- Reliability: SLO burn for key journeys (p95 latency, error rate).
- Quality: test coverage deltas, contract drift, flake count.
- Observability: span/log coverage baselines and KP correlation health.
- Security: critical vulns open time, secret scan violations.
- Hygiene: docs coverage, stale flag age, waiver count/age.

## Computation & Sources

- CI artifacts, ObservaKit, Kaizen reports, and KP materialized views.
- Weekly digest from Improve layer; red/yellow/green per category.

## Usage

- Review weekly; select 1–2 improvements for Kaizen/owners.
- Waivers require explicit expiration and follow‑ups.

## Related Docs

- Methodology overview: `docs/methodology/README.md`
- Implementation guide: `docs/methodology/implementation-guide.md`
- Layers model: `docs/methodology/layers.md`
- Improve layer: `docs/methodology/improve-layer.md`
- Knowledge Plane: `docs/architecture/knowledge-plane.md`
- Governance: `docs/architecture/governance-model.md`
- Architecture overview: `docs/architecture/overview.md`
- Observability requirements: `docs/architecture/observability-requirements.md`
