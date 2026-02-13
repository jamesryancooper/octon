---
title: Incident Response
description: Severity levels, roles, communications, runbooks, and postmortems — integrated with flags, rollback, and KP provenance.
---

# Incident Response

Status: Draft stub (define severities and comms)

## Two‑Dev Scope

- One on‑call at a time; rotate weekly. Keep a simple escalation path: rollback first, validate, communicate.
- Runbooks: ≤ 10 steps each; store alongside code; keep a single comms channel (e.g., Slack) and one status note template.
- Watch window: 30 minutes post‑promote for High‑risk; avoid complex paging policies.
- Postmortems: 30 minutes, templated; max 3 action items with owners and due dates.

## Pillars Alignment

- Speed with Safety: Rollback‑first policy, feature kill‑switches, and a short watch window drive fast, safe recovery.
- Simplicity over Complexity: A minimal severity matrix and clear roles/runbooks reduce confusion during incidents.
- Quality through Determinism: PR/build/trace correlation and postmortem actions make response auditable and improvements trackable.
- Guided Agentic Autonomy: Agents can surface alerts and open incident records, but humans decide rollback/promote and own communications.
- Evolvable Modularity: Stable, contract‑driven runbooks and tooling boundaries keep incident workflows effective even as infrastructure, providers, or observability stacks change.

See `.harmony/cognition/methodology/README.md` for Harmony’s five pillars.

## Severities (suggested)

- SEV1 outage; SEV2 partial degradation; SEV3 minor impact; SEV4 informational.

## Roles and Flow

- On‑call leads triage; Product/Security looped in by impact; TL decides promote/rollback.
- Open incident record; correlate PR/build/trace IDs in KP.

## Runbooks

- Flip kill switches; roll back by re‑promote prior preview; validate health; communicate status.

## Postmortems

- Blameless; capture root causes, actions, and owners; time‑bound follow‑ups.

## Related Docs

- Runtime policy: `docs/architecture/runtime-policy.md`
- Governance model: `.harmony/cognition/architecture/governance-model.md`
- Methodology overview: `.harmony/cognition/methodology/README.md`
- Implementation guide: `.harmony/cognition/methodology/implementation-guide.md`
- Layers model: `.harmony/cognition/methodology/layers.md`
- Improve layer: `.harmony/cognition/methodology/improve-layer.md`
- Architecture overview: `.harmony/cognition/architecture/overview.md`
- Observability requirements: `.harmony/cognition/architecture/observability-requirements.md`
