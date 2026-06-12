---
name: current-state-mechanism-architecture-review
description: >
  Thin invocation surface for the native Current-State Mechanism Architecture
  Review workflow. Reviews an existing governed mechanism's current architecture
  and evidence boundaries. The workflow contract is authoritative; this skill
  only routes the operator or agent to that workflow.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-06-11"
  updated: "2026-06-11"
skill_sets: [executor, guardian]
capabilities: [domain-specialized, self-validating]
allowed-tools: Read Glob Grep Write(/.octon/state/evidence/runs/workflows/*)
---

# Current-State Mechanism Architecture Review

Use this skill to invoke the native workflow at:

- `/.octon/framework/orchestration/runtime/workflows/audit/current-state-mechanism-architecture-review/`

The workflow reviews a durable mechanism as it exists now, including authority
refs, mutable controls, evidence roots, generated projections, raw input
boundaries, validators, ownership, and non-authority boundaries.

## Boundaries

- The workflow contract is the execution authority.
- This skill is only an invocation helper.
- The review produces retained evidence and does not mutate mechanism docs or
  authorize redesign without a separate lifecycle route.
