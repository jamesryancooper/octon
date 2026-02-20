---
title: Validation Reference
description: Acceptance criteria and verification for the audit-subsystem-health skill.
---

# Validation Reference

Acceptance criteria for a complete audit-subsystem-health execution.

## Acceptance Criteria

### Phase Completion

All 4 mandatory phases must execute to completion:

| Phase | Required | Completion Condition |
| ----- | -------- | -------------------- |
| Config Consistency | Yes | All manifest entries reconciled against registry and SKILL.md |
| Schema Conformance | Yes (if schema_ref available) | All entries validated against schema |
| Semantic Quality | Yes | All semantic checks applied |
| Self-Challenge | Yes | All 4 challenge checks executed |

### Lens Isolation

Each verification layer must complete fully before the next begins:

- [ ] Config consistency completed and findings recorded before schema conformance starts
- [ ] Schema conformance completed before semantic quality starts
- [ ] All 3 layers completed before self-challenge starts
- [ ] Findings from one layer do not influence another layer's check strategy

### Report Completeness

The output report must include:

- [ ] Executive summary with total findings and layer breakdown
- [ ] Severity distribution table
- [ ] Findings from each executed layer
- [ ] Each finding has: file path, line number (where applicable), description, severity
- [ ] Recommended fix batches (grouped by priority)
- [ ] Entries confirmed clean (proves coverage, not just findings)
- [ ] Execution metadata (date, subsystem path, entry count)

### Coverage Verification

| Check | Requirement |
| ----- | ----------- |
| All manifest entries checked | Every entry in manifest.yml was validated in all layers |
| All definition files discovered | Every SKILL.md in the subsystem was found and cross-referenced |
| All schema fields validated | Every declared skill_set, capability, and group was checked against valid values |
| All triggers analyzed | Every trigger phrase was checked for overlaps |
| Coverage proof complete | Report includes clean entries, not just findings |

### Quality Gates

| Gate | Pass Condition |
| ---- | -------------- |
| No silent failures | If a layer encounters an error, it's reported (not swallowed) |
| No false classification | Config mismatches in operational files are never classified below HIGH |
| No duplicates | Same file:line does not appear twice in the report |
| Batches are actionable | Each fix batch can be applied independently |

### Idempotency

The same subsystem + same codebase must produce substantially the same findings:

- [ ] Report includes idempotency metadata: scope hash, entry count, timestamp
- [ ] No findings depend on execution order within a layer
- [ ] No findings depend on which agent session runs the audit
- [ ] Severity classification uses fixed rules (never subjective judgment)

An audit is **idempotent** when re-running it with an unchanged subsystem produces:

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
| Subsystem directory not found | Skill stops, reports error |
| No config files found | Skill stops, reports error |
| Schema reference not found | Schema conformance layer skipped with warning |
| Write permission denied | Skill stops, reports error |
| Docs directory not found (when docs param set) | Doc alignment checks skipped with warning |

## Verification Checklist

After skill execution, verify:

1. Report exists at `.harmony/output/reports/YYYY-MM-DD-subsystem-health-audit.md`
2. Report has findings from all 3 mandatory layers (even if 0 findings)
3. Self-challenge phase executed with all 4 checks documented
4. Report includes coverage proof section (entries confirmed clean)
5. Report includes idempotency metadata (scope hash, entry count, timestamp)
6. Each layer completed fully before the next began (lens isolation)
7. Log exists at `_ops/state/logs/audit-subsystem-health/{{run_id}}.md`
8. Log index updated at `_ops/state/logs/audit-subsystem-health/index.yml`
9. No source files were modified (read-only guarantee)
10. Alignment validator passes when architecture surfaces changed:
    - `bash .harmony/assurance/_ops/scripts/validate-audit-subsystem-health-alignment.sh`
