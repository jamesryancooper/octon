---
name: audit-operational-readiness
description: >
  Bounded operational-readiness audit that verifies ownership and reliability
  objective coverage, runbook and incident-response preparedness, resilience and
  capacity safeguards, and operational evidence completeness. Applies fixed
  audit layers with lens isolation, stable finding IDs, acceptance criteria,
  coverage accounting, and deterministic convergence receipts. Produces
  structured findings suitable for pre-release and post-remediation gates.
  Read-only -- does not modify source files.
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

# Audit Operational Readiness

Layered operational-readiness audit that verifies ownership posture, runbook and incident preparedness, resilience controls, and evidence-backed readiness across a target scope.

## When to Use

Use this skill when:

- You need a deterministic operational-readiness gate before release or scale-up
- You suspect drift between declared reliability/ops expectations and real service posture
- You need to verify ownership, on-call, runbook, and SLO/capacity safeguards
- You need evidence-backed readiness checks for reliability and operations governance

## Quick Start

```text
/audit-operational-readiness scope=".harmony"
```

With explicit baseline references:

```text
/audit-operational-readiness scope=".harmony" operations_baseline_ref=".harmony/cognition/practices/methodology/reliability-and-ops.md" incident_baseline_ref=".harmony/engine/practices/incident-operations.md"
```

With stricter threshold:

```text
/audit-operational-readiness scope=".harmony/capabilities/runtime/services" severity_threshold="high"
```

## Core Workflow

1. **Configure** -- Parse parameters, resolve scope, and lock layers plus severity rules.
2. **Operational Ownership and Reliability Objectives** -- Verify ownership, service-tier intent, and reliability objective artifacts are complete and traceable.
3. **Runbook and Incident Response Preparedness** -- Verify runbooks, escalation paths, and incident-response artifacts are actionable for critical paths.
4. **Resilience, Capacity, and Evidence Readiness** -- Verify resilience and capacity safeguards plus evidence-backed operations readiness.
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

This skill accepts one required parameter (`scope`) and optional controls for operations/incident baselines, artifact discovery globs, severity threshold, and convergence (`post_remediation`, `convergence_k`, `seed_list`).

## Output Location

Output paths are defined in `.harmony/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.harmony/output/reports/analysis/YYYY-MM-DD-operational-readiness-audit-<run-id>.md` -- Structured findings report
- `.harmony/output/reports/audits/YYYY-MM-DD-<run-id>/` -- Authoritative bounded-audit bundle
- `_ops/state/logs/audit-operational-readiness/` -- Execution logs with index

## Severity Classification

| Severity | Definition |
| -------- | ---------- |
| CRITICAL | Missing or broken operational controls on critical paths likely to cause severe outage impact without reliable response or recovery |
| HIGH | Material operational-readiness gap in ownership, incident preparedness, or resilience safeguards |
| MEDIUM | Partial or inconsistent operations artifacts reducing confidence and traceability |
| LOW | Non-blocking clarity issues, stale references, or minor consistency drift |

## Done Gate

- Discovery mode (`post_remediation=false`): done-gate value is recorded for planning.
- Post-remediation mode (`post_remediation=true`): pass requires convergence stability and zero open findings at or above threshold.

## Boundaries

- **Read-only:** Never modify source files in audited scope
- Write only to designated output paths (reports and logs)
- Coverage claims must be evidence-backed (file-path and section-level where possible)
- If evidence is insufficient, mark explicit unknowns rather than inferring operational readiness
- Apply lens isolation: complete each layer before moving to the next

## When to Escalate

- `scope` does not exist or cannot be read
- Scope exceeds 500 files in a mandatory layer (recommend partitioning)
- Both operations and incident baselines are unavailable and no reliable fallback can be established
- Findings indicate one-way-door risk (for example, critical service without ownership/on-call or incident response evidence)

## References

- [Behavior phases](references/phases.md)
- [I/O contract](references/io-contract.md)
- [Safety policies](references/safety.md)
- [Validation](references/validation.md)
- [Examples](references/examples.md)
- [Glossary](references/glossary.md)
- [Decisions](references/decisions.md)
- [Checkpoints](references/checkpoints.md)
