---
name: spec-to-implementation
description: >
  Transform a product specification or design document into a staged
  implementation plan with task decomposition, dependency ordering,
  acceptance criteria, and profile-governance receipts.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-02-09"
  updated: "2026-03-04"
skill_sets: [executor, coordinator]
capabilities: [human-collaborative]
allowed-tools: Read Glob Grep Write(../../output/plans/*) Write(_ops/state/logs/*)
---

# Spec to Implementation

Transform a product specification into a staged implementation plan.

## When to Use

Use this skill when:

- You have a PRD, design doc, or feature spec that needs to become work items
- A feature touches multiple services, layers, or teams
- You need to sequence work to respect dependencies (DB -> API -> UI)
- You need profile-governed planning output with explicit compliance sections

## Quick Start

```
/spec-to-implementation spec="docs/specs/auth-overhaul.md"
```

Or with explicit profile input:

```
/spec-to-implementation spec="Add OAuth login" change_profile="atomic"
```

## Core Workflow

1. **Parse** — Extract requirements, constraints, and acceptance criteria from the spec
2. **Map** — Identify affected domains, services, and components in the codebase
3. **Decompose** — Break down into discrete, independently deliverable tasks
4. **Sequence** — Order tasks by dependencies, risk, and delivery value
5. **Receipt** — Determine release state, select one `change_profile`, and record profile-selection facts
6. **Plan** — Generate plan with required sections
7. **Review** — Present plan for human review before finalization

## Required Output Sections

Generated plans must contain these top-level sections:

1. `Profile Selection Receipt`
2. `Implementation Plan`
3. `Impact Map (code, tests, docs, contracts)`
4. `Compliance Receipt`
5. `Exceptions/Escalations`

## Parameters

Parameters are defined in `.octon/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts required spec input and optional governance selectors:

- `change_profile` (`atomic` or `transitional`)
- `release_state` (`auto`, `pre-1.0`, or `stable`)
- `transitional_exception_note` (required for pre-1.0 transitional)

## Output Location

Output paths are defined in `.octon/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.octon/output/plans/YYYY-MM-DD-implementation-plan-{{run_id}}.md`
- `_ops/state/logs/spec-to-implementation/`

## Boundaries

- Read-only against the codebase — analyze but do not modify source files
- Do not make architectural decisions unilaterally — present options at review step
- Do not estimate time or story points — use relative complexity (S/M/L) only
- If profile tie-break ambiguity exists, stop and escalate

## When to Escalate

- Spec has contradictory requirements
- Feature requires technology decisions not covered by the spec
- Profile tie-break ambiguity exists (`atomic` and `transitional` both appear required)
- Pre-1.0 transitional is requested without complete exception note

## References

For detailed documentation:

- [Behavior phases](references/phases.md)
- [I/O contract](references/io-contract.md)
- [Safety policies](references/safety.md)
- [Validation](references/validation.md)
- [Examples](references/examples.md)
- [Orchestration](references/orchestration.md)
- [Interaction](references/interaction.md)
