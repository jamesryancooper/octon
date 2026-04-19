---
title: Methodology Authority Crosswalk
description: Canonical crosswalk mapping active agency contract precedence to cognition principles and pillar guidance for methodology documents.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-05
canonical_links:
  - "/AGENTS.md"
  - "/.octon/framework/constitution/CHARTER.md"
  - "/.octon/framework/constitution/precedence/normative.yml"
  - "/.octon/framework/execution-roles/governance/CONSTITUTION.md"
  - "/.octon/framework/execution-roles/governance/DELEGATION.md"
  - "/.octon/framework/execution-roles/governance/MEMORY.md"
  - "/.octon/framework/cognition/governance/principles/principles.md"
  - "/.octon/framework/cognition/governance/pillars/README.md"
---

# Methodology Authority Crosswalk

This crosswalk defines how methodology artifacts under `/.octon/framework/cognition/practices/methodology/` should resolve authority when guidance appears in multiple governance surfaces.

## Primary Precedence (Binding)

When instructions conflict, methodology policy follows repository precedence:

1. `AGENTS.md`
2. `/.octon/framework/constitution/CHARTER.md`
3. `/.octon/framework/constitution/obligations/fail-closed.yml`
4. `/.octon/framework/constitution/precedence/normative.yml`
5. `/.octon/framework/execution-roles/governance/CONSTITUTION.md`
6. `/.octon/framework/execution-roles/governance/DELEGATION.md`
7. `/.octon/framework/execution-roles/governance/MEMORY.md`
8. `/.octon/framework/execution-roles/runtime/orchestrator/ROLE.md`

This precedence is authoritative for execution contracts, profile governance, escalation behavior, and implementation receipts.

## Cognition Governance Mapping

Cognition principles and pillars remain normative framing for methodology outcomes and vocabulary:

- `/.octon/framework/cognition/governance/principles/principles.md`
- `/.octon/framework/cognition/governance/principles/README.md`
- `/.octon/framework/cognition/governance/pillars/README.md`

Use these surfaces to describe purpose, principles, and pillar-oriented quality outcomes. They do not override agency contract precedence above.

## Operational Rule

For methodology execution language, use this standard sentence:

`ACP receipt outcomes determine runtime promotion authority; humans retain policy authorship, exceptions, and escalation authority.`

## Change Control Notes

- If this crosswalk changes, update `methodology-as-code.md` and `index.yml` in the same change.
- Keep references path-absolute to preserve deterministic machine discovery.
