---
name: partition
title: "Partition"
description: "Divide scope into disjoint partitions with explicit coverage accounting."
---

# Step 2: Partition

## Purpose

Create disjoint partitions so each in-scope file belongs to exactly one partition.

## Actions

1. Apply partition strategy (`by-directory`, `by-type`, `by-concern`, `auto`).
2. Validate no gaps and no overlaps.
3. Record partition coverage map (`file -> partition`).
4. Produce partition plan with file counts and filters.

## Output

- Partition plan
- Partition coverage map

## Proceed When

- [ ] No file gaps
- [ ] No overlaps
- [ ] Every partition has at least one file
