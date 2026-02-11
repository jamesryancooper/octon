---
name: report
title: "Generate Pre-Release Report"
description: "Generate consolidated pre-release readiness report."
---

# Step 5: Generate Pre-Release Report

## Input

- Unified findings collection from step 4
- Go/no-go recommendation from step 4
- Individual audit report paths from steps 2–3

## Purpose

Produce a single consolidated report that combines all audit findings, presents a release-readiness assessment, and links to the individual audit reports for details.

## Actions

1. **Generate consolidated report:**

   Write to `.harmony/output/reports/YYYY-MM-DD-pre-release-audit.md`:

   ```markdown
   # Pre-Release Audit Report

   **Date:** YYYY-MM-DD
   **Subsystem:** {{subsystem}}
   **Migration manifest:** {{manifest_path|not provided}}
   **Companion docs:** {{docs_path|not provided}}
   **Audits run:** {{list of audits}}

   ## Release Readiness

   **Recommendation: {{GO|CONDITIONAL-GO|NO-GO}}**

   {{rationale}}

   | Criterion | Result | Threshold |
   |-----------|--------|-----------|
   | CRITICAL findings | {{count}} | 0 |
   | HIGH operational findings | {{count}} | Review required |
   | Audit coverage | {{percentage}} | Both audits pass |

   ## Executive Summary

   **Total findings: {{total}} across {{file_count}} files**

   ### By Audit

   | Audit | Status | Findings |
   |-------|--------|----------|
   | Migration (reference integrity) | {{completed|skipped|failed}} | {{count}} |
   | Health (subsystem coherence) | {{completed|failed}} | {{count}} |

   ### By Severity

   | Severity | Count | Impact |
   |----------|-------|--------|
   | CRITICAL | {{n}} | Blocker |
   | HIGH | {{n}} | Warning |
   | MEDIUM | {{n}} | Advisory |
   | LOW | {{n}} | Advisory |

   ## Blocker Findings (CRITICAL)
   [If any — these must be resolved before release]

   ## Warning Findings (HIGH)
   [Findings requiring review before release]

   ## Advisory Findings (MEDIUM + LOW)
   [Can be addressed post-release]

   ## Recommended Fix Batches

   ### Batch 1: Release blockers ({{n}} findings)
   [CRITICAL findings from either audit]

   ### Batch 2: Pre-release recommended ({{n}} findings)
   [HIGH findings in operational files]

   ### Batch 3: Post-release follow-up ({{n}} findings)
   [MEDIUM + LOW findings]

   ## Coverage Summary

   | Dimension | Coverage |
   |-----------|----------|
   | Migration mappings checked | {{n/n}} |
   | Config entries reconciled | {{n/n}} |
   | Schema fields validated | {{n/n}} |
   | Semantic checks applied | {{n/n}} |
   | Self-challenge passes | {{n/n}} |

   ## Individual Reports

   - [Migration Audit Report]({{migration_report_path}}) {{if available}}
   - [Health Audit Report]({{health_report_path}}) {{if available}}

   ## Audit Methodology

   This report was produced by the `pre-release-audit` workflow, which chains:
   1. `audit-migration` — Post-migration reference integrity (grep sweep, cross-ref, semantic read-through)
   2. `audit-subsystem-health` — Subsystem coherence (config consistency, schema conformance, semantic quality)

   Both skills follow bounded audit principles: fixed lenses, lens isolation, self-challenge, and idempotency guarantees.
   ```

2. **Write execution log:**

   Log to `_state/logs/` or workflow checkpoint directory.

## Idempotency

**Check:** Consolidated report already exists for today's date.

- [ ] `.harmony/output/reports/YYYY-MM-DD-pre-release-audit.md` exists

**If Already Complete:**

- Skip generation, report cached
- Re-run if merge results have changed

**Marker:** `checkpoints/pre-release-audit/05-report.complete`

## Error Messages

- Write failed: "REPORT_WRITE_FAILED: Cannot write to .harmony/output/reports/"

## Output

- Consolidated pre-release audit report
- Path to report for verification step

## Proceed When

- [ ] Report written to `.harmony/output/reports/YYYY-MM-DD-pre-release-audit.md`
- [ ] Go/no-go recommendation is clearly stated
