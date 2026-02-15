---
name: audit-freshness-and-supersession
description: >
  Bounded staleness audit that checks freshness and supersession integrity for
  .harmony operational artifacts, including context docs, decision records,
  plans, and reports. Detects stale artifacts relative to changed source
  surfaces, missing superseded-by chains, orphaned historical files, and
  contradictory current-state markers. Produces severity-tiered findings with
  remediation batches and coverage proof. Read-only — does not modify source
  files.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Harmony Framework
  created: "2026-02-15"
  updated: "2026-02-15"
skill_sets: [executor, guardian]
capabilities: [domain-specialized, self-validating]
allowed-tools: Read Glob Grep Write(../../output/reports/*) Write(_ops/state/logs/*)
---

# Audit Freshness And Supersession

Layered freshness audit that verifies staleness controls and supersession chains across `.harmony` artifacts.

## When to Use

Use this skill when:

- You suspect stale plans, reports, or context records are still treated as current
- Supersession chains may be missing or inconsistent
- Changed architecture surfaces may not be reflected in downstream artifacts
- You need a release gate for document freshness hygiene

## Quick Start

```text
/audit-freshness-and-supersession scope=".harmony"
```

With explicit age threshold:

```text
/audit-freshness-and-supersession scope=".harmony" max_age_days="30"
```

## Core Workflow

1. **Configure** — Parse scope, artifact classes, and thresholds
2. **Artifact Inventory** — Enumerate target files and map freshness anchors
3. **Freshness Checks** — Detect stale artifacts relative to source changes and age thresholds
4. **Supersession Integrity** — Validate supersedes/superseded-by chains and current-state markers
5. **Self-Challenge** — Verify findings and search for missed stale paths
6. **Report** — Emit severity-tiered findings, batches, and coverage proof

## Parameters

Parameters are defined in `.harmony/capabilities/skills/registry.yml` (single source of truth).

This skill accepts optional parameters for scope, artifact selection, maximum age threshold, and severity filtering.

## Output Location

Output paths are defined in `.harmony/capabilities/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.harmony/output/reports/YYYY-MM-DD-freshness-and-supersession-audit.md` — Findings report
- `_ops/state/logs/audit-freshness-and-supersession/` — Execution logs with index

## Severity Classification

| Severity | Definition |
|----------|-----------|
| CRITICAL | Current-state guidance points to stale/invalid artifacts likely to cause bad execution |
| HIGH | Missing or broken supersession links on authoritative artifacts |
| MEDIUM | Stale but non-authoritative artifacts or inconsistent freshness metadata |
| LOW | Formatting, metadata completeness, or non-blocking archival hygiene issues |

## Boundaries

- **Read-only:** Never modify source files — audit only, report findings
- Write only to designated output paths (reports and logs)
- Maximum scope: 1500 files per run (escalate if exceeded)
- Evaluate freshness using deterministic ordering and explicit thresholds
- Include checked-clean proof, not only findings

## When to Escalate

- No target artifact families found in scope
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
