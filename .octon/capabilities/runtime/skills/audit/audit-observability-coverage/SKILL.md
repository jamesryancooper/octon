---
name: audit-observability-coverage
description: >
  Bounded observability coverage audit that verifies whether service surfaces
  have complete telemetry contracts, SLO and alert coverage, and operational
  readiness artifacts (runbooks and dashboards). Applies fixed audit layers
  with lens isolation, stable finding IDs, acceptance criteria, coverage
  accounting, and deterministic convergence receipts. Produces structured
  findings suitable for pre-release and post-remediation gates. Read-only --
  does not modify source files.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-02-22"
  updated: "2026-02-22"
skill_sets: [executor, guardian]
capabilities: [domain-specialized, self-validating]
allowed-tools: Read Glob Grep Write(../../output/reports/*) Write(_ops/state/logs/*)
---

# Audit Observability Coverage

Layered observability coverage audit that verifies telemetry, SLO and alert coverage, and operational readiness artifacts across a target scope.

## When to Use

Use this skill when:

- You need a pre-release reliability gate for telemetry and operational visibility
- You suspect missing SLO objectives, alert policy gaps, or incomplete runbook coverage
- You want deterministic findings with stable IDs and explicit acceptance criteria
- You need post-remediation verification that observability gaps are actually closed

## Quick Start

```text
/audit-observability-coverage scope=".octon/capabilities/runtime/services"
```

Use an explicit contract reference:

```text
/audit-observability-coverage scope=".octon/capabilities/runtime/services" observability_contract_ref=".octon/cognition/_meta/architecture/observability-requirements.md"
```

Narrow discovery behavior:

```text
/audit-observability-coverage scope=".octon/capabilities/runtime/services" service_manifest_glob="**/SERVICE.md" severity_threshold="high"
```

## Core Workflow

1. **Configure** -- Parse parameters, resolve scope, and lock coverage lenses plus severity rules.
2. **Signal Contract Coverage** -- Verify service surfaces declare expected telemetry signals and ownership metadata.
3. **SLO and Alert Coverage** -- Verify measurable SLO artifacts and associated alerting policies exist for in-scope critical paths.
4. **Runbook and Dashboard Coverage** -- Verify operator guidance and dashboard references exist for alertable surfaces.
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

Parameters are defined in `.octon/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts one required parameter (`scope`) and optional controls for observability contract source, artifact discovery globs, severity threshold, and convergence (`post_remediation`, `convergence_k`, `seed_list`).

## Output Location

Output paths are defined in `.octon/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.octon/output/reports/analysis/YYYY-MM-DD-observability-coverage-audit-<run-id>.md` -- Structured findings report
- `.octon/output/reports/audits/YYYY-MM-DD-<run-id>/` -- Authoritative bounded-audit bundle
- `_ops/state/logs/audit-observability-coverage/` -- Execution logs with index

## Severity Classification

| Severity | Definition |
| -------- | ---------- |
| CRITICAL | Missing telemetry/SLO/alert coverage on critical service paths that can mask incidents or block reliable operation |
| HIGH | Coverage gap in SLO, alerting, runbook, or dashboard linkage that materially increases incident response risk |
| MEDIUM | Partial or inconsistent coverage reducing diagnosability, ownership clarity, or operational confidence |
| LOW | Non-blocking clarity issues, stale references, or minor consistency drift |

## Done Gate

- Discovery mode (`post_remediation=false`): done-gate value is recorded for planning.
- Post-remediation mode (`post_remediation=true`): pass requires convergence stability and zero open findings at or above threshold.

## Boundaries

- **Read-only:** Never modify source files in audited scope
- Write only to designated output paths (reports and logs)
- Coverage claims must be evidence-backed (file-path and section-level where possible)
- If evidence is insufficient, mark explicit unknowns rather than inferring compliance
- Apply lens isolation: complete each layer before moving to the next

## When to Escalate

- `scope` does not exist or cannot be read
- Scope exceeds 500 files in a mandatory layer (recommend partitioning)
- Observability contract reference is missing and no reliable fallback baseline can be established
- Findings indicate one-way-door risk (for example, production alerting blind spots on critical paths)

## References

- [Behavior phases](references/phases.md)
- [I/O contract](references/io-contract.md)
- [Safety policies](references/safety.md)
- [Validation](references/validation.md)
- [Examples](references/examples.md)
- [Glossary](references/glossary.md)
- [Decisions](references/decisions.md)
- [Checkpoints](references/checkpoints.md)
