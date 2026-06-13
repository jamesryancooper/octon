---
name: proposal-packet-terminal-closeout
description: >
  Operations skill for proposal packet terminal readiness checks that emit an
  archive-ready or blocked receipt without archiving the packet.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-06-13"
  updated: "2026-06-13"
skill_sets: []
capabilities: []
allowed-tools: Read Glob Grep Write(/.octon/state/evidence/runs/skills/proposal-packet-terminal-closeout/*) Write(/.octon/state/evidence/validation/analysis/*)
---

# Proposal Packet Terminal Closeout

Run the canonical proposal packet terminal closeout workflow for an implemented
proposal packet.

## When to Use

Use this skill after a packet has completed implementation, implementation
conformance, post-implementation drift/churn review, and closeout evidence, and
before invoking `archive-proposal`.

## Route

Delegate to:

```text
.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-terminal-closeout/workflow.yml
```

The matching command surface is:

```text
/proposal-packet-terminal-closeout target=<proposal-packet-path> [outcome=archive-ready] [profile=<profile-path>] [run-id=<id>]
```

## Required Checks

- Validate any supplied profile with `validate-proposal-packet-terminal-closeout-profile.sh`.
- Verify implementation conformance and post-implementation drift receipts are present and fresh.
- Validate publication freshness through target-owned validators and canonical publisher receipts.
- Classify repo hygiene and worktree hygiene without deleting residue.
- Treat post-integration architecture review and terminal evaluator output as evidence-only.
- Delegate Git, GitHub, branch landing, branch cleanup, and PR-specific work to their canonical routes.
- Validate the final receipt with `validate-proposal-packet-terminal-closeout-receipt.sh`.

## Outputs

Output paths are defined in `.octon/framework/capabilities/runtime/skills/registry.yml`.
The primary durable outputs are the workflow evidence bundle, the terminal
summary, and the packet-local `support/proposal-terminal-closeout.yml` receipt.

## Boundaries

- Do not archive, move, or rename the proposal packet.
- Do not mutate `proposal.yml` status.
- Do not create a PR, stage, commit, push, land, or clean up branches.
- Do not delete repo hygiene residue or worktree residue.
- Do not edit generated/effective outputs by hand.
- Do not treat proposal-local support files, generated outputs, host/tool/chat
  state, or raw extension inputs as authority.
- Report `blocked` with the next canonical route when any archive-ready
  prerequisite is missing, stale, contradictory, or outside local authority.
