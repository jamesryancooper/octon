---
name: configure
title: "Configure"
description: "Parse migration manifest and enumerate full scope for partition planning."
---

# Step 1: Configure

## Input

- Migration manifest (inline YAML or file path)
- Scope directory (default: `.`)
- Severity threshold (default: `all`)
- Partition strategy (default: `by-directory`)
- Optional: `concern_map`, `partition_count`, `structure_spec`, `template_dir`

## Purpose

Parse and validate the migration manifest, then enumerate the complete file list. This step produces the inputs needed for partition planning in step 2.

## Actions

1. **Parse the migration manifest:**

   Use the same validation rules as the `audit-migration` skill:

   - `mappings` must be a non-empty list
   - Each mapping must have `old` and `new` fields
   - `old` must be non-empty
   - No duplicate `old` patterns
   - `old` and `new` must differ

2. **Resolve exclusion zones:**

   Convert exclusion patterns to concrete path lists. Include default exclusions (`node_modules/`, `.git/`, `dist/`, `build/`, `.history/`, `.specstory/`).

3. **Enumerate the full scope file list:**

   ```text
   1. Glob all files in scope directory
   2. Apply exclusion filters
   3. Sort alphabetically (deterministic order)
   4. Record total: "Full scope: N files in M directories"
   ```

4. **Count files by directory and type** (for partition planning):

   ```text
   | Directory | File Count |
   | docs/ | 45 |
   | .harmony/agency/ | 32 |
   | .harmony/capabilities/ | 68 |
   | ... | ... |
   ```

5. **Record configuration summary:**

   - Manifest name and mapping count
   - Exclusion count
   - Total files in scope
   - Partition strategy selected

## Idempotency

**Check:** Configuration summary already exists in checkpoint.

- [ ] Checkpoint file exists at `checkpoints/orchestrate-audit/01-configure.complete`
- [ ] Manifest hash matches current manifest

**If Already Complete:**

- Skip to step 2
- Re-run if manifest has changed

**Marker:** `checkpoints/orchestrate-audit/01-configure.complete`

## Error Messages

- Invalid manifest: "MANIFEST_INVALID: {validation error}"
- Empty scope: "SCOPE_EMPTY: No files found in scope after exclusions"
- Scope directory missing: "SCOPE_NOT_FOUND: Directory '{scope}' does not exist"

## Output

- Validated migration manifest
- Full scope file list (sorted, exclusions applied)
- File counts by directory and type
- Configuration summary

## Proceed When

- [ ] Manifest is valid (all validation rules pass)
- [ ] Scope has at least 1 file after exclusions
- [ ] Configuration summary recorded
