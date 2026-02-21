---
name: merge
title: "Merge"
description: "Collect partition reports, extract findings, and deduplicate across partitions."
---

# Step 4: Merge

## Input

- List of partition report paths (from step 3)
- List of failed partitions (from step 3)

## Purpose

Read all partition reports, collect findings, and deduplicate across partitions. This produces a unified findings collection for the global self-challenge and consolidated report.

## Actions

1. **Read each partition report:**

   For each successful partition report, extract:

   - All findings (file, line, description, severity, layer)
   - Coverage proof stats (files scanned, files with findings, files clean)
   - Self-challenge results from the partition
   - Partition metadata (name, file count, filter)

2. **Deduplicate findings:**

   Primary key: `file:line` + `layer`

   - If the same `file:line` appears in multiple partition reports (possible at partition boundaries), keep the entry with the highest severity
   - Note which partitions flagged the same finding
   - This should be rare if partitions are properly disjoint

3. **Merge coverage proofs:**

   ```text
   Total files scanned = sum across partitions
   Total files with findings = sum across partitions (after dedup)
   Total files confirmed clean = sum across partitions
   Verify: total files across partitions = total files in full scope
   ```

   If the totals don't match, flag as a coverage gap.

4. **Flag failed partitions:**

   - Any partition that did not produce a report is flagged as "incomplete coverage"
   - Record which files were in the failed partition (from the partition plan)
   - These files appear as "unaudited" in the coverage proof

5. **Record merge summary:**

   ```markdown
   ## Merge Summary

   - Partition reports read: K of K total
   - Total findings (pre-dedup): N
   - Duplicates removed: M
   - Total findings (post-dedup): N - M
   - Coverage: X files audited of Y total
   - Failed partitions: Z (list)
   ```

## Idempotency

**Check:** Merge summary already exists in checkpoint.

- [ ] Checkpoint file exists at `checkpoints/orchestrate-audit/04-merge.complete`
- [ ] All partition reports match current run

**If Already Complete:**

- Skip to step 5
- Re-run if any partition report has changed

**Marker:** `checkpoints/orchestrate-audit/04-merge.complete`

## Error Messages

- No reports found: "MERGE_NO_REPORTS: No partition reports exist to merge"
- Coverage gap: "MERGE_GAP: {N} files not covered by any partition report"
- Read failure: "MERGE_READ_FAILED: Could not read partition report at '{path}'"

## Output

- Merged findings collection (deduplicated)
- Merged coverage stats
- Failed partition list with impact assessment
- Merge summary

## Proceed When

- [ ] All available partition reports have been read
- [ ] Findings deduplicated
- [ ] Coverage stats merged and verified
- [ ] Failed partition impacts documented
