---
name: audit-security-compliance
description: >
  Bounded security and compliance audit that verifies policy-control coverage,
  secrets and access-control safeguards, dependency and supply-chain evidence,
  and compliance-readiness artifacts. Applies fixed audit layers with lens
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

# Audit Security Compliance

Layered security and compliance audit that verifies policy and control coverage, secrets and access safeguards, and evidence readiness across a target scope.

## When to Use

Use this skill when:

- You need a pre-release security and compliance gate with deterministic findings
- You suspect drift between declared security policy and implemented controls
- You need to verify secrets handling and authorization enforcement coverage
- You need evidence-backed readiness checks for compliance or governance reviews

## Quick Start

```text
/audit-security-compliance scope=".octon/framework/capabilities/runtime/services"
```

With explicit baseline references:

```text
/audit-security-compliance scope=".octon/framework/capabilities/runtime/services" policy_baseline_ref=".octon/framework/assurance/practices/standards/security-and-privacy.md" control_baseline_ref=".octon/framework/cognition/practices/methodology/security-baseline.md"
```

With stricter threshold:

```text
/audit-security-compliance scope=".octon" severity_threshold="high"
```

## Core Workflow

1. **Configure** -- Parse parameters, resolve scope, and lock layers plus severity rules.
2. **Policy and Control Coverage** -- Verify policy baselines and control artifacts are present, aligned, and actionable.
3. **Secrets and Access Safeguards** -- Verify secrets handling and authorization enforcement artifacts exist for in-scope critical paths.
4. **Dependency and Evidence Readiness** -- Verify dependency/supply-chain evidence and compliance receipts are present and traceable.
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

This skill accepts one required parameter (`scope`) and optional controls for policy/control baselines, artifact discovery globs, severity threshold, and convergence (`post_remediation`, `convergence_k`, `seed_list`).

## Output Location

Output paths are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.octon/state/evidence/validation/analysis/YYYY-MM-DD-security-compliance-audit-<run-id>.md` -- Structured findings report
- `.octon/state/evidence/validation/audits/YYYY-MM-DD-<run-id>/` -- Authoritative bounded-audit bundle
- `/.octon/state/evidence/runs/skills/audit-security-compliance/` -- Execution logs with index

## Severity Classification

| Severity | Definition |
| -------- | ---------- |
| CRITICAL | Missing or broken controls on critical paths that can permit unauthorized access, secrets leakage, or non-compliant release |
| HIGH | Material security or compliance coverage gap likely to fail governance gates or incident readiness expectations |
| MEDIUM | Partial or inconsistent controls/evidence reducing assurance or traceability |
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
- Both policy and control baselines are unavailable and no reliable fallback can be established
- Findings indicate one-way-door risk (for example, critical access-control or secrets-safety gaps)

## References

- [Behavior phases](references/phases.md)
- [I/O contract](references/io-contract.md)
- [Safety policies](references/safety.md)
- [Validation](references/validation.md)
- [Examples](references/examples.md)
- [Glossary](references/glossary.md)
- [Decisions](references/decisions.md)
- [Checkpoints](references/checkpoints.md)
