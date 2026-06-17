---
name: proposal-packet-delivery
description: >
  Operations skill for accepted proposal packets that coordinates durable
  implementation, promotion, packet closeout, terminal closeout, archive
  handoff, Change closeout, final sync, branch cleanup, terminal proof, and
  cleanup proof without taking over target-owned lifecycle authority.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-06-16"
  updated: "2026-06-16"
skill_sets: []
capabilities: []
allowed-tools: Read Glob Grep Write(/.octon/state/evidence/runs/skills/proposal-packet-delivery/*) Write(/.octon/state/evidence/validation/analysis/*)
---

# Proposal Packet Delivery

Run the canonical proposal packet delivery workflow for an accepted proposal
packet.

## When to Use

Use this skill after a proposal packet has been accepted and implementation
authorized, and the operator requests delivery through durable implementation,
promotion, packet closeout, terminal closeout, archive handoff, Change closeout,
landing, sync, branch cleanup, terminal proof, and final hygiene.

## Route

Delegate to:

```text
.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/workflow.yml
```

The matching command surface is:

```text
/proposal-packet-delivery target=<proposal-packet-path> outcome=cleaned route=branch-no-pr [profile=<profile-path>] [run-id=<id>]
```

## Required Checks

- Validate any supplied profile with `validate-proposal-packet-delivery-profile.sh`.
- Re-run accepted review, strict architecture review, implementation readiness,
  and proposal subtype validators.
- Bind `route=branch-no-pr` for cleaned delivery and refuse PR fallback when
  the selected profile forbids PR creation.
- Run or resume implementation through `run-packet-implementation`.
- Validate implementation conformance, post-implementation drift/churn,
  generated publication freshness, and governed mechanism integration coverage
  when applicable.
- Route implemented status through `promote-proposal`.
- Route packet closeout through `closeout-packet`.
- Route terminal closeout through `proposal-packet-terminal-closeout`.
- Route archive relocation through `archive-proposal`.
- Route Git mutation, branch-no-pr landing, final sync, branch cleanup, and
  Change closeout through `closeout-change` or `closeout-worktree`.
- Route residue deletion only through `repo-hygiene-cleanup` with cleanup
  authorization.
- Validate terminal current-state proof and worktree hygiene after the final
  mutation.
- Validate the aggregate receipt with `validate-proposal-packet-delivery-receipt.sh`.

## Outputs

Output paths are defined in `.octon/framework/capabilities/runtime/skills/registry.yml`.
The primary durable outputs are the workflow evidence bundle, the delivery
summary, and the aggregate `proposal-packet-delivery-receipt-v1` receipt.

## Boundaries

- Do not widen accepted promotion targets.
- Do not archive, move, or rename the packet directly from delivery.
- Do not mutate Git, hosted branches, or PR state outside Change closeout.
- Do not delete repo hygiene residue or worktree residue without the owning
  cleanup authorization.
- Do not edit generated/effective outputs by hand.
- Do not treat proposal-local support files, generated prompts, generated
  outputs, dashboards, host/tool/chat state, or model memory as authority.
- Report `blocked` with the next owning lifecycle when any delivery prerequisite
  is missing, stale, contradictory, denied, or outside local authority.
