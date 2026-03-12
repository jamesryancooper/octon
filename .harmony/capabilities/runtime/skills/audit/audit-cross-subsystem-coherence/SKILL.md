---
name: audit-cross-subsystem-coherence
description: >
  Bounded cross-subsystem coherence audit that validates alignment across
  .harmony subsystem manifests, registries, architecture docs, and quality
  gates. Detects contradictory declarations, broken cross-subsystem references,
  ownership collisions, and policy conflicts. Produces severity-tiered findings
  with stable IDs, acceptance criteria, coverage accounting, and deterministic
  convergence receipts. Read-only -- does not modify source files.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Harmony Framework
  created: "2026-02-15"
  updated: "2026-02-22"
skill_sets: [executor, guardian]
capabilities: [domain-specialized, self-validating]
allowed-tools: Read Glob Grep Write(../../output/reports/*) Write(_ops/state/logs/*)
---

# Audit Cross Subsystem Coherence

Layered coherence audit that verifies cross-subsystem contract alignment in `.harmony`.

## When to Use

Use this skill when:

- You suspect drift or conflicts between subsystem contracts
- Architecture docs and manifests may no longer agree
- Cross-subsystem references may be broken or contradictory
- You need a release gate focused on whole-harness coherence

## Quick Start

```text
/audit-cross-subsystem-coherence scope=".harmony"
```

With focused subsystems:

```text
/audit-cross-subsystem-coherence scope=".harmony" subsystems="agency,capabilities,orchestration,quality"
```

## Core Workflow

1. **Configure** -- Parse scope, subsystem list, and thresholds.
2. **Contract Graph Build** -- Enumerate manifests, registries, workflow/skill contracts, and architecture indexes.
3. **Cross-Subsystem Consistency** -- Validate IDs, paths, and ownership mappings across boundaries.
4. **Conflict and Drift Analysis** -- Detect semantic contradictions, incompatible policy statements, and unresolved links.
5. **Self-Challenge** -- Re-check for blind spots, false positives, and counter-examples.
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

Parameters are defined in `.harmony/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts optional parameters for scope, subsystem selection, docs root, severity threshold, and convergence controls (`post_remediation`, `convergence_k`, `seed_list`).

## Output Location

Output paths are defined in `.harmony/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.harmony/output/reports/analysis/YYYY-MM-DD-cross-subsystem-coherence-audit.md` -- Human-readable findings report
- `.harmony/output/reports/audits/YYYY-MM-DD-<run-id>/` -- Authoritative bounded-audit bundle
- `_ops/state/logs/audit-cross-subsystem-coherence/` -- Execution logs with index

## Severity Classification

| Severity | Definition |
| -------- | ---------- |
| CRITICAL | Conflicts that invalidate routing, execution, or governance safety |
| HIGH | Cross-subsystem contract mismatches likely to cause operational errors |
| MEDIUM | Semantic drift, stale ownership mapping, or inconsistent guidance |
| LOW | Clarity, naming, or non-blocking consistency issues |

## Done Gate

- Discovery mode (`post_remediation=false`): done-gate value is recorded for planning.
- Post-remediation mode (`post_remediation=true`): pass requires convergence stability and zero open findings at or above threshold.

## Boundaries

- **Read-only:** Never modify source files -- audit only, report findings
- Write only to designated output paths (reports and logs)
- Maximum scope: 1200 files per run (escalate if exceeded)
- Include explicit coverage proof for checked-clean artifacts
- Maintain deterministic processing order for idempotent result generation
- Emit stable finding IDs and acceptance criteria in bundle mode

## When to Escalate

- No valid subsystem contracts are found in scope
- Scope exceeds threshold and requires partitioning
- Found conflicts imply one-way-door architecture decisions
- Required docs path is missing when explicitly provided

## References

- [Behavior phases](references/phases.md)
- [I/O contract](references/io-contract.md)
- [Safety policies](references/safety.md)
- [Validation](references/validation.md)
- [Examples](references/examples.md)
- [Glossary](references/glossary.md)
