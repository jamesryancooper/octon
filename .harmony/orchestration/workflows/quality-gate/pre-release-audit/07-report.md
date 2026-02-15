---
name: report
title: "Generate Pre-Release Report"
description: "Generate consolidated pre-release readiness report."
---

# Step 7: Generate Pre-Release Report

## Input

- Unified findings collection from step 6
- Go/no-go recommendation from step 6
- Individual report paths from steps 2–5

## Purpose

Produce a consolidated pre-release report with a release recommendation, merged findings, coverage proof, and links to all contributing audit reports.

## Actions

1. **Generate consolidated report:**

   Write to `.harmony/output/reports/YYYY-MM-DD-pre-release-audit.md`:

   ```markdown
   # Pre-Release Audit Report

   **Date:** YYYY-MM-DD
   **Subsystem:** {{subsystem}}
   **Migration manifest:** {{manifest_path|not provided}}
   **Companion docs:** {{docs_path|not provided}}
   **Audits run:** {{list of completed/skipped/failed stages}}

   ## Release Readiness

   **Recommendation: {{GO|CONDITIONAL-GO|NO-GO}}**

   {{rationale}}

   | Criterion | Result | Threshold |
   |-----------|--------|-----------|
   | CRITICAL findings | {{count}} | 0 |
   | HIGH operational findings | {{count}} | Review required |
   | Audit coverage | {{percentage}} | All planned stages executed or explicitly skipped |

   ## Executive Summary

   **Total findings: {{total}} across {{file_count}} files**

   ### By Audit Stage

   | Audit Stage | Status | Findings |
   |-------------|--------|----------|
   | Migration (reference integrity) | {{completed|skipped|failed}} | {{count}} |
   | Health (subsystem coherence) | {{completed|failed}} | {{count}} |
   | Cross-subsystem coherence | {{completed|skipped|failed}} | {{count}} |
   | Freshness and supersession | {{completed|skipped|failed}} | {{count}} |

   ### By Severity

   | Severity | Count | Impact |
   |----------|-------|--------|
   | CRITICAL | {{n}} | Blocker |
   | HIGH | {{n}} | Warning |
   | MEDIUM | {{n}} | Advisory |
   | LOW | {{n}} | Advisory |

   ## Blocker Findings (CRITICAL)
   [If any]

   ## Warning Findings (HIGH)
   [If any]

   ## Advisory Findings (MEDIUM + LOW)
   [If any]

   ## Recommended Fix Batches

   ### Batch 1: Release blockers ({{n}} findings)
   [CRITICAL]

   ### Batch 2: Pre-release recommended ({{n}} findings)
   [HIGH operational]

   ### Batch 3: Post-release follow-up ({{n}} findings)
   [MEDIUM + LOW]

   ## Coverage Summary

   | Dimension | Coverage |
   |-----------|----------|
   | Migration mappings checked | {{n/n}} |
   | Subsystem health layers completed | {{n/n}} |
   | Cross-subsystem contract edges validated | {{n/n}} |
   | Freshness checks applied | {{n/n}} |
   | Supersession chains validated | {{n/n}} |

   ## Individual Reports

   - [Migration Audit Report]({{migration_report_path}}) {{if available}}
   - [Health Audit Report]({{health_report_path}}) {{if available}}
   - [Cross-Subsystem Coherence Report]({{cross_subsystem_report_path}}) {{if available}}
   - [Freshness And Supersession Report]({{freshness_report_path}}) {{if available}}

   ## Audit Methodology

   This report was produced by `pre-release-audit`, which orchestrates:
   1. `audit-migration`
   2. `audit-subsystem-health`
   3. `audit-cross-subsystem-coherence`
   4. `audit-freshness-and-supersession`
   ```

2. **Write execution log:**

   Write workflow log/checkpoint metadata for verification.

## Idempotency

**Check:** Consolidated report already exists for today's date.

- [ ] `.harmony/output/reports/YYYY-MM-DD-pre-release-audit.md` exists

**If Already Complete:**

- Reuse cached report
- Re-run if merge results changed

**Marker:** `checkpoints/pre-release-audit/07-report.complete`

## Error Messages

- Write failed: `REPORT_WRITE_FAILED: Cannot write pre-release audit report`

## Output

- Consolidated report path

## Proceed When

- [ ] Report written to `.harmony/output/reports/YYYY-MM-DD-pre-release-audit.md`
- [ ] Recommendation is explicit with rationale
