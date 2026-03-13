---
name: configure
title: "Configure Release Readiness Audit Workflow"
description: "Parse parameters and build bounded stage plan with deterministic controls."
---

# Step 1: Configure Release Readiness Audit Workflow

## Input

- `scope` (required)
- `severity_threshold` (default `all`)
- `run_operational` (default `true`)
- `run_api_contract` (default `true`)
- `run_test_quality` (default `true`)
- `run_observability` (default `true`)
- `run_security` (default `true`)
- `run_data_governance` (default `true`)
- `post_remediation` (default `false`)
- `convergence_k` (default `3`)
- `seed_list` (optional)

## Purpose

Build an explicit layered execution plan and done-gate mode before any stage runs.

## Actions

1. Validate `scope` exists and is readable.
2. Resolve run/skip matrix for all supplemental layers.
3. Confirm mandatory release-core layer is enabled.
4. Verify required skill dependencies for all enabled layers.
5. Record deterministic controls (`post_remediation`, `convergence_k`, `seed_list`) for downstream report metadata.
6. Persist bounded execution plan.

## Proceed When

- [ ] Stage plan is explicit
- [ ] Dependency checks pass
- [ ] Deterministic controls are recorded
