---
name: report
title: "Report"
description: "Generate consolidated report combining partition results with global challenge and optional global audits."
---

# Step 8: Report

## Input

- Final findings collection, post-global-challenge (from step 5)
- Merged coverage stats (from step 4)
- Partition plan (from step 2)
- Global challenge results (from step 5)
- Cross-subsystem audit status/report (from step 6)
- Freshness audit status/report (from step 7)

## Purpose

Generate the consolidated report that combines partitioned migration findings with global-stage outcomes into a single deliverable.

## Actions

1. **Assign final severity** to each partitioned migration finding (may be adjusted by global challenge).

2. **Group into fix batches** (same logic as the skill: Critical, High, Medium, Low groupings).

3. **Read optional global-stage reports** (if completed):

   - `.harmony/output/reports/YYYY-MM-DD-cross-subsystem-coherence-audit.md`
   - `.harmony/output/reports/YYYY-MM-DD-freshness-and-supersession-audit.md`

   Extract summary counts and blocker-level signals for recommendation context.

4. **Generate consolidated report** at `.harmony/output/reports/YYYY-MM-DD-migration-audit-consolidated.md`:

   ```markdown
   # Post-Migration Audit Report (Consolidated)

   **Date:** YYYY-MM-DD
   **Migration:** {{migration.name}}
   **Scope:** {{scope}} (N files scanned)
   **Audit Mode:** Partitioned (K partitions)
   **Bounded audit:** 7 principles enforced

   ## Executive Summary

   **Total migration findings: N across M files (K partitions)**

   | Layer | Findings |
   | ----- | -------- |
   | Grep Sweep | N |
   | Cross-Reference Audit | N |
   | Semantic Read-Through | N |
   | Self-Challenge (partition) | N |
   | Self-Challenge (global) | N |

   | Severity | Count |
   | -------- | ----- |
   | CRITICAL | N |
   | HIGH | N |
   | MEDIUM | N |
   | LOW | N |

   ## Optional Global Stage Summary

   | Stage | Status | Findings |
   | ----- | ------ | -------- |
   | Cross-subsystem coherence | {{completed|skipped|failed}} | {{count|n/a}} |
   | Freshness and supersession | {{completed|skipped|failed}} | {{count|n/a}} |

   ## Consolidated Recommendation

   **Recommendation: {{GO|CONDITIONAL-GO|NO-GO}}**

   {{rationale referencing migration + optional global stages}}

   ## Partition Summary

   | Partition | Files | Findings | Status |
   | --------- | ----- | -------- | ------ |
   | docs | 45 | 12 | Complete |
   | harmony-agency | 32 | 8 | Complete |
   | ... | ... | ... | ... |

   ## Findings by Layer
   [All partition findings, annotated with source partition]

   ## Global Self-Challenge Results
   [Cross-partition checks, boundary integrity, global mapping coverage]

   ## Recommended Fix Batches
   [Grouped by priority; may group cross-partition issues together]

   ## Coverage Proof
   [Global coverage = union of all partition coverage proofs]

   ## Optional Global Stage Reports

   - [Cross-Subsystem Coherence Report]({{cross_subsystem_report_path}}) {{if completed}}
   - [Freshness And Supersession Report]({{freshness_report_path}}) {{if completed}}

   ## Per-Partition Reports
   [Links to individual partition reports for drill-down]

   ## Exclusion Zones
   [Global exclusion list]

   ## Idempotency Metadata
   [Manifest hash, partition plan hash, file count, sorted file list hash, global stage parameters]
   ```

5. **Write execution log** for the orchestration run:

   Log to `.harmony/capabilities/skills/_ops/state/logs/audit-migration/{{run_id}}-consolidated.md`.

6. **Preserve individual partition reports:**

   Do not delete partition reports. The consolidated report links to them for detailed drill-down.

## Idempotency

**Check:** Consolidated report already exists at expected path.

- [ ] Report file exists at `.harmony/output/reports/YYYY-MM-DD-migration-audit-consolidated.md`
- [ ] Report matches current findings and stage parameters (check idempotency metadata)

**If Already Complete:**

- Skip to step 9
- Re-run if findings or global-stage outputs changed

**Marker:** `checkpoints/orchestrate-audit/08-report.complete`

## Error Messages

- Write failure: `REPORT_WRITE_FAILED: Could not write consolidated report: {error}`
- Missing findings: `REPORT_NO_FINDINGS: No findings to report (this may indicate a problem)`

## Output

- Consolidated report at `.harmony/output/reports/YYYY-MM-DD-migration-audit-consolidated.md`
- Execution log at `.harmony/capabilities/skills/_ops/state/logs/audit-migration/{{run_id}}-consolidated.md`

## Proceed When

- [ ] Consolidated report written
- [ ] Execution log written
- [ ] Individual partition reports preserved
