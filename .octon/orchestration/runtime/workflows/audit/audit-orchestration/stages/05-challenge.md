---
name: challenge
title: "Challenge"
description: "Run cross-partition and self-consistency challenge checks."
---

# Step 5: Challenge

## Purpose

Stress-test merged findings for false positives, missed scope, and unstable identity.

## Actions

1. Validate cross-partition references and boundary integrity.
2. Reconcile contradictory pass outcomes.
3. Re-run deterministic hash check on merged findings.
4. Mark invalidated findings with evidence.
5. Record challenge outcomes (added, removed, unchanged findings).

## Output

- Challenged findings set
- Challenge outcome summary

## Proceed When

- [ ] Boundary integrity checked
- [ ] Contradictions resolved or documented
- [ ] Stable findings hash recorded
