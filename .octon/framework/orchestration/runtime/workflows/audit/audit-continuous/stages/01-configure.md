---
name: configure
title: "Configure Continuous Audit"
description: "Parse parameters and build bounded stage plan with deterministic recurring controls."
---

# Step 1: Configure Continuous Audit

## Input

- `subsystem` (required)
- `docs` (optional)
- `severity_threshold` (default `all`)
- `cadence` (default `weekly`)
- `lookback_days` (default `7`)
- `run_operational` (default `true`)
- `run_api_contract` (default `true`)
- `run_test_quality` (default `true`)
- `run_security` (default `true`)
- `run_data_governance` (default `true`)
- `run_cross_subsystem` (default `true`)
- `run_freshness` (default `true`)
- `max_age_days` (default `30`)
- `post_remediation` (default `false`)
- `convergence_k` (default `3`)
- `seed_list` (optional)

## Purpose

Build an explicit layered execution plan and continuous-cadence metadata before any stage runs.

## Actions

1. Validate `subsystem` exists and is readable.
2. Validate optional `docs` when provided.
3. Validate `cadence` in allowed set (`daily`, `weekly`).
4. Validate `lookback_days` and `max_age_days` are positive integers.
5. Resolve run/skip matrix for supplemental layers.
6. Confirm mandatory layers (subsystem-health and observability) are enabled.
7. Verify required skill dependencies for all enabled layers.
8. Record deterministic controls (`post_remediation`, `convergence_k`, `seed_list`) and cadence metadata (`cadence`, `lookback_days`).
9. Persist bounded execution plan.

## Proceed When

- [ ] Stage plan is explicit
- [ ] Dependency checks pass
- [ ] Deterministic controls are recorded
