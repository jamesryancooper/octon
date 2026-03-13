---
title: Evaluate Workflow
description: Assess a canonical workflow and its workflow README.
access: agent
argument-hint: <path>
---

# Evaluate Workflow `/evaluate-workflow`

Assess a canonical workflow together with its workflow README for contract
integrity, README drift, and authoring quality.

## Usage

```text
/evaluate-workflow <path>
```

## Implementation

Execute the canonical workflow at:

- `/.octon/orchestration/runtime/workflows/meta/evaluate-workflow/`

The evaluation should score:

1. Canonical workflow contract quality
2. Stage asset completeness
3. Guide integrity
4. Drift and validation risk

## Output

An evaluation report that tells the operator whether the canonical workflow and
its workflow README remain aligned.
