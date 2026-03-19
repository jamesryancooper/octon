---
name: audit-freshness-and-supersession
description: >
  Bounded staleness audit that checks freshness and supersession integrity for
  .octon operational artifacts, including context docs, decision records,
  plans, and reports. Detects stale artifacts relative to changed source
  surfaces, missing superseded-by chains, orphaned historical files, and
  contradictory current-state markers. Produces severity-tiered findings with
  stable IDs, acceptance criteria, coverage accounting, and deterministic
  convergence receipts. Read-only -- does not modify source files.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-02-15"
  updated: "2026-02-22"
skill_sets: [executor, guardian]
capabilities: [domain-specialized, self-validating]
allowed-tools: Read Glob Grep Write(/.octon/state/evidence/validation/analysis/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Audit Freshness And Supersession

Layered freshness audit that verifies staleness controls and supersession chains across `.octon` artifacts.

## When to Use

Use this skill when:

- You suspect stale plans, reports, or context records are still treated as current
- Supersession chains may be missing or inconsistent
- Changed architecture surfaces may not be reflected in downstream artifacts
- You need a release gate for document freshness hygiene

## Quick Start

```text
/audit-freshness-and-supersession scope=".octon"
```

With explicit age threshold:

```text
/audit-freshness-and-supersession scope=".octon" max_age_days="30"
```

## Core Workflow

1. **Configure** -- Parse scope, artifact classes, and thresholds.
2. **Artifact Inventory** -- Enumerate target files and map freshness anchors.
3. **Freshness Checks** -- Detect stale artifacts relative to source changes and age thresholds.
4. **Supersession Integrity** -- Validate supersedes/superseded-by chains and current-state markers.
5. **Self-Challenge** -- Verify findings and search for missed stale paths.
6. **Report** -- Emit bounded findings plus coverage and convergence receipts.

### Bounded Audit Principles

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

Parameters are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts optional parameters for scope, artifact selection, age thresholds, severity threshold, and convergence controls (`post_remediation`, `convergence_k`, `seed_list`).

## Output Location

Output paths are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.octon/state/evidence/validation/analysis/YYYY-MM-DD-freshness-and-supersession-audit.md` -- Human-readable findings report
- `.octon/state/evidence/validation/audits/YYYY-MM-DD-<run-id>/` -- Authoritative bounded-audit bundle
- `/.octon/state/evidence/runs/skills/audit-freshness-and-supersession/` -- Execution logs with index

## Severity Classification

| Severity | Definition |
| -------- | ---------- |
| CRITICAL | Current-state guidance points to stale artifacts likely to cause bad execution |
| HIGH | Missing or broken supersession links on authoritative artifacts |
| MEDIUM | Stale but non-authoritative artifacts or inconsistent freshness metadata |
| LOW | Formatting, metadata completeness, or non-blocking archival hygiene issues |

## Done Gate

- Discovery mode (`post_remediation=false`): done-gate value is recorded for planning.
- Post-remediation mode (`post_remediation=true`): pass requires convergence stability and zero open findings at or above threshold.

## Boundaries

- **Read-only:** Never modify source files -- audit only, report findings
- Write only to designated output paths (reports and logs)
- Maximum scope: 1500 files per run (escalate if exceeded)
- Evaluate freshness with deterministic ordering and explicit thresholds
- Include checked-clean proof, not only findings
- Emit stable finding IDs and acceptance criteria in bundle mode

## When to Escalate

- No target artifact families are found in scope
- Freshness anchors cannot be resolved for selected artifact classes
- Scope exceeds threshold and requires partitioning
- Findings indicate governance ambiguity around authoritative sources

## References

- [Behavior phases](references/phases.md)
- [I/O contract](references/io-contract.md)
- [Safety policies](references/safety.md)
- [Validation](references/validation.md)
- [Examples](references/examples.md)
- [Glossary](references/glossary.md)
