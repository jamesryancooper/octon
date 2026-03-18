---
name: merge
title: "Merge Stage Results"
description: "Merge primary and supplemental evidence into one stable architecture-readiness recommendation set."
---

# Step 6: Merge Stage Results

## Purpose

Build one stable finding set and unified recommendation across all executed
stages.

## Actions

1. Parse the primary audit outputs from step 3.
2. Parse supplemental reports from steps 4 and 5 when present.
3. Preserve the primary target classification as authoritative.
4. Normalize and deduplicate findings by stable-ID rule.
5. Preserve acceptance criteria and evidence references.
6. Compute consolidated recommendation:
   - `NOT-APPLICABLE` when the primary audit is not applicable
   - `NOT-IMPLEMENTATION-READY` when blocking findings remain
   - `CONDITIONALLY-IMPLEMENTATION-READY` when only non-blocking concerns remain
   - `IMPLEMENTATION-READY` when no open findings exist at or above threshold

## Output

- Unified findings set
- Unified coverage summary
- Consolidated recommendation and rationale inputs for report step

## Proceed When

- [ ] No duplicate stable finding IDs remain
- [ ] Primary classification is preserved
- [ ] Coverage summary includes stage-level accounting
