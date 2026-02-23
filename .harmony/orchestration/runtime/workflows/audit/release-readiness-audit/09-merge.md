---
name: merge
title: "Merge Stage Results"
description: "Merge layered stage findings into one stable release-readiness recommendation set."
---

# Step 9: Merge Stage Results

## Purpose

Build one stable finding set and unified coverage/convergence summary across all executed layers.

## Actions

1. Parse available stage reports from steps 2-8.
2. Normalize findings into a common schema.
3. Deduplicate by stable-ID rule (`taxonomy + layer + location + predicate`).
4. Preserve acceptance criteria and evidence references.
5. Merge coverage ledgers and unresolved unknowns from executed stages.
6. Compute recommendation signal:
   - `NO-GO` when blocking findings remain,
   - `CONDITIONAL-GO` when only non-blocking concerns remain,
   - `GO` when no open findings exist at or above threshold.

## Output

- Unified findings set
- Unified coverage summary
- Recommendation and rationale inputs for report step

## Proceed When

- [ ] No duplicate stable finding IDs remain
- [ ] Acceptance criteria preserved for merged findings
- [ ] Coverage summary includes stage-level accounting
