---
title: Weekly Evaluations Runbook
description: Procedure for producing and reviewing weekly cognition scorecard evaluations.
---

# Weekly Evaluations Runbook

## Purpose

Produce weekly scorecard evaluations under `/.octon/cognition/runtime/evaluations/digests/` from deterministic evidence sources.

## Inputs

- `/.octon/cognition/runtime/context/metrics-scorecard.md`
- CI artifacts and quality-gate outputs
- Observability traces and Knowledge Plane references

## Procedure

1. Create a weekly digest artifact under `/.octon/cognition/runtime/evaluations/digests/`.
2. Record metric snapshots and status per scorecard category.
3. Record week-over-week deltas and supporting evidence links.
4. Populate digest frontmatter machine fields:
   - `week`
   - `digest_date`
   - `status`
   - `actions` (id, owner, due_date, status, summary, evidence)
5. Run:
   - `bash .octon/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh`
6. Validate:
   - `bash .octon/cognition/_ops/runtime/scripts/validate-generated-runtime-artifacts.sh`
   - `bash .octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh`

## Required Output

Each weekly digest MUST include:

- category status (green/yellow/red),
- metric values and deltas,
- remediation actions (owner + date),
- evidence links and representative trace IDs.
