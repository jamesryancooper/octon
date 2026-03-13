---
name: assess-portfolio
title: "Assess Portfolio"
description: "Detect lifecycle gaps, overlaps, dependency cycles, and validator blind spots."
---

# Step 4: Assess Portfolio

## Purpose

Evaluate the workflow system as a portfolio rather than a bag of independent files.

## Actions

1. Check lifecycle-pair expectations from the workflow-system audit contract.
2. Detect duplicate triggers, duplicate commands, and workflow dependency cycles.
3. Detect manifest-only, registry-only, and disk-only drift.
4. Classify which findings are already enforced by `validate-workflows.sh` and which are new blind spots.

## Output

- Portfolio findings
- Validator coverage and blind-spot accounting

## Proceed When

- [ ] Lifecycle and topology checks are complete
- [ ] Blocking blind spots are identified separately from the triggering findings

## Idempotency

Portfolio analysis is a deterministic merge over the same inventory and per-workflow results.
