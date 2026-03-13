---
title: Methodology Authority Crosswalk
description: Canonical crosswalk mapping active agency contract precedence to cognition principles and pillar guidance for methodology documents.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-05
canonical_links:
  - "/AGENTS.md"
  - "/.octon/agency/governance/CONSTITUTION.md"
  - "/.octon/agency/governance/DELEGATION.md"
  - "/.octon/agency/governance/MEMORY.md"
  - "/.octon/cognition/governance/principles/principles.md"
  - "/.octon/cognition/governance/pillars/README.md"
---

# Methodology Authority Crosswalk

This crosswalk defines how methodology artifacts under `/.octon/cognition/practices/methodology/` should resolve authority when guidance appears in multiple governance surfaces.

## Primary Precedence (Binding)

When instructions conflict, methodology policy follows repository precedence:

1. `AGENTS.md`
2. `/.octon/agency/governance/CONSTITUTION.md`
3. `/.octon/agency/governance/DELEGATION.md`
4. `/.octon/agency/governance/MEMORY.md`
5. `/.octon/agency/runtime/agents/architect/AGENT.md`
6. `/.octon/agency/runtime/agents/architect/SOUL.md`

This precedence is authoritative for execution contracts, profile governance, escalation behavior, and implementation receipts.

## Cognition Governance Mapping

Cognition principles and pillars remain normative framing for methodology outcomes and vocabulary:

- `/.octon/cognition/governance/principles/principles.md`
- `/.octon/cognition/governance/principles/README.md`
- `/.octon/cognition/governance/pillars/README.md`

Use these surfaces to describe purpose, principles, and pillar-oriented quality outcomes. They do not override agency contract precedence above.

## Operational Rule

For methodology execution language, use this standard sentence:

`ACP receipt outcomes determine runtime promotion authority; humans retain policy authorship, exceptions, and escalation authority.`

## Change Control Notes

- If this crosswalk changes, update `methodology-as-code.md` and `index.yml` in the same change.
- Keep references path-absolute to preserve deterministic machine discovery.
