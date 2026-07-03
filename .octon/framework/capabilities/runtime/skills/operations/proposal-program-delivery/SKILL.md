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
/proposal-program-delivery target=<proposal-program-path> outcome=cleaned profile=<profile-path> run-id=<id>
```

Accepted operator alias:

```text
/octon-proposal-run-program-delivery target=<proposal-program-path> outcome=cleaned profile=<profile-path> run-id=<id>
```

The alias delegates to `proposal-program-delivery`. It is operator vocabulary
only and does not create an independent lifecycle contract, workflow id, skill
authority, closeout rule, archive rule, cleanup rule, Git mutation rule, branch
cleanup rule, generated publication rule, receipt schema, profile schema, or
terminal proof rule.

## Required Checks

- Require caller-supplied or fresh target-bound workflow evidence for
  `profile_path`/`profile`, `delivery_run_id`/`run-id`, target program path,
  and `target_outcome`/`outcome` before workflow admission.
- Validate the bound profile with `validate-proposal-program-delivery-profile.sh`.
- Require profile or workflow evidence for release state, order policy, PR policy, stash policy, operator grant context when supplied, runner handoff refs when supplied, include-path classification state, and retained preflight refs.
- Enforce `execution_order_policy`: `child-before-parent-delivery` is canonical, and non-canonical requested order requires a retained target-bound `proposal-program-delivery-order-override-receipt-v1`.
- Run the retained delivery-readiness preflight before child lifecycle continuation, parent delivery, Git mutation, publication checks, landing, sync, cleanup, or branch deletion.
- Re-run accepted review, implementation readiness, and proposal subtype validators.
- Run or resume child packet lifecycles through their owning packet workflows.
- Validate target-owned child receipts directly by source receipt ref plus digest; parent summaries, readiness projections, aggregate delivery receipts, delivery evidence indexes, generated outputs, host state, chat, model memory, and tool state are not sufficient.
- Validate implementation conformance, post-implementation drift/churn, generated publication freshness, feature-catalog drift, and governed mechanism integration coverage through owning validators and source receipts.
- Route packet closeout and archive through their owning lifecycles.
- Route Git mutation, branch-no-pr landing, final sync, branch cleanup, and Change closeout through `closeout-change` or `closeout-worktree` with explicit include paths, exclude paths, route hints, target lifecycle outcome, validation floor, rollback posture, profile constraints, source receipt refs, readiness receipt ref, and blocker context.
- Require git mutation preflight before branch-local commit, push, hosted no-PR landing, sync, cleanup, or branch deletion; retain typed blocked evidence such as `git-index-write-denied` or `git-ref-write-denied` instead of retrying blindly.
- When source posture is dirty or stale, require a route-owned clean worktree from current `origin/main` and include-path classification before reconstruction, broad stage-all, staging, or commit.
- When repeated blocker, recovery, or long-run thresholds apply, require validated lifecycle postmortem evidence before learned-from completion claims.
- Route residue deletion only through `repo-hygiene-cleanup` with cleanup authorization.
- Validate terminal current-state proof and worktree hygiene after the final mutation.
- Validate the aggregate receipt with `validate-proposal-program-delivery-receipt.sh`.
- Require the aggregate receipt to record source receipt refs, digests, disclosure tiers, non-authority classifications, excluded evidence classes, stop condition IDs, owning next routes, highest evidence-backed outcome, clean-worktree route, include-path classification status, lifecycle postmortem status when required, and downgrade rationale.
- Generate the compact retained delivery evidence index with `generate-proposal-program-delivery-evidence-index.sh`.
- Validate the compact retained delivery evidence index with `validate-proposal-program-delivery-evidence-index.sh`.

## Outputs

Output paths are defined in `.octon/framework/capabilities/runtime/skills/registry.yml`.
The primary durable outputs are the workflow evidence bundle, the delivery
summary, the aggregate `proposal-program-delivery-receipt-v1` receipt, and the
compact `proposal-program-delivery-evidence-index-v1` retained index.
The aggregate receipt must bind the evidence index by path and validator
posture without embedding the index digest; the evidence index remains the
digest-bound artifact for the source receipt and cited refs.

## Boundaries

- Do not widen accepted promotion targets.
- Do not archive, move, or rename child packets directly from delivery.
- Do not mutate Git, hosted branches, or PR state outside Change closeout.
- Do not proceed with non-canonical delivery order without a valid retained order override receipt.
- Do not treat runner handoff refs or delivery-readiness evidence as child packet, archive, generated-publication, cleanup, Change, branch, final sync, or terminal proof authority.
- Do not treat proposal-local support files, generated prompts, generated
  outputs, dashboards, host/tool/chat state, model memory, parent summaries,
  aggregate delivery receipts, or delivery evidence indexes as substitutes for
  required delivery admission inputs.
- Do not reconstruct, broad stage-all, stage, commit, push, land, sync, cleanup, or delete branches from dirty or stale source posture without route-owned clean worktree selection and include-path classification.
- Do not delete repo hygiene residue or worktree residue without the owning cleanup authorization.
- Do not edit generated/effective outputs by hand.
- Do not treat the delivery evidence index as delivery authorization, archive authorization, landing authorization, cleanup authorization, child validation, child receipt replacement, or child lifecycle outcome evidence.
- Do not treat proposal-local support files, generated prompts, generated outputs, dashboards, host/tool/chat state, or model memory as authority.
- Report `blocked` with the next owning lifecycle when any delivery prerequisite is missing, stale, contradictory, or outside local authority.
