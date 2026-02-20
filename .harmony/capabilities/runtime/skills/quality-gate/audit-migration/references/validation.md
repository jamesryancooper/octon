---
title: Validation Reference
description: Acceptance criteria and verification for the audit-migration skill.
---

# Validation Reference

Acceptance criteria for a complete audit-migration execution.

## Acceptance Criteria

### Phase Completion

All 4 mandatory phases must execute to completion:

| Phase | Required | Completion Condition |
| ----- | -------- | -------------------- |
| Grep Sweep | Yes | All mappings searched with all applicable variations |
| Cross-Reference Audit | Yes | All key files scanned, all extracted paths verified |
| Semantic Read-Through | Yes | All priority operational files read end-to-end |
| Self-Challenge | Yes | All 4 challenge checks executed (mapping coverage, blind spots, finding verification, counter-examples) |
| Structure Diff | Only if `structure_spec` provided | Filesystem compared against spec |
| Template Smoke Test | Only if `template_dir` provided | All template files scanned |

### Lens Isolation

Each verification layer must complete fully before the next begins:

- [ ] Grep sweep completed and findings recorded before cross-reference audit starts
- [ ] Cross-reference audit completed before semantic read-through starts
- [ ] All 3 layers completed before self-challenge starts
- [ ] Findings from one layer do not influence another layer's search strategy

### Report Completeness

The output report must include:

- [ ] Executive summary with total findings and layer breakdown
- [ ] Severity distribution table
- [ ] Findings from each executed layer
- [ ] Each finding has: file path, line number, description, severity
- [ ] Recommended fix batches (grouped by priority)
- [ ] Files confirmed clean (proves coverage, not just findings)
- [ ] Exclusion zones listed with rationale
- [ ] Execution metadata (date, scope, mappings count)

### Coverage Verification

| Check | Requirement |
| ----- | ----------- |
| All mappings searched | Every `old` pattern from the manifest was grepped |
| All variations attempted | 6-8 search variations per mapping (as applicable) |
| All key files scanned | Every file in the key files list was read |
| All paths checked | Every extracted path reference was verified against disk |
| Exclusions documented | Every excluded file/directory appears in the report |

### Partition-Scoped Validation (when `partition` is set)

When running in partition mode, validation criteria adjust:

| Standard Criterion | Partition Adjustment |
| ------------------ | -------------------- |
| All mappings searched | Only mappings with in-partition files must be searched |
| All key files scanned | Only key files matching `file_filter` must be scanned |
| All paths checked | Only paths extracted from in-partition files must be verified |
| Exclusions documented | Same (no change) |
| Zero unaccounted files | Applies only within partition scope |

Additional partition-specific criteria:

| Check | Requirement |
| ----- | ----------- |
| Partition metadata present | Report header includes `partition`, `file_filter`, `partition_mode: true` |
| Partition coverage recorded | Report states M files in partition of N total |
| Self-challenge notes partial scope | Self-challenge section includes deferred-merge note |
| Out-of-partition key files noted | Key files outside filter are listed as "out of partition scope" |

### Quality Gates

| Gate | Pass Condition |
| ---- | -------------- |
| No silent failures | If a layer encounters an error, it's reported (not swallowed) |
| No false classification | Findings in operational files are never classified below HIGH |
| No duplicates | Same file:line does not appear twice in the report |
| Batches are actionable | Each fix batch can be applied independently |

### Idempotency

The same manifest + same codebase must produce substantially the same findings:

- [ ] Report includes idempotency metadata: manifest hash, file count, timestamp
- [ ] No findings depend on execution order within a layer
- [ ] No findings depend on which agent session runs the audit
- [ ] Self-challenge phase checks for findings that might vary between runs
- [ ] Severity classification uses fixed rules (never subjective judgment)

An audit is **idempotent** when re-running it with an unchanged manifest against an unchanged codebase produces:

- The same set of findings (identical file:line + description)
- The same severity classifications
- The same fix batch groupings

Minor acceptable variance:

- Timestamp and run ID in metadata
- Ordering of findings within the same severity tier
- Wording differences in descriptions (substance must match)

## Failure Conditions

| Condition | Result |
| --------- | ------ |
| Migration manifest is invalid | Skill stops, reports validation error |
| No mappings in manifest | Skill stops, reports error |
| All key files missing | Layer 3 skipped with warning, other layers continue |
| Scope directory does not exist | Skill stops, reports error |
| Write permission denied for report | Skill stops, reports error |

## Verification Checklist

After skill execution, verify:

1. Report exists at `.harmony/output/reports/YYYY-MM-DD-migration-audit.md`
2. Report has findings from all 3 mandatory layers (even if 0 findings)
3. Self-challenge phase executed with all 4 checks documented
4. Report includes coverage proof section (files confirmed clean)
5. Report includes idempotency metadata (manifest hash, file count, timestamp)
6. Each layer completed fully before the next began (lens isolation)
7. Log exists at `_ops/state/logs/audit-migration/{{run_id}}.md`
8. Log index updated at `_ops/state/logs/audit-migration/index.yml`
9. No source files were modified (read-only guarantee)
10. If partition mode: report filename includes partition name
11. If partition mode: report metadata includes partition, file_filter, partition_mode
12. If partition mode: self-challenge notes partial scope with deferred-merge note
