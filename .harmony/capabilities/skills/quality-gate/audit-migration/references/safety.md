---
title: Safety Reference
description: Safety policies and behavioral constraints for the audit-migration skill.
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Output paths: .harmony/capabilities/skills/registry.yml
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# Safety Reference

Safety policies and behavioral constraints for the audit-migration skill.

> **Authoritative Sources:**
>
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Output paths: `.harmony/capabilities/skills/registry.yml`

## Tool Policy

### Mode

Deny-by-default

Allowed tools are defined in SKILL.md `allowed-tools` frontmatter (single source of truth).

This skill requires:

- Read access to codebase files (for all layers)
- Glob for file discovery and path existence verification
- Grep for pattern-based search
- Write access to report output directory
- Write access to execution log directory

This skill explicitly does **NOT** have:

- Edit access (no source file modifications)
- Bash access (no shell commands)
- Task access (no sub-agent delegation)

## File Policy

### Read Scope

The skill reads files across the entire codebase within the defined scope. No read restrictions beyond standard filesystem permissions.

### Write Scope

The skill may only write to:

- `.harmony/output/reports/` — Audit report deliverable
- `.harmony/capabilities/skills/logs/audit-migration/` — Execution logs

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

## Exclusion Zone Enforcement

Exclusion zones defined in the migration manifest are enforced across all layers:

1. **Grep Sweep:** Matches in excluded files are silently filtered out
2. **Cross-Reference Audit:** Excluded files are not scanned for path references
3. **Semantic Read-Through:** Excluded files are not read for semantic analysis
4. **Report:** Excluded files are listed in the "Exclusion Zones" section for transparency

### Default Exclusion Patterns

Even without user-defined exclusions, the skill always excludes:

| Pattern | Reason |
| ------- | ------ |
| `node_modules/` | Third-party code |
| `.git/` | Version control internals |
| `dist/`, `build/` | Build outputs |
| `.history/` | Conversation history (not part of harness) |
| `.specstory/` | Spec history (not part of harness) |

### Append-Only File Handling

Files with `mutability: append-only` in frontmatter are:

- **Included** in grep sweep (their content is scanned for stale patterns)
- **Flagged** with a note that findings are informational only
- **NOT** recommended for modification in fix batches
- **Listed** separately in the report under "Historical/Append-Only Findings"

## Scope Signals

| Metric | Threshold | Action |
| ------ | --------- | ------ |
| Files in grep sweep scope | >500 | Warn, offer to narrow scope |
| Key files for cross-ref | >50 | Warn, prioritize operational files |
| Findings in single layer | >100 | Recommend phased remediation |
| Total findings | >200 | Recommend mission-level coordination |

## Lens Isolation

Each verification layer operates in isolation to prevent cross-lens bias:

### Isolation Rules

1. **Sequential execution only** — Complete one layer fully before starting the next
2. **No cross-pollination** — Findings from layer N must not alter the search strategy of layer N+1
3. **Independent severity** — Each layer classifies its own findings independently; deduplication happens only in the report phase
4. **No early termination** — A high finding count in one layer does not cause another layer to be skipped

### Execution Order

Layers execute in fixed order (grep sweep → cross-reference → semantic → self-challenge → report). This order is intentional:

- Grep sweep runs first because it's cheapest and catches the most obvious issues
- Cross-reference runs second because it checks structural integrity independently of text patterns
- Semantic read-through runs third because it requires the most attention and catches what the others miss
- Self-challenge runs after all layers to review the combined output with fresh eyes
- Report runs last to consolidate, deduplicate, and structure all findings

### What Isolation Prevents

| Violation | Risk |
| --------- | ---- |
| Reading grep findings before cross-ref | Cross-ref may only check paths near grep hits, missing isolated broken references |
| Skipping semantic after "enough" grep findings | Conceptual staleness is invisible to grep — it would go undetected |
| Adjusting severity mid-audit based on finding volume | Severity drift across layers makes the report inconsistent |

## Behavioral Boundaries

- Never modify source files
- Never skip a layer (all 3 mandatory layers + self-challenge must execute)
- Never report findings in excluded files
- Never interleave layers — complete each fully before starting the next
- Always document exclusion zones in the report
- Always list clean files to prove coverage
- Always deduplicate findings across layers (in report phase only)
- Always include idempotency metadata in the report
- Stop and report if manifest validation fails
- Escalate if scope thresholds are exceeded

## Partition Scope Safety

When running in partition mode:

### Scope Containment

- The skill only reads files matching the `file_filter` within the `scope` directory
- Findings are only recorded for files within the partition
- Cross-partition references (paths pointing to files outside the partition) are noted but not classified as findings
- The skill never modifies its behavior for files outside the partition

### Report Isolation

- Partition reports are self-contained and do not reference other partition reports
- Each partition report uses its own filename: `YYYY-MM-DD-migration-audit-{partition}.md`
- Partition reports do not claim global coverage — they explicitly state they are partition-scoped

### No Cross-Partition Coordination

- The skill in partition mode does NOT communicate with other partition instances
- It does NOT read other partition reports
- It does NOT deduplicate across partitions (that is the orchestration workflow's responsibility)
- It does NOT perform global self-challenge (deferred to merge step)

## Escalation Triggers

| Trigger | Action |
| ------- | ------ |
| Invalid migration manifest | Report error, cannot proceed |
| Scope >500 files | Warn, offer to narrow scope |
| >100 findings in one layer | Recommend phased approach |
| Key file does not exist | Note in report, continue |
| Exclusion conflicts with key file | Ask for clarification |
