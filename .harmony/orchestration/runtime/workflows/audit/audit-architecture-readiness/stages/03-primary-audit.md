---
name: primary-audit
title: "Run Primary Architecture Readiness Audit"
description: "Run the primary audit-architecture-readiness skill and capture its verdict and outputs."
---

# Step 3: Run Primary Architecture Readiness Audit

## Purpose

Obtain the primary readiness verdict and structured outputs from the canonical
audit skill.

## Actions

1. Invoke `audit-architecture-readiness` with:
   - `target_path`
   - `severity_threshold`
   - `post_remediation`
   - `convergence_k`
   - `seed_list`
2. Capture:
   - markdown report
   - summary JSON
   - bounded-audit bundle metadata
3. Preserve the skill's target classification and primary verdict.

## Proceed When

- [ ] Primary report exists
- [ ] Summary JSON exists
- [ ] Target classification and verdict are explicit
