---
name: audit-api-contract
description: >
  Bounded API-contract audit that verifies contract definition coverage,
  implementation conformance, compatibility and versioning safeguards, and
  evidence readiness for release gates. Applies fixed audit layers with lens
  isolation, stable finding IDs, acceptance criteria, coverage accounting, and
  deterministic convergence receipts. Produces structured findings suitable for
  pre-release and post-remediation gates. Read-only -- does not modify source
  files.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-02-23"
  updated: "2026-02-23"
skill_sets: [executor, guardian]
capabilities: [domain-specialized, self-validating]
allowed-tools: Read Glob Grep Write(/.octon/state/evidence/validation/analysis/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Audit API Contract

Layered API-contract audit that verifies contract definitions, implementation conformance, compatibility posture, and evidence-backed gate readiness across a target scope.

## When to Use

Use this skill when:

- You need a deterministic API-contract gate before release
- You suspect drift between declared contracts and implementation surfaces
- You need to verify compatibility, versioning, and deprecation safeguards
- You need evidence-backed readiness checks for interface governance

## Quick Start

```text
/audit-api-contract scope=".octon/framework/capabilities/runtime/services/interfaces"
```

With explicit baseline references:

```text
/audit-api-contract scope=".octon" contract_baseline_ref=".octon/framework/cognition/governance/principles/contract-first.md" api_design_baseline_ref=".octon/framework/scaffolding/governance/patterns/api-design-guidelines.md"
```

With stricter threshold:

```text
/audit-api-contract scope=".octon/framework/capabilities/runtime/services/interfaces" severity_threshold="high"
```

## Core Workflow

1. **Configure** -- Parse parameters, resolve scope, and lock layers plus severity rules.
2. **Contract Definition and Specification Coverage** -- Verify contract and schema artifacts are complete, coherent, and traceable.
3. **Implementation and Compatibility Conformance** -- Verify implementations align with declared contracts and compatibility controls.
4. **Versioning, Deprecation, and Evidence Readiness** -- Verify versioning/deprecation posture and gate evidence for critical interfaces.
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

Parameters are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts one required parameter (`scope`) and optional controls for contract/design baselines, artifact discovery globs, severity threshold, and convergence (`post_remediation`, `convergence_k`, `seed_list`).

## Output Location

Output paths are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.octon/state/evidence/validation/analysis/YYYY-MM-DD-api-contract-audit-<run-id>.md` -- Structured findings report
- `.octon/state/evidence/validation/audits/YYYY-MM-DD-<run-id>/` -- Authoritative bounded-audit bundle
- `/.octon/state/evidence/runs/skills/audit-api-contract/` -- Execution logs with index

## Severity Classification

| Severity | Definition |
| -------- | ---------- |
| CRITICAL | Missing or broken API-contract controls on critical paths likely to cause unsafe interface breakage or release failure |
| HIGH | Material contract coverage or compatibility gap that weakens release confidence |
| MEDIUM | Partial or inconsistent contract artifacts reducing traceability and assurance |
| LOW | Non-blocking clarity issues, stale references, or minor consistency drift |

## Done Gate

- Discovery mode (`post_remediation=false`): done-gate value is recorded for planning.
- Post-remediation mode (`post_remediation=true`): pass requires convergence stability and zero open findings at or above threshold.

## Boundaries

- **Read-only:** Never modify source files in audited scope
- Write only to designated output paths (reports and logs)
- Coverage claims must be evidence-backed (file-path and section-level where possible)
- If evidence is insufficient, mark explicit unknowns rather than inferring contract conformance
- Apply lens isolation: complete each layer before moving to the next

## When to Escalate

- `scope` does not exist or cannot be read
- Scope exceeds 500 files in a mandatory layer (recommend partitioning)
- Both contract and API-design baselines are unavailable and no reliable fallback can be established
- Findings indicate one-way-door risk (for example, critical interface drift without rollback compatibility evidence)

## References

- [Behavior phases](references/phases.md)
- [I/O contract](references/io-contract.md)
- [Safety policies](references/safety.md)
- [Validation](references/validation.md)
- [Examples](references/examples.md)
- [Glossary](references/glossary.md)
- [Decisions](references/decisions.md)
- [Checkpoints](references/checkpoints.md)
