---
name: audit-subsystem-health
description: >
  Bounded subsystem coherence audit that verifies internal consistency across
  config files, schema conformance against declared contracts, and semantic
  quality of triggers and naming conventions. Complements audit-migration
  (which checks post-migration reference integrity) by checking ongoing
  subsystem health independent of any migration event. Applies three mandatory
  verification layers (config consistency, schema conformance, semantic quality)
  with lens isolation, a mandatory self-challenge phase, stable finding
  identity, and deterministic convergence receipts. Produces structured findings
  with coverage proof and explicit done-gate semantics. Read-only -- does not
  modify source files.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Harmony Framework
  created: "2026-02-10"
  updated: "2026-02-24"
skill_sets: [executor, guardian]
capabilities: [domain-specialized, self-validating]
allowed-tools: Read Glob Grep Write(../../output/reports/*) Write(_ops/state/logs/*)
---

# Audit Subsystem Health

Layered coherence audit that verifies a subsystem's internal consistency, schema conformance, and semantic quality.

## When to Use

Use this skill when:

- You want to verify that a subsystem's config files agree with each other
- You need to check schema conformance against declared contracts (for example `capabilities.yml`)
- You suspect trigger overlaps, naming violations, or orphaned entries
- You want a pre-release health check before declaring a subsystem stable
- No migration occurred and you still need bounded audit assurance

## Quick Start

```text
/audit-subsystem-health subsystem=".harmony/capabilities/runtime/skills"
```

With a schema reference:

```text
/audit-subsystem-health subsystem=".harmony/capabilities/runtime/skills" schema_ref="capabilities.yml"
```

With companion docs:

```text
/audit-subsystem-health subsystem=".harmony/capabilities/runtime/skills" docs=".harmony/cognition/_meta/architecture"
```

## Core Workflow

1. **Configure** -- Parse parameters, identify config files, enumerate scope, and lock severity/taxonomy.
2. **Config Consistency** -- Reconcile manifest, registry, and definition files field-by-field.
3. **Schema Conformance** -- Validate entries against declared schema constraints.
4. **Semantic Quality** -- Detect trigger overlaps, naming drift, orphaned state paths, and doc-to-source misalignment.
5. **Self-Challenge** -- Re-check for blind spots, false positives, and missing evidence.
6. **Report** -- Emit bounded findings plus coverage and convergence receipts.

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

This skill accepts one required parameter (`subsystem`) and optional audit controls for schema/docs scope, severity threshold, and convergence (`post_remediation`, `convergence_k`, `seed_list`).

## Output Location

Output paths are defined in `.harmony/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.harmony/output/reports/analysis/YYYY-MM-DD-subsystem-health-audit.md` -- Human-readable findings report
- `.harmony/output/reports/audits/YYYY-MM-DD-<run-id>/` -- Authoritative bounded-audit bundle
- `_ops/state/logs/audit-subsystem-health/` -- Execution logs with index

## Severity Classification

| Severity | Definition |
| -------- | ---------- |
| CRITICAL | Config conflicts that break routing, execution, or safety gates |
| HIGH | Schema violations or contract mismatches likely to fail runtime gates |
| MEDIUM | Semantic quality drift (trigger overlap, naming inconsistency, doc/source skew) |
| LOW | Cosmetic or non-blocking clarity issues |

## Done Gate

- Discovery mode (`post_remediation=false`): done-gate value is recorded but does not block completion.
- Post-remediation mode (`post_remediation=true`): completion requires `stable=true` and zero findings at or above threshold across `convergence_k` controlled reruns.

## Boundaries

- **Read-only:** Never modify source files -- audit only, report findings
- Write only to designated output paths (reports and logs)
- Maximum scope: 500 files per layer (escalate if exceeded)
- **Lens isolation:** Complete each layer fully before starting the next
- **Coverage proof:** Every in-scope file is scanned, summarized+sampled, or explicitly excluded with reason
- **Stable IDs:** Findings must use deterministic IDs with explicit acceptance criteria in bundle mode
- **Determinism receipt:** Include commit, seed policy, params hash, and findings hash metadata

## When to Escalate

- Subsystem directory does not exist -- report error
- No config files found (manifest/registry/definitions) -- report error
- Scope exceeds 500 files in a layer -- recommend partitioning
- More than 100 findings in one layer -- recommend phased remediation
- Schema reference file not found -- warn and skip schema conformance

## References

For detailed documentation:

- [Behavior phases](references/phases.md) -- Full phase-by-phase instructions
- [I/O contract](references/io-contract.md) -- Inputs, outputs, and bundle schema
- [Safety policies](references/safety.md) -- Read-only policy and scope enforcement
- [Validation](references/validation.md) -- Acceptance criteria and done-gate checks
- [Alignment contract](references/alignment-contract.md) -- Drift contract for architecture-skill synchronization
- [Examples](references/examples.md) -- Full audit examples
- [Glossary](references/glossary.md) -- Subsystem audit terminology
