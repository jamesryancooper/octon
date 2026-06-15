---
name: proposal-program-delivery
description: >
  Operations skill for accepted proposal programs that coordinates child packet
  implementation, publication freshness, closeout, archive handoff, Change
  closeout, final sync, and cleanup proof without taking over child authority.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-06-14"
  updated: "2026-06-14"
skill_sets: []
capabilities: []
allowed-tools: Read Glob Grep Write(/.octon/state/evidence/runs/skills/proposal-program-delivery/*) Write(/.octon/state/evidence/validation/analysis/*)
---

# Proposal Program Delivery

Run the canonical proposal program delivery workflow for an accepted proposal
program.

## When to Use

Use this skill after a proposal program has been accepted and implementation
authorized, and the operator requests delivery through durable implementation,
packet closeout, archive handoff, Change closeout, landing, sync, branch
cleanup, terminal proof, and final hygiene.

## Route

Delegate to:

```text
.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/workflow.yml
```

The matching command surface is:

```text
/proposal-program-delivery target=<proposal-program-path> [outcome=cleaned] [profile=<profile-path>] [run-id=<id>]
```

## Required Checks

- Validate any supplied profile with `validate-proposal-program-delivery-profile.sh`.
- Re-run accepted review, implementation readiness, and proposal subtype validators.
- Run or resume child packet lifecycles through their owning packet workflows.
- Validate target-owned child receipts directly; parent summaries are not sufficient.
- Validate implementation conformance, post-implementation drift/churn, generated publication freshness, and governed mechanism integration coverage.
- Route packet closeout and archive through their owning lifecycles.
- Route Git mutation, branch-no-pr landing, final sync, branch cleanup, and Change closeout through `closeout-change` or `closeout-worktree`.
- Route residue deletion only through `repo-hygiene-cleanup` with cleanup authorization.
- Validate terminal current-state proof and worktree hygiene after the final mutation.
- Validate the aggregate receipt with `validate-proposal-program-delivery-receipt.sh`.

## Outputs

Output paths are defined in `.octon/framework/capabilities/runtime/skills/registry.yml`.
The primary durable outputs are the workflow evidence bundle, the delivery
summary, and the aggregate `proposal-program-delivery-receipt-v1` receipt.

## Boundaries

- Do not widen accepted promotion targets.
- Do not archive, move, or rename child packets directly from delivery.
- Do not mutate Git, hosted branches, or PR state outside Change closeout.
- Do not delete repo hygiene residue or worktree residue without the owning cleanup authorization.
- Do not edit generated/effective outputs by hand.
- Do not treat proposal-local support files, generated prompts, generated outputs, dashboards, host/tool/chat state, or model memory as authority.
- Report `blocked` with the next owning lifecycle when any delivery prerequisite is missing, stale, contradictory, or outside local authority.
