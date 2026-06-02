# Lifecycle Executor Context Pack Integration

This is a child architecture proposal packet in the Token-Efficient Proposal Program Controller.

## Purpose

Apply Context Pack Builder inclusion modes to lifecycle, skill, bootstrap, generated, evidence, raw-log, and proposal context.

## Parent Program

Parent: `token-efficient-proposal-program-controller`

## Phase

`phase-2` / group `context-runtime`

## Non-Authority Statement

This child is a non-authoritative proposal input. It does not implement changes or authorize execution. Durable outputs must land in the declared promotion targets outside the proposal workspace.

## Model Route

Default route: deterministic policy enforcement; high-reasoning only on context authority conflict

Token ceiling: stage-specific; default proposal-program child dispatch ≤12k before target file excerpts

Escalation trigger: required source omitted, context hash mismatch, raw/generated source marked authority, budget conflict over required evidence

## Core Changes

- Add proposal-program context policy with stage-specific inclusion modes.
- Make lifecycle executor construct route context through Context Pack Builder before material authorization.
- Record omission reasons and escalation conditions for every omitted source.
- Ensure lifecycle/skill/bootstrap context uses digest-only or handle-only for stable governance and generated state by default.

## Validators

- test-context-pack-builder.sh
- context omission manifest test
- raw/generated authority negative control
- invalid context-pack blocks authorization test

## Governance

Context compaction is legal only when retained, hashed, and subordinate to authorization.
