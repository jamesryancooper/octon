---
name: audit-test-quality
description: >
  Bounded test-quality audit that verifies test strategy coverage,
  contract and integration assurance, determinism and flake controls, and
  evidence readiness for release gates. Applies fixed audit layers with lens
  isolation, stable finding IDs, acceptance criteria, coverage accounting, and
  deterministic convergence receipts. Produces structured findings suitable for
  pre-release and post-remediation gates. Read-only -- does not modify source
  files.
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

# Audit Test Quality

Layered test-quality audit that verifies strategy coverage, contract and integration assurance, reliability controls, and evidence readiness across a target scope.

## When to Use

Use this skill when:

- You need a deterministic test-quality gate before release
- You suspect drift between declared testing strategy and actual test surfaces
- You need to verify contract, integration, and regression evidence quality
- You need evidence-backed readiness checks for quality and governance reviews

## Quick Start

```text
/audit-test-quality scope=".harmony"
```

With explicit baseline references:

```text
/audit-test-quality scope=".harmony" testing_baseline_ref=".harmony/assurance/practices/standards/testing-strategy.md" quality_gate_baseline_ref=".harmony/cognition/practices/methodology/ci-cd-quality-gates.md"
```

With stricter threshold:

```text
/audit-test-quality scope=".harmony/capabilities/runtime/services" severity_threshold="high"
```

## Core Workflow

1. **Configure** -- Parse parameters, resolve scope, and lock layers plus severity rules.
2. **Test Strategy and Coverage Topology** -- Verify testing strategy artifacts align with unit/integration/contract/regression surface coverage.
3. **Contract and Integration Assurance** -- Verify contract and integration test artifacts are present, traceable, and actionable for in-scope critical paths.
4. **Determinism, Flake Control, and Gate Evidence** -- Verify determinism controls, flake management, and quality-gate evidence artifacts.
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

This skill accepts one required parameter (`scope`) and optional controls for testing/gate baselines, artifact discovery globs, severity threshold, and convergence (`post_remediation`, `convergence_k`, `seed_list`).

## Output Location

Output paths are defined in `.harmony/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.harmony/output/reports/analysis/YYYY-MM-DD-test-quality-audit-<run-id>.md` -- Structured findings report
- `.harmony/output/reports/audits/YYYY-MM-DD-<run-id>/` -- Authoritative bounded-audit bundle
- `_ops/state/logs/audit-test-quality/` -- Execution logs with index

## Severity Classification

| Severity | Definition |
| -------- | ---------- |
| CRITICAL | Missing or broken test controls on critical paths likely to permit high-impact regressions or unsafe release decisions |
| HIGH | Material test-quality gap in strategy coverage, contract/integration assurance, or gate evidence readiness |
| MEDIUM | Partial or inconsistent test artifacts reducing reliability and traceability |
| LOW | Non-blocking clarity issues, stale references, or minor consistency drift |

## Done Gate

- Discovery mode (`post_remediation=false`): done-gate value is recorded for planning.
- Post-remediation mode (`post_remediation=true`): pass requires convergence stability and zero open findings at or above threshold.

## Boundaries

- **Read-only:** Never modify source files in audited scope
- Write only to designated output paths (reports and logs)
- Coverage claims must be evidence-backed (file-path and section-level where possible)
- If evidence is insufficient, mark explicit unknowns rather than inferring quality readiness
- Apply lens isolation: complete each layer before moving to the next

## When to Escalate

- `scope` does not exist or cannot be read
- Scope exceeds 500 files in a mandatory layer (recommend partitioning)
- Both testing and quality-gate baselines are unavailable and no reliable fallback can be established
- Findings indicate one-way-door risk (for example, critical-path release without reliable contract/integration test evidence)

## References

- [Behavior phases](references/phases.md)
- [I/O contract](references/io-contract.md)
- [Safety policies](references/safety.md)
- [Validation](references/validation.md)
- [Examples](references/examples.md)
- [Glossary](references/glossary.md)
- [Decisions](references/decisions.md)
- [Checkpoints](references/checkpoints.md)
