---
name: evaluate-workflows
title: "Evaluate Workflows"
description: "Score each workflow against the shared evaluator and collect findings."
---

# Step 3: Evaluate Workflows

## Purpose

Apply one shared scoring model across directory and single-file workflows.

## Actions

1. Run the shared scorer against every manifest workflow.
2. Use `WORKFLOW.md` as the directory entrypoint and support single-file workflow `.md` artifacts directly.
3. Capture per-workflow scores, grade, issues, and machine-readable evidence.
4. Preserve human-facing compatibility by keeping score output renderable as a readable workflow report.

## Output

- Per-workflow score records
- Workflow-local issues ready for normalization into findings

## Proceed When

- [ ] Every manifest workflow has a score record
- [ ] Directory and single-file workflows are both covered

## Idempotency

The same workflow tree and contract must produce the same workflow scores and issue set.
