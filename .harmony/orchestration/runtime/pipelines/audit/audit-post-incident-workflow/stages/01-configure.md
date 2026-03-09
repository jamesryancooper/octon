---
name: configure
title: "Configure Post-Incident Audit"
description: "Parse incident parameters and build bounded stage plan with deterministic controls."
---

# Step 1: Configure Post-Incident Audit

## Input

- `incident_id` (required)
- `subsystem` (required)
- `incident_report` (optional)
- `docs` (optional)
- `severity_threshold` (default `all`)
- `run_security` (default `true`)
- `run_data_governance` (default `true`)
- `run_api_contract` (default `true`)
- `run_test_quality` (default `true`)
- `run_cross_subsystem` (default `true`)
- `run_freshness` (default `true`)
- `max_age_days` (default `30`)
- `post_remediation` (default `false`)
- `convergence_k` (default `3`)
- `seed_list` (optional)

## Purpose

Capture incident context and lock a deterministic layered execution plan before running incident-closure checks.

## Actions

1. Validate required inputs (`incident_id`, `subsystem`).
2. Validate optional `incident_report` and `docs` when provided.
3. Resolve run/skip matrix for optional layers.
4. Confirm mandatory layers (operational and observability) are enabled.
5. Verify required skill dependencies for all enabled stages.
6. Record deterministic controls (`post_remediation`, `convergence_k`, `seed_list`).
7. Persist bounded execution plan with incident context summary.

## Proceed When

- [ ] Stage plan is explicit
- [ ] Dependency checks pass
- [ ] Deterministic controls are recorded
