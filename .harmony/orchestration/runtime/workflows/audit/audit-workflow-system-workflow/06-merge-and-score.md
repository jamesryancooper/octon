---
name: merge-and-score
title: "Merge and Score"
description: "Deduplicate issues into stable findings and compute workflow/system scores."
---

# Step 6: Merge and Score

## Purpose

Turn raw issues into one stable, bounded audit result.

## Actions

1. Normalize issues into deterministic finding IDs using the bounded-audit findings contract.
2. Deduplicate repeated predicates at the same location.
3. Compute per-workflow scores and the system-level scorecard.
4. Evaluate the blocking threshold against the consolidated findings set.

## Output

- `findings.yml`
- `scores.yml`
- `portfolio.yml`
- Initial done-gate inputs

## Proceed When

- [ ] Findings are deduplicated and stable
- [ ] Scorecard artifacts are generated
- [ ] Blocking/non-blocking split is explicit

## Idempotency

Stable finding identity is required. The same location and predicate must reuse the same ID.
