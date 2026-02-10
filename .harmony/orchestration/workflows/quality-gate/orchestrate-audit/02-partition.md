---
name: partition
title: "Partition"
description: "Divide the audit scope into disjoint partitions for parallel execution."
---

# Step 2: Partition

## Input

- Full scope file list (from step 1)
- File counts by directory and type (from step 1)
- Partition strategy parameter
- Optional: `concern_map` (for `by-concern`), `partition_count` (for `auto`)

## Purpose

Divide the scope into disjoint partitions, each with a label and file filter glob. Every file in scope must belong to exactly one partition. The partition plan drives parallel dispatch in step 3.

## Actions

1. **Select partition strategy:**

   | Strategy | How It Works | When to Use |
   | -------- | ------------ | ----------- |
   | `by-directory` | Split at top-level directories within scope | Default; good for organized codebases |
   | `by-type` | Split by file extension groups | When migration affects specific file types differently |
   | `by-concern` | Use provided `concern_map` (manual groupings) | When domain boundaries don't align with directory structure |
   | `auto` | Split into N roughly equal partitions by file count | When no logical grouping exists |

2. **Execute the selected strategy:**

   **`by-directory` (default):**

   - List top-level directories in scope
   - Each directory becomes a partition: label = directory name, filter = `{dir}/**`
   - Files at the scope root become a `root-files` partition: filter = `*` (non-recursive)

   **`by-type`:**

   - Group files by extension:
     - `markdown`: `**/*.md`
     - `config`: `**/*.{yml,yaml,json}`
     - `code`: `**/*.{ts,js,py,sh}`
     - `other`: everything else
   - Each group becomes a partition

   **`by-concern`:**

   - Read the `concern_map` parameter (YAML mapping of label to glob pattern list)
   - Each concern becomes a partition
   - Example:

     ```yaml
     concern_map:
       docs: ["docs/**"]
       agency: [".harmony/agency/**"]
       capabilities: [".harmony/capabilities/**"]
       orchestration: [".harmony/orchestration/**", ".harmony/continuity/**"]
       config: ["**/*.yml", "**/*.yaml", "**/*.json"]
     ```

   **`auto`:**

   - Sort all files alphabetically
   - Split into `partition_count` groups (default: 6)
   - Label as `partition-1`, `partition-2`, etc.

3. **Validate partition plan:**

   - Every file in scope must belong to exactly one partition (no gaps, no overlaps)
   - Each partition must have at least 1 file
   - Warn if any partition exceeds 500 files (skill scope limit per layer)

4. **Record partition plan:**

   ```markdown
   | # | Partition | Filter | File Count |
   | - | --------- | ------ | ---------- |
   | 1 | docs | docs/** | 45 |
   | 2 | harmony-agency | .harmony/agency/** | 32 |
   | 3 | harmony-capabilities | .harmony/capabilities/** | 68 |
   | ... | ... | ... | ... |

   Total: K partitions covering N files
   ```

## Idempotency

**Check:** Partition plan already exists in checkpoint.

- [ ] Checkpoint file exists at `checkpoints/orchestrate-audit/02-partition.complete`
- [ ] Partition plan covers all files in scope

**If Already Complete:**

- Skip to step 3
- Re-run if scope file list has changed

**Marker:** `checkpoints/orchestrate-audit/02-partition.complete`

## Error Messages

- Gap detected: "PARTITION_GAP: {N} files not covered by any partition"
- Overlap detected: "PARTITION_OVERLAP: {N} files appear in multiple partitions"
- Empty partition: "PARTITION_EMPTY: Partition '{label}' has zero files"
- Oversize partition: "PARTITION_LARGE: Partition '{label}' has {N} files (>500); consider narrowing"

## Output

- Partition plan: list of `{label, file_filter, file_count}` entries
- Validation result (pass/warn/fail)

## Proceed When

- [ ] Partition plan has at least 1 partition
- [ ] All files accounted for (no gaps)
- [ ] No empty partitions
- [ ] Oversize warnings acknowledged (if any)
