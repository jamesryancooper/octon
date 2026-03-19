---
name: audit-surface-architecture
description: >
  Bounded architecture audit for one durable Octon surface or surface unit.
  Classifies authority shape, identifies hidden authority and validator/doc
  drift, and recommends the smallest robust target architecture with stable
  findings, acceptance criteria, coverage accounting, and deterministic
  convergence receipts. Read-only -- does not modify source files.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-03-12"
  updated: "2026-03-12"
skill_sets: [executor, guardian]
capabilities: [domain-specialized, self-validating]
allowed-tools: Read Glob Grep Write(/.octon/state/evidence/validation/analysis/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Audit Surface Architecture

Bounded architecture audit for one durable Octon surface or surface unit.

## When to Use

Use this skill when:

- You need to evaluate one workflow, skill, watcher, automation, service
  contract, or methodology surface
- You need explicit authority-model classification for a single surface
- You suspect hidden authority, validator gaps, or doc/contract drift
- You need the smallest robust target architecture for one durable surface unit

Use another surface when:

- The target is a whole Octon domain or a planned domain:
  `audit-domain-architecture`
- The target is whole-harness or bounded-domain implementation readiness:
  `audit-architecture-readiness`

## Quick Start

```text
/audit-surface-architecture surface_path=".octon/framework/orchestration/runtime/workflows/meta/create-design-proposal"
```

For a skill target:

```text
/audit-surface-architecture surface_path=".octon/framework/capabilities/runtime/skills/audit/audit-api-contract"
```

For a methodology surface:

```text
/audit-surface-architecture surface_path=".octon/framework/cognition/practices/methodology/audits/README.md"
```

## Core Workflow

1. **Configure** -- Parse parameters, normalize scope, and inventory candidate
   artifacts.
2. **Target Resolution and Applicability Gate** -- Confirm the path maps to one
   durable surface unit or return `not-applicable`.
3. **Authority and Artifact Mapping** -- Identify canonical artifacts, support
   assets, validators, and explanatory docs.
4. **Surface Needs and Drift Analysis** -- Classify authority model, inspect
   machine-readable vs prose obligations, and detect hidden authority or drift.
5. **Self-Challenge** -- Re-check evidence sufficiency, disprove weak findings,
   and record unknowns explicitly.
6. **Report** -- Emit bounded findings, acceptance criteria, keep-as-is
   decisions, and done-gate metadata.

### Bounded Audit Principles

This skill enforces bounded-audit convergence rules:

| # | Principle | What It Prevents |
| - | --------- | ---------------- |
| 1 | Fixed lenses (layers) | Attention drift between runs |
| 2 | Fixed taxonomy + severity bar | Open-ended issue inflation |
| 3 | Coverage accounting | Invisible scope gaps |
| 4 | Stable finding IDs | Finding identity drift |
| 5 | Acceptance criteria per finding | Ambiguous remediation targets |
| 6 | Determinism receipt | Untraceable run variance |
| 7 | Mandatory self-challenge | One-pass omissions |
| 8 | Explicit done gate | Infinite rerun loops |

## Parameters

Parameters are defined in `.octon/framework/capabilities/runtime/skills/registry.yml`
(single source of truth).

This skill accepts one required parameter (`surface_path`) and optional controls
for `surface_kind`, severity threshold, evidence depth, and convergence
(`post_remediation`, `convergence_k`, `seed_list`).

## Output Location

Output paths are defined in `.octon/framework/capabilities/runtime/skills/registry.yml`
(single source of truth).

Outputs are written to:

- `.octon/state/evidence/validation/YYYY-MM-DD-surface-architecture-audit-<run-id>.md`
- `.octon/state/evidence/validation/audits/YYYY-MM-DD-<run-id>/`
- `/.octon/state/evidence/runs/skills/audit-surface-architecture/`

## Severity Classification

| Severity | Definition |
| -------- | ---------- |
| CRITICAL | Canonical authority is missing or unsafe for an execution-bearing surface |
| HIGH | Material authority, validator, or contract/doc split gap likely to cause drift or misuse |
| MEDIUM | Partial or inconsistent surface structure reducing traceability and maintainability |
| LOW | Non-blocking clarity or consistency issue |

## Done Gate

- Discovery mode (`post_remediation=false`): done-gate value is recorded for
  planning.
- Post-remediation mode (`post_remediation=true`): pass requires convergence
  stability and zero open findings at or above threshold.

## Boundaries

- **Read-only:** Never modify source files in the audited scope
- Write only to designated report and log paths
- Unsupported multi-unit targets must return `not-applicable`, not a forced
  architecture verdict
- Evidence gaps must remain explicit unknowns
- Do not force workflow-shaped structures onto unrelated surfaces

## When to Escalate

- `surface_path` is missing, unreadable, or outside `/.octon/`
- The target cannot be normalized to one durable surface unit
- Evidence is too sparse to defend a material finding
- Findings imply one-way-door or high-blast-radius architecture change

## References

- [Behavior phases](references/phases.md)
- [I/O contract](references/io-contract.md)
- [Safety policies](references/safety.md)
- [Validation](references/validation.md)
- [Examples](references/examples.md)
- [Glossary](references/glossary.md)
- [Decisions](references/decisions.md)
- [Checkpoints](references/checkpoints.md)
