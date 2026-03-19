---
name: audit-data-governance
description: >
  Bounded data-governance audit that verifies data classification policy
  coverage, retention and deletion controls, lineage and provenance
  traceability, privacy safeguards, and evidence readiness for governance
  gates. Applies fixed audit layers with lens isolation, stable finding IDs,
  acceptance criteria, coverage accounting, and deterministic convergence
  receipts. Produces structured findings suitable for pre-release and
  post-remediation gates. Read-only -- does not modify source files.
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

# Audit Data Governance

Layered data-governance audit that verifies classification, retention, lineage, privacy safeguards, and governance evidence readiness across a target scope.

## When to Use

Use this skill when:

- You need a deterministic data-governance gate before release
- You suspect drift in classification, retention, or provenance documentation
- You need to verify privacy safeguards and data-contract traceability
- You need evidence-backed readiness checks for governance and compliance reviews

## Quick Start

```text
/audit-data-governance scope=".octon"
```

With explicit baseline references:

```text
/audit-data-governance scope=".octon" classification_baseline_ref=".octon/framework/assurance/practices/standards/data-handling-and-retention.md" privacy_baseline_ref=".octon/framework/assurance/practices/standards/security-and-privacy.md"
```

With stricter threshold:

```text
/audit-data-governance scope=".octon/framework/capabilities/runtime/services" severity_threshold="high"
```

## Core Workflow

1. **Configure** -- Parse parameters, resolve scope, and lock layers plus severity rules.
2. **Classification and Retention Coverage** -- Verify classification policy artifacts align with retention and deletion controls.
3. **Lineage and Contract Traceability** -- Verify data lineage, provenance, and contract metadata are present and linkable.
4. **Privacy Safeguards and Evidence Readiness** -- Verify privacy safeguards and governance evidence artifacts for in-scope critical paths.
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

This skill accepts one required parameter (`scope`) and optional controls for classification/privacy baselines, artifact discovery globs, severity threshold, and convergence (`post_remediation`, `convergence_k`, `seed_list`).

## Output Location

Output paths are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.octon/state/evidence/validation/analysis/YYYY-MM-DD-data-governance-audit-<run-id>.md` -- Structured findings report
- `.octon/state/evidence/validation/audits/YYYY-MM-DD-<run-id>/` -- Authoritative bounded-audit bundle
- `/.octon/state/evidence/runs/skills/audit-data-governance/` -- Execution logs with index

## Severity Classification

| Severity | Definition |
| -------- | ---------- |
| CRITICAL | Missing or broken data-governance controls on critical paths that can cause policy breach, data leakage, or non-compliant retention |
| HIGH | Material governance gap in classification, retention, lineage, privacy safeguards, or evidence readiness |
| MEDIUM | Partial or inconsistent governance artifacts reducing traceability or assurance |
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
- Both classification and privacy baselines are unavailable and no reliable fallback can be established
- Findings indicate one-way-door risk (for example, missing retention policy controls for sensitive classes)

## References

- [Behavior phases](references/phases.md)
- [I/O contract](references/io-contract.md)
- [Safety policies](references/safety.md)
- [Validation](references/validation.md)
- [Examples](references/examples.md)
- [Glossary](references/glossary.md)
- [Decisions](references/decisions.md)
- [Checkpoints](references/checkpoints.md)
