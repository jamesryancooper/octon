---
name: merge
title: "Merge"
description: "Normalize, deduplicate, and assign stable finding IDs with acceptance criteria."
---

# Step 4: Merge

## Purpose

Consolidate all pass outputs into one authoritative findings set.

## Actions

1. Normalize findings into a common schema.
2. Deduplicate by deterministic predicate + normalized location.
3. Assign stable finding IDs per findings contract.
4. Attach acceptance criteria and evidence refs.
5. Merge coverage ledgers and compute `unaccounted_files`.

## Output

- Consolidated `findings` collection with stable IDs
- Consolidated `coverage` collection
- Deterministic merged findings hash

## Proceed When

- [ ] No duplicate finding IDs
- [ ] All findings have acceptance criteria
- [ ] Coverage shows zero unaccounted files or explicit failure state
