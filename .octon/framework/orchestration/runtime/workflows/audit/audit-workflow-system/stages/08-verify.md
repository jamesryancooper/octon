---
name: verify
title: "Verify"
description: "Validate done-gate outcomes, coverage accounting, and convergence metadata."
---

# Step 8: Verify

## Purpose

Fail closed if the audit outputs are incomplete or the done gate is false.

## Actions

1. Validate that all required bundle files exist.
2. Validate that `findings.yml`, `coverage.yml`, and `convergence.yml` satisfy the bounded-audit contract.
3. Validate that `scores.yml`, `portfolio.yml`, and `scenarios.yml` exist.
4. Confirm the done-gate result is recorded in both `validation.md` and `convergence.yml`.
5. Confirm `convergence_k` and `seed_list` were recorded in the convergence evidence.
6. If `post_remediation=true`, confirm K-run convergence is stable and empty at/above threshold.

## Output

- Final pass/fail result for the workflow-system audit

## Workflow Complete When

- [ ] Required bundle files exist
- [ ] Coverage unaccounted files is zero
- [ ] Stable finding IDs and acceptance criteria are present
- [ ] Done gate evaluates to true for the selected threshold

## Idempotency

Verification is a deterministic read-only pass over the emitted artifacts.
