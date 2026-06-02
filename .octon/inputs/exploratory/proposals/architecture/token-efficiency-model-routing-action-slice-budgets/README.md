# Model Routing And Action Slice Budgets

This is a child architecture proposal packet in the Token-Efficient Proposal Program Controller.

## Purpose

Add deterministic-first routing, token ceilings, route decision receipts, escalation triggers, fallback behavior, and short action-slice loops.

## Parent Program

Parent: `token-efficient-proposal-program-controller`

## Phase

`phase-4` / group `routing-loop`

## Non-Authority Statement

This child is a non-authoritative proposal input. It does not implement changes or authorize execution. Durable outputs must land in the declared promotion targets outside the proposal workspace.

## Model Route

Default route: deterministic-first; high-reasoning only on escalation

Token ceiling: slice-specific; final completion ≤8k, child dispatch ≤12k base, architecture exception ≤40k

Escalation trigger: authority ambiguity, architecture decision, rollback conflict, support-proof interpretation, promotion evidence conflict, archive/recovery failure, unexplained test failure

## Core Changes

- Define deterministic/small/medium/high/high-on-escalation routing matrix.
- Emit route-decision receipts and model-routing receipts for each lifecycle slice.
- Bound parent loops into load_program_spine, evaluate_dependency_vector, select_runnable_children, dispatch_child_or_no_dispatch, summarize_terminal_blockers, validate_completion, emit_closeout_capsule.
- Convert publication freshness, generated freshness, blocker aggregation zero-state, dependency vector, manifest completeness, registry projection, raw-log indexing, closeout schema validation, and worktree cleanliness to deterministic preflights.

## Validators

- model-routing receipt emission test
- route bypass negative control
- action-slice budget regression test
- deterministic preflight fixture tests

## Governance

Routing can reduce cost but cannot bypass authorization, gates, receipts, replay, rollback, or support proof.
