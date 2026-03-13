---
name: configure
title: "Configure Pre-Release Audit"
description: "Parse parameters and build bounded stage plan with deterministic controls."
---

# Step 1: Configure Pre-Release Audit

## Input

- `subsystem` (required)
- `manifest` (optional)
- `docs` (optional)
- `severity_threshold` (default `all`)
- `run_cross_subsystem` (default `true`)
- `run_freshness` (default `true`)
- `max_age_days` (default `30`)
- `post_remediation` (default `false`)
- `convergence_k` (default `3`)
- `seed_list` (optional)

## Purpose

Build a bounded stage plan with explicit done-gate evaluation semantics.

## Actions

1. Validate subsystem path and optional manifest/docs paths.
2. Resolve run/skip matrix for migration, health, cross-subsystem, and freshness stages.
3. Verify required skill/workflow dependencies for enabled stages.
4. Record deterministic controls (`post_remediation`, `convergence_k`, `seed_list`).
5. Persist execution plan for downstream merge/report.

## Proceed When

- [ ] Stage plan is explicit
- [ ] Dependency checks pass
- [ ] Deterministic controls are recorded
