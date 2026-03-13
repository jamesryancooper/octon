---
name: merge
title: "Merge Audit Results"
description: "Build one stable release-readiness findings set with acceptance criteria and coverage accounting."
---

# Step 6: Merge Audit Results

## Purpose

Merge completed stage outputs into a stable, deduplicated release-readiness findings set.

## Actions

1. Parse available stage reports.
2. Normalize findings into common schema.
3. Deduplicate by stable ID rule (`taxonomy + location + predicate`).
4. Preserve acceptance criteria and evidence references.
5. Merge coverage metadata from available stages.
6. Compute recommendation signal:
   - `NO-GO` if blocking findings remain,
   - `CONDITIONAL-GO` for warning-only,
   - `GO` for empty blocking set.

## Output

- Unified findings set
- Unified coverage summary
- Recommendation signal and rationale

## Proceed When

- [ ] No duplicate finding IDs
- [ ] Acceptance criteria preserved
- [ ] Coverage summary includes stage-level accounting
