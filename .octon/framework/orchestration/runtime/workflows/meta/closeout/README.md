---
title: Branch Closeout Workflow
description: Canonical branch/PR closeout workflow entry point for Octon's worktree-native Git and GitHub operating model.
---

# Branch Closeout Workflow

This workflow family owns branch and PR closeout semantics for Octon.

Ingress does not define closeout trigger logic, merge-lane selection, or
compatibility fallback prompts inline. It points here.

Canonical policy and execution surfaces:

- `/.octon/framework/orchestration/runtime/workflows/meta/closeout/workflow.yml`
- `/.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`
- `/.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/SKILL.md`

This workflow covers:

- contextual closeout triggering at a credible completion point
- worktree and PR state detection
- autonomous versus manual merge-lane routing
- status-only responses for already-ready PRs
- compatibility fallback handling for legacy adapters

This workflow does not own build-to-delete or release-claim closeout. Those
governance closure surfaces live under
`/.octon/instance/governance/contracts/closeout-reviews.yml`.
