---
name: audit-migration
description: >
  Bounded, layered post-migration audit that systematically verifies codebase
  integrity after directory restructuring, renames, or reorganizations.
  Applies three mandatory verification layers (grep sweeps, cross-reference
  validation, semantic read-through) with lens isolation, a mandatory
  self-challenge phase, idempotency guarantees, and stable finding identity.
  Produces structured findings with coverage proof, acceptance criteria, and
  deterministic run receipts. Read-only — does not modify source files.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-02-08"
  updated: "2026-02-22"
skill_sets: [executor, guardian]
capabilities: [domain-specialized]
allowed-tools: Read Glob Grep Write(../../output/reports/*) Write(_ops/state/logs/*)
---

# Audit Migration

Layered post-migration audit that verifies codebase integrity after structural changes.

## When to Use

Use this skill when:

- A directory restructuring or migration was recently completed
- You need to verify all references were updated after renames or moves
- You suspect stale cross-references, broken paths, or conceptual staleness
- You want a comprehensive audit before declaring a migration complete

## Quick Start

```
/audit-migration manifest="migration: {name: 'restructure', mappings: [{old: '.workspace/', new: '.octon/'}]}"
```

Or with a manifest file:

```
/audit-migration manifest=".octon/migrations/restructure-manifest.yml"
```

## Core Workflow

1. **Configure** — Parse migration manifest, validate mappings, identify exclusion zones, enumerate scope manifest
2. **Grep Sweep** — Pattern-based search for all old→new mappings (8 variations per mapping)
3. **Cross-Reference Audit** — Extract paths from key files, verify each resolves on disk
4. **Semantic Read-Through** — Read key operational files, flag conceptual staleness
5. **Self-Challenge** — Revisit findings and scope for overlooked gaps, false negatives, and counterpoints
6. **Report** — Generate structured findings report with coverage proof, severity tiers, and fix batches

### Bounded Audit Principles

This skill follows eight principles for audit stability and reproducibility:

| #   | Principle                      | What It Prevents                 |
| --- | ------------------------------ | -------------------------------- |
| 1   | Fixed lenses (layers)          | Attention drift between sessions |
| 2   | Fixed severity bar             | Calibration variance             |
| 3   | Self-challenge phase           | Incomplete passes                |
| 4   | Enumerated search patterns     | Search strategy variance         |
| 5   | Coverage manifest with proof   | Invisible gaps                   |
| 6   | Idempotency guarantee          | Session-to-session variance      |
| 7   | Stable finding identity        | Finding re-key drift             |
| 8   | Lens isolation                 | Cross-lens bias                  |

### Optional Layers

- **Structure Diff** — Compare filesystem against documented structure (when `structure_spec` provided)
- **Template Smoke Test** — Scan template directories for stale patterns (when `template_dir` provided)

### Partition Mode (Optional)

When `partition` and `file_filter` are provided, the skill runs in partition mode — a scoped execution designed for parallel orchestration. In this mode:

- **Scope is narrowed** by `file_filter` (glob pattern applied within `scope` directory)
- **Report filename** includes the partition name: `YYYY-MM-DD-migration-audit-{partition}.md`
- **Report metadata** includes `partition`, `file_filter`, and `partition_mode: true`
- **Coverage proof** is partition-scoped (proves coverage for the filtered slice only)
- **Self-challenge** notes this is a partial audit (global self-challenge deferred to merge)
- **Validation relaxes** key file completeness (some key files may live in other partitions)

When `partition` is not set, the skill operates identically to its non-partitioned behavior. Partition mode is backward compatible.

See the companion workflow `audit-orchestration` at `.octon/orchestration/runtime/workflows/audit/audit-orchestration/` for coordinated parallel execution.

## Parameters

Parameters are defined in `.octon/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts one required parameter (`manifest`) describing the migration mappings and exclusions, plus optional bounded-audit controls (scope, threshold, partition controls, and convergence controls) defined in the registry.

## Output Location

Output paths are defined in `.octon/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.octon/output/reports/analysis/YYYY-MM-DD-migration-audit.md` — Findings report (unified mode)
- `.octon/output/reports/analysis/YYYY-MM-DD-migration-audit-{partition}.md` — Findings report (partition mode)
- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/` — Authoritative bounded-audit bundle (when orchestrated)
- `_ops/state/logs/audit-migration/` — Execution logs with index

## Severity Classification

| Severity | Definition |
|----------|-----------|
| CRITICAL | Operational files with broken paths that cause workflow failures |
| HIGH | Active files with stale references that mislead agents or humans |
| MEDIUM | Non-operational files (docs, examples) with incorrect references |
| LOW | Cosmetic or historical issues, terminology drift |

## Boundaries

- **Read-only:** Never modify source files — audit only, report findings
- Write only to designated output paths (reports and logs)
- Respect exclusion zones defined in the migration manifest
- Do not flag findings in explicitly excluded files
- Maximum scope: 500 files per layer (escalate if exceeded)
- **Lens isolation:** Complete each layer fully before starting the next — never interleave
- **Idempotency:** Same manifest + same codebase must produce substantially the same findings
- **Coverage proof:** Report must include what was checked and found clean, not just findings
- **Stable IDs:** Findings should be emitted with deterministic IDs and acceptance criteria in orchestrated mode
- **Determinism receipt:** Runs should record seed/fingerprint policy and findings hash
- **Partition scope:** When in partition mode, all layers operate within the filtered file set only

## When to Escalate

- Migration manifest is missing or has no mappings — report error
- Scope exceeds 500 files in any single layer — warn and offer to narrow scope
- More than 100 findings in grep sweep alone — recommend phased remediation
- Exclusion zone conflicts with key operational files — ask for clarification

## References

For detailed documentation:

- [Behavior phases](references/phases.md) — Full phase-by-phase instructions
- [I/O contract](references/io-contract.md) — Inputs, outputs, migration manifest schema
- [Safety policies](references/safety.md) — Read-only policy, exclusion zone enforcement
- [Validation](references/validation.md) — Acceptance criteria for complete audits
- [Examples](references/examples.md) — Full audit examples from real migrations
- [Glossary](references/glossary.md) — Migration audit terminology
