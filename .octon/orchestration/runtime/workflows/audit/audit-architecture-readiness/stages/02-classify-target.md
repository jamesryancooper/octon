---
name: classify-target
title: "Classify Target"
description: "Resolve whole-harness, bounded-domain, or not-applicable mode before any scoring or supplemental stage runs."
---

# Step 2: Classify Target

## Purpose

Prevent unsupported targets from entering the architecture-readiness scorecard.

## Actions

1. Classify `target_path` as:
   - `whole-harness`
   - `bounded-domain`
   - `not-applicable`
2. Resolve supplemental stage run/skip matrix from the classification:
   - `whole-harness` may run `cross-subsystem-audit`
   - `bounded-domain` may run `domain-architecture-audit`
   - `not-applicable` skips both
3. Record target profile, evaluation mode, and stage applicability.

## Proceed When

- [ ] Target classification is explicit
- [ ] Supplemental stage matrix is explicit
