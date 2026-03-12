---
title: Safety Reference
description: Safety policies and constraints for the audit-subsystem-health skill.
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Output paths: .harmony/capabilities/runtime/skills/registry.yml
#
# Current allowed-tools: Read Glob Grep Write(../../output/reports/*) Write(_ops/state/logs/*)
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# Safety Reference

Safety policies and behavioral constraints for the audit-subsystem-health skill.

> **Authoritative Sources:**
>
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Output paths: `.harmony/capabilities/runtime/skills/registry.yml`

## Tool Policy

### Mode

Deny-by-default

Allowed tools are defined in SKILL.md `allowed-tools` frontmatter (single source of truth).

This skill requires:

- Read access to subsystem files (for all layers)
- Glob for file discovery and path existence verification
- Grep for pattern-based search and trigger analysis
- Write access to report output directory
- Write access to execution log directory

This skill explicitly does **NOT** have:

- Edit access (no source file modifications)
- Bash access (no shell commands)
- Task access (no sub-agent delegation)

## File Policy

### Read Scope

The skill reads files within the subsystem directory and optionally the companion docs directory. No read restrictions beyond standard filesystem permissions.

### Write Scope

The skill may only write to:

- `.harmony/output/reports/analysis/` — Audit report deliverable
- `.harmony/capabilities/runtime/skills/_ops/state/logs/audit-subsystem-health/` — Execution logs

### Source Code Modifications

None. This skill is **read-only**. It never modifies source files, configuration, or any file outside the two designated output directories. This is a fundamental safety guarantee — an audit should never change what it's auditing.

### Destructive Actions

None. The skill:

- **Does NOT** modify any source files
- **Does NOT** delete any files
- **Does NOT** rename or move any files
- **Does NOT** run shell commands
- **Does NOT** commit to git
- **Does** create new report files (non-destructive)
- **Does** create/update log files (non-destructive)

## Scope Signals

| Metric | Threshold | Action |
| ------ | --------- | ------ |
| Files in scope | >500 | Warn, offer to narrow scope |
| Entries to validate | >100 | Warn, offer to filter by group |
| Findings in single layer | >100 | Recommend phased remediation |
| Total findings | >200 | Recommend mission-level coordination |

## Lens Isolation

Each verification layer operates in isolation to prevent cross-lens bias:

### Isolation Rules

1. **Sequential execution only** — Complete one layer fully before starting the next
2. **No cross-pollination** — Findings from layer N must not alter the check strategy of layer N+1
3. **Independent severity** — Each layer classifies its own findings independently; deduplication happens only in the report phase
4. **No early termination** — A high finding count in one layer does not cause another layer to be skipped

### Execution Order

Layers execute in fixed order (config consistency → schema conformance → semantic quality → self-challenge → report). This order is intentional:

- Config consistency runs first because it validates the foundation (do entries agree?)
- Schema conformance runs second because it checks structural validity against declared contracts
- Semantic quality runs third because it requires understanding meaning beyond structure
- Self-challenge runs after all layers to review the combined output with fresh eyes
- Report runs last to consolidate, deduplicate, and structure all findings

### What Isolation Prevents

| Violation | Risk |
| --------- | ---- |
| Reading consistency findings before schema check | Schema check may only validate entries near inconsistencies, missing other violations |
| Skipping semantic after "enough" schema findings | Trigger overlaps and doc drift would go undetected |
| Adjusting severity mid-audit based on finding volume | Severity drift across layers makes the report inconsistent |

## Behavioral Boundaries

- Never modify source files
- Never skip a layer (all 3 mandatory layers + self-challenge must execute)
- Never interleave layers — complete each fully before starting the next
- Always document what was checked and found clean (coverage proof)
- Always deduplicate findings across layers (in report phase only)
- Always include idempotency metadata in the report
- Stop and report if subsystem directory does not exist
- Escalate if scope thresholds are exceeded

## Escalation Triggers

| Trigger | Action |
| ------- | ------ |
| Subsystem directory not found | Report error, cannot proceed |
| No config files found | Report error, cannot proceed |
| Schema reference not found | Warn, skip schema conformance layer |
| Scope >500 files | Warn, offer to narrow scope |
| >100 findings in one layer | Recommend phased approach |
| Write permission denied for report | Report error, cannot proceed |
