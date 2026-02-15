---
name: configure
title: "Configure"
description: "Parse migration manifest, resolve parameters, and enumerate full scope for partition planning."
---

# Step 1: Configure

## Input

- Migration manifest (inline YAML or file path)
- Scope directory (default: `.`)
- Severity threshold (default: `all`)
- Partition strategy (default: `by-directory`)
- Optional: `concern_map`, `partition_count`, `docs`, `run_cross_subsystem`, `run_freshness`, `max_age_days`, `structure_spec`, `template_dir`

## Purpose

Parse and validate the migration manifest, normalize stage controls, then enumerate the complete file list. This step produces partition planning inputs plus a deterministic execution plan for optional global stages.

## Actions

1. **Parse parameters and defaults:**

   | Parameter | Required | Default | Purpose |
   | --------- | -------- | ------- | ------- |
   | `manifest` | Yes | — | Migration mapping source |
   | `scope` | No | `.` | Root directory to scan |
   | `severity_threshold` | No | `all` | Minimum severity to report |
   | `strategy` | No | `by-directory` | Partition strategy |
   | `run_cross_subsystem` | No | `true` | Enable cross-subsystem global stage |
   | `run_freshness` | No | `true` | Enable freshness global stage |
   | `max_age_days` | No | `30` | Freshness threshold in days |
   | `docs` | No | — | Companion docs root for alignment checks |

2. **Parse the migration manifest:**

   Use the same validation rules as the `audit-migration` skill:

   - `mappings` must be a non-empty list
   - Each mapping must have `old` and `new` fields
   - `old` must be non-empty
   - No duplicate `old` patterns
   - `old` and `new` must differ

3. **Resolve exclusion zones:**

   Convert exclusion patterns to concrete path lists. Include default exclusions (`node_modules/`, `.git/`, `dist/`, `build/`, `.history/`, `.specstory/`).

4. **Enumerate the full scope file list:**

   ```text
   1. Glob all files in scope directory
   2. Apply exclusion filters
   3. Sort alphabetically (deterministic order)
   4. Record total: "Full scope: N files in M directories"
   ```

5. **Count files by directory and type** (for partition planning):

   ```text
   | Directory | File Count |
   | docs/ | 45 |
   | .harmony/agency/ | 32 |
   | .harmony/capabilities/ | 68 |
   | ... | ... |
   ```

6. **Verify required skill availability:**

   - `audit-migration` must be active
   - If `run_cross_subsystem=true`, `audit-cross-subsystem-coherence` must be active
   - If `run_freshness=true`, `audit-freshness-and-supersession` must be active

7. **Record configuration summary and execution plan:**

   - Manifest name and mapping count
   - Exclusion count
   - Total files in scope
   - Partition strategy selected
   - Cross-subsystem stage: run/skip
   - Freshness stage: run/skip
   - Freshness max age (days)
   - Docs path (if provided)

## Idempotency

**Check:** Configuration summary already exists in checkpoint.

- [ ] Checkpoint file exists at `checkpoints/orchestrate-audit/01-configure.complete`
- [ ] Manifest hash matches current manifest
- [ ] Stage-control parameters match current invocation

**If Already Complete:**

- Skip to step 2
- Re-run if manifest or stage parameters changed

**Marker:** `checkpoints/orchestrate-audit/01-configure.complete`

## Error Messages

- Invalid manifest: `MANIFEST_INVALID: {validation error}`
- Empty scope: `SCOPE_EMPTY: No files found in scope after exclusions`
- Scope directory missing: `SCOPE_NOT_FOUND: Directory '{scope}' does not exist`
- Missing required skill: `SKILL_NOT_AVAILABLE: {skill-id} is not active in the skill manifest`

## Output

- Validated migration manifest
- Full scope file list (sorted, exclusions applied)
- File counts by directory and type
- Configuration summary and global-stage execution plan

## Proceed When

- [ ] Manifest is valid (all validation rules pass)
- [ ] Scope has at least 1 file after exclusions
- [ ] Required skills for enabled stages are active
- [ ] Configuration summary and stage plan recorded
