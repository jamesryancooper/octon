---
name: audit-subsystem-health
description: >
  Bounded subsystem coherence audit that verifies internal consistency across
  config files, schema conformance against declared contracts, and semantic
  quality of triggers and naming conventions. Complements audit-migration
  (which checks post-migration reference integrity) by checking ongoing
  subsystem health independent of any migration event. Applies three mandatory
  verification layers (config consistency, schema conformance, semantic quality)
  with lens isolation, a mandatory self-challenge phase, and idempotency
  guarantees. Produces a structured findings report with coverage proof,
  severity tiers, and recommended fix batches. Read-only — does not modify
  source files.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Harmony Framework
  created: "2026-02-10"
  updated: "2026-02-10"
skill_sets: [executor, guardian]
capabilities: [domain-specialized, self-validating]
allowed-tools: Read Glob Grep Write(../../output/reports/*) Write(_ops/state/logs/*)
---

# Audit Subsystem Health

Layered coherence audit that verifies a subsystem's internal consistency, schema conformance, and semantic quality.

## When to Use

Use this skill when:

- You want to verify that a subsystem's config files agree with each other
- You need to check schema conformance against declared contracts (e.g., capabilities.yml)
- You suspect trigger overlaps, naming violations, or orphaned entries
- You want a pre-release health check before declaring a subsystem stable
- No migration occurred — you just want to know if the subsystem is coherent

## Quick Start

```
/audit-subsystem-health subsystem=".harmony/capabilities/skills"
```

With a schema reference:

```
/audit-subsystem-health subsystem=".harmony/capabilities/skills" schema_ref="capabilities.yml"
```

With companion docs:

```
/audit-subsystem-health subsystem=".harmony/capabilities/skills" docs=".harmony/cognition/_meta/architecture/skills"
```

## Core Workflow

1. **Configure** — Parse parameters, identify config files, enumerate scope, load schema reference
2. **Config Consistency** — Field-by-field reconciliation across manifest, registry, and definition files
3. **Schema Conformance** — Validate all entries against declared schema (required fields, valid enums, capability refs)
4. **Semantic Quality** — Trigger overlap detection, naming convention checks, state directory contract verification, doc-to-source alignment
5. **Self-Challenge** — Revisit findings and scope for overlooked gaps, false negatives, and counterpoints
6. **Report** — Generate structured findings report with coverage proof, severity tiers, and fix batches

### Bounded Audit Principles

This skill follows the same seven principles as `audit-migration` for stability and reproducibility:

| #   | Principle                      | What It Prevents                 |
| --- | ------------------------------ | -------------------------------- |
| 1   | Fixed lenses (layers)          | Attention drift between sessions |
| 2   | Fixed severity bar             | Calibration variance             |
| 3   | Self-challenge phase           | Incomplete passes                |
| 4   | Enumerated check patterns      | Check strategy variance          |
| 5   | Coverage manifest with proof   | Invisible gaps                   |
| 6   | Idempotency guarantee          | Session-to-session variance      |
| 7   | Lens isolation                 | Cross-lens bias                  |

## Parameters

Parameters are defined in `.harmony/capabilities/skills/registry.yml` (single source of truth).

This skill accepts one required parameter (`subsystem`) identifying the root directory to audit, plus optional parameters for schema reference path, documentation directory, severity threshold, and file type filters.

## Output Location

Output paths are defined in `.harmony/capabilities/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.harmony/output/reports/YYYY-MM-DD-subsystem-health-audit.md` — Findings report
- `_ops/state/logs/audit-subsystem-health/` — Execution logs with index

## Severity Classification

| Severity | Definition |
|----------|-----------|
| CRITICAL | Config files disagree on values that affect routing or execution (e.g., skill ID mismatch between manifest and SKILL.md) |
| HIGH | Schema violations that would fail validation (missing required fields, invalid enum values) |
| MEDIUM | Semantic quality issues (trigger overlaps, naming convention violations, doc-to-source drift) |
| LOW | Cosmetic issues, optional field gaps, informational warnings |

## Boundaries

- **Read-only:** Never modify source files — audit only, report findings
- Write only to designated output paths (reports and logs)
- Maximum scope: 500 files per layer (escalate if exceeded)
- **Lens isolation:** Complete each layer fully before starting the next — never interleave
- **Idempotency:** Same subsystem + same codebase must produce substantially the same findings
- **Coverage proof:** Report must include what was checked and found clean, not just findings

## When to Escalate

- Subsystem directory does not exist — report error
- No config files found (no manifest.yml, registry.yml, or definition files) — report error
- Scope exceeds 500 files in any single layer — warn and offer to narrow scope
- More than 100 findings in any layer — recommend phased remediation
- Schema reference file not found — warn and skip schema conformance layer

## References

For detailed documentation:

- [Behavior phases](references/phases.md) — Full phase-by-phase instructions
- [I/O contract](references/io-contract.md) — Inputs, outputs, parameter schema
- [Safety policies](references/safety.md) — Read-only policy, scope enforcement
- [Validation](references/validation.md) — Acceptance criteria for complete audits
- [Alignment contract](references/alignment-contract.md) — Drift contract for architecture-skill synchronization
- [Examples](references/examples.md) — Full audit examples
- [Glossary](references/glossary.md) — Subsystem audit terminology
