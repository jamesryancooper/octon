---
name: configure
title: "Configure Architecture Readiness Audit Workflow"
description: "Parse parameters and build a bounded execution plan with deterministic controls."
---

# Step 1: Configure Architecture Readiness Audit Workflow

## Input

- `target_path` (required)
- `severity_threshold` (default `all`)
- `run_cross_subsystem` (default `true`)
- `run_domain_architecture` (default `true`)
- `post_remediation` (default `false`)
- `convergence_k` (default `3`)
- `seed_list` (optional)

## Purpose

Build an explicit execution plan and done-gate mode before any stage runs.

## Actions

1. Validate `target_path` exists and is readable.
2. Record deterministic controls (`post_remediation`, `convergence_k`, `seed_list`).
3. Record requested supplemental stages without deciding applicability yet.
4. Persist bounded execution plan.

## Proceed When

- [ ] Stage plan is explicit
- [ ] Deterministic controls are recorded
