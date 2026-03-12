---
name: audit-release-readiness
description: >
  Bounded release-readiness audit that verifies release criteria coverage,
  deployment and rollback safeguards, operational response readiness, and gate
  evidence completeness. Applies fixed audit layers with lens isolation, stable
  finding IDs, acceptance criteria, coverage accounting, and deterministic
  convergence receipts. Produces structured findings suitable for pre-release
  and post-remediation gates. Read-only -- does not modify source files.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Harmony Framework
  created: "2026-02-23"
  updated: "2026-02-23"
skill_sets: [executor, guardian]
capabilities: [domain-specialized, self-validating]
allowed-tools: Read Glob Grep Write(../../output/reports/*) Write(_ops/state/logs/*)
---

# Release Readiness Audit

Layered release-readiness audit that verifies release policy coverage, deployment and rollback safeguards, and evidence-backed gate readiness across a target scope.

## When to Use

Use this skill when:

- You need a deterministic release-readiness gate before shipping
- You suspect drift between declared release policy and operational reality
- You need to verify rollback/incident preparedness for critical paths
- You need evidence-backed readiness checks for governance and launch reviews

## Quick Start

```text
/audit-release-readiness scope=".harmony"
```

With explicit baseline references:

```text
/audit-release-readiness scope=".harmony" release_baseline_ref=".harmony/cognition/practices/methodology/ci-cd-quality-gates.md" operations_baseline_ref=".harmony/engine/practices/incident-operations.md"
```

With stricter threshold:

```text
/audit-release-readiness scope=".harmony/capabilities/runtime/services" severity_threshold="high"
```

## Core Workflow

1. **Configure** -- Parse parameters, resolve scope, and lock layers plus severity rules.
2. **Release Criteria and Change-Control Coverage** -- Verify release policy, criteria, and change-control artifacts are complete and aligned.
3. **Deployment and Rollback Safeguards** -- Verify deployment controls, rollback plans, and dependency/compatibility safeguards for critical paths.
4. **Operational Response and Gate Evidence** -- Verify on-call/incident readiness artifacts and release-gate evidence traceability.
5. **Self-Challenge** -- Re-check evidence sufficiency, blind spots, and possible false positives.
6. **Report** -- Emit bounded findings, coverage ledger, and convergence/done-gate receipts.

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

This skill accepts one required parameter (`scope`) and optional controls for release/operations baselines, artifact discovery globs, severity threshold, and convergence (`post_remediation`, `convergence_k`, `seed_list`).

## Output Location

Output paths are defined in `.harmony/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.harmony/output/reports/analysis/YYYY-MM-DD-audit-release-readiness-<run-id>.md` -- Structured findings report
- `.harmony/output/reports/audits/YYYY-MM-DD-<run-id>/` -- Authoritative bounded-audit bundle
- `_ops/state/logs/audit-release-readiness/` -- Execution logs with index

## Severity Classification

| Severity | Definition |
| -------- | ---------- |
| CRITICAL | Missing or broken release controls on critical paths likely to cause unsafe rollout or unrecoverable production impact |
| HIGH | Material release-readiness gap in policy coverage, rollback posture, or operational response readiness |
| MEDIUM | Partial or inconsistent release artifacts reducing confidence and traceability |
| LOW | Non-blocking clarity issues, stale references, or minor consistency drift |

## Done Gate

- Discovery mode (`post_remediation=false`): done-gate value is recorded for planning.
- Post-remediation mode (`post_remediation=true`): pass requires convergence stability and zero open findings at or above threshold.

## Boundaries

- **Read-only:** Never modify source files in audited scope
- Write only to designated output paths (reports and logs)
- Coverage claims must be evidence-backed (file-path and section-level where possible)
- If evidence is insufficient, mark explicit unknowns rather than inferring release readiness
- Apply lens isolation: complete each layer before moving to the next

## When to Escalate

- `scope` does not exist or cannot be read
- Scope exceeds 500 files in a mandatory layer (recommend partitioning)
- Both release and operations baselines are unavailable and no reliable fallback can be established
- Findings indicate one-way-door risk (for example, critical release path without rollback or incident response evidence)

## References

- [Behavior phases](references/phases.md)
- [I/O contract](references/io-contract.md)
- [Safety policies](references/safety.md)
- [Validation](references/validation.md)
- [Examples](references/examples.md)
- [Glossary](references/glossary.md)
- [Decisions](references/decisions.md)
- [Checkpoints](references/checkpoints.md)
