---
name: run-scenarios
title: "Run Scenarios"
description: "Run representative workflow rehearsals for core and external-dependent surfaces."
---

# Step 5: Run Scenarios

## Purpose

Prove that a fixed representative slice of the workflow system can be resolved and rehearsed deterministically.

## Actions

1. Load the named scenario pack from `.harmony/orchestration/governance/workflow-system-audit-v1.yml`.
2. For `mode=full`, resolve the workflow, materialize parameters, walk the step graph or inline flow, and confirm verification is reachable.
3. For `mode=prereq-only`, stop before side-effectful generation and validate prerequisites, format, and execution-profile expectations.
4. Record machine-readable scenario results in `scenarios.yml`.

## Output

- Representative scenario results
- Scenario-failure findings when representative workflows cannot be rehearsed

## Proceed When

- [ ] Scenario pack executed or explicitly disabled
- [ ] Failed rehearsals are converted into findings with evidence

## Idempotency

The representative scenario pack is fixed by contract and must produce stable results for the same inputs.
