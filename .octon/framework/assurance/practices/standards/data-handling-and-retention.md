---
title: Data Handling and Retention
description: Practical guidance for classification, retention/erasure, environment data policies, backups, and encryption.
---

# Data Handling and Retention

Status: Draft stub (fill policy durations and owners)

## Two‑Dev Scope

- Classification: stick to four levels (Public, Internal, Confidential, Restricted). Maintain a single table (owner, systems, flows) per slice.
- Retention: define 2–3 pragmatic durations (e.g., logs, analytics, primary records) and revisit quarterly. Avoid per‑field policies.
- Non‑prod data: do not copy prod data. If an exception is required, use a masked snapshot with documented scope and expiry.
- Backups & drills: weekly backups; quarterly restore drill. One named owner; keep runbooks short (≤ 10 steps).

## Pillars Alignment

- Speed with Safety: Pre‑defined retention, erasure, and restore runbooks make operational changes fast and reversible while protecting user data.
- Simplicity over Complexity: A single, clear classification model and explicit retention durations avoid bespoke policies per slice.
- Quality through Determinism: Deterministic policies, auditable backups, and tested erasure/restore procedures ensure reproducible outcomes.
- Guided Agentic Autonomy: Agents may propose classification mappings or retention updates, but ACP gate is required; GuardKit redaction defaults apply to logs/traces.

See `.octon/framework/cognition/practices/methodology/README.md` for Octon’s five pillars.

## Classification and Locations

- Map PII/PHI to systems; record owners; document flows per slice.

## Retention and Erasure

- Define retention by data type; document deletion/erasure requests; test procedures.

## Environment Data Policy

- Avoid production data in non‑prod; if required, mask/anonymize; document exceptions.

## Backups and Restore Drills

- Periodic backups; test restores; encrypt at rest/in transit; document RPO/RTO.

## Related Docs

- Security baseline: `.octon/framework/assurance/practices/standards/security-and-privacy.md`
- Knowledge Plane: `.octon/instance/cognition/context/shared/knowledge/knowledge.md`
- Methodology overview: `.octon/framework/cognition/practices/methodology/README.md`
- Implementation guide: `.octon/framework/cognition/practices/methodology/implementation-guide.md`
- Layers model: `.octon/framework/cognition/_meta/architecture/layers.md`
- Improve layer: `.octon/framework/cognition/_meta/architecture/layers.md#improve-layer`
- Architecture overview: `.octon/framework/cognition/_meta/architecture/overview.md`
- Runtime policy: `.octon/framework/cognition/_meta/architecture/runtime-policy.md`
- Governance model: `.octon/framework/cognition/_meta/architecture/governance-model.md`
