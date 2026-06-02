# Semantic Cache And Context Reuse

This is a child architecture proposal packet in the Token-Efficient Proposal Program Controller.

## Purpose

Add source-hash invalidated semantic cache, context-pack layer reuse, generated graph/index reuse, parent-to-child handoff reuse, and lifecycle-level budgets at scale.

## Parent Program

Parent: `token-efficient-proposal-program-controller`

## Phase

`phase-5` / group `mature-scale`

## Non-Authority Statement

This child is a non-authoritative proposal input. It does not implement changes or authorize execution. Durable outputs must land in the declared promotion targets outside the proposal workspace.

## Model Route

Default route: deterministic cache lookup; medium only for summary regeneration; high only on authority conflict

Token ceiling: cache hit context overhead ≤2k; regenerated summaries stage-specific

Escalation trigger: source digest drift, policy digest drift, summary/source contradiction, missing retained model-visible hash

## Core Changes

- Add semantic summaries keyed by source digest, policy digest, route purpose, and trust class.
- Reuse context-pack layers for stable governance, prompt capsules, generated freshness handles, and child handoff capsules.
- Invalidate on source digest drift, policy digest drift, request binding mismatch, expired freshness, missing retained evidence, trust downgrade, explicit governance invalidation.
- Add lifecycle-level token budgets and CI token regression tests for repeated proposal runs.

## Validators

- semantic cache invalidation test
- context-pack layer reuse replay test
- source digest drift negative control
- CI token regression threshold test

## Governance

Cached summaries are never authority and cannot satisfy gates without fresh source/evidence bindings.
