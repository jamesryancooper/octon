---
name: configure
title: Configure Design Package Audit
description: Resolve target package, mode, bundle paths, and expected stage set.
---

# Step 1: Configure Design Package Audit

## Input

- `package_path` (required)
- `mode` (optional, default `rigorous`)
- `output_slug` (optional)
- `summary_root` (optional, default `.harmony/output/reports`)
- `bundle_root` (optional, default `.harmony/output/reports/audits`)

## Purpose

Validate the target package, resolve the selected pipeline mode, and create a
bounded execution plan before any stage runs.

## Actions

1. Validate that `package_path` exists and is a directory.
2. Resolve `mode`:
   - default to `rigorous`
   - accept only `rigorous` or `short`
3. Derive `slug` from `output_slug` or the target package directory name.
4. Record the expected stage set for the selected mode from the canonical
   pipeline contract.
6. Persist `plan.md` with:
   - package path
   - mode
   - slug
   - selected stages
   - expected report paths

## Output

- Validated execution plan at `bundle/plan.md`
- Resolved bundle root and report root
- Recorded selected stage set

## Proceed When

- [ ] Target package exists
- [ ] Mode is valid
- [ ] Canonical pipeline contract exists
- [ ] Execution plan is recorded
