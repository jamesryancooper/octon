---
name: update-harness
description: >
  Align an existing harness with current canonical conventions by auditing
  gaps, planning updates, and executing bounded remediations.
steps:
  - id: audit-state
    file: 01-audit-state.md
    description: Audit current harness state.
  - id: identify-gaps
    file: 02-identify-gaps.md
    description: Identify contract and structure gaps.
  - id: assess-tokens
    file: 03-assess-tokens.md
    description: Assess token footprint and disclosure budget.
  - id: propose-changes
    file: 04-propose-changes.md
    description: Propose concrete update actions.
  - id: execute
    file: 05-execute.md
    description: Execute approved updates.
---

# Update Harness Workflow

Use [00-overview.md](./00-overview.md) for invocation and policy guidance, then
run the listed steps in sequence.
