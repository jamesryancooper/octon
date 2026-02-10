---
name: report
title: "Report"
description: "Generate consolidated report combining all partition results with global challenge."
---

# Step 6: Report

## Input

- Final findings collection, post-global-challenge (from step 5)
- Merged coverage stats (from step 4)
- Partition plan (from step 2)
- Global challenge results (from step 5)

## Purpose

Generate the consolidated report that combines all partition results with the global challenge into a single deliverable. This is the primary output of the orchestrated audit.

## Actions

1. **Assign final severity** to each finding (may be adjusted by global challenge).

2. **Group into fix batches** (same logic as the skill: Critical, High, Medium, Low groupings).

3. **Generate consolidated report** at `.harmony/output/reports/YYYY-MM-DD-migration-audit-consolidated.md`:

   ```markdown
   # Post-Migration Audit Report (Consolidated)

   **Date:** YYYY-MM-DD
   **Migration:** {{migration.name}}
   **Scope:** {{scope}} (N files scanned)
   **Audit Mode:** Partitioned (K partitions)
   **Bounded audit:** 7 principles enforced

   ## Executive Summary

   **Total findings: N across M files (K partitions)**

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

   ## Partition Summary

   | Partition | Files | Findings | Status |
   | --------- | ----- | -------- | ------ |
   | docs | 45 | 12 | Complete |
   | harmony-agency | 32 | 8 | Complete |
   | ... | ... | ... | ... |

   ## Findings by Layer
   [All findings, annotated with source partition]

   ## Global Self-Challenge Results
   [Cross-partition checks, boundary integrity, global mapping coverage]

   ## Recommended Fix Batches
   [Grouped by priority; may group cross-partition issues together]

   ## Coverage Proof
   [Global coverage = union of all partition coverage proofs]

   ## Per-Partition Reports
   [Links to individual partition reports for drill-down]

   ## Exclusion Zones
   [Global exclusion list]

   ## Idempotency Metadata
   [Manifest hash, partition plan hash, file count, sorted file list hash]
   ```

4. **Write execution log** for the orchestration run:

   Log to `.harmony/capabilities/skills/logs/audit-migration/{{run_id}}-consolidated.md`.

5. **Preserve individual partition reports:**

   Do not delete partition reports. The consolidated report links to them for detailed drill-down.

## Idempotency

**Check:** Consolidated report already exists at expected path.

- [ ] Report file exists at `.harmony/output/reports/YYYY-MM-DD-migration-audit-consolidated.md`
- [ ] Report matches current findings (check idempotency metadata)

**If Already Complete:**

- Skip to step 7
- Re-run if findings have changed

**Marker:** `checkpoints/orchestrate-audit/06-report.complete`

## Error Messages

- Write failure: "REPORT_WRITE_FAILED: Could not write consolidated report: {error}"
- Missing findings: "REPORT_NO_FINDINGS: No findings to report (this may indicate a problem)"

## Output

- Consolidated report at `.harmony/output/reports/YYYY-MM-DD-migration-audit-consolidated.md`
- Execution log at `.harmony/capabilities/skills/logs/audit-migration/{{run_id}}-consolidated.md`

## Proceed When

- [ ] Consolidated report written
- [ ] Execution log written
- [ ] Individual partition reports preserved
