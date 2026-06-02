# Structured Receipts And Concise Publication

This is a child architecture proposal packet in the Token-Efficient Proposal Program Controller.

## Purpose

Move evidence to machine-readable receipts, concise closeout projections, compact publication summaries, and on-demand expanded reports.

## Parent Program

Parent: `token-efficient-proposal-program-controller`

## Phase

`phase-3` / group `receipts-output`

## Non-Authority Statement

This child is a non-authoritative proposal input. It does not implement changes or authorize execution. Durable outputs must land in the declared promotion targets outside the proposal workspace.

## Model Route

Default route: small/medium summary; deterministic schema and evidence ref validation

Token ceiling: closeout projection ≤4k; expanded report generated only on demand

Escalation trigger: missing evidence ref, closeout authorization ambiguity, rollback evidence missing, support-proof claim conflict

## Core Changes

- Define structured receipt templates with verdict, blockers, unresolved questions, evidence refs, source digests, validation counts, changed files, rollback refs, gate state, and exclusions.
- Make closeout-change and closeout-worktree consume concise closeout projections by default.
- Publish compact final summaries that reference retained evidence instead of duplicating it.
- Add expanded report generator that reconstructs narrative from retained evidence on demand.

## Validators

- closeout-change lifecycle alignment validation
- closeout worktree wrapper tests
- structured receipt schema validation
- expanded report reconstruction test

## Governance

Machine-readable receipts improve auditability; narrative compaction does not remove evidence.
