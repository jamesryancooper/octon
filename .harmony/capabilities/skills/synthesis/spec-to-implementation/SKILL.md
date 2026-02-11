---
name: spec-to-implementation
description: >
  Transform a product specification or design document into a staged
  implementation plan with task decomposition, dependency ordering,
  and acceptance criteria. Bridges the gap between "what to build" and
  "how to build it" by producing actionable, sequenced work items that
  respect architectural boundaries and delivery constraints.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Harmony Framework
  created: "2026-02-09"
  updated: "2026-02-10"
skill_sets: [executor, coordinator]
capabilities: [human-collaborative]
allowed-tools: Read Glob Grep Write(../../output/plans/*) Write(logs/*)
---

# Spec to Implementation

Transform a product specification into a staged implementation plan.

## When to Use

Use this skill when:

- You have a PRD, design doc, or feature spec that needs to become work items
- A feature touches multiple services, layers, or teams
- You need to sequence work to respect dependencies (DB → API → UI)
- You want acceptance criteria derived from spec requirements
- You need to estimate scope and identify risks before starting implementation

## Quick Start

```
/spec-to-implementation spec="docs/specs/auth-overhaul.md"
```

Or with inline spec:

```
/spec-to-implementation spec="Add user authentication with email/password and OAuth"
```

## Core Workflow

1. **Parse** — Extract requirements, constraints, and acceptance criteria from the spec
2. **Map** — Identify affected domains, services, and components in the codebase
3. **Decompose** — Break down into discrete, independently deliverable tasks
4. **Sequence** — Order tasks by dependencies, risk, and delivery value
5. **Plan** — Generate the implementation plan with milestones and acceptance criteria
6. **Review** — Present plan for human approval before proceeding

### Decomposition Principles

| Principle | Application |
|-----------|------------|
| Vertical slices | Each task delivers end-to-end value (not "build all models, then all APIs") |
| Dependency ordering | Data layer before API, API before UI, shared before specific |
| Risk-first | Uncertain or high-risk items scheduled early for faster feedback |
| Interface contracts | Define API contracts at boundaries before implementing either side |
| Incremental delivery | Each milestone produces a working, testable increment |

### Task Anatomy

Each task in the plan includes:

- **ID** — Sequential identifier (e.g., `T01`, `T02`)
- **Title** — Action-oriented description
- **Domain** — Affected area (e.g., `database`, `api`, `frontend`, `infra`)
- **Dependencies** — Which tasks must complete first (e.g., `depends: T01, T03`)
- **Acceptance criteria** — Concrete conditions for "done" (derived from spec)
- **Risk flags** — Known unknowns or areas needing investigation
- **Estimated complexity** — S/M/L relative sizing (not time estimates)

## Parameters

Parameters are defined in `.harmony/capabilities/skills/registry.yml` (single source of truth).

This skill accepts one required parameter (`spec`) pointing to the specification document, plus optional parameters for scope constraints and output format.

## Output Location

Output paths are defined in `.harmony/capabilities/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.harmony/output/plans/YYYY-MM-DD-{{feature}}-implementation-plan.md` — Implementation plan
- `logs/spec-to-implementation/` — Execution logs with index

## Boundaries

- Read-only against the codebase — analyze but do not modify source files
- Do not make architectural decisions unilaterally — present options at review step
- Do not estimate time or story points — use relative complexity (S/M/L) only
- If spec is ambiguous, list assumptions explicitly rather than guessing
- Maximum scope: 30 tasks per plan (split into phases if exceeded)
- Always present the plan for human review before it's considered final

## When to Escalate

- Spec has contradictory requirements — flag conflicts, ask for clarification
- Feature requires technology decisions not covered by the spec — present options
- Scope exceeds 30 tasks — recommend splitting into phases or milestones
- Spec references systems or services not visible in the codebase — flag unknowns

## References

For detailed documentation:

- [Behavior phases](references/phases.md) — Full phase-by-phase instructions
- [I/O contract](references/io-contract.md) — Inputs, outputs, plan schema
- [Safety policies](references/safety.md) — Read-only policy, decision deferral
- [Validation](references/validation.md) — Acceptance criteria for complete plans
- [Examples](references/examples.md) — Plan examples from real specs
- [Orchestration](references/orchestration.md) — Task coordination and dependency management
- [Interaction](references/interaction.md) — Human review checkpoints
