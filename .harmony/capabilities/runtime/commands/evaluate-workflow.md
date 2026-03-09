---
title: Evaluate Workflow
description: Assess a canonical pipeline and its workflow projection.
access: agent
argument-hint: <path>
---

# Evaluate Workflow `/evaluate-workflow`

Assess a canonical pipeline together with its workflow projection for contract
integrity, projection drift, and authoring quality.

## Usage

```text
/evaluate-workflow <path>
```

## Implementation

Execute the canonical pipeline at:

- `/.harmony/orchestration/runtime/pipelines/meta/evaluate-workflow/`

The evaluation should score:

1. Canonical pipeline contract quality
2. Stage asset completeness
3. Projection integrity
4. Drift and validation risk

## Output

An evaluation report that tells the operator whether the canonical pipeline and
its workflow projection remain aligned.
