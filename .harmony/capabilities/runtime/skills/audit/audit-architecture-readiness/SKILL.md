---
name: audit-architecture-readiness
description: >
  Bounded architecture-readiness audit for Harmony whole-harness and
  bounded-surface domain targets. Verifies objective binding, authority,
  policy, evidence, control-plane separation, recovery posture, and failure-mode
  resistance using a deterministic scorecard plus stable findings, coverage
  accounting, and convergence receipts. Produces structured outputs suitable for
  design review and remediation planning. Read-only -- does not modify source
  files.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Harmony Framework
  created: "2026-03-11"
  updated: "2026-03-11"
skill_sets: [executor, guardian]
capabilities: [domain-specialized, self-validating]
allowed-tools: Read Glob Grep Write(../../output/reports/*) Write(_ops/state/logs/*)
---

# Architecture Readiness Audit

Bounded architecture-readiness audit for Harmony control-plane and
bounded-surface domain targets.

## When to Use

Use this skill when:

- You need an implementation-readiness verdict for `/.harmony/`
- You need a readiness verdict for one bounded-surface top-level domain
- You need explicit hard-gate failures, failure-mode analysis, and remediation
  artifacts
- You need structured output for design review or workflow orchestration

Use `audit-surface-architecture` instead when the question is about one
workflow, skill, watcher, automation, contract surface, or methodology surface
rather than whole-harness or bounded-domain readiness.

## Quick Start

```text
/audit-architecture-readiness target_path=".harmony"
```

With bounded-domain scope:

```text
/audit-architecture-readiness target_path=".harmony/capabilities" severity_threshold="high"
```

With strict post-remediation gate:

```text
/audit-architecture-readiness target_path=".harmony" post_remediation=true convergence_k="3"
```

## Core Workflow

1. **Configure** -- Parse parameters, normalize severity rules, and inventory candidate evidence.
2. **Target Classification and Applicability Gate** -- Resolve whole-harness, bounded-domain, or not-applicable outcome before scoring.
3. **Dimension Scoring** -- Score the 13 architecture-readiness dimensions with evidence-backed claims and hard-gate tracking.
4. **Failure-Mode and Boundary Analysis** -- Evaluate resistance to mandatory failure modes plus control-plane vs execution-plane integrity.
5. **Self-Challenge** -- Re-check evidence sufficiency, downgrade unsupported claims, and record unknowns explicitly.
6. **Report** -- Emit markdown report, summary JSON, bounded-audit bundle, and run log.

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

Parameters are defined in `.harmony/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts one required parameter (`target_path`) and optional controls for severity threshold, evidence depth, target-classification references, and convergence (`post_remediation`, `convergence_k`, `seed_list`).

## Output Location

Output paths are defined in `.harmony/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.harmony/output/reports/analysis/YYYY-MM-DD-architecture-readiness-audit-<run-id>.md`
- `.harmony/output/reports/analysis/YYYY-MM-DD-architecture-readiness-audit-<run-id>.json`
- `.harmony/output/reports/audits/YYYY-MM-DD-<run-id>/`
- `_ops/state/logs/audit-architecture-readiness/`

## Severity Classification

| Severity | Definition |
| -------- | ---------- |
| CRITICAL | Hard-gate or structural failure that blocks implementation-ready verdict |
| HIGH | Material readiness gap that substantially weakens governability or recovery confidence |
| MEDIUM | Partial or inconsistent readiness coverage that reduces traceability or assurance |
| LOW | Non-blocking clarity, naming, or consistency issue |

## Done Gate

- Discovery mode (`post_remediation=false`): done-gate value is recorded for planning.
- Post-remediation mode (`post_remediation=true`): pass requires convergence stability and zero open findings at or above threshold.

## Boundaries

- **Read-only:** Never modify source files in the audited scope
- Write only to designated report and log paths
- Unsupported targets must return `not-applicable`, not a forced score
- Coverage claims must be evidence-backed
- Existing audits may inform orchestrated runs, but this skill does not invoke them directly

## When to Escalate

- `target_path` is missing, unreadable, or cannot be normalized
- target classification is ambiguous
- evidence is too sparse to support a defensible verdict
- findings imply one-way-door architectural change

## References

- [Behavior phases](references/phases.md)
- [I/O contract](references/io-contract.md)
- [Safety policies](references/safety.md)
- [Validation](references/validation.md)
- [Examples](references/examples.md)
- [Glossary](references/glossary.md)
- [Decisions](references/decisions.md)
- [Checkpoints](references/checkpoints.md)
