# Prompt Pack Handles And Compiled Instruction Capsules

This is a child architecture proposal packet in the Token-Efficient Proposal Program Controller.

## Purpose

Replace full prompt asset expansion by default with digest-bound prompt-pack handles, route capsules, compiled governance capsules, and controlled expansion rules.

## Parent Program

Parent: `token-efficient-proposal-program-controller`

## Phase

`phase-2` / group `prompt-runtime`

## Non-Authority Statement

This child is a non-authoritative proposal input. It does not implement changes or authorize execution. Durable outputs must land in the declared promotion targets outside the proposal workspace.

## Model Route

Default route: high-reasoning only for architecture review; runtime capsule generation deterministic

Token ceiling: route prompt header plus capsules ≤4k before stage context

Escalation trigger: digest drift, mutation-sensitive work, gate dispute, authority conflict, audit request

## Core Changes

- Modify prompt_bundle.rs to support prompt-pack handle mode and retained full prompt packet refs.
- Compile stable prompt/reference/shared-reference assets into capsules with source digests and visible short rules.
- Expand full prompt text only under explicit prompt-expansion-policy-v1 triggers.
- Retain full prompt packet for replay and audit.

## Validators

- prompt-pack capsule generation test
- stale capsule fail-closed test
- mutation-sensitive expansion test
- prompt model-visible hash replay test

## Governance

Full prompt packets remain retained and hash-bound; capsules cannot widen authority.
