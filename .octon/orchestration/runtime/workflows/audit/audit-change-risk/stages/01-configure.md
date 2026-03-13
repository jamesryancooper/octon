---
name: configure
title: "Configure Change Risk Audit"
description: "Parse parameters and build bounded stage plan with deterministic controls."
---

# Step 1: Configure Change Risk Audit

## Input

- `subsystem` (required)
- `manifest` (optional)
- `docs` (optional)
- `severity_threshold` (default `all`)
- `run_migration` (default `true`)
- `run_api_contract` (default `true`)
- `run_test_quality` (default `true`)
- `run_operational` (default `true`)
- `run_cross_subsystem` (default `true`)
- `run_freshness` (default `true`)
- `max_age_days` (default `30`)
- `post_remediation` (default `false`)
- `convergence_k` (default `3`)
- `seed_list` (optional)

## Purpose

Build a deterministic layered execution plan and explicit done-gate mode before running audits.

## Actions

1. Validate `subsystem` path and optional `manifest`/`docs` paths.
2. Resolve run/skip matrix for all stages.
3. If `manifest` is missing, force migration stage to skip with explicit rationale.
4. Verify required dependencies for enabled stages.
5. Record deterministic controls (`post_remediation`, `convergence_k`, `seed_list`).
6. Persist bounded execution plan.

## Proceed When

- [ ] Stage plan is explicit
- [ ] Dependency checks pass
- [ ] Deterministic controls are recorded
